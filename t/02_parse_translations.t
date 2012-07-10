#! /usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

use Test::More;
use Wiktionary::Parser::Section::Translations;
use Wiktionary::Parser::Document;

my @first = (
	'{{trans-top|fruit}}',
);

my @lines = (
 	{
 	 input => '* Swedish: {{t+|sv|apelsin|c}}',
 	 output => \&result_sv,
 	},
	{
	 input => '* Persian: {{t+|fa|نارنج|tr=nâranj|xs=Persian}}, {{t+|fa|پرتقال|tr=porteghâl|xs=Persian}}',
	 output => \&result_fa,
	},
	{
	 input => '* Slovene: [[oranževec]] {{m}}',
	 output => \&result_sl,
	},
	{
	 input => "* Arabic: {{t|ar|برتقالة|f|tr=burtuqaala|sc=Arab}}, {{qualifier|collective}} {{t|ar|برتقال|m|tr=burtuqaal|sc=Arab}}",
	 output => \&result_ar,
	},
	{ 
	 input => "*: Egyptian Arabic: {{tø|arz|برتقان|tr=burtuʕaan|sc=Arab|xs=Egyptian Arabic}} ''(collective)''",
	 output => \&result_arz,
	},
	{
	 input  => '* Chinese:',
	 output => \&result_zh,
	},
	{
	 input => '*: Mandarin: {{t-|cmn|橙|tr=chéng|sc=Hani}}, {{t|cmn|橙子|tr=chéngzi|sc=Hani}}, {{qualifier|technically "tangerine", but often used as "orange"}} {{t-|cmn|橘子|tr=júzi|sc=Hani}}, {{qualifier|alternative form:}} {{t|cmn|桔子|tr=júzi|sc=Hani}}',
	 output => \&result_cmn,
	},
	{
	 input => '* Kurdish: {{t+|ku|pirteqal}}, {{ku-Arab|[[پرته‌قاڵ]]}',
	 output => \&result_ku,
	},
	{
	 input => '* Scottish Gaelic: [[òr-mheas]] {{m}}, {{t-|gd|oraindsear|m|xs=Scottish Gaelic}}',
	 output => \&result_gd,
	},
	{
	 input => '* Sindhi: {{sd-Arab|[[نارنگِي]]}} (narangi) {{f}',
	 output => \&result_sd,	 
	},
	{
	 input => '* Spanish: {{t+|es|naranja|f}}, {{t+|es|china|f}} {{qualifier|Dominican Republic|Puerto Rico}}',
	 output => \&result_es,
	},
	{
	 input => '* Tetum: [[sabraka]]',
	 output => \&result_tet,
	},
	{
	 input => '* Vietnamese: ([[quả]] / [[trái]]) {{t+|vi|cam|xs=Vietnamese}}',
	 output => \&result_vi,
	},
	{
	 input => '* Vietnamese: [[màu]] ([[da]]) [[cam]]',
	 output => \&result_vi2,
	},
	{
	 input => '* Sardinian: [[colore de aranzu]], [[ruggiu]], [[ruiu]], [[arrubiu]]',
	 output => \&result_sc,
	},
	{ 
	 input => '* Irish: [[dath oráiste]] {{m}}, {{t|ga|oráiste}}',
	 output => \&result_ga, 
	}
);

for my $hr (@lines) {
	my $section = Wiktionary::Parser::Section::Translations->new(
		section_number => '1.1',
		header => 'translations',
	);

	for my $_line (@first,$hr->{input}) {
		$section->add_content($_line);
	}

	my $document = Wiktionary::Parser::Document->new(
		sections => [$section],
	);

#	print Dumper $document->get_translations();
#	print Dumper $hr->{output}->();
	unless(is_deeply(
		$document->get_translations(),
		$hr->{output}->(),
		"parsed $hr->{input}",
	)) {
		print Dumper $document->get_translations();
	}
}



sub result_sv {
    return {
        'fruit' => {
            'sv' => {
                'language'     => 'Swedish',
                'translations' => [ 'apelsin' ]
            }
        }
    };
}

sub result_fa {
    return {
        'fruit' => {
            'fa' => {
                'language'     => 'Persian',
                'translations' => [ 'نارنج', 'پرتقال' ]
            }
        }
    };
}

sub result_sl {
    return {
        'fruit' => {
            'sl' => {
                'language'     => 'Slovenian',
                'translations' => ['oranževec'],
            }
        }
    };
}

sub result_ar {
    return {
        'fruit' => {
            'ar' => {
                'language' => 'Arabic',
                'translations' => [ 'برتقالة', 'برتقال' ]
            }
        }
    };
}

sub result_arz {
    return {
        'fruit' => {
            'arz' => {
                'language'     => 'Egyptian Arabic',
                'translations' => [ 'برتقان' ]
            }
        }
    };
}

sub result_zh {
    return {};
}

sub result_cmn {
    return {
        'fruit' => {
            'cmn' => {
                'language'     => 'Mandarin Chinese',
                'translations' => [
                    '橙', '橙子',
                    '橘子', '桔子'
                ]
            }
        }
    };
}

sub result_ku {
    return {
        'fruit' => {
            'ku' => {
                'language'     => 'Kurdish',
                'translations' => [ 'pirteqal', 'پرته‌قاڵ' ]
            }
        }
    };
}

sub result_gd {
    return {
        'fruit' => {
            'gd' => {
                'language'     => 'Gaelic',
                'translations' => [ 'oraindsear', 'òr-mheas' ]
            }
        }
    };
}

sub result_sd {
    return {
        'fruit' => {
            'sd' => {
                'language'     => 'Sindhi',
                'translations' => [ 'نارنگِي', 'narangi' ]
            }
        }
    };
}

sub result_es {
    return {
        'fruit' => {
            'es' => {
                'language'     => 'Spanish',
                'translations' => [ 'naranja','china']
            }
        }
    };
}

sub result_tet {
    return {
        'fruit' => {
            'tet' => {
                'language'     => 'Tetum',
                'translations' => [ 'sabraka' ]
            }
        }
    };
}

sub result_vi {
    return {
        'fruit' => {
            'vi' => {
                'language'     => 'Vietnamese',
                'translations' => [ 'cam', 'quả', 'trái' ]
            }
        }
    };
}

sub result_vi2 {
    return {
        'fruit' => {
            'vi' => {
                'language'     => 'Vietnamese',
                'translations' => [ 'da', 'màu', 'cam' ]
            }
        }
    };
}

sub result_sc {
    return {
        'fruit' => {
            'sc' => {
                'language' => 'Sardinian',
                'translations' =>
                  [ 'colore de aranzu', 'ruggiu', 'ruiu', 'arrubiu' ]
            }
        }
    };

}

sub result_ga {
    return {
        'fruit' => {
            'ga' => {
                'language'     => 'Irish',
                'translations' => [ 'oráiste', 'dath oráiste' ]
            }
        }
    };
}
