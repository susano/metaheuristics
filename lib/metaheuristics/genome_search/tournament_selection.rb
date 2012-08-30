require 'metaheuristics/metaheuristic_interface'
require 'metaheuristics/individual_solution'
require 'metaheuristics/search_results'

class TournamentSelection < MetaheuristicInterface

	DEFAULTS = {
		:population_size => 100,
		:tournament_size => 4,
		:elitism         => 0
	}

	attr_reader :results

	# ctor
	def initialize(options)
		@population_size = options[:population_size] || DEFAULTS[:population_size]
		@tournament_size = options[:tournament_size] || DEFAULTS[:tournament_size]
		@elitism         = options[:elitism        ] || DEFAULTS[:elitism        ]
		@evaluator       = options[:evaluator      ] || (raise ArgumentError)
		@mutation_rate   = options[:mutation_rate  ] || (raise ArgumentError)

		# population
		genome_init = options[:genome_init] || (raise ArgumentError)
		@initial_genomes = Array.new(@population_size){ genome_init.call }
		@population = nil

		# results
		@results = SearchResults.new
	end

	# run once
	def run_once

		# genomes
		genomes =
			if @initial_genomes # use initial genomes
				ig = @initial_genomes
				@initial_genomes = nil
				ig
			else # not initial run: generate new genomes
				array = Array.new(@population_size)

				# elitism
				@elitism.times do |i|
					array[i] = @population[i].solution
				end

				# generate children
				(@population_size - @elitism).times do |i|
					parent1 = pick_parent
					parent2 = pick_parent

					array[@elitism + i] = parent1.crossover(parent2).mutate!(@mutation_rate)
				end

				array
			end

		# evaluate genomes into the population
		@population = genomes.collect do |genome|
 		 	IndividualSolution.new(genome, @evaluator, @results)
		end

		@population.sort!.reverse!
		@results.increment_generation

		self
	end # run_once

private
	# pick parent
	def pick_parent
		@population.sample(@tournament_size).max.solution
	end
end # TournamentSelection

