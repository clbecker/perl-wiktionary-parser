#! /usr/bin/env perl
# test individual parsing steps to weed out errors in the process
use strict;
use warnings;
use Data::Dumper;

use Test::More;
use Wiktionary::Parser::Section::Translations;
use Wiktionary::Parser::Document;

my $line1 = '{{trans-top|test-word-sense}}';

my $test_data = (
	{
		input => '* Scottish Gaelic: [[òr-mheas]] {{m}}, {{t-|gd|oraindsear|m|xs=Scottish Gaelic}}',
		output => {
			# results of each successive match against template patterns
			template_result1 => {
				language => 'Scottish Gaelic'
			},
			template_result2 => {
				'translations' => [
					'òr-mheas'
				],
				'gender' => 'm'
			},
			template_result3 => {
				meta => 'end_segment'
			},
			template_result4 => {
				'language_code' => 'gd',
				'translations' => [
					'oraindsear'
				],
				'xs' => 'Scottish Gaelic',
				'gender' => 'm'
			},
			template_result5 => undef,

			lexeme_parsed_language_name => 'Scottish Gaelic', # language parsed from text "* Scottish Gaelic: "
			translation_languages => ['Scottish Gaelic'],
			language_code => 'gd', # code returned from language2code
			normalized_language => 'Gaelic', # language returned from code2language
			tagged_language_code => 'gd', # code parsed from text: "{{t-|gd|oraindsear..."
			tagged_normalized_language => 'Gaelic', # language returned from code2language
			tagged_normalized_language_code => 'gd', # code returned from language2code
		},
	}
);


test1($test_data);

sub test1 {
	my $hr = shift;
	my $pos_section = Wiktionary::Parser::Section::Translations->new(
		section_number => '1.1',
		header => 'noun',
	);

	my $section = Wiktionary::Parser::Section::Translations->new(
		section_number => '1.1.1',
		header => 'translations',
	);

	my $document = Wiktionary::Parser::Document->new(
		sections => [$section,$pos_section],
	);

	my $lexeme = Wiktionary::Parser::Section::Translations::WordSense::Lexeme->new();

	my $template0_result = $section->get_template_match($line1);

	my $template_result1 = $section->get_template_match($hr->{input});

	is_deeply($template_result1,$hr->{output}{template_result1},'Parsed out language name from text');
	$lexeme->set_language_name($template_result1->{language});

	my $template_result2 = $section->get_template_match($hr->{input});
	is_deeply($template_result2,$hr->{output}{template_result2},'Parsed out translations and gender');


	$lexeme->set_gender($template_result2->{gender});
	$lexeme->add_translations(@{$template_result2->{translations}});


	my $template_result3 = $section->get_template_match($hr->{input});
	is_deeply($template_result3,$hr->{output}{template_result3},'Parsed out comma delimiter');


	my $template_result4 = $section->get_template_match($hr->{input});
	is_deeply($template_result4,$hr->{output}{template_result4},'Parsed out translations and language code');

	$lexeme->add_translations(@{$template_result4->{translations}});
	$lexeme->set_language_code($template_result4->{language_code});;

	my $template_result5 = $section->get_template_match($hr->{input});
	is_deeply($template_result5,$hr->{output}{template_result5},'parsing done');	



	my $word_sense = Wiktionary::Parser::Section::Translations::WordSense->new(word_sense => 'test');
	$word_sense->add_lexeme($lexeme);

	my $translations = $word_sense->get_translations();
	is_deeply([keys %$translations],$hr->{output}{translation_languages},'languages retrieved for word sense');

	my ($language) = keys %$translations;
	my $language_code = $document->get_language_mapper()->language2code($language);
	my $normalized_language = $document->get_language_mapper()->code2language($language_code);

	# TODO: determine if this is where different values are being generated in blead-perl
	is($language_code,$hr->{output}{language_code},"section's language code is $hr->{output}{language_code}");
	is($normalized_language,$hr->{output}{normalized_language},"section's normalized language is $hr->{output}{normalized_language}");

	my $lexemes = $translations->{$language};
	($lexeme) = @{$lexemes};
	my $tagged_language_code = $lexeme->get_language_code();

	my $tagged_normalized_language = $document->get_language_mapper()->code2language($tagged_language_code);
	my $tagged_normalized_language_code = $document->get_language_mapper()->language2code($tagged_normalized_language);


	is($lexeme->get_language_name(),$hr->{output}{lexeme_parsed_language_name},"Lexeme's parsed language name is $hr->{output}{lexeme_parsed_language_name}");
	is($tagged_language_code,$hr->{output}{tagged_language_code},"lexeme's tagged language code is $hr->{output}{tagged_language_code}");
	is($tagged_normalized_language,$hr->{output}{tagged_normalized_language},"lexeme's tagged normalized language name is $hr->{output}{tagged_normalized_language}");
	is($tagged_normalized_language_code,$hr->{output}{tagged_normalized_language_code},"lexeme's tagged normalized language code is $hr->{output}{tagged_normalized_language_code}");
}


done_testing();
