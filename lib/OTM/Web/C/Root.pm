package OTM::Web::C::Root;
use strict;
use warnings;
use utf8;

sub index {
    my ($class,$c,$router) = @_;

#    my @entries = @{$c->dbh->selectall_arrayref(
#        q{SELECT * FROM entry ORDER BY entry_id DESC LIMIT 10},
#        {Slice => {}}
#    )};
    return $c->render( "index.tt" => {} ); # entries => \@entries, } );
};

sub logout {
    my ($class,$c,$router) = @_;
    $c->session->expire();
    return $c->redirect('/');
};

1;
