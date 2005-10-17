package AI::Pathfinding::AStar;

use 5.006;
use strict;
use warnings;
use Carp;

our $VERSION = '0.04';

use Heap::Simple;
my $nodes;

sub _init {
    my $self = shift;
    croak "no getSurrounding() method defined" unless $self->can("getSurrounding");

    return $self->SUPER::_init(@_);
}


sub findPath {
	my ($map, $start, $target) = @_;

	my $open = Heap::Simple->new(order => "<", elements => [Any => \&calcF], user_data => "Open List");
	$nodes = {};
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
	while ( ($open->count) > 0 ) {
		#choose the one with the lowest F score, remove it from the OPEN and add to the CLOSED list
		my $nxt_node = $open->extract_min;
		$curr_node = $nxt_node;
		$nodes->{$curr_node}->{inopen} = 0;

		#get surrounding squares
		my $surr_nodes = $map->getSurrounding($curr_node, $target);
		foreach my $node (@$surr_nodes) {
			my ($surr_id, $surr_cost, $surr_h) = @$node;

			#skip the node if it's in the CLOSED list
			next if ( (exists $nodes->{$surr_id}) && (! $nodes->{$surr_id}->{inopen}) );

			#add it if it's not already in the OPEN
			if (! exists $nodes->{$surr_id}) {
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
			my $currG = calcG($surr_id);
			my $possG = calcG($curr_node) + $surr_cost;
			if ($possG < $currG) {
				#change the parent
				$nodes->{$surr_id}->{parent} = $curr_node;
				#re-sort the OPEN list
				$open->clear;
				foreach my $node (keys %$nodes)	{
					if ($nodes->{$node}->{inopen}) {
						$open->insert($node);
					}
				}
			}
		}
	}	#end pathfinding while

	#if the loop exited because the target was found, fillup the $path array
	if (exists $nodes->{$target}) {
		unshift @$path, $target;
		my $curr_node = $nodes->{$target}->{parent};
		while (defined $curr_node) {
			unshift @$path, $curr_node;
			$curr_node = $nodes->{$curr_node}->{parent};
		}
	}

	#if the target was unreacheable, return an empty array ref
	return wantarray ? @$path : $path;
}

#F = G + H
sub calcF {
	my $node = shift;
	my $f = $nodes->{$node}->{h};
	$f += calcG($node);

	return $f;
}

sub calcG {
	my $node = shift;
	my $g = $nodes->{$node}->{cost};
	$node = $nodes->{$node}->{parent};
	while (defined $node) {
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

  package My::Map::Package;
  use base AI::Pathfinding::AStar;

  # Methods required by AI::Pathfinding::AStar
  sub getSurrounding { ... }

  package main;
  use My::Map::Package;

  my $map = My::Map::Package->new or die "No map for you!";
  my $path = $map->findPath($start, $target);
  print join(', ', @$path), "\n";

=head1 DESCRIPTION

This module implements the A* pathfinding algorithm.  It acts as a base class from which a custom map object can be derived.  It requires from the map object a subroutine named C<getSurrounding> (described below) and provides to the object a routine called C<findPath> (also described below.)  It should also be noted that AI::Pathfinding::AStar defines two other subs (C<calcF> and C<calcG>) which are used only by the C<findPath> routine.

AI::Pathfinding::AStar requires that the map object define a routine named C<getSurrounding> which accepts the starting and target node ids for which you are calculating the path.  In return it should provide an array reference containing the following details about each of the immediately surrounding nodes:

=over

=item * Node ID

=item * Cost to enter that node

=item * Heuristic

=back

Basically you should return an array reference like this: C<[ [$node1, $cost1, $h1], [$node2, $cost2, $h2], [...], ...];>  For more information on heuristics and the best ways to calculate them, visit the links listed in the I<SEE ALSO> section below.  For a very brief idea of how to write a getSurrounding routine, refer to the included tests.

As mentioned earlier, AI::Pathfinding::AStar provides a routine named C<findPath> which requires as input the starting and target node identifiers.  The C<findPath> routine does not care what format you choose for your node IDs.  As long as they are unique, and can be distinguished by Perl's C<exists $hash{$nodeid}>, then they will work.  In return, this routine returns an array (or reference) of node identifiers representing the least expensive path to your target node.  An empty array means that the target node is entirely unreacheable from the given source.

=head1 PREREQUISITES

This module requires Heap::Simple to function.

=head1 SEE ALSO

Heap::Simple, L<http://www.policyalmanac.org/games/aStarTutorial.htm>, L<http://xenon.stanford.edu/~amitp/gameprog.html>

=head1 AUTHOR

Aaron Dalton - aaron@daltons.ca
This is my very first CPAN contribution and I am B<not> a professional programmer.  Any feedback you may have, even regarding issues of style, would be greatly appreciated.  I hope it is of some use.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2004 Aaron Dalton.  All rights reserved.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

