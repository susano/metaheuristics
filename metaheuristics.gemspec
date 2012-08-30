Gem::Specification.new do |s|
  s.name        = 'metaheuristics'
  s.version     = '0.1.0'
  s.date        = '2012-08-29'
  s.summary     = 'Metaheuristic search/optimisation algorithms.'
  s.description = 'Metaheuristics include Genetic Algorithms (GAs), such as ALPS and tournament selection.'
  s.authors     = ['Jean Krohn']
  s.email       = 'jbk@susano.org'
  s.files       = [
		'README.md',
		'lib/metaheuristics/individual_solution.rb',
		'lib/metaheuristics/search_results.rb',
		'lib/metaheuristics/metaheuristic_interface.rb',
		'lib/metaheuristics/metaheuristic_init_factory.rb',
		'lib/metaheuristics/genome_search/alps_ga.rb',
		'lib/metaheuristics/genome_search/fgrn_ga.rb',
		'lib/metaheuristics/genome_search/tournament_selection.rb',
		'examples/example_minimiser.rb']
  s.homepage    = 'http://github.com/susano/metaheuristics'
end

