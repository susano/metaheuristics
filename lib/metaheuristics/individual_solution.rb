
class IndividualSolution
	include Comparable

	attr_reader \
		:age,
		:solution,
		:fitness

	# ctor
	def initialize(solution, evaluator, results)
		@solution  = solution
		@evaluator = evaluator
		@results   = results
		@age       = 0
		evaluate
	end

	# increment age
	def increment_age
		@age += 1
	end

	# re-evaluate fitness
	def reevaluate
		raise RuntimeError if @fitness.nil?
		evaluate
	end

	# <=>
	def <=>(es)
		@fitness <=> es.fitness
	end

private
	# evaluate
	def evaluate
		@fitness = @evaluator.call(@solution)
		@results.add_solution(@solution, @fitness)
	end
end # IndividualSolution

