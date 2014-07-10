package TileMapJP::TengModel::Teng;
use parent 'Teng';
use Smart::Args;

__PACKAGE__->load_plugin('Count');
__PACKAGE__->load_plugin('FindOrCreate');
__PACKAGE__->load_plugin('Pager');
__PACKAGE__->load_plugin('SQLPager');

{
    no warnings 'redefine';
    # DBIx::Inspectorのtablesが空間検索用テーブル等も返すので抑止
    *DBIx::Inspector::Driver::SQLite::tables = sub {
        if (wantarray) {
            my @arr = DBIx::Inspector::Driver::Base::tables(@_);

            return grep { $_->{'TABLE_NAME'} !~ /(?:^sqlite_sequence$|^sql_statements_log$|^SpatialIndex$|^virts_geometry_columns|^views_geometry_columns|^spatial_ref_sys$|^spatialite_history$|^idx_|^geometry_columns)/ } @arr;
        } else {
            return DBIx::Inspector::Driver::Base::tables(@_);
        }
    };
    # selectで別名やsql関数指定可能に
    *SQL::Maker::new_select = sub {
        my $self = shift;
        my %args = @_==1 ? %{$_[0]} : @_;
        my @select;
        my $s_map = $args{'select_map'}         = +{};
        my $r_map = $args{'select_map_reverse'} = +{};
        foreach my $arg (@{$args{select}}) {
            if (ref $arg eq 'HASH') {
                foreach my $key (keys %{$arg}) {
                    $s_map->{$key}         = $arg->{$key};
                    $r_map->{$arg->{$key}} = $key;
                    push @select, $key;
                }
            } else {
                push @select, $arg;
            }
        }
        $args{select} = \@select;
    
        return $self->select_class->new(
            name_sep   => $self->name_sep,
            quote_char => $self->quote_char,
            new_line   => $self->new_line,
            %args,
        );
    };
}

# 一部読み込み系メソッド
sub partial_single {
    my ($self, $table_name, $select, $where, $opt) = @_;
    $opt->{limit} = 1;
    $self->partial_search($table_name, $select, $where, $opt)->next;
}

sub partial_search {
    my ($self, $table_name, $select, $where, $opt) = @_;
    
    my $table = $self->schema->get_table( $table_name );
    if (! $table) {
        Carp::croak("No such table $table_name");
    }
    
    my ($sql, @binds) = $self->sql_builder->select(
        $table_name,
        $select,
        $where,
        $opt
    );
    
    $self->search_by_sql($sql, \@binds, $table_name);
}

sub partial_search_with_pager {
    my ($self, $table_name, $select, $where, $opt) = @_;

    my $table = $self->schema->get_table($table_name) or Carp::croak("'$table_name' is unknown table");

    my $page = $opt->{page};
    my $rows = $opt->{rows};
    for (qw/page rows/) {
        Carp::croak("missing mandatory parameter: $_") unless exists $opt->{$_};
    }

    my ($sql, @binds) = $self->sql_builder->select(
        $table_name,
        $select,
        $where,
        +{
            %$opt,
            limit => $rows + 1,
            offset => $rows*($page-1),
        }
    );

    my $sth = $self->dbh->prepare($sql) or Carp::croak $self->dbh->errstr;
    $sth->execute(@binds) or Carp::croak $self->dbh->errstr;

    my $ret = [ Teng::Iterator->new(
        teng             => $self,
        sth              => $sth,
        sql              => $sql,
        row_class        => $self->schema->get_row_class($table_name),
        table            => $table,
        table_name       => $table_name,
        suppress_object_creation => $self->suppress_row_objects,
    )->all];

    my $has_next = ( $rows + 1 == scalar(@$ret) ) ? 1 : 0;
    if ($has_next) { pop @$ret }

    my $pager = Data::Page::NoTotalEntries->new(
        entries_per_page     => $rows,
        current_page         => $page,
        has_next             => $has_next,
        entries_on_this_page => scalar(@$ret),
    );

    return ($ret, $pager);
}

# TengでPgのlast_insert_idがおかしい
sub _last_insert_id {
    if ($_[0]->{driver_name} eq 'Pg') {
        return $_[0]->dbh->last_insert_id( undef, undef, $_[1], undef );
    } else {
        return Teng::_last_insert_id(@_);
    }
}

1;