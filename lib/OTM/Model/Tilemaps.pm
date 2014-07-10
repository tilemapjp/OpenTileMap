package OTM::Model::Tilemaps;
use strict;
use warnings;
use utf8;
use parent 'TileMapJP::TengModel::Base';
#use Smart::Args;
use TileMapJP::WKT;
use Scalar::Util 'looks_like_number'; 
#use DBIx::QueryLog;

sub fetch_by_map_and_user {
    my ($self, $map_id, $user_id) = @_;

    my $row = $self->partial_single(
        ['map_id', 'user_id', 'map_name', 'map_url', 'description', 'attribution', 'is_tms', 'min_lat', 'min_lng', 'max_lat', 'max_lng', 'min_year', 'max_year', 'era_name', 'min_zoom', 'max_zoom', 'xml_url'],
        { map_id => $map_id, user_id => $user_id }
    );

    return $row;
}

sub search_map_with_pager {
    my ($self, $user_id, $perpage, $page) = @_;
    $perpage ||= 10;
    $page    ||= 1;

    my ($rows, $pager) = $self->partial_search_with_pager(
        ['map_id', 'user_id', 'map_name', 'map_url', 'description', 'attribution', 'is_tms', 'min_lat', 'min_lng', 'max_lat', 'max_lng', 'min_year', 'max_year', 'era_name', 'min_zoom', 'max_zoom', 'xml_url'],
        {'user_id' => $user_id}, 
        {'page'=>$page,'rows'=>$perpage}
    );
    #use Data::Dumper; warn Dumper($rows); warn Dumper($pager);
    return [$rows, $pager];
}

sub search_map_from_geometry {
    my ($self, $args) = @_;
    my ($user_id, $min_lat, $min_lng, $max_lat, $max_lng, $zoom) = map { $args->{$_} } qw/user_id min_lat min_lng max_lat max_lng zoom/;

    my $gsql;
    if (defined($min_lat)) {
        my $polygon = latlng2geomfromtext($min_lat, $min_lng, $max_lat, $max_lng, $self->is_pg);
        $gsql = spatialsearchcondition($polygon, 'geoms', 'mapgeoms', $self->dbdriver);
    }

    my $cond = SQL::Maker::Condition->new(
        name_sep   => $self->db->sql_builder->name_sep,
        quote_char => $self->db->sql_builder->quote_char,
    );

    if (defined($user_id)) {
        $cond->add('user_id' => $user_id);
    }
    if ($gsql) {
        $gsql = 'mapgeom_id IN (SELECT geom_id FROM mapgeoms WHERE ' . $gsql . ')';
        $cond->add_raw($gsql);
    }
    if (defined($zoom)) {
        $cond->add('max_zoom' => { '>=' => $zoom });
#        $cond->add('min_zoom' => { '<=' => $zoom });
    }

    my @row_arr = $self->partial_search(
        ['map_id', 'user_id', 'map_name', 'map_url', 'description', 'attribution', 'is_tms', 'min_lat', 'min_lng', 'max_lat', 'max_lng', 'min_year', 'max_year', 'era_name', 'min_zoom', 'max_zoom', 'xml_url', 'zoom_index'],
        $cond,
        { order_by => 'zoom_index DESC' }
    );

    return \@row_arr;
    #mysql   MBRIntersects($polygon,mapbounds) AND Intersects($polygon,mapbounds)
    #postgis $polygon && mapbounds AND ST_Intersects($polygon,mapbounds);
    #sqlite  ST_Intersects($polygon, mapbounds) AND ROWID IN (SELECT ROWID FROM SpatialIndex WHERE f_table_name='tilemaps' AND search_frame=$polygon)
}

sub delete_map {
    my ( $self, $args ) = @_;
    my ( $user_id, $map_id ) = map { $args->{$_} } qw/user_id map_id/;

    eval {
        my $txn = $self->db->txn_scope;

        my ($geom_id, $era_id);

        # 関連POLYGON削除判断
        if ($map_id) {
            my $row = $self->partial_single(
                ['mapgeom_id', 'mapera_id'],
                { map_id => $map_id, user_id => $user_id }
            );
            die 'No map found as such map_id' if (!$row);
            $geom_id = $row->mapgeom_id;
            $era_id  = $row->mapera_id;
        } else {
            die 'In delete operation, map_id must be set';
        }

        $self->db->delete('mapgeoms',{geom_id=>$geom_id,geom_type=>'each'});
        if ($era_id) {
            $self->db->delete('maperas',{era_id=>$era_id,era_type=>'each'});
        }

        $self->delete({
            user_id      => $user_id,
            map_id       => $map_id
        });

        $txn->commit;
    };
    if ($@) {
        warn $@;
        return 0;
    } else {
        return 1;
    }
}

sub add_map {
    my ( $self, $args ) = @_;
    my ( $user_id, $map_id, $map_name, $map_url, $description, $attribution, $is_tms, 
            $min_lat, $min_lng, $max_lat, $max_lng, $min_year, $max_year, $min_zoom, $max_zoom, $xml_url) = 
        map { $args->{$_} } qw/user_id map_id map_name map_url description attribution is_tms 
            min_lat min_lng max_lat max_lng min_year max_year min_zoom max_zoom xml_url/;

    if (!looks_like_number($min_year)) {
        $min_year = undef;
        $max_year = undef;
    } 
    if (!looks_like_number($max_year)) {
        $max_year = undef;
    }

    # zoomIndexの計算
    my $zoom_index = latlng2zoomindex($min_lat, $min_lng, $max_lat, $max_lng);

    # 空間POLYGON作成
    my $polygon = latlng2geomfromtext($min_lat, $min_lng, $max_lat, $max_lng, $self->is_pg);

    # 時間POLYGON作成
    my $timegon;
    if (defined($min_year)) {
        if (!defined($max_year)) { $max_year = $min_year }
        my $timegon = latlng2geomfromtext(-1000, $min_year, 1000, $max_year + 1, $self->is_pg, -1);
    }

    my $result;
    eval {
        my $txn = $self->db->txn_scope;

        my ($geom_id, $era_id);

        # INSERT OR UPDATE 判断
        if ($map_id) {
            my $row = $self->partial_single(
                ['mapgeom_id', 'mapera_id'],
                { map_id => $map_id, user_id => $user_id }
            );
            die 'No map found as such map_id' if (!$row);
            $geom_id = $row->mapgeom_id;
            $era_id  = $row->mapera_id;
        }

        # 空間POLYGON処理
        my $gset = {
            geoms     => \$polygon,
            geom_type => 'each',
            geom_name => $map_name
        };

        if ($geom_id) {
            $self->db->update('mapgeoms',$gset,{geom_id=>$geom_id});
        } else {
            my $grow = $self->db->insert('mapgeoms',$gset);
            $geom_id = $grow->geom_id;
        }

        # 時間POLYGON処理
        if ($timegon) {
            my $tset = {
                eras     => \$timegon,
                era_type => 'each',
                era_name => $map_name
            };

            if ($era_id) {
                $self->db->update('maperas',$tset,{era_id=>$era_id});
            } else {
                my $trow = $self->db->insert('maperas',$tset);
                $era_id = $trow->era_id;
            }
        } elsif ($era_id) {
            $self->db->delete('maperas',{era_id=>$era_id,era_type=>'each'});
            $era_id = undef;
        }

        my $set = {
            map_name     => $map_name,
            map_url      => $map_url,
            description  => $description,
            attribution  => $attribution,
            is_tms       => $is_tms,
            min_lat      => $min_lat,
            min_lng      => $min_lng,
            max_lat      => $max_lat,
            max_lng      => $max_lng,
            min_year     => $min_year,
            max_year     => $max_year,
            min_zoom     => $min_zoom,
            max_zoom     => $max_zoom,
            zoom_index   => $zoom_index,
            xml_url      => $xml_url,
            nontms_logic => '',
            mapgeom_id   => $geom_id,
            mapera_id    => $era_id
        };
        my $cond = {};

        if ($map_id) {
            $result = $self->update($set,{
                user_id      => $user_id,
                map_id       => $map_id
            });
        } else {
            $set->{user_id}  =  $user_id;
            $result = $self->insert($set);
        }

        $txn->commit;
    };
    if ($@) {
        warn $@;
        $result = 0;
    }

    return $result;
}

1;