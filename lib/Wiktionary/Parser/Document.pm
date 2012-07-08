package  Wiktionary::Parser::Document;

use strict;
use warnings;
use Data::Dumper;
use Wiktionary::Parser::Section;
use Wiktionary::Parser::Section::Translations;
use Wiktionary::Parser::Section::PartofSpeech;
use Wiktionary::Parser::Section::Etymology;
use Wiktionary::Parser::Section::Synonym;
use Wiktionary::Parser::Section::Hyponym;
use Wiktionary::Parser::Section::Hypernym;
use Wiktionary::Parser::Section::Antonym;
use Wiktionary::Parser::Section::Etymology;
use Wiktionary::Parser::Section::Pronunciation;
use Wiktionary::Parser::Section::DerivedTerms;
use Wiktionary::Parser::Section::AlternativeForms;

sub new {
	my $class = shift;
	my %args = @_;
	my $self = bless \%args, $class;
	return $self;
}

sub get_title {
	my $self = shift;
	return $self->{title};
}

sub add_section {
	my $self = shift;
	my $section = shift;
	die 'given value is not of type Wiktionary::Parser::Section' unless $section->isa('Wiktionary::Parser::Section');

	my $section_number = $section->get_section_number();
	$self->{sections}{$section_number} = $section;
}

# by default return a list of all sections
# if title is given, return all sections matching that title
# title may be a string or regex
sub get_sections {
	my $self = shift;
	my %args = @_;
	my $title = $args{title};

	if ($title) {
		my @sections;
		for my $number ($self->get_section_numbers()) {
			
			next unless $self->get_section(number => $number)->get_header() =~ m/$title/i;
			push @sections, $self->get_section(number => $number);
		}
		return \@sections;
	}

	return $self->{sections};
}

sub get_section {
	my $self = shift;
	my %args = @_;
	my $number = $args{number}; # lookup section by number

	if ($number) {
		return $self->{sections}{$number};
	}
	return;
}

# act as a section factory
sub create_section {
	my $self = shift;
	my %args = @_;
	my $section_number = $args{section_number};
	my $header = $args{header};

	my $section;
	my $class;
	if ($header =~ m/translation/i) {
		$class = 'Wiktionary::Parser::Section::Translations';
	} elsif ($header =~ m/etymology/i) {
		$class = 'Wiktionary::Parser::Section::Etymology';
	} elsif ($header =~ m/synonym/i) {
		$class = 'Wiktionary::Parser::Section::Synonym';
	} elsif ($header =~ m/hypernym/i) {
		$class = 'Wiktionary::Parser::Section::Hypernym';
	} elsif ($header =~ m/hyponym/i) {
		$class = 'Wiktionary::Parser::Section::Hyponym';
	} elsif ($header =~ m/antonym/i) {
		$class = 'Wiktionary::Parser::Section::Antonym';
	} elsif ($header =~ m/pronunciation/i) {
		$class = 'Wiktionary::Parser::Section::Pronunciation';
	} elsif ($header =~ m/alternat\w+ form/i) {
		$class = 'Wiktionary::Parser::Section::AlternativeForms';
	} elsif ($header =~ m/derived\sterm/i) {
		$class = 'Wiktionary::Parser::Section::DerivedTerms';
	} elsif ($self->is_part_of_speech($header)) {
		$class = 'Wiktionary::Parser::Section::PartofSpeech'
	} else {
		$class = 'Wiktionary::Parser::Section';
	}

	$section = $class->new(
		section_number => $section_number,
		header         => $header,
		document       => $self,
	);

	$self->add_section($section);

	return $section;
}

sub get_table_of_contents {
	my $self = shift;
	my @contents;
	for my $number ($self->get_section_numbers()) {
		push @contents, sprintf("%s,%s",$number,$self->get_section(number => $number)->get_header());
	}
	return \@contents;
}


# grab all translation sections
sub get_translation_sections {
	my $self = shift;
	return $self->get_sections_of_type('Wiktionary::Parser::Section::Translations');
}

# grab all part of speech sections
sub get_part_of_speech_sections {
	my $self = shift;
	return $self->get_sections_of_type('Wiktionary::Parser::Section::PartofSpeech');
}

sub get_synonym_sections {
	my $self = shift;
	return $self->get_sections_of_type('Wiktionary::Parser::Section::Synonym');
}

sub get_hypernym_sections {
	my $self = shift;
	return $self->get_sections_of_type('Wiktionary::Parser::Section::Hypernym');
}

sub get_hyponym_sections {
	my $self = shift;
	return $self->get_sections_of_type('Wiktionary::Parser::Section::Hyponym');
}


sub get_sections_of_type {
	my $self = shift;
	my $type = shift;
	my @sections;
	for my $number ($self->get_section_numbers()) {
		next unless $self->get_section(number => $number)->isa($type);
		push @sections, $self->get_section(number => $number);
	}
	return \@sections;
}


sub get_section_numbers {
	my $self = shift;
	return (sort {$a cmp $b} grep {$_} keys %{$self->{sections} || {}});
}


sub get_word_senses {
	my $self = shift;
	my $sections = $self->get_translation_sections();
	my @word_senses;
	for my $section (@{$sections || []}) {
		my $word_senses = $section->get_word_senses();

		for my $word_sense (@{$word_senses || []}) {
			push @word_senses, $word_sense->get_word();
		}
	}

	return \@word_senses;
}



sub get_synonyms {
	my $self = shift;
	my %args = @_;
	return $self->get_classifications(
		class => 'Wiktionary::Parser::Section::Synonym',
	);
}

sub get_hyponyms {
	my $self = shift;
	my %args = @_;
	return $self->get_classifications(
		class => 'Wiktionary::Parser::Section::Hyponym',
	);
}

sub get_hypernyms {
	my $self = shift;
	my %args = @_;
	return $self->get_classifications(
		class => 'Wiktionary::Parser::Section::Hypernym',
	);
}

sub get_antonyms {
	my $self = shift;
	my %args = @_;
	return $self->get_classifications(
		class => 'Wiktionary::Parser::Section::Antonym',
	);
}


sub get_classifications {
	my $self = shift;
	my %args = @_;
	my $class = $args{class};

#	if ($self->{"__get_${class}__"}) {
#		return $self->{"__get_${class}__"};
#	}
	my $sections = $self->get_sections_of_type($class);
	my %x_nyms;
	for my $section (@{$sections || []}) {
		my $x_nyms = $section->get_groups();
		for my $x_nym (@{$x_nyms || []}) {

			my $lang = $x_nym->{language};
			my $sense = $x_nym->{sense};
			push @{$x_nyms{$lang}{$sense}}, @{$x_nym->{lexemes} || []};
		}
	}

#	$self->{"__get_${class}__"} = \%x_nyms;

	return \%x_nyms;
}






sub get_pronunciations {
	my $self = shift;
	my %args = @_;
	my $class = $args{class} || 'Wiktionary::Parser::Section::Pronunciation';

	my $sections = $self->get_sections_of_type($class);
	my %meta;
	my %seen;

	for my $section (@{$sections || []}) {

		{
			my $hr = $section->get_pronunciations();
			for my $lang (keys %{$hr}) {
				push @{$meta{$lang}{pronunciation}}, @{$hr->{$lang}};
			}
		}

		{
			my $hr = $section->get_audio();
			for my $lang (keys %{$hr}) {
				# remove duplicates
				push @{$meta{$lang}{audio}}, grep {!$seen{audio}{$lang}{ $_->{file} }++} @{$hr->{$lang}};
			}
		}

		{
			my $hr = $section->get_rhymes();
			for my $lang (keys %{$hr}) {
				push @{$meta{$lang}{rhyme}}, @{$hr->{$lang}};
			}
		}

		{
			my $hr = $section->get_homophones();
			for my $lang (keys %{$hr}) {
				push @{$meta{$lang}{homophone}}, @{$hr->{$lang}};
			}
		}

		{
			my $hr = $section->get_hyphenations();
			for my $lang (keys %{$hr}) {
				push @{$meta{$lang}{hyphenation}}, @{$hr->{$lang}};
			}
		}


	}

	return \%meta;
}



sub get_parts_of_speech {
	my $self = shift;
	my %args = @_;

	if ($self->{__get_parts_of_speech__}) {
		return $self->{__get_parts_of_speech__};
	}

	my $sections = $self->get_part_of_speech_sections();

	my %parts_of_speech;
	for my $section (@{$sections || []}) {
		my $pos = $section->get_part_of_speech();
		my $lang_code = $section->get_language_code();
		next unless $pos && $lang_code;
		push @{$parts_of_speech{$lang_code}}, $pos;
	}

	$self->{__get_parts_of_speech__} = \%parts_of_speech;
	return \%parts_of_speech;
}

sub get_translations {
	my $self = shift;

	if ($self->{__get_translations__}) {
		return $self->{__get_translations__};
	}

	my $sections = $self->get_translation_sections();
	my @word_senses;
	my %translations;
	for my $section (@{$sections || []}) {
		my $word_senses = $section->get_word_senses();

		for my $word_sense (@{$word_senses || []}) {
			my $word_sense_lexeme = $word_sense->get_word();
			my $translations = $word_sense->get_translations();

			for my $language (keys %{$translations || {}}) {
				my $lexemes = $translations->{$language};
				my %seen;
				for my $lexeme (@{$lexemes}) {
					my $lex = $lexeme->get_lexeme();
					next unless defined $lex;
					unless (grep {$_ eq $lex} @{$translations{$word_sense_lexeme}{$language} || []}) {
						push @{$translations{$word_sense_lexeme}{$language}},$lex;
					}
				}
			}

		}
	}

	$self->{__get_translations__} = \%translations;

	return \%translations;
}

sub is_part_of_speech {
	my $self = shift;
	my $header = shift;
	return 1 if grep { $header =~ m/^$_$/i } qw(
		noun
		verb
		adjective
		adverb
		pronoun
		preposition
		article
		conjunction
		determiner
		interjection
		symbol
	);

	return 0;
}


1;
