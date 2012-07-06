package Wiktionary::Parser::Section::Hypernym;

use strict;
use warnings;
use Data::Dumper;
use Wiktionary::Parser::Section::Classifications;

use base qw(Wiktionary::Parser::Section::Classifications);

sub new {
	my $class = shift;
	my %args = @_;
	my $self = bless Wiktionary::Parser::Section::Classifications->new(%args), $class;
	return $self;
}

sub get_hypernyms {
	my $self = shift;
	return $self->{groups};
}

1;
