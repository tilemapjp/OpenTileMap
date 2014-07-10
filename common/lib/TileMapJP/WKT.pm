package TileMapJP::WKT;
use strict;
use warnings;
use utf8;
use base 'Exporter';
our @EXPORT = qw/latlng2wkt latlng2geomfromtext latlng2zoomindex spatialsearchcondition/;

use Math::Trig qw( tan pi );

my $ZOOM0_DIST = 56674632.1090732;
my $MERC_MAX   = 20037508.34278925;

sub latlng2wkt {
    my ($min_lat, $min_lng, $max_lat, $max_lng) = @_;
    my $wkt = '';

    if (!defined($max_lat)) {
        $wkt = 'POINT(' . $min_lng . ' ' . $min_lat . ')';
    } else {
        if ($min_lng > $max_lng) {
            $wkt = 'MULTIPOLYGON(((' .
                '-180.00 '     . $max_lat . ', ' .
                $max_lng . ' ' . $max_lat . ', ' .
                $max_lng . ' ' . $min_lat . ', ' .
                '-180.00 '     . $min_lat . ', ' .
                '-180.00 '     . $max_lat . ')), ((' .
                $min_lng . ' ' . $max_lat . ', ' .
                '180.00 '      . $max_lat . ', ' .
                '180.00 '      . $min_lat . ', ' .
                $min_lng . ' ' . $min_lat . ', ' .
                $min_lng . ' ' . $max_lat . ')))';
        } else {
            $wkt = 'POLYGON((' . 
                $min_lng . ' ' . $max_lat . ', ' .
                $max_lng . ' ' . $max_lat . ', ' .
                $max_lng . ' ' . $min_lat . ', ' .
                $min_lng . ' ' . $min_lat . ', ' .
                $min_lng . ' ' . $max_lat . '))';
        }
    }
    return $wkt;
}

sub latlng2geomfromtext {
    my ($min_lat, $min_lng, $max_lat, $max_lng, $is_pg, $srid) = @_;
    my $wkt = latlng2wkt(@_);
    $srid ||= 4326;

    return ($is_pg ? 'ST_' : '') . "GeomFromText('" . $wkt . "', $srid)";
}

sub latlng2zoomindex {
    my ($min_lat, $min_lng, $max_lat, $max_lng) = @_;

    #zoomIndexの計算
    my $minMercX     = $MERC_MAX * ($min_lng + 180) / 360;
    my $maxMercX     = $MERC_MAX * ($max_lng + 180) / 360;
    $maxMercX        += $MERC_MAX * 2 if ($min_lng > $max_lng);

    my $minMercY     = log(tan((90 + $min_lat) * pi() / 360)) / pi() * $MERC_MAX;
    my $maxMercY     = log(tan((90 + $max_lat) * pi() / 360)) / pi() * $MERC_MAX;

    my $map_dist     = sqrt(($maxMercY - $minMercY) ** 2 + ($maxMercX - $minMercX) ** 2);

    return log($ZOOM0_DIST / $map_dist) / log(2);
}

sub spatialsearchcondition {
    my ($geom, $geomcolumn, $geomtable, $driver) = @_;
    my $sql;
    if ($driver eq 'mysql') {
        $sql = 'MBRIntersects(' . $geom . ',' . $geomtable . '.' . $geomcolumn . ') AND ST_Intersects(' . $geom . ',' . $geomtable . '.' . $geomcolumn . ')';
    } elsif ($driver eq 'pg') {
        $sql = $geom . '&& ' . $geomtable . '.' . $geomcolumn . ' AND ST_Intersects(' . $geom . ',' . $geomtable . '.' . $geomcolumn . ')';
    } else {
        $sql = 'Intersects(' . $geom . ', ' . $geomtable . '.' . $geomcolumn . ') AND ' . $geomtable . '.ROWID IN (SELECT ROWID FROM SpatialIndex ' . 
            "WHERE f_table_name='" . $geomtable . "' AND search_frame=" . $geom . ')';
    }
    return $sql;
}

1;