package Wiktionary::Parser;

use strict;
use warnings;
use Data::Dumper;
use LWP;
use JSON::XS qw(decode_json);
use Encode qw(decode encode);

use Wiktionary::Parser::Document;
use Carp::Always;
our $VERSION = 0.01;

sub new {
	my $class = shift;
	my %args = @_;

	$args{lang} = 'en'; # only works for en.wiktionary.org now
	$args{wiktionary_url} ||= sprintf('%s.wiktionary.org/w/api.php',$args{lang});

	my $self = bless \%args, $class;
	return $self;
}


# create the base url for the request composed of the host and port
# add http if it hasn't already been prepended
sub wiktionary_url {
	my $self = shift;
	my $url = $self->{wiktionary_url};
	$url =~ s|/$||;
	return sprintf("%s$url", $url =~ m|^https?://| ? '' : 'http://');
}


sub get_document {
	my $self = shift;
	my %args = @_;
	my $title = $args{title};

	my $content = $self->get_page_content(
		title => $title,
	);

	die "no content found for $title" unless $content;

	return $self->parse_page_content(
		content => $content,
		title   => $title,
	);
}


sub parse_page_content {
	my $self = shift;
	my %args = @_;
	my $content = $args{content};
	my $title = $args{title};
	my $document_content = $self->extract_document(content => $content);

	die 'document not defined' unless defined $document_content;

	my @lines = split(/\n/,$document_content);
	my %sections = ();
	my @section_number = ();

	my $document = Wiktionary::Parser::Document->new( title => $title );
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
			my $section_number = join('.',map {$_ || 0} @section_number);

			$current_section = $document->create_section(
				section_number => $section_number,
				header => $header,
			);
		} else {
			$current_section->add_content($line);
		}
	}

	return $document;
}


sub extract_document {
	my $self = shift;
	my %args = @_;
	my $content = $args{content};

	my $page;
	if ($content->{query} && $content->{query}{pages}) {
		my @pages = keys %{$content->{query}{pages}};
		$page = shift @pages;
	}
	return unless defined $page;
	
	my @revisions = @{$content->{query}{pages}{$page}{revisions} || []};

	my $doc = shift @revisions;
	return $doc->{'*'};
}

sub get_page_content {
	my $self = shift;
	my %args = @_;
	my $title = $args{title};
    
	die 'title is not defined' unless defined $title;

	my $content = $self->remote_request(
		path => $self->wiktionary_url(),
		params => [
			titles => $title,
			action => 'query',
			prop   => 'revisions',
			rvprop => 'content',
			format => 'json',
		]
	);
	
	my $parsed_data = decode_json($content);

	return $parsed_data;
}

sub get_page_id {
	my $self = shift;
	my %args = @_;
	my $title = $args{title};

	my $response_content = $self->remote_request(
		path => $self->wiktionary_url(),
		params => [
			titles => $title,
			action => 'query',
			format => 'json',
		]
	);

	my $page_data = decode_json($response_content);

	if ($page_data->{query} &&
	    $page_data->{query}{pages}) {
		my @pages = keys %{$page_data->{query}{pages} || {}};
		return $pages[0];
	}

	return;
}

sub remote_request {
	my $self = shift;
	my %args = @_;
	my $path = $args{path} || '';
	my $params = $args{params};

	die 'params must be an array' unless ref $params eq 'ARRAY';

	my $uri = URI->new($path);
	$uri->query_form(@{$params || []});

	my $response = $self->user_agent()->get($uri);

	die 'no response' unless $response;
	unless ($response->is_success()) {
		die sprintf("Error: ",
				  $response->code(),
				  $response->message(),
			  );
	}

	my $body = $response->decoded_content();
}

sub user_agent {
	return LWP::UserAgent->new(
		timeout => 10,
		agent => "Wiktionary::Parser::$VERSION",
		keep_alive => 1,
	);
}

1;

=pod

=head1 Wiktionary::Parser

=cut
