#! /usr/bin/env perl
#
# This example uses the get_pronunciations() method to print out
# structured data pulled from the pronunciation sections of a
# wiktionary page.  

use warnings;
use strict;
use Data::Dumper;

use Wiktionary::Parser;
use Encode qw(encode);

my $word = 'cat';
my $parser = Wiktionary::Parser->new();
my $document = $parser->get_document(title => $word);

my $pron = $document->get_pronunciations();

for my $language_code (sort keys %{ $pron || {} }) {

	my $pronunciation = $pron->{$language_code}{pronunciation};
	my $audio         = $pron->{$language_code}{audio};
	my $rhyme         = $pron->{$language_code}{rhyme};
	my $homophone     = $pron->{$language_code}{homophone};

	# not necessary related to pronunciation,
	# but present in this section on some page like 'forward'
	my $hyphenation = $pron->{$language_code}{hyphenation};

	my $language_name = $pron->{$language_code}{language};

	print "\n Language: $language_name, Code: $language_code\n";

	if ($pronunciation) {
		print "\n\t Pronunciations: \n";
		for my $representation (@$pronunciation) {
			printf(
				"\t\t%s: %s\n",
				$representation->get_representation(),
				join( 
					', ', 
					map {encode('utf8',$_)} @{ $representation->get_pronunciation() },
				)
			);
		}
	}


	# if there are audio files linked to these pronunciations
	# the audio objects provide methods for downloading the .ogg files
	if ($audio) {
		for my $aud (@$audio) {
			printf( "\n\t Audio Available: %s, File: %s\n", 
				$aud->get_text(),
				$aud->get_file(),	   
			);

			## 
			# uncomment this to download the .ogg files 
			# to the specified direcory on your local machine
			# $aud->download_file(directory => '/tmp/')
			#
		}

	}
}

