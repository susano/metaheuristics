
# The interface to be implemented by metaheuristics algorithms.
class MetaheuristicInterface

	# Should return a +SearchResult+ object (or an object with the same interface
	# as +SearchResult+)
	def results ; raise NotImplementedError; end
	
	# Run one search iteration, this should include the evaluation of the fitness
	# of one or more individuals (e.g. a population generation for a GA)
	def run_once; raise NotImplementedError; end
end # MetaheuristicInterface

