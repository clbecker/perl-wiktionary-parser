package Wiktionary::Parser::Section::Translations;

use strict;
use warnings;
use Data::Dumper;
use Wiktionary::Parser::Section;
use Wiktionary::Parser::Section::Translations::WordSense;
use Encode;

use base qw(Wiktionary::Parser::Section);

sub new {
	my $class = shift;
	my %args = @_;
	my $self = bless Wiktionary::Parser::Section->new(%args), $class;
	return $self;
}

# add a line of content to this section and parse it into its meaningful parts
sub add_content {
	my $self = shift;
	my $line = shift;
	
	if ($line =~ m/{{trans-top\|([^}]+)/) {
		my $sense = $1;
		my $word_sense = Wiktionary::Parser::Section::Translations::WordSense->new(
			word_sense => $sense,
		);

		$self->add_word_sense($word_sense);
		$self->set_current_word_sense($word_sense);
	} elsif ($line =~ m/\{\{trans-(mid|bottom)/) {
		return;

	} elsif ($line =~ m/\{\{\w+-top/) {
		$self->set_current_word_sense(undef);
		return;

	} elsif($line =~ m/^\*/ && $self->get_current_word_sense()) {

		$line =~ s/^[\s\*\:]*//i;
		my ($language_name) = $line =~ m/^([^\:]+)\:/;
		my ($meta) =  $line =~ m/\:\s*(.+)$/;

		if (!$language_name) {
			$self->debug('Language not defined in:',Encode::encode('utf8',$line));
			return;
		}
		if ($meta) {

			# extract translation metadata from brackets
			my @meta = $meta =~ m/(\{{2}[^\}]+\}{2})/g;

			$meta =~ s/(\{{2}[^\}]+\}{2})//;

			# extract alternate translations from parenthesis
			my @alt_meta = $meta =~ m/(\([^\)]+\))/g;

			my $prev_language_code;
			for my $meta (@meta,@alt_meta) {
				if ($meta =~ m/^(\{+)|(\}+)/) {
					$meta =~ s/^\{+//i;
					$meta =~ s/\}+\s*$//i;
					
					$meta =~ s/^t[^\|]*\|//; # remove template code

					if (length($meta) <= 2) {
						# property of previous lexeme
						$self->get_current_word_sense()->add_extra($meta);

					}
					my ($language_code,$translated_word,@extra) = split(/\|/,$meta);


					$self->get_current_word_sense()->add_translation(
						language_code => $language_code || $language_name,
						language_name => $language_name,
						translated_word => $translated_word,
						extra => \@extra,
					);

					$prev_language_code = $language_code;
				} elsif ($meta =~ s/^(\()|(\))$//i) {
				
					$self->get_current_word_sense()->add_translation(
						language_code => $prev_language_code || $language_name,
						language_name => $language_name,
						translated_word => $meta,
					);

				}
				
			}
		} else {
			#warn ("No metadata for %s\n",Encode::encode('utf8',$line));
		}
	}

	push @{$self->{content}}, $line;
}

sub add_word_sense {
	my $self = shift;
	my $word_sense = shift;
	my $sense = $word_sense->get_word();
	$self->{word_senses}{$sense} = $word_sense;
}


sub get_word_senses {
	my $self = shift;
	return [values %{$self->{word_senses} || {}}];
}

sub get_word_sense {
	my $self = shift;
	my $word = shift;
	return $self->{word_senses}{$word};
}


sub set_current_word_sense {
	my $self = shift;
	$self->{current_word_sense} = shift;
}

sub get_current_word_sense {
	my $self = shift;
	return $self->{current_word_sense};
}


sub get_translations {
	my $self = shift;
	return $self->{content};
}

sub debug {
	my $self = shift;
	return unless $self->{verbose};
	local $\ = "\n";
	print STDERR @_;
}

1;
