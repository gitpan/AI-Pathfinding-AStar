use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'AI::Pathfinding::AStar',
    'VERSION_FROM' => 'AStar.pm', # finds $VERSION
    'PREREQ_PM'         => {Heap::Simple => 0.05}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
		(ABSTRACT_FROM => 'AStar.pm', # retrieve abstract from module
		AUTHOR     => 'Aaron Dalton <acdalton@cpan.org>') : ()),
);
