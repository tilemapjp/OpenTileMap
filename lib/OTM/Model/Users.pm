package OTM::Model::Users;
use strict;
use warnings;
use utf8;
use parent 'TileMapJP::TengModel::Base';
#use Smart::Args;

sub fetch {
    my ($self, $user_id) = @_;

    my $row = $self->single({ user_id => $user_id });

    return $row;
}

sub fetch_by_site_or_create {
    my ( $self, $site, $site_id, $site_name ) = @_;

    my $row = $self->single({ site => $site, site_id => $site_id });

    if (!$row) {
        $row = $self->insert({ site => $site, site_id => $site_id, user_name => $site_name });
    }

    return $row;
}

sub update_name {
    my ( $self, $user_id, $user_name ) = @_;

    my $row = $self->update({ user_name => $user_name }, { user_id => $user_id } );

    return $row; 
}

1;