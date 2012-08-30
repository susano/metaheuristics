require 'metaheuristics/metaheuristic_init_factory'

class GenomeValues

	attr_reader :values

	# randomly generate a new random genome with +size+ components in the real range [-1.0, 1.0]
	def self.new_random(size)
		self.new(Array.new(size){ (rand - 0.5) * 2.0 })
	end

	# ctor
	def initialize(values)
		@values = values
	end

	# clone
	def clone
		self.new(values.clone)
	end

	# mutate this genome, return self
	def mutate!(mutation_rate)
		@values.size.times do |i|
			@values[i] += (rand - 0.5) * 0.05 if rand < mutation_rate
		end

		self
	end

	# crossover this genome with another one, and return the resulting offspring
	def crossover(genome)
		self_values = @values
		other_values = genome.values

		values =
			Array.new(self_values.size) do |i|
				[self_values, other_values][rand(2)][i]
			end

		GenomeValues.new(values)
	end
end # GenomeValues


# lambda: generate a genome with 8 values randomly generated in the real range [-1.0, 1.0]
genome_init = lambda do
	GenomeValues.new_random(8)
end

search_definition = {
	:name            => :tournament_selection,
	:population_size => 100,
	:tournament_size => 10,
	:elitism         => 5,
	:mutation_rate   => 0.2
}

search_init = MetaheuristicInitFactory.from_definition(search_definition)

# an evaluator which returns a higher fitness for components with lower
# distance to the origin point (i.e minimises the absolute value of the
# components).
evaluator_minimiser = lambda do |genome|
	sum_of_squares = genome.values.collect{ |v| v * v }.inject(&:+)
	fitness = 1.0 / (1.0 + sum_of_squares)

	fitness
end

search = search_init.call(
	:genome_init => genome_init,
	:evaluator   => evaluator_minimiser)

highest_fitness = 0.0

while highest_fitness < 0.99999999995
	search.run_once

	results    = search.results
	best_hash  = results.best
	generation = results.generation

	highest_fitness = best_hash[:fitness]
	fitness_string = ('%.10f' % highest_fitness).rjust(10)
	generation_string = generation.to_s.rjust(5)
	values_string = best_hash[:solution].values.collect{ |v| ('%.6f' % v).rjust(9) }.join(', ')
	puts "  generation #{generation_string}   fitness: #{fitness_string}   values: #{values_string}"
end

