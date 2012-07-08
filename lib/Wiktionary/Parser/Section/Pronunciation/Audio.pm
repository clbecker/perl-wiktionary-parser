package Wiktionary::Parser::Section::Pronunciation::Audio;

use strict;
use warnings;
use Data::Dumper;

# keys:
#  file: name of the audio file
#  text: text label for this file
#  context: e.g. en(US), en(UK)
sub new {
	my $class = shift;
	my %args = @_;
	my $self = bless \%args, $class;
	return $self;
}

sub get_file {
	my $self = shift;
	return $self->{file};
}

sub get_text {
	my $self = shift;
	return $self->{text};
}

sub get_context {
	my $self = shift;
	return $self->{context};
}

# TODO: create method for downloading audio file
#sub download_file {
#	my $self = shift;
#	my $file_key = 'File:'.$self->{file}
#}

1;
