require 'metaheuristics/metaheuristic_interface'
require 'metaheuristics/search_results'

class AlpsGa < MetaheuristicInterface

	# From Hornby 2006 ALPS
	DEFAULTS = {
		:layer_size                  => 100,
		:max_layer_count             => 10,
		:tournament_size             => 7,
		:age_gap                     => 10,
		:aging_scheme                => :polynomial,
		:layer_elitism               => 3,
		:overall_elitism             => 0,
		:parents_from_previous_layer => true
	}

	attr_reader :results

	class Individual
		include Comparable

		attr_reader :age, :solution, :fitness

		# ctor
		def initialize(solution, age = 0)
			@solution = solution
			@age      = age
			@used     = false
			@fitness  = nil
		end

		# tag as used 
		def tag_as_used
			@used = true
		end

		# age
		def age!
			if @used
				@used = false
				@age += 1
			end
		end

		# evaluate, return fitness
		def evaluate(evaluator)
			@fitness = evaluator.call(solution)
		end

		# <=>
		def <=>(individual)
			self.fitness <=> individual.fitness
		end
	end # Individual

	# ctor
	def initialize(options)
		@layer_size                  = options[:layer_size                 ] || DEFAULTS[:layer_size                 ]
		@max_layer_count             = options[:max_layer_count            ] || DEFAULTS[:max_layer_count            ]
		@tournament_size             = options[:tournament_size            ] || DEFAULTS[:tournament_size            ]
		@age_gap                     = options[:age_gap                    ] || DEFAULTS[:age_gap                    ]
		@aging_scheme                = options[:aging_scheme               ] || DEFAULTS[:aging_scheme               ]
		@layer_elitism               = options[:layer_elitism              ] || DEFAULTS[:layer_elitism              ]
		@overall_elitism             = options[:overall_elitism            ] || DEFAULTS[:overall_elitism            ]
		@parents_from_previous_layer = options[:parents_from_previous_layer] || DEFAULTS[:parents_from_previous_layer]

		@evaluator       = options[:evaluator      ] || (raise ArgumentError)
		@mutation_rate   = options[:mutation_rate  ] || (raise ArgumentError)
		@genome_init     = options[:genome_init    ] || (raise ArgumentError)

		raise ArgumentError unless [:linear, :fibonacci, :polynomial, :exponential].include?(@aging_scheme)

		@results = SearchResults.new
		@layers  = []
	end

	# run once
	def run_once
		generation = @results.generation
		if generation == 0
			@layers[0] = Array.new(@layer_size){ Individual.new(@genome_init.call) }
			evaluate_layer(0)
		else
			# all but bottom layer
			(@layers.size - 1).downto(1) do |i|
				generate_new_population_layer(i)
				evaluate_layer(i)
			end

			# bottom layer
			if generation % @age_gap == 0
				move_to_layer(@layers[0], 1)
				@layers[0] = Array.new(@layer_size){ Individual.new(@genome_init.call) }
			else
				generate_new_population_layer(0)
			end
			evaluate_layer(0)
		end

		# age population
		@layers.each do |l|
			l.each do |individual|
				individual.age!
			end
		end

		# promote individuals
		promote_individuals

		@results.increment_generation

		@layers.each.with_index do |l, idx|
			l.sort!.reverse!
			$stderr << "= layer #{idx} : max age #{max_layer_age(idx)} ---------------------------------------------------------------\n"
			l.each do |i|
				$stderr << " - #{i.solution.__id__.to_s.rjust(7)}, fitness #{i.fitness.to_i.to_s.rjust(6)}, age #{i.age.to_s.rjust(4)}\n"
			end
		end
		$stderr << "\n"
	end

private

	# max age for layer +n+
	def max_layer_age(n)
		case(@aging_scheme)
		when :linear     ; n + 1
		when :fibonacci  ; fibonacci(n + 1)
		when :polynomial ; n < 2 ? n + 1 : n ** 2
		when :exponential; 2 ** n
		else raise ArgumentError
		end * @age_gap
	end

	# fibonacci
	def fibonacci(n)
		if n == 0 || n == 1
			1
		else
			fibonacci(n - 1) + fibonacci(n - 2)
		end
	end

	# evaluate layer
	def evaluate_layer(n)
		@layers[n].each do |individual|
			fitness = individual.evaluate(@evaluator)
			@results.add_solution(individual.solution, fitness)
		end
	end

	# generate new population layer
	def generate_new_population_layer(n)
		current_layer = @layers[n]

		parent_population = ((n == 0 || !@parents_from_previous_layer) ? current_layer : (@layers[n - 1] + current_layer)).sort

		new_population = []

		# elitism
		elitism = @layer_elitism
		elitism = @overall_elitism if n == (@layers.size - 1) && @overall_elitism > elitism

		if elitism > 0
			current_layer.sort.reverse[0, [elitism, current_layer.size].min].each do |i|
				new_population << i
			end
		end

		(@layer_size - new_population.size).times do
			parent1_index = Array.new(@tournament_size){ rand(parent_population.size) }.max
			parent2_index = Array.new(@tournament_size){ rand(parent_population.size) }.reject{ |v| v == parent1_index }.max
			while parent2_index == nil || parent2_index == parent1_index
				parent2_index = rand(parent_population.size)
			end

			parent1 = parent_population[parent1_index]
			parent2 = parent_population[parent2_index]
			
			parent1.tag_as_used
			parent2.tag_as_used
			new_solution = parent1.solution.crossover(parent2.solution).mutate!(@mutation_rate)
			new_population << Individual.new(new_solution, [parent1.age, parent2.age].max + 1)
		end

		@layers[n] = new_population
	end

	# promote individuals
	def promote_individuals
		layer_count = @layers.size

		((layer_count == @max_layer_count) ? (layer_count - 2) : (layer_count -  1)).downto(0) do |n|
			layer = @layers[n]
			# take old ones from current layer
			max_age = max_layer_age(n)
			oldies = layer.select{ |i| i.age >= max_age }
			if !oldies.empty?
				layer.delete_if{     |i| i.age >= max_age }
				move_to_layer(oldies, n + 1) # try to fit them in with the layer above
			end
		end
	end

	# try to fit individual within layer
	def move_to_layer(individuals, n)
		# add layer
		if n > (@layers.size - 1)
			raise RuntimeError unless n <  @max_layer_count
			raise RuntimeError unless n == @layers.size
			@layers[n] = []
		end

		# add oldies in layer
		a = (@layers[n] + individuals).sort do |a, b|
			cmp_fitness = a.fitness <=> b.fitness
			if cmp_fitness == 0
				a.age <=> b.age
			else
				cmp_fitness
			end
		end.reverse

		@layers[n] = a[0, [a.size, @layer_size].min]
	end
end # AlpsGa

