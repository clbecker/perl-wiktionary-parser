package  Wiktionary::Parser::Document;

use strict;
use warnings;
use Data::Dumper;
use Wiktionary::Parser::Section;
use Wiktionary::Parser::Section::Translations;
use Wiktionary::Parser::Section::PartofSpeech;
use Wiktionary::Parser::Section::Etymology;
use Wiktionary::Parser::Section::Synonym;

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

sub get_sections {
	my $self = shift;
	return $self->{sections};
}

sub get_section {
	my $self = shift;
	my $number = shift;
	return $self->{sections}{$number};
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
		push @contents, sprintf("%s,%s",$number,$self->get_section($number)->get_header());
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

sub get_sections_of_type {
	my $self = shift;
	my $type = shift;
	my @sections;
	for my $number ($self->get_section_numbers()) {
		next unless $self->get_section($number)->isa($type);
		push @sections, $self->get_section($number);
	}
	return \@sections;
}


sub get_section_numbers {
	my $self = shift;
	return (sort {$a cmp $b} keys %{$self->{sections} || {}});
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

	if ($self->{__get_synonyms__}) {
		return $self->{__get_synonyms__};
	}

	my $sections = $self->get_synonym_sections();
	my %synonyms;
	for my $section (@{$sections || []}) {
		my $synonyms = $section->get_synonyms();
		for my $synonym (@{$synonyms || []}) {

			
			push @{$synonyms{ $synonym->{language} }}, {
				sense => $synonym->{sense}, 
				synonyms => $synonym->{lexemes},
			};
		}
	}

	$self->{__get_synonyms__} = \%synonyms;

	return \%synonyms;
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
