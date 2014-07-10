package TileMapJP::Amon2DBI;
use strict;
use warnings;

sub init {
    my ($class, $context_class, $config) = @_;

    no strict 'refs';
    *{"$context_class\::dbh"} = \&_dbh;
}

sub _dbh {
    my ($self) = @_;

    if ( !defined $self->{dbh} ) {
        my $conf = $self->config->{'DBI'}
            or die "missing configuration for 'DBI'";
        $self->{dbh} = TileMapJP::Amon2DBI::DB->connect(@$conf);
    }
    return $self->{dbh};
}

package TileMapJP::Amon2DBI::DB;

use parent 'Amon2::DBI';

sub connect {
    my $dbh = shift->SUPER::connect(@_);
    if ($dbh && $dbh->{Driver}->{Name} =~ /sqlite/i) {
        $dbh->sqlite_enable_load_extension(1);
        eval {
            my $sth = $dbh->prepare("select load_extension('libspatialite.so')");
            $sth->execute();
        };
        if ($@) {
            # テスト環境（MacOSX）
            my $sth = $dbh->prepare("select load_extension('libspatialite.dylib')");
            $sth->execute();
        }
    }
    return $dbh;
}

package TileMapJP::Amon2DBI::DB::dr;
our @ISA = qw(Amon2::DBI::dr);

package TileMapJP::Amon2DBI::DB::db; # database handler
our @ISA = qw(Amon2::DBI::db);

package TileMapJP::Amon2DBI::DB::st; # statement handler
our @ISA = qw(Amon2::DBI::st);




1;