package Wiktionary::Parser::Section;

use strict;
use warnings;
use Data::Dumper;

sub new {
	my $class = shift;
	my %args = @_;

	die 'section_number not defined' unless defined $args{section_number};
	$args{header} = lc($args{header}) if $args{header};

	my $self = bless \%args, $class;

	return $self;
}

sub get_section_number {
	my $self = shift;
	return $self->{section_number};
}

sub get_header {
	my $self = shift;
	return lc $self->{header};
}

sub set_header {
	my $self = shift;
	$self->{header} = lc shift;
}

# add a line of content to this section
sub add_content {
	my $self = shift;
	my $line = shift;
	
	push @{$self->{content}}, $line;
}

# return an arrayref of lines of text from this section
sub get_content {
	my $self = shift;
	return $self->{content};
}

sub get_document {
	my $self = shift;
	return $self->{document};
}

# return the parent section
# e.g. if this is section 1.2.1
# return section 1.2
sub get_parent_section {
	my $self = shift;
	my $num = $self->get_section_number();
	if ($num =~ m/\./) {
		$num =~ s/\.\d+$//;
		$num =~ s/\.0*$//; # remove trailing zero's - if sections were added too deep e.g. secttion ===== under ===

		return $self->get_document()->get_section($num);
	}
	return;
}

# returns the topmost section in the hierarchy
sub get_parent_language_section {
	my $self = shift;
	my $sections = $self->get_ancestor_sections();
	return $sections->[-1];
}

# get all parent sections up to the top level
sub get_ancestor_sections {
	my $self = shift;
	my @ancestors;
	my $section = $self;
	while (my $parent = $section->get_parent_section()) {
		push @ancestors, $parent;
		$section = $parent;
	}

	return \@ancestors;
}

1;

