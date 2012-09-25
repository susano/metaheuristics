require 'metaheuristic_interface'
require 'metaheuristics/individual_solution'

class FgrnGa < MetaheuristicInterface

	DEFAULTS = {
		:age_max             => 10,
		:children_count      => 80,
		:parents_coeff       => 0.4,
		:population_size     => 100,
		:random_parent_coeff => 0.01
	}

	attr_reader :results, :population

	# ctor
	def initialize(options)
		@children_count         = options[:children_count        ] || DEFAULTS[:children_count     ]
		@parents_coeff          = options[:parents_coeff         ] || DEFAULTS[:parents_coeff      ]
		@population_size        = options[:population_size       ] || DEFAULTS[:population_size    ]
		@random_parent_coeff    = options[:random_parent_coeff   ] || DEFAULTS[:random_parent_coeff]
		@age_max                = options[:age_max               ] || DEFAULTS[:age_max            ]
		@evaluate_children_only = options[:evaluate_children_only] || false
		@evaluator              = options[:evaluator             ] || (raise ArgumentError)
		@mutation_rate          = options[:mutation_rate         ] || (raise ArgumentError)

		genome_init = options[:genome_init] || (raise ArgumentError)
		@initial_genomes = Array.new(@population_size){ genome_init.call }

		@results = SearchResults.new
	end

	# run once
	def run_once
		if @initial_genomes
			@population = @initial_genomes.collect{ |genome| IndividualSolution.new(genome, @evaluator, @results) }
			@initial_genomes = nil
		else
			# generate children
			children =
				Array.new(@children_count) do
					parent1 = pick_parent
					parent2 = pick_parent

					genome = (parent1.crossover(parent2)).mutate!(@mutation_rate)
					IndividualSolution.new(genome, @evaluator, @results)
				end

			@population.each{    |individual| individual.increment_age   } # increment age
			@population.reject!{ |individual| individual.age >= @age_max } # reject too old

			# carry over the best
			carried_over_count = @population_size - @children_count
			carried_over = @population[0, [carried_over_count, @population.size].min]

			# re-evaluate carried over
			if !@evaluate_children_only
				carried_over.each do |individual|
					individual.reevaluate
				end
			end

			# merge carried over and children
			@population = carried_over + children
		end

		@population.sort!.reverse!
		@results.increment_generation

		# debug: print population
		@population.each do |i|
			$stderr << "#{('%d' % i.fitness).rjust(5)} - #{i.__id__.to_s.rjust(10)} - age #{'X' * i.age}\n"
		end
	end # run_once

private
	# pick parent
	def pick_parent
		index = 
			rand < @random_parent_coeff ?
				rand(@population.size) :                                                # pick a parent at random
				rand([(@parents_coeff * @population_size).round, @population.size].min) # pick a parent amongst the best individuals
		@population[index].solution
	end
end # FgrnGa

