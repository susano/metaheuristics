

class SearchResults

	attr_reader \
		:generation,
		:evaluation,
		:best        # hash containing the keys : fitness, solution, evaluation, generation

	# ctor
	def initialize
		@generation = 0
		@evaluation = 0
		@best       = nil
	end

	# increment generation
	def increment_generation
		@generation += 1
	end

	# add solution
	def add_solution(solution, fitness)
		@evaluation += 1
		if @best.nil? || fitness > @best[:fitness]
			@best = {
				:fitness    => fitness,
				:solution   => solution,
				:evaluation => @evaluation,
				:generation => @generation
			}
		end
	end

	# to hash
	def to_hash
		{
			:generation => @generation,
			:evaluation => @evaluation,
			:best       => @best.clone
		}
	end
end # SearchResults

