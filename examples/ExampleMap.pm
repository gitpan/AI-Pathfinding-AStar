package ExampleMap;

use strict;
use warnings;

#This example module represents the following map:
#	
#	. . . . . . . 
#	. . . | . . .
#	. @ . | . * .
#	. . . | . . .
#	. . . . . . . 
#
#Where . represents open squares and | represents walls.  The @ represents our starting square and the * the target square.  This module assumes that orthogonal moves cost 10 points and diagonal moves cost 14.  The heuristic used is Manhattan, which simply counts the orthogonal distance between any 2 squares whilst disregarding any barriers.
#
#This module is for example only and does not do any exception checking as it should!

sub new
{
	my $self = {};

	#{map} contains the open/closed status of a given node.
	#NodeID's consist of the x/col value followed by a . followed by the y/row value.
	#A value of 1 means the node is open.  A value of 0 means it is impassable.

	for(my $x=1; $x<=7; $x++)
	{
		for(my $y=1; $y<=5; $y++)
			{$self->{map}->{$x.'.'.$y} = 1;}
	}
	$self->{map}->{'4.2'} = 0;
	$self->{map}->{'4.3'} = 0;
	$self->{map}->{'4.4'} = 0;
	
	bless $self;
	return $self;
}

sub astar_surrounding
{
	my ($self, $source, $target) = @_;

	my ($src_x, $src_y) = split(/\./, $source);

	my $surrounding = [];

	#orthogonal moves cost 10, diagonal cost 14
	foreach my $node (&getOrth($source))
	{
		if ( (exists $self->{map}->{$node}) && ($self->{map}->{$node}) )
			{push @$surrounding, [$node, 10, &calcH($node, $target)];}
	}
	foreach my $node (&getDiag($source))
	{
		if ( (exists $self->{map}->{$node}) && ($self->{map}->{$node}) )
			{push @$surrounding, [$node, 14, &calcH($node, $target)];}
	}

	return $surrounding;
}

sub getOrth
{
	my ($source) = @_;

	my @return = ();
	my ($x, $y) = split(/\./, $source);

	push @return, ($x+1).'.'.$y, ($x-1).'.'.$y, $x.'.'.($y+1), $x.'.'.($y-1);
	return @return;
}

sub getDiag
{
		my ($source) = @_;

		my @return = ();
		my ($x, $y) = split(/\./, $source);

		push @return, ($x+1).'.'.($y+1), ($x+1).'.'.($y-1), ($x-1).'.'.($y+1), ($x-1).'.'.($y-1);
		return @return;
}     

sub calcH
{
	my ($source, $target) = @_;

	my ($x1, $y1) = split(/\./, $source);
	my ($x2, $y2) = split(/\./, $target);

	return (abs($x1-$x2) + abs($y1-$y2));
}

1;
