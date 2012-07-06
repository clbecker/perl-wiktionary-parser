package Wiktionary::Parser::Section::Translations::WordSense::Lexeme;

use strict;
use warnings;
use Data::Dumper;

sub new {
	my $class = shift;
	my %args = @_;

	# fields
	# language_code
	# language_name
	# lexeme
	# extra

	#die 'language_code is not defined' unless defined $args{language_code};
	#die 'lexeme is not defined' unless defined $args{lexeme};

	my $self = bless \%args, $class;
	return $self;
}

sub get_lexeme {
	my $self = shift;
	return $self->{lexeme};
}

sub get_language_code {
	my $self = shift;
	return $self->{language_code};
}

sub get_language_name {
	my $self = shift;
	return $self->{language_name};
}


sub add_extra {
	my $self = shift;
	push @{$self->{extra}},@_;
}

1;
