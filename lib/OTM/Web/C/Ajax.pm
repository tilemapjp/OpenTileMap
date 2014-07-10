package OTM::Web::C::Ajax;
use strict;
use warnings;
use utf8;

use Aspect;
use JSON;

#around {
before {
    my ($class,$c,$router) = $_->args;

    if ($c->req->env->{'REQUEST_METHOD'} ne 'POST') {
        warn "########################" . $c->{env}->{'REQUEST_METHOD'};
        $_->return_value($c->res_403());
        return;
    }
} call qr/Ajax::(?:account|addmap|deletemap)$/;

#    $_->proceed;

after {
    my ($class,$c,$router) = $_->args;
    my $ret = $_->return_value();
    # mysql5.6で、数値を文字列として返すようになってしまったのでワークアラウンド
    use Devel::Peek;
    if (defined($ret->{maps})) {
        foreach my $emap (@{$ret->{maps}}) {
            for my $numkey (qw/min_lat max_lat min_lng max_lng min_zoom max_zoom min_year max_year zoom_index/) {
                if (defined($emap->{$numkey})){
                    warn "$numkey: origin\n" . Dump( $emap->{$numkey} );
                    warn "$numkey: + 0.0\n" . Dump( $emap->{$numkey} += 0.0 );
                }
            }
        }
    }

    $_->return_value($c->render_json($ret));
} call qr/Ajax::(?:account|parsexml|addmap|getmap|listmaps|deletemap)$/;

sub account {
    my ($class,$c,$router) = @_;

    my $new_acc = $c->req->param('user_name');
    my $user_id = $c->user_id;
    my $result  = JSON::true;

    eval {
        my $db = $c->model('Users');
        $db->update_name($user_id,$new_acc);
        $c->session->set('user_name' => $new_acc);
    };
    if ($@) {
        warn $new_acc;
        warn $user_id;
        warn $@;
        $result = JSON::false;
    }

    return {
        result    => $result,
        user_name => $c->user_name(),
    };
};

sub parsexml {
    my ($class,$c,$router) = @_;

    my $xml_url = $c->req->param('xml_url');
    my $user_id = $c->user_id;

    my ($result, $retval) = $c->model('MapXML')->parse_content($xml_url);

    if ($result) {
        return {
            result  => JSON::true,
            meta    => $retval,
        };
    } else {
        return {
            result  => JSON::false,
            message => $retval,
        };
    }
};

sub addmap {
    my ($class,$c,$router) = @_;
    my $req = $c->req;

    my $args = {user_id => $c->user_id};
    foreach my $key (qw/map_id map_name map_url description attribution is_tms min_lat min_lng max_lat max_lng min_zoom max_zoom min_year max_year xml_url/) {
        $args->{$key} = $req->param($key);
    }

    my $db = $c->model('Tilemaps');
    my $result = $db->add_map($args);

    return {
        result  => $result ? JSON::true : JSON::false,
    };
}

sub listmaps {
    my ($class,$c,$router) = @_;
    my ($min_lat, $max_lat, $min_lng, $max_lng, $page);
    if (defined($c->req->param('min_lat')) && defined($c->req->param('min_lng'))) {
        $min_lat = $c->req->param('min_lat');
        $max_lat = $c->req->param('max_lat');
        $min_lng = $c->req->param('min_lng');
        $max_lng = $c->req->param('max_lng');
    } elsif (defined($c->req->param('lat')) && defined($c->req->param('lng'))) {
        $min_lat = $c->req->param('lat');
        $min_lng = $c->req->param('lng');
    } elsif (defined($c->req->param('page'))) {
        $page    = $c->req->param('page');
    }
    my $user_id = $c->user_id;
    my $zoom;
    if (defined($c->req->param('zoom'))) {
        $zoom = $c->req->param('zoom');
    }

    my $db = $c->model('Tilemaps');
    my ($result, $pager);
    if (defined($page)) {
        my $back = $db->search_map_with_pager($user_id,10,$page);
        $result    = $back->[0];
        my $pagero = $back->[1];
        $pager = +{ map { $_ => $pagero->$_; } qw/has_next entries_per_page current_page entries_on_this_page next_page prev_page first last/ };
    } else {
        $result = $db->search_map_from_geometry({
            min_lat => $min_lat,
            min_lng => $min_lng, 
            max_lat => $max_lat, 
            max_lng => $max_lng,
            zoom    => $zoom
        });
    }
    $result = [
        map { $_->{row_data} } @{$result}
    ];

    my $ret = {
        result  => JSON::true,
        maps    => $result
    };
    $ret->{pager} = $pager if ($pager);

    return $ret;
}

sub getmap {
    my ($class,$c,$router) = @_;

    my $map_id  = $c->req->param('map_id');    
    my $user_id = $c->user_id;

    my $db = $c->model('Tilemaps');
    my $map = $db->fetch_by_map_and_user($map_id, $user_id);

    my  $result = {
        result => JSON::true
    };

    if ( !$map ) {
        $result->{result} = JSON::false;
    } else {
        $result->{map}    = $map->{row_data};
    }

    return $result;
}

sub deletemap {
    my ($class,$c,$router) = @_;

    my $map_id  = $c->req->param('map_id');    
    my $user_id = $c->user_id;

    my $db = $c->model('Tilemaps');
    my $count = $db->delete_map({
        map_id  => $map_id, 
        user_id => $user_id
    });

    my  $result = {
        result => $count ? JSON::true : JSON::false
    };

    return $result;
}

1;

