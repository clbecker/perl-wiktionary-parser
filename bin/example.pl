#! /usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

use Wiktionary::Parser;
$\ = "\n";
my $word = shift || 'orange';

my $parser = Wiktionary::Parser->new();

my $document = $parser->get_document(title => $word);

{
#	my $sub_document = $document->get_sub_document(title => 'pronunciation');
#print Dumper $sub_document->get_pronunciations();
#print Dumper $document->get_synonyms();
print Dumper $document->get_parts_of_speech();

#	print Dumper $sub_document->get_table_of_contents();
	exit;
}


{
	print Dumper $document->get_derived_terms();
	exit;
}


exit;
print "\nsynonyms\n";
print Dumper $document->get_synonyms();
print "\nhypernyms\n";
print Dumper $document->get_hypernyms();
print "\nhyponyms\n";
print Dumper $document->get_hyponyms();


exit;

print Dumper $document->get_language_section(language => 'danish')->get_table_of_contents();

print Dumper $document->get_language_section(language => 'danish')->get_parts_of_speech();

print Dumper $document->get_language_section(language => 'danish')->get_pronunciations();


exit;
#print Dumper $document->get_table_of_contents();

{
	my $sections = $document->get_pronunciation_sections();

	for my $sec (@$sections) {

		my $audio_per_language = $sec->get_audio();
		while (my ($lang,$audio_list) = each %{$audio_per_language || {}}) {
			
			for my $audio (@$audio_list) {
				my $path = $audio->download_file(
					directory => '/tmp/audio/',
				);

				print "Downloaded $path";

			}
		}
	}
}

exit;


exit;
print Dumper $document->get_translations();
print Dumper $document->get_word_senses();
print Dumper $document->get_parts_of_speech();
print "\nsynonyms\n";
print Dumper $document->get_synonyms();
print "\nhypernyms\n";
print Dumper $document->get_hypernyms();
print "\nhyponyms\n";
print Dumper $document->get_hyponyms();
print "\nantonyms\n";
print Dumper $document->get_antonyms();

print "\npronunciations\n";
print Dumper $document->get_pronunciations();


exit;
{
	my $sections = $document->get_sections_of_type('Wiktionary::Parser::Section::AlternativeForms');

	for my $sec (@$sections) {
		printf "section: %s\n",$sec->get_header();
		printf "language: %s\n",$sec->get_parent_language_section()->get_header();
		print Dumper $sec->get_content();
	}
}


exit;

{
	my $sections = $document->get_sections(title => qr/altern\w+ forms/);

	for my $sec (@$sections) {
		printf "section: %s\n",$sec->get_header();
		printf "language: %s\n",$sec->get_parent_language_section()->get_header();
		print Dumper $sec->get_content();
	}
}
exit;

{
	my $lang_sections = $document->get_sections(title => qr/english|dutch/);

	for my $sec (@$lang_sections) {
		print ">>".$sec->get_header(),"\n";
		my $sect_list = $sec->get_child_sections();
		for my $sec (@$sect_list) {
			print $sec->get_header(),"\n";
		}
	}
}

exit;
my $etymology_sections = $document->get_sections(title => 'etymology');

for my $es ( @$etymology_sections ) {
	print $es->get_header();
	print Dumper $es->get_content();
}
exit;




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


