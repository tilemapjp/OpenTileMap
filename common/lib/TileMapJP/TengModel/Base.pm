package TileMapJP::TengModel::Base;
use strict;
use warnings;
use utf8;
use TileMapJP::TengModel;

sub new {
    my $class = shift;
    my $self  = bless +{}, $class;

    my ($table) = reverse split /::/, $class;
    $self->{table_name} = lc($table);

    return $self;
}

sub db {
    return container('db');
}

sub is_pg {
    my $self = shift;
    $self->db->dbh->{Driver}->{Name} =~ /pg/i ? 1 : 0;
}

sub is_mysql {
    my $self = shift;
    $self->db->dbh->{Driver}->{Name} =~ /mysql/i ? 1 : 0;
}

sub is_sqlite {
    my $self = shift;
    $self->db->dbh->{Driver}->{Name} =~ /sqlite/i ? 1 : 0;
}

sub dbdriver {
    my $self = shift;
    return $self->is_mysql ? 'mysql' : $self->is_pg ? 'pg' : 'sqlite';
}

sub single {
    my $self = shift;
    return $self->db->single($self->{table_name},@_);
}

sub search {
    my $self = shift;
    return $self->db->search($self->{table_name},@_);
}

sub search_with_pager {
    my $self = shift;
    return $self->db->search_with_pager($self->{table_name},@_);
}

sub partial_single {
    my $self = shift;
    return $self->db->partial_single($self->{table_name},@_);
}

sub partial_search {
    my $self = shift;
    return $self->db->partial_search($self->{table_name},@_);
}

sub partial_search_with_pager {
    my $self = shift;
    return $self->db->partial_search_with_pager($self->{table_name},@_);
}

sub insert {
    my $self = shift;
    return $self->db->insert($self->{table_name},@_);
}

sub update {
    my $self = shift;
    return $self->db->update($self->{table_name},@_);
}

sub delete {
    my $self = shift;
    return $self->db->delete($self->{table_name},@_);
}


1;
