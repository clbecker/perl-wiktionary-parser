#! /usr/bin/env perl
#
# This example uses the get_parts_of_speech() method to print out
# all parts of speech for each language
#

use warnings;
use strict;
use Data::Dumper;

use Wiktionary::Parser;
use Encode qw(encode);

my $word = 'cat';
my $parser = Wiktionary::Parser->new();
my $document = $parser->get_document(title => $word);

my $pos = $document->get_parts_of_speech();

for my $language_code (keys %{$pos || {}}) {

	my @parts_of_speech = @{ $pos->{$language_code}{part_of_speech} };

	print "\n$pos->{$language_code}{language}\n";

	print "\t $_ \n" for @parts_of_speech;
}
