require 'metaheuristics/genome_search/alps_ga'
require 'metaheuristics/genome_search/fgrn_ga'
require 'metaheuristics/genome_search/tournament_selection'

class MetaheuristicInitFactory

	# from definition
	def self.from_definition(definition)
		name = definition[:name]
		case(name)

		# alps
		when :alps
			args = {
				:layer_size      => definition[:layer_size     ],
				:max_layer_count => definition[:max_layer_count],
				:tournament_size => definition[:tournament_size],
				:age_gap         => definition[:age_gap        ],
				:aging_scheme    => definition[:aging_scheme   ],
				:layer_elitism   => definition[:layer_elitism  ],
				:overall_elitism => definition[:overall_elitism],
				:mutation_rate   => definition[:mutation_rate  ] || (raise ArgumentError)
			}

			# init block
			lambda do |options|
				genome_init = options[:genome_init] || (raise ArgumentError)
				evaluator   = options[:evaluator]   || (raise ArgumentError)

				AlpsGa.new(args.merge(
					:genome_init => genome_init,
					:evaluator   => evaluator))
			end

		# fga
		when :fga
			args = {
				:population_size        => definition[:population_size       ] || (raise ArgumentError),
				:children_count         => definition[:children_count        ] || (raise ArgumentError),
				:mutation_rate          => definition[:mutation_rate         ] || (raise ArgumentError),
				:parents_coeff          => definition[:parents_coeff         ] || (raise ArgumentError),
				:random_parent_coeff    => definition[:random_parent_coeff   ] || (raise ArgumentError),
				:age_max                => definition[:age_max               ] || (raise ArgumentError),
				:evaluate_children_only => definition[:evaluate_children_only] || false
			}

			# init block
			lambda do |options|
				genome_init = options[:genome_init] || (raise ArgumentError)
				evaluator   = options[:evaluator]   || (raise ArgumentError)

				FgrnGa.new(args.merge(
					:genome_init => genome_init,
					:evaluator   => evaluator))
			end

		# tournament selection
		when :tournament_selection
			args = {
				:mutation_rate   => definition[:mutation_rate  ] || (raise ArgumentError),
				:population_size => definition[:population_size],
				:elitism         => definition[:elitism        ],
				:tournament_size => definition[:tournament_size]
			}

			# init block
			lambda do |options|
				genome_init = options[:genome_init] || (raise ArgumentError)
				evaluator   = options[:evaluator]   || (raise ArgumentError)

				TournamentSelection.new(args.merge(
					:genome_init => genome_init,
					:evaluator   => evaluator))
			end

		else raise ArgumentError, name end
	end # from_definition
end # MetaheuristicInitFactory

