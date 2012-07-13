#! /usr/bin/env perl
#
# This shows how to access parts of the parsed wiktionary page
#
#

use warnings;
use strict;
use Data::Dumper;

use Wiktionary::Parser;
use Encode qw(encode);

my $word = 'dog';

my $parser = Wiktionary::Parser->new();
my $document = $parser->get_document(title => $word);


# get a Wiktionary::Parser::Document object
# that contains a 'sub document' of just the Danish
# section and its child sections in the page. 
#
# Any methods that can be called on the whole document can be called 
# on just this section of the document via the sub document.  
my $sub_document = $document->get_language_section(language => 'danish');

# this returns a list of sections in the document
# which reads like a mediawiki table of contents.  
#
# The main use of this method is just to give yourself a summary
# of what's in the document for info/debugging.  
my $table_of_contents = $document->get_language_section(language => 'danish')->get_table_of_contents();

# get just the part of speech data in the danish section.
# (see get_parts_of_speech.pl for details on this data structure)
my $parts_of_speech = $document->get_language_section(language => 'danish')->get_parts_of_speech();

# get just the pronunciation data in the danish section.
# (see get_pronunciations.pl
my $pronunciations = $document->get_language_section(language => 'danish')->get_pronunciations();




# get_sub_document() lets you extract sections of a document by matching the header
# in this example, the subdocument will contain all of the 'etymology'
# sections and their child sections from the whole document.  
#
# the 'title' param can be a string or a regular expression, so you can match
# or exclude any combination of titles using certain patterns.  

my $sub_document_etym = $document->get_sub_document(title => 'etymology');

# this gives you a sub-document with just the english and dutch sections

my $sub_document_en_nl = $document->get_sub_document(title => qr/(english|dutch)/);

print Dumper $sub_document_en_nl->get_table_of_contents();

