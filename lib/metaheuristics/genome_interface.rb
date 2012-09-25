
class GenomeInterface
	def clone                 ; raise NotImplementeError; end
	def mutate!(mutation_rate); raise NotImplementeError; end
	def crossover(genome)     ; raise NotImplementeError; end
end # GenomeInterface

