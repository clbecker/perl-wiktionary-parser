#! /usr/bin/env perl
#
# This example uses the get_synonyms() method to print out
# all synonyms for each word sense & language available
#

use warnings;
use strict;
use Data::Dumper;

use Wiktionary::Parser;
use Encode qw(encode);

my $word = 'cat';
my $parser = Wiktionary::Parser->new();
my $document = $parser->get_document(title => $word);

#
# The following methods return data in identical data structures:
#
# $document->get_synonyms()
# $document->get_hyponyms()
# $document->get_hypernyms()
# $document->get_antonyms();
#
#
# Note that for each of these, the document parser
# will follow any 'Wikisaurus' links and return data
# from the extended lists on those pages

my $synonyms = $document->get_synonyms();

for my $language_code (sort keys %{ $synonyms || {} }) {

 	print "$synonyms->{$language_code}{language}; $language_code\n";

 	for my $word_sense (sort keys %{ $synonyms->{$language_code}{sense} }) {

		print "\t$word_sense\n";
		
		my @words = @{ $synonyms->{$language_code}{sense}{$word_sense} };

		for my $word (@words) {
			print "\t\t$word\n";
		}
 	}
}
