
Metaheuristics
==============

A ruby library of metaheuristics for search/optimisation.


Usage
-----

For a given problem, the following must be implemented:
 * a genome class (details below)
 * a lambda taking no argument and producing a different randomly generated
   genome each time it is called
 * an evaluator lambda taking as argument a `genome` object, and returning a
   fitness object which much implement the `Comparable` interface (usually
   float is used)


The genome class must implements the following methods:
 * `clone()` return a deep copy of the genome
 * `mutate!(mutation_rate)` mutates each gene of the genome with probability `mutation_rate`, return `self`
 * `crossover(genome)` return a new genome which is a combination of this genome and the `genome` parameter


    require 'metaheuristics/metaheuristic_init_factory'

    search_definition = {
      :name            => :tournament_selection,
      :mutation_rate   => 0.1               # depends on the number of genes in a genome
    }
    
    search_init = MetaheuristicInitFactory.from_definition(search_definition)
    
    search = search_init.call(
      :genome_init => genome_init,          # the lambda generating random genomes
      :evaluator   => evaluator_minimiser)  # the evaluator lambda

     # run the search until the fitness is over 9000!
     begin 
       search.run_once
     end while search.results.best[:fitness] <= 9000
    

A rule of thumb for the mutation rate is to aim for one mutation per genome, the
mutation rate should then be the inverse of the number of genes in a genome.

The file `examples/example_minimiser.rb` demonstrates usage for a simple minimisation problem.


Implementing new algorithms
---------------------------

New algorithms should implement the `MetaheuristicInterface`, and be given an
entry in `MetaheuristicInitFactory::from_definition()`. Then if you are happy
with the licensing, please send me a pull request!


Algorithms Details
------------------

At the moment `metaheuristics` contains only Genetic Algorithms (GAs), but has
vocation to not only contain genome based methods, but also eventually
array-of-values based methods.

 * The traditional tournament selection.
 * An implementation of the ALPS paradigm using tournament selection in the layers.
 * FgrnGa, a GA in which fittest individual are kept in the population across several generations.
 
If you don't know which one to use, ALPS is recommended.

For more on metaheuristics, check out [Sean Luke's great
book][http://cs.gmu.edu/~sean/book/metaheuristics/], available for download for
free, or in printed paper form for money.



### Tournament selection

A simple, basic GA, where each parent is selected by taking a random sample
of the population, and choosing the fittest individual in that sample.


### Age-Layered Population Structure (ALPS)

An implementation of the ALPS paradigm which aims to prevent premature
convergence, combined here with tournament selection in the layers.
[Greg Hornby's ALPS paper][http://idesign.ucsc.edu/papers/hornby_gecco06.pdf]


### FgrnGa

An implementation of a GA keeping fit parents across multiple generations.
It has notably been used to evolve FGRN genomes, which explains the naming.
A description is available in Peter Bentley's thesis.


License
-------

This software is provided under an open source MIT-like license:

Copyright (c) 2012 Jean-Baptiste Krohn <http://susano.org>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

