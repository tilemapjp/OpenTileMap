use strict;
use warnings;
use utf8;
use Test::More;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '../lib');
use lib File::Spec->catdir(dirname(__FILE__), '../extlib');

use_ok 'OTM';
use_ok 'OTM::Web';
use_ok 'OTM::Web::Dispatcher';

done_testing;
