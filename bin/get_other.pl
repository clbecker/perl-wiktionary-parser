#! /usr/bin/env perl
#

use warnings;
use strict;
use Data::Dumper;

use Wiktionary::Parser;

my $word = 'orange';
my $parser = Wiktionary::Parser->new();
my $document = $parser->get_document(title => $word);


# the table of contents just gives you a summary of the 
# sections in this document
print Dumper $document->get_table_of_contents();



# returns structured data parsed from the Derived Terms
# sections of the page.  This is a hash mapping language to 
# a list of words for each language
my $derived_terms = $document->get_derived_terms();

print Dumper $derived_terms;

# this returns a list of word senses from the given page
# these are parsed from the translation section.
my $word_senses = $document->get_word_senses();

print Dumper $word_senses;


# Getting dictionary definitions
# The current way to get dictionary definitions is to dump out the content of the parts of speech sections.  
# One way to do that would be to run:

my $word = 'orange';
my $parser = Wiktionary::Parser->new();
my $document = $parser->get_document(title => $word);

my $sections = $document->get_part_of_speech_sections();

for my $section (@$sections) {
	print Dumper $section->get_content();
}



# However, in practice, only the English section of each wiktionary page has detailed
# definition information.  So one way to just retrieve that data would be extract the 
# English section as a sub document first, and then dump out the content of 
# the part of speech sections under it:

my $sections = $document->get_sub_document(title => 'english')->get_part_of_speech_sections();

for my $section (@$sections) {
	print Dumper $section->get_content();
}


