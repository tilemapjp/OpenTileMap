package OTM::Model::MapXML;
use strict;
use warnings;
use utf8;
use LWP::Simple;
use XML::Simple;
use JSON::XS;
use Algorithm::Diff qw(sdiff);

$LWP::Simple::ua->agent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17');

sub new {
    my $class = shift;
    my $self  = bless +{}, $class;

    my ($table) = reverse split /::/, $class;
    $self->{table_name} = lc($table);

    return $self;
}

sub parse_content {
    my ($self, $xml_url) = @_;
    my $retval = 0;

    my $document;
    eval {
        $document = get($xml_url) or die "Cannot access $xml_url";
    };
    if ($@) {
        return $self->handle_error($@);
    }

    return $self->parse_xml($document, $xml_url);
}

sub parse_xml {
    my ($self, $document, $xml_url) = @_;
    
    my $parser   = XML::Simple->new(SuppressEmpty => ''); #, forcearray => 1);
    my $meta;
    eval {
        $meta = $parser->XMLin($document);
    };
    if ($@) {
        return $self->parse_json($document);
    }

    my $retval;
    eval {
        die 'This service can handle only TMS 1.0.0'
            if ($meta->{tilemapservice} ne 'http://tms.osgeo.org/1.0.0' || $meta->{version} ne '1.0.0');
        die 'This service can handle only EPSG:900913 or EPSG:3857 (Spherical Mercator)'
            if ($meta->{SRS} ne 'EPSG:900913' && $meta->{SRS} ne 'EPSG:3857');

        my $map_name    = $meta->{Title}         || '';
        my $description = $meta->{Abstract}      || '';
        my $min_lat     = $meta->{BoundingBox}->{minx};
        my $max_lat     = $meta->{BoundingBox}->{maxx};
        my $min_lng     = $meta->{BoundingBox}->{miny};
        my $max_lng     = $meta->{BoundingBox}->{maxy};
        my $ext         = $meta->{TileFormat}->{extension};
        my $min_zoom    = 20;
        my $max_zoom    = 0;
        my $map_url     = '';

        foreach my $zoom_setting (@{$meta->{TileSets}->{TileSet}}) {
            my $zoom = $zoom_setting->{order};
            if ($map_url eq '') {
                $map_url = $zoom_setting->{href};
                $map_url =~ s/\/${zoom}$/\/{z}\/{x}\/{y}.${ext}/;
            }
            if ($zoom > $max_zoom) { $max_zoom = $zoom; }
            if ($zoom < $min_zoom) { $min_zoom = $zoom; }
        } 

        if ($map_url !~ /^http/) {
            ($map_url) =  $xml_url =~ /^(.+\/)[^\/]+$/;
            $map_url   .= "{z}/{x}/{y}.${ext}";
        }

        $retval = {
            map_name    => $map_name,
            description => $description,
            min_lat     => $min_lat,
            max_lat     => $max_lat,
            min_lng     => $min_lng,
            max_lng     => $max_lng,
            min_zoom    => $min_zoom,
            max_zoom    => $max_zoom,
            map_url     => $map_url,
            is_tms      => 1
        };
    };
    if ($@) {
        return $self->handle_error($@);
    }
    return (1, $retval);
}

sub parse_json {
    my ($self, $document) = @_;
    
    my $meta;
    eval {
        $meta = decode_json($document);
    };
    if ($@) {
        return (0, 'This URL cannot parse as both resourcetile.xml and TileJSON formats.');
    }

    my $retval;
    eval {
        my $bounds = $meta->{bounds};

        my $map_name    = $meta->{name}          || '';
        my $description = $meta->{description}   || '';
        my $attribution = $meta->{attribution}   || '';
        my $min_lat     = $bounds->[1];
        my $max_lat     = $bounds->[3];
        my $min_lng     = $bounds->[0];
        my $max_lng     = $bounds->[2];
        my $min_zoom    = $meta->{minzoom}       || 0;
        my $max_zoom    = $meta->{maxzoom}       || 20;
        my $map_url     = $self->check_tileurl($meta->{tiles});
        my $is_tms      = ($meta->{scheme} eq 'tms') ? 1 : 0;

        $retval = {
            map_name    => $map_name,
            description => $description,
            attribution => $attribution,
            min_lat     => $min_lat,
            max_lat     => $max_lat,
            min_lng     => $min_lng,
            max_lng     => $max_lng,
            min_zoom    => $min_zoom,
            max_zoom    => $max_zoom,
            map_url     => $map_url,
            is_tms      => $is_tms
        };
    };
    if ($@) {
        return $self->handle_error($@);
    }
    return (1, $retval);
}

sub check_tileurl {
    my ($self, $tileurls) = @_;

    use Data::Dumper;warn Dumper($tileurls);

    if (@{$tileurls} < 2) {
        my $returl = @{$tileurls} == 0 ? '' : $tileurls->[0];
        return $returl;
    }

    my @src = split(//,$tileurls->[0]);
    my @dst = split(//,$tileurls->[1]);

    my @diff = sdiff(\@src, \@dst);
    my $before    = '';
    my $after     = '';
    my $domain1   = '';
    my $domain2   = '';
    my $phase     = 0;
    my $thisphase = '';

    foreach my $char (@diff) {
        if ($phase == 1) {
            if ($char->[0] eq 'u' && ($char->[1] eq '/' || $char->[1] eq '.')) {
                $phase = 2;
                $after = $char->[1];
            } else {
                $domain1 .= $char->[1];
                $domain2 .= $char->[2];
            }
        } elsif ($phase == 2) {
            if ($char->[0] ne 'u') {
                die 'Tile URLs are something wrong (too many different part, exactly same, not URL or so)';
            } else {
                $after .= $char->[1];
            }
        } else {
            if ($char->[0] ne 'u') {
                $phase = 1;
                $domain1 = $thisphase . $char->[1];
                $domain2 = $thisphase . $char->[2];

                $thisphase = '';
            } else {
                if ($char->[1] eq '/' || $char->[1] eq '.') {
                    $before .= $thisphase . $char->[1];
                    $thisphase = '';
                } else {
                    $thisphase .= $char->[1];
                }
            }
        }
    }

    if ($before eq '' || $after eq '') {
        die 'Tile URLs are something wrong (too many different part, exactly same, not URL or so)';
    }

    my @subsomains = ($domain1, $domain2);
    for (my $i=2;$i<@{$tileurls};$i++) {
        my $thisurl   = $tileurls->[$i];
        if (my ($thissub) =$thisurl =~ /^${before}(.+)${after}$/) {
            push @subsomains, $thissub;
        } else {
            die 'Tile URLs are something wrong (too many different part, exactly same, not URL or so)';
        }
    }

    my $retUrl = $before . '{' . join(',',@subsomains) . '}' . $after;

    return $retUrl;
}

sub handle_error {
    my ($self, $error) = @_;
    warn $error;
    chomp($error);
    $error =~ s/ at \/.+\.pm line \d+\.$//;

    return (0, $error);
}

1;
