package Wiktionary::Parser;

use strict;
use warnings;
use Data::Dumper;

use MediaWiki::API;
use Wiktionary::Parser::Document;
use Carp::Always;

our $VERSION = 0.11;

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

=head1 Name

Wiktionary::Parser - Client and Parser of content from the Wiktionary API

=head1 Synopsis

This package may be used to query the Wiktionary API (en.wiktionary.org/w/api.php) for documents by title.  It parses the resulting MediaWiki document and provides access to data structures containing word senses, translations, synonyms, parts of speech, etc.  It also provides access to the raw content of each MediaWiki section should you wish to extract other data on your own, or build on top of this package.  

The repository for this package is available on github at https://github.com/clbecker/perl-wiktionary-parser
And on CPAN at: http://search.cpan.org/~clbecker/Wiktionary-Parser/

=head1 Usage

	my $parser = Wiktionary::Parser->new();
	
	my $document = $parser->get_document(title => 'bunny');
	
	my $translation_hashref     = $document->get_translations();
	my $word_sense_hashref      = $document->get_word_senses();
	my $parts_of_speech_hashref = $document->get_parts_of_speech();
	my $pronunciations_hashref  = $document->get_pronunciations();
	my $synonyms_hashref        = $document->get_synonyms();
	my $hyponyms_hashref        = $document->get_hyponyms();
	my $hypernyms_hashref       = $document->get_hypernyms();
	my $antonyms_hashref        = $document->get_antonyms();
	my $derived_terms_hashref   = $document->get_derived_terms();

	my $section_hashref = $document->get_sections();
	my $sub_document = $document->get_sub_document(title => 'string or regex');
	my $table_of_contents_arrayref = $document->get_table_of_contents();

        my $english_section = $document->get_language_section(language => 'English');

=head2 Methods for Wiktionary::Parser

=over

=item B<new>

Create an instance of the Wiktionary::Parser.  This object is used to contact the Wiktionary API, and parse the results.  

     my $parser = Wiktionary::Parser->new();


=item B<get_document> (title => TITLE)

Contacts the wiktionary API, and downloads the page with the given title.  It then parses the content and returns a Wiktionary::Parser::Document object that you can call further methods on.  

     my $document = $parser->get_document(title => 'orange');

=back


=head2 Methods for Wiktionary::Parser::Document

See https://github.com/clbecker/perl-wiktionary-parser/wiki for details and examples on methods for the Wiktionary::Parser::Document object.

=over


=item B<get_derived_terms>

Returns a reference to a hash mapping language to a list of derived terms and phrases

     my $derived_words = $document->get_derived_words();

     print Dumper $derived_words;
     
     $VAR1 = {
          'en' => [
                'bergamot orange',
                'bitter orange',
                'blood orange',
                'burnt orange',
                ...
          ],
          ...
     }

=item B<get_parts_of_speech>

Returns a reference to a hash mapping language to a list of parts of speech.  See https://github.com/clbecker/perl-wiktionary-parser/wiki/Parts-of-speech for details.  


     my $parts_of_speech = $document->get_parts_of_speech();
	
     print Dumper $parts_of_speech;
     
     $VAR1 = {
          'en' => {
               'language' => 'English',
               'part_of_speech' => [
                    'noun',
                    'adj',
                    'verb'
                ]
          },
          'sv' => {
               'language' => 'Swedish',
               'part_of_speech' => [
                    'adjective',
                    'noun'
               ]
          },
          ...
     }


=item B<get_pronunciations>

Returns a reference to a hash mapping language to a pronunciation metadata.  See https://github.com/clbecker/perl-wiktionary-parser/wiki/pronunciations for details.  

     my $pronunciations = $document->get_pronunciations();
     
=item B<get_translations>

Returns a reference to a hash mapping word sense to language to translated words

     my $translations = $document_get_translations();

     print Dumper $translations
     
     $VAR1 = {
          'fruit' => {
               'tr' => {
                    'language' => 'Turkish',
                    'translations' => [
                         'portakal'
                    ],
                    'part_of_speech' => 'noun'
               },
               'fr' => {
                    'language' => 'French',
                    'translations' => [
                         'orange'
                    ],
                    'part_of_speech' => 'noun'
               },
               'da' => {
                    'language' => 'Danish',
                    'translations' => [
                         'appelsin'
                    ],
                    'part_of_speech' => 'noun'
               },
               ...
          },
          ...    
     }


=item B<get_word_senses>

Returns an arrayref containing a list of word senses


     my $word_senses = $document->get_word_senses();
     	
     print Dumper $word_senses;
     
     $VAR1 = [
          'tree',
          'colour',
          'fruit',
          ...
     ]

=item B<get_synonyms>

Returns a reference to a hash mapping language and word sense to a list of synonyms

     my $synonyms = $document->get_synonyms();

     # Synonyms of 'cat'
     print Dumper $synonyms;
     
     $VAR1 = {
          'en' => {
               'language' => 'English',
               'sense' => {
                    'domestic species' => [
                         'housecat',
                         'kitten',
                         'kitty',
                         ...
                    ],
                    ...
               },
          }
     }

=item B<get_hyponyms>

Returns a reference to a hash mapping language and word sense to a list of hyponyms

     my $hyponyms = $document->get_hyponyms();

=item B<get_hypernyms>

Returns a reference to a hash mapping language and word sense to a list of hypernyms

     my $hypernyms = $document->get_hypernyms();

=item B<get_antonyms>

Returns a reference to a hash mapping language and word sense to a list of antonyms

     my $antonyms = $document->get_antonyms();



=item B<get_section> (number => SECTION_NUMBER)

Given the section number, returns the corresponding Wiktionary::Parser::Section object.  Numbers correspond to the those in the table of contents shown on a mediawiki page.  

     my $section = $document->get_section(number => '1.2');

=item B<get_sections>

Returns a reference to a hash of Wiktionary::Parser::Section objects.  These provide access to the data for each section of the document.
The format of the hash is { $section_number => object }  e.g. {'1.2.1' => $obj}

=item B<get_sections> (title => STRING_OR_REGEX)

Given a string or regular expression, this will return an array of Section objects containing any sections that match the given title pattern.  

This returns a list containing section(s) with 'english' in the title (case insensitive)	 In most cases this will just return the 'English' section, in some cases you'll also get the 'Old English' section too.

     my $sections = $document->get_sections(title => 'english');

If you want to get only the "English" section, use this pattern:

     my $sections = $document->get_sections(title => '^english$');

This returns an array of all etymology, pronunciation, and synonym sections
     my $sections = $document->get_sections(title => 'etymology|pronunciation|synonyms');

=item B<get_language_section> (language => LANGUAGE_STRING)

Extract the document that corresponds only to that language, which must be described by a capitalized word such as English or Spanish. For instance

    my $section = $document->get_language_section(language => 'Spanish' );

returns a hash with the sections that have Spanish as a language.


=item B<get_sub_document> (title => STRING_OR_REGEX)

Given a string or regular expression, this will return a Wiktionary::Parser::Document object consisting of just the matching sections, and their child sections.  This can be used if you're just interested in certain parts of a document.


This returns a document object containing just the sections with 'english' in the title (case insensitive).  In most cases this will just return the 'English' section, in some cases you'll also get the 'Old English' section too.

     my $sub_document = $document->get_sub_document(title => 'english');

If you want to get only the "English" section, use this pattern:

     my $sub_document = $document->get_sub_document(title => '^english$');

     # To verify what sections you have, you can print out the table of contents for this sub document.  
     print Dumper $sub_document->get_table_of_contents();


=item B<get_part_of_speech_sections>

Returns an array of Wiktionary::Parser::Section objects representating all the sections on the page that cover a part of speech. This current includes all sections that match the following header:


     Parts of Speech used in Wiktionary include:
     
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


     my $sections = $document->get_part_of_speech_section();


=item B<get_translation_sections>

Returns an array of Wiktionary::Parser::Section objects consisting of all Translation sections in the document.

     my $sections = $document->get_translation_sections();


=item B<get_synonym_sections>

Returns an array of Wiktionary::Parser::Section objects consisting of all Synonym sections in the document.

     my $sections = $document->get_synonym_sections();


=item B<get_hyponym_sections>

Returns an array of Wiktionary::Parser::Section objects consisting of all Hyponym sections in the document.

     my $sections = $document->get_hyponym_sections();


=item B<get_hypernym_sections>

Returns an array of Wiktionary::Parser::Section objects consisting of all Hypernym sections in the document.

     my $sections = $document->get_hypernym_sections();


=item B<get_antonym_sections>

Returns an array of Wiktionary::Parser::Section objects consisting of all Antonym sections in the document.

     my $sections = $document->get_antonym_sections();

=item B<get_pronunciation_sections>

Returns an array of Wiktionary::Parser::Section objects consisting of all Pronunciation sections in the document.

     my $sections = $document->get_pronunciation_sections();




=item B<get_table_of_contents>

Returns an arrayref containing section numbers and names.  Mostly helpful for informational / debugging purposes when you need a summary of what's in your document object.

     my $table_of_contents = $document->get_table_of_contents();


     print Dumper $table_of_contents;

     $VAR1 = [
          '1,english',
          '1.1,etymology',
          '1.2,pronunciation',
          '1.2.1,usage notes',
          '1.3,noun',
          '1.3.1,derived terms',
          '1.3.2,translations',
          '1.4,adjective',
          '1.4.1,translations',
          ...
      ]

=item B<get_title>

Return the document title.  ( i.e. the argument you used in $parser->get_document(title => $title) )

=item B<get_categories>

Return an array of all categories this page falls under.  (These are usually the links that appear at the bottom of a wiki page)


=back

=head2 Methods for Wiktionary::Parser::Section

=over

=item B<get_content>

Returns an arrayref containing lines of text from the section of the document

=item B<get_header>

Returns the section heading name

=item B<get_section_number>

Returns the number of this section (e.g. 1.2.1)

=item B<get_parent_section>

Return the Wiktionary::Parser::Section instane of the parent section.  e.g. if you call this on section 1.2.1, it'll return the object for section 1.2

=item B<get_language>

Returns the language that this section falls under.  

=item B<get_part_of_speech>

Returns the part of speech that this section falls under.

=item B<get_ancestor_sections>

Return an arrayref containing all sections above this one in the hierarchy.  

=item B<get_child_document>

This returns a Wiktionary::Parser::Document object containing the current section and all its child sections.  

=item B<get_child_sections>

Returns an array of all sections below this one in the hierarchy

=back

=cut
