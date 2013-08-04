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

my $word = 'chair';
my $parser = Wiktionary::Parser->new();
my $document = $parser->get_document(title => $word);

my $translations = $document->get_translations(

# uncomment this option to exclude transliterations from the results
#	include_transliterations => 0,

# uncomment this option to exclude alternate translations from the results
#	include_alternate_translations => 0,
);

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
