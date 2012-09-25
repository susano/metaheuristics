Gem::Specification.new do |s|
  s.name        = 'metaheuristics'
  s.version     = '0.2.0'
  s.date        = '2012-09-25'
  s.summary     = 'Metaheuristic search/optimisation algorithms.'
  s.description = 'Metaheuristics include Genetic Algorithms (GAs), such as ALPS and tournament selection.'
  s.authors     = ['Jean Krohn']
  s.email       = 'jbk@susano.org'
  s.files       = [
		'README.md',
		'lib/metaheuristic_interface.rb',
		'lib/metaheuristic_init_factory.rb',
		'lib/metaheuristics/genome_generic.rb',
		'lib/metaheuristics/genome_interface.rb',
		'lib/metaheuristics/individual_solution.rb',
		'lib/metaheuristics/search_results.rb',
		'lib/metaheuristics/genome_search/alps_ga.rb',
		'lib/metaheuristics/genome_search/fgrn_ga.rb',
		'lib/metaheuristics/genome_search/tournament_selection.rb',
		'examples/example_minimiser.rb']
  s.homepage    = 'http://github.com/susano/metaheuristics'
end

