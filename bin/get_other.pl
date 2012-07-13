#! /usr/bin/env perl
#

use warnings;
use strict;
use Data::Dumper;

use Wiktionary::Parser;

my $word = 'orange';
my $parser = Wiktionary::Parser->new();
my $document = $parser->get_document(title => $word);

# returns structured data parsed from the Derived Terms
# sections of the page.  This is a hash mapping language to 
# a list of words for each language
my $derived_terms = $document->get_derived_terms();

print Dumper $derived_terms;

# this returns a list of word senses from the given page
# these are parsed from the translation section.
my $word_senses = $document->get_word_senses();

print Dumper $word_senses;
