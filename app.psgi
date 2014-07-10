use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use lib File::Spec->catdir(dirname(__FILE__), 'common/lib');
use Plack::Builder;

use OTM::Web;
use OTM;
use Plack::Session::Store::DBI;
use Plack::Session::State::Cookie;
use DBI;

#OTM->config->{DBI} = OTM->config->{DBD}->{OTM->config->{DBD}->{select}};
{
    my $c = OTM->new();
    $c->setup_schema(dirname(__FILE__));
}
my $db_config = OTM->config->{DBI} || die "Missing configuration for DBI";
builder {
    enable 'Plack::Middleware::Static',
        path => qr{^(?:/(?:common/)?static/)},
        root => File::Spec->catdir(dirname(__FILE__));
    enable 'Plack::Middleware::Static',
        path => qr{^(?:/robots\.txt|/favicon\.ico)$},
        root => File::Spec->catdir(dirname(__FILE__), 'static');
    enable 'Plack::Middleware::ReverseProxy';
    enable 'Plack::Middleware::Session',
        store => Plack::Session::Store::DBI->new(
            get_dbh => sub {
                DBI->connect( @$db_config )
                    or die $DBI::errstr;
            }
        ),
        state => Plack::Session::State::Cookie->new(
            httponly => 1,
        );
    enable 'Plack::Middleware::JSONP';
    enable 'Plack::Middleware::ErrorDocument', 
        404 => 'common/static/404.html', 
        500 => 'common/static/500/html', 
        502 => 'common/static/502/html', 
        503 => 'common/static/503/html', 
        504 => 'common/static/504/html';

    OTM::Web->to_app();
};
