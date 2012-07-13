#! /usr/bin/env perl
#
# This example uses the get_translations() method to print out
# all translations for each word sense of a given word.  
#

use warnings;
use strict;
use Data::Dumper;

use Wiktionary::Parser;
use Encode qw(encode);

my $word = 'orange';
my $parser = Wiktionary::Parser->new();
my $document = $parser->get_document(title => $word);

my $translations = $document->get_translations();

for my $word_sense (sort keys %{ $translations || {} }) {

	print "\nWord Sense: $word_sense\n";

	for my $language_code (sort keys %{ $translations->{$word_sense} }) {
		
		my $language_name = $translations->{$word_sense}{$language_code}{language};
		my @translations = @{ $translations->{$word_sense}{$language_code}{translations} };

		printf(
			"%25s: %-4s - %s\n",
			$language_name || '',
			$language_code || '',
			join(',',map { encode('utf8',$_) } @translations),
		);
	}
}
