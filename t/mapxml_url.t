use strict;
use warnings;
use utf8;
use Test::More;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '../lib');
use lib File::Spec->catdir(dirname(__FILE__), '../extlib');
use OTM::Model::MapXML;

my $xmld = OTM::Model::MapXML->new();

is ($xmld->check_tileurl(['http://ab.cd.ef/ghi','http://ab.cd2.ef/ghi']),'http://ab.{cd,cd2}.ef/ghi');
is ($xmld->check_tileurl(['http://a.cd.ef/ghi','http://b.cd.ef/ghi','http://a2.cd.ef/ghi']),'http://{a,b,a2}.cd.ef/ghi');

done_testing;
