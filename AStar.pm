package AI::Pathfinding::AStar;

use 5.006;
use strict;
use warnings;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;

@ISA = qw(Exporter AutoLoader);
@EXPORT = qw();
@EXPORT_OK = qw(&findPath);

$VERSION = '0.01';

use Heap::Simple;
my $open = Heap::Simple->new(order => "<", elements => [Any => \&calcF], user_data => "Open List");
my $nodes = {};

sub findPath
{
	my ($map, $start, $target) = @_;

	my $path = [];
	my $curr_node = undef;

	#add starting square to the open list
	$nodes->{$start}->{parent} = undef;
	$nodes->{$start}->{cost} = 0;
	$nodes->{$start}->{h} = 0;
	$nodes->{$start}->{inopen} = 1;
	$open->insert($start);
	$curr_node = $start;

BIGLOOP:
	while ( ($open->count) > 0 )
	{
		#choose the one with the lowest F score, remove it from the OPEN and add to the CLOSED list
		my $nxt_node = $open->extract_min;
		$curr_node = $nxt_node;
		$nodes->{$curr_node}->{inopen} = 0;

		#get surrounding squares
		my $surr_nodes = $map->astar_surrounding($curr_node, $target);
		foreach my $node (@$surr_nodes)
		{
			my ($surr_id, $surr_cost, $surr_h) = @$node;
			
			#skip the node if it's in the CLOSED list
			next if ( (exists $nodes->{$surr_id}) && (! $nodes->{$surr_id}->{inopen}) );

			#add it if it's not already in the OPEN
			if (! exists $nodes->{$surr_id})
			{
				$nodes->{$surr_id}->{parent} = $curr_node;
				$nodes->{$surr_id}->{cost} = $surr_cost;
				$nodes->{$surr_id}->{h} = $surr_h;
				$nodes->{$surr_id}->{inopen} = 1;
				$open->insert($surr_id);

				#exit the loop if we've reached our target
				last BIGLOOP if (exists $nodes->{$target});
			}

			#otherwise it's already in the OPEN list
			#check to see if it's cheaper to go through the current square compared to the previous path
			my $currG = &calcG($surr_id);
			my $possG = &calcG($curr_node) + $surr_cost;
			if ($possG < $currG)
			{
				#change the parent
				$nodes->{$surr_id}->{parent} = $curr_node;
				#re-sort the OPEN list
				$open->clear;
				foreach my $node (keys %$nodes)
				{
					if ($nodes->{$node}->{inopen})
						{$open->insert($node);}
				}
			}
		}
	}	#end pathfinding while

	#if the loop exited because the target was found, fillup the $path array
	if (exists $nodes->{$target})
	{
		unshift @$path, $target;
		my $curr_node = $nodes->{$target}->{parent};
		while (defined $curr_node)
		{
			unshift @$path, $curr_node;
			$curr_node = $nodes->{$curr_node}->{parent};
		}
	}

	#if the target was unreacheable, return an empty array ref
	return $path;
}

#F = G + H
sub calcF
{
	my $node = shift;
	my $f = $nodes->{$node}->{h};
	$f += &calcG($node);

	return $f;
}

sub calcG
{
	my $node = shift;
	my $g = $nodes->{$node}->{cost};
	$node = $nodes->{$node}->{parent};
	while (defined $node)
	{
		$g += $nodes->{$node}->{cost};
		$node = $nodes->{$node}->{parent};
	}

	return $g;
}

1;
__END__

=head1 NAME

AI::Pathfinding::AStar - Perl implementation of the A* pathfinding algorithm

=head1 SYNOPSIS

  use AI::Pathfinding::AStar qw(findPath)
  my $path = &findPath($map_obj, $start, $target);

  print join(', ', @$path), "\n";

=head1 DESCRIPTION

This module implements the A* pathfinding algorithm.  It attempts to be as generally useful as possible by leaving the determination of legal moves and heuristic calculations to an external map object.

This object can export a single function, C<&findPath>, and requires the following parameters:

=over

=item Map Object

AI::Pathfinding::AStar assumes that the user has created a Perl object representing the given playing field.  A reference to this object must be passed.  This object must implement a method by the name C<&astar_surrounding> which accepts an identifier for a node on your map as well as an identifier for the target node.  This method must return a reference to an array containing references to sub-arrays each describing the nodes adjacent to the given node.  Each sub-array should have 3 elements:

=over

=item Node ID

=item Cost to enter that node

=item Heuristic

=back

Basically you should return a reference like this: C<return [ [$node1, $cost1, $h1], [$node2, $cost2, $h2], [...], ...];>
I know this sounds confusing.  Please refer to the ExampleMap.pm sourcefile for a very basic example of a conforming map object.

=item Starting Node ID

=item Target Node ID

AI::Pathfinding::AStar of course needs to know from where you're starting and where you're heading.  The AStar routine does not care  really what format you choose for your Node IDs.  As long as they are unique and can be recognized by Perl's C<exists $hash{$nodeid}> then they will work.

=back

This routine then returns a reference to an array of Node IDs representing the least expensive path to your target node.

=head1 PREREQUISITES

This module requires Heap::Simple to function.

=head1 SEE ALSO

Heap::Simple, L<http://www.policyalmanac.org/games/aStarTutorial.htm>
This distribution contains an example map object and test script in the examples directory that may be of assistance.

=head1 AUTHOR

Aaron Dalton - acdalton@cpan.org
This is my very first CPAN contribution and I am B<not> a professional programmer.  Any feedback you may have, even regarding issues of style, would be greatly appreciated.  I hope it is of some use to somebody.

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Aaron Dalton

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

