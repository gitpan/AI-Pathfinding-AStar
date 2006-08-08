package AI::Pathfinding::AStarNode;

use strict;
use Heap::Elem;
use vars qw(@ISA);

@ISA = qw(Heap::Elem);

sub new {
	my $class  = shift;
	my ($self) = Heap::Elem->new();
	bless($self, $class);

	my ($id,$g,$h) = @_;

	$self->{id}     = $id;
	$self->{g}      = $g;
	$self->{h}      = $h;
	$self->{f}      = $g+$h;
	$self->{parent} = undef;
	$self->{cost}   = 0;
	$self->{inopen} = 0;

	return $self;
}

sub cmp {
    my $self = shift;
    my $other = shift;

    my $f1 = $self->{g}  + $self->{h};
    my $f2 = $other->{g} + $other->{h};
    return ($f1 <=> $f2);
}
