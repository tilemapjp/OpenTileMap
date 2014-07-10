package OTM::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use TileMapJP::Dispatcher;

use OTM::Web::C::Root;
use OTM::Web::C::Ajax;

connect '/'             => 'Root#index';
connect '/:action'      => 'Root';
connect '/ajax/:action' => 'Ajax';

#post '/post' => sub {
#    my ($c) = @_;
#
#    if (my $body = $c->req->param('body')) {
#        $c->dbh->insert(entry => +{
#            body => $body,
#        });
#    }
#    return $c->redirect('/');
#};

#any '/' => sub {
#    my ($c) = @_;
#    return $c->render('index.tt');
#};

1;
