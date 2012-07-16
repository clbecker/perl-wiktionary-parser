#! /usr/bin/env perl
#
# If you want to go crazy, you can also work with the parsed
# output on a section by section basis.  Here's some of the available
# methods for doing so.

use warnings;
use strict;
use Data::Dumper;

use Wiktionary::Parser;
use Encode qw(encode);

my $word = 'cat';
my $parser = Wiktionary::Parser->new();
my $document = $parser->get_document(title => $word);

# get an array of all section objects that match the title "etymology"
my $section_list = $document->get_sections(title => 'etymology');


for my $section (@$section_list) {

	printf "Number: %s\n",$section->get_section_number();
	printf "Header: %s\n",$section->get_header();

	# this returns an array of all lines of text from this section
	print Dumper $section->get_content();

	# this returns an array of all sections under this one
	# in the hierarchy.
	my $child_sections = $section->get_child_sections();

	# this returns all child sections wrapped in a 
	# Document object for easy manipulation.
	my $child_document = $section->get_child_document();

	# this returns a Section object of the immediate parent
	# to this section.
	my $parent_section = $section->get_parent_section();


	# this returns a list of sections above this
	# one in the hierarchy.  
	my $ancestor_sections = $section->get_ancestor_sections();

	# this returns the language based on the heading
	# of the top-level language section that this
	# section falls under
	my $language = $section->get_language();

}
