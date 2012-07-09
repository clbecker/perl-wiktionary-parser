package Wiktionary::Parser;

use strict;
use warnings;
use Data::Dumper;
use LWP;
use JSON::XS qw(decode_json);
use Encode qw(decode encode);

use MediaWiki::API;
use Wiktionary::Parser::Document;
use Carp::Always;

our $VERSION = 0.03;

my $CACHE;

sub new {
	my $class = shift;
	my %args = @_;

	$args{wiktionary_url} ||= 'http://en.wiktionary.org/w/api.php';

	my $self = bless \%args, $class;

	$self->{cache} = 0;  # 1: cache content locally, 0: don't
	$self->{mediawiki_client} = MediaWiki::API->new({ api_url => $self->get_wiktionary_url() });

	return $self;
}


# create the base url 
# add http if it hasn't already been prepended
sub get_wiktionary_url {
	my $self = shift;
	my $url = $self->{wiktionary_url};
	$url =~ s|/$||;
	return sprintf("%s$url", $url =~ m|^https?://| ? '' : 'http://');
}


sub get_document {
	my $self = shift;
	my %args = @_;
	my $title = $args{title};

	if ($self->get_cache($title)) {
		return $self->get_cache($title);
	}

	my $page_data = $self->get_page_data(
		title => $title,
	);
	my $content = $page_data->{'*'}; 

	return unless $content;

	my $document = $self->parse_page_content(
		content => $content,
		title   => $title,
	);

	$self->set_cache($title,$document);

	return $document;
}


sub get_cache {
	my $self = shift;
	return unless $self->{cache};
	my $title = shift;
	return $CACHE->{ $self->get_wiktionary_url() }{$title};
}

sub set_cache {
	my $self = shift;
	return unless $self->{cache};
	my $title = shift;
	my $document = shift;
	$CACHE->{ $self->get_wiktionary_url() }{$title} = $document;
}


sub parse_page_content {
	my $self = shift;
	my %args = @_;
	my $document_content = $args{content};
	my $title = $args{title};

	die 'document not defined' unless defined $document_content;

	my @lines = split(/\n/,$document_content);
	my %sections = ();
	my @section_number = ();

	my $document = Wiktionary::Parser::Document->new( 
		title => $title,
		# pass in a parser if we want this document to follow
		# links to other documents (e.g. wikisaurus) 
		# and include metadata from them
		parser => $self,
	);

	my $current_section = $document->create_section(
		section_number => 0,
		header => $title,
	);

	for my $line (@lines) {
		chomp $line;
		next unless $line;
		if ($line =~ m/^(==+)([^=]+)/) {
			my $markup = $1;
			my $header = $2;
			my $n = length($markup);
			$section_number[$n-2]++;
			$#section_number = $n-2;
			my $section_number = join('.',map {$_ || ()} @section_number);

			$current_section = $document->create_section(
				section_number => $section_number,
				header => $header,
			);
		} elsif ($line =~ m/^\[\[(Category:[^\]]+)\]\]/) {
		# e.g. [[Category:Animals]]
			$document->add_category(category => $1);
		} elsif ($line =~ m/^\[\[([a-z]+:$title)\]\]/) {
		# e.g. [[de:dog]]
			$document->add_language_link(tag => $1);
		} else {
			$current_section->add_content($line);
		}
	}

	return $document;
}

sub get_page_data {
	my $self = shift;
	my %args = @_;
	my $title = $args{title};
    
	die 'title is not defined' unless defined $title;

	my $page_data = $self->get_mediawiki_client()->get_page({title => $title});

	return $page_data;
}

sub get_mediawiki_client {
	my $self = shift;
	return $self->{mediawiki_client};
}




1;

=pod

=head1 Wiktionary::Parser

=cut
