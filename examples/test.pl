#!/usr/bin/perl -w

use strict;
use warnings;

use ExampleMap;
my $map = ExampleMap::new();
use AI::Pathfinding::AStar qw(&findPath);

my $path = &findPath($map, '2.3', '6.3' );
print join(', ', @$path), "\n";

