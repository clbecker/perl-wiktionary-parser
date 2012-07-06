package Wiktionary::Parser::Section::Classifications;

use strict;
use warnings;
use Data::Dumper;
use Wiktionary::Parser::Section;

use base qw(Wiktionary::Parser::Section);

sub new {
	my $class = shift;
	my %args = @_;
	my $self = bless Wiktionary::Parser::Section->new(%args), $class;
	return $self;
}



# add a line of content to this section and parse it into its component parts
sub add_content {
	my $self = shift;
	my $line = shift;

	# * {{sense|swindler}} [[swindler]], [[cheat]]	
	# * {{l|en|blee}}
	# * {{l|pt|para|gloss=[[to]], [[for]]}}

	my $language_node = $self->get_parent_language_section();
	my $language = $language_node ? $language_node->get_header() : '';

	if ($line =~ m/^\*\s\{\{([^\}]+)\}\}/) {
		my $meta = $1;
		my @meta_parts = split(/\|/,$meta);
		
		my @lexemes = $line =~ m/\[\[([^\]]+)\]\]/g;

		if ($meta_parts[0] =~ m/sense/i) {
			$self->add_group(
				sense => $meta_parts[1],
				language => $language,
				lexemes => \@lexemes,
			)
		} elsif ($meta_parts[0] =~ m/^l$/) {
			my @lexemes;
			push @lexemes, $meta_parts[2];
			push @lexemes, $line =~ m/\[\[([^\]]+)\]\]/g;

			$self->add_group(
				sense => $self->get_document()->get_title(),
				language => $language || $meta_parts[1],
				lexemes => \@lexemes,
			);
		}
	} else {
		my @lexemes = $line =~ m/\[\[([^\]]+)\]\]/g;
		$self->add_group(
			sense => $self->get_document()->get_title(),
			language => $language,
			lexemes => \@lexemes,
		)

	}
	
	push @{$self->{content}}, $line;
}

sub add_group {
	my $self = shift;
	my %args = @_;
	my $language = $args{language};
	my $sense = $args{sense};
	my $lexemes = $args{lexemes};
	push @{$self->{groups}}, {
		sense => $sense,
		language => $language,								
		lexemes => $lexemes,
	};
}
1;
