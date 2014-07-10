package OTM;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
our $VERSION='0.01';
use 5.008001;

__PACKAGE__->load_plugin(qw/+TileMapJP::Amon2DBI/);
__PACKAGE__->load_plugin(qw/+TileMapJP::TengModel/);

# initialize database
use DBI;
sub setup_schema {
    my $self = shift;
    my $dir  = shift || '.';
    my $dbh = $self->dbh();
    my $driver_name = $dbh->{Driver}->{Name};
    my $fname = $dir . '/' . lc("sql/${driver_name}.sql");
#    my $fname = lc("sql/${driver_name}.sql");
    open my $fh, '<:encoding(UTF-8)', $fname or die "$fname: $!";
    my $source = do { local $/; <$fh> };
    for my $stmt (split /;;/, $source) {
        next unless $stmt =~ /\S/;
        $stmt .= ';';
        $dbh->do($stmt) or die $dbh->errstr();
    }
}

sub default_title { 'OpenTileMap' }

sub narrow_layout { 0 }

1;
