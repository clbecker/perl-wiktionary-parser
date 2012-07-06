#! /usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

use Wiktionary::Parser;

my $word = shift || 'orange';

my $parser = Wiktionary::Parser->new();

my $document = $parser->get_document(title => $word);

#print Dumper $document->get_translations();
#print Dumper $document->get_word_senses();

#print Dumper $document->get_parts_of_speech();

print Dumper $document->get_synonyms();

exit;
my $sections = $document->get_part_of_speech_sections();

for my $s (@$sections) {

	# display the full hierarchy for each section
	# followed by the content of that section
#	my $parents = $s->get_ancestor_sections();
#	for my $p (@$parents) {
#		print $p->get_header(),"->";
#	}

	print $s->get_parent_language_section()->get_header().'-->'.$s->get_header(),"\n";

	print Dumper $s->get_content(),"\n\n";
}


