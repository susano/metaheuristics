require 'metaheuristics/genome_interface'

# A generic genome class.
# random genomes for a given structure definition can be generated
# via calls to the class method +new_random+. The structure definition
# is an array of gene definitions; a gene definition is a hash like the followings:
#
# * { :type => :boolean }
# * { :type => :int    , :range => 0..10        }
# * { :type => :real   , :range => -3.42..176.8 }
#
class GenomeGeneric < GenomeInterface

	attr_reader :definition, :values

	# new random genome from definition
	def self.new_random(definition)
		values = definition.collect do |h|
			type = h[:type]
			case(type)
			# boolean
			when :boolean
				rand(2) == 0

			# int
			when :int
				range = h[:range] || (raise ArgumentError)
				rand(range.last - range.first + 1) + range.first

			# real
			when :real
				range = h[:range] || (raise ArgumentError)
				rand * (range.last - range.first) + range.first

			# sample
			when :sample
				range = h[:range] || (raise ArgumentError)
				size  = h[:size ] || (raise ArgumentError)
				range.to_a.sample(size)

			else raise ArgumentError, "Unknown gene type '#{type}'" end
		end

		self.new(
			definition,
			values)
	end

	# ctor
	def initialize(definition, values)
		definition.freeze
		@definition = definition
		@values     = values
	end

	# clone
	def clone
		GenomeGeneric.new(
			@definition,
			@values.clone)
	end


	# mutate this
	def mutate!(mutation_rate)
		@definition.size.times do |i|
			if rand < mutation_rate
				h = @definition[i]
				case(h[:type])
				when :boolean # boolean
					@values[i] = !@values[i]

				when :int     # int
					range = h[:range]
					@values[i] = rand(range.last - range.first + 1) + range.first

				when :real    # real
					range = h[:range]
					@values[i] = rand * (range.last - range.first) + range.first

				when :sample # sample
					range = h[:range]
					size  = h[:size ]
					assert{ @values[i].size == size }
					a = range.to_a
					index = rand(size)
					current = @values[i]
					new_int = a.sample(1) while current.include?(new_int)
					current[index] = new_int

				else raise RuntimeError end
			end
		end

		self
	end


	# crossover (uniformly applied)
	def crossover(genome)
		self_values  = @values
		other_values = genome.values
		values =
			Array.new(self_values.size) do |i|
				h = @definition[i]
				case(h[:type])
				when :boolean, :int, :real
					[self_values, other_values][rand(2)][i]

				when :sample # sample
					range = h[:range]
					size  = h[:size ]
					(self_values[i] + other_values[i]).sort.uniq.sample(size)
 		 
				else raise RuntimeError end
			end

		GenomeGeneric.new(
			@definition,
			@values)
	end

	# to string
	def to_s
		Array.new(@definition.size) do |i|
			h = @definition[i]
			v = @values[i]
			case(h[:type])
			when :boolean # boolean
				v ? 'X' : '_'

			when :int     # int
				range = h[:range]
				count = (range.last - range.first) / 10
				" #{v.to_s.rjust(count + 1)} "

			when :real    # real
				range = h[:range]
				" #{'%.2f' % v} "

			when :sample  # sample
				"[#{v.collect{ |r| r.to_s.rjust(2) }.join(', ') }]"

			else raise RuntimeError end
		end.join
	end
end # GenomeGeneric

