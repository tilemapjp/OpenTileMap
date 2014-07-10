package TileMapJP::TengModel;
use strict;
use warnings;
use Object::Container::Exporter -base;
use Amon2::Declare;
use Teng::Schema::Loader;
use TileMapJP::TengModel::Teng;

our $ModelNameSpace = '';

sub init {
    my ($class, $context_class, $config) = @_;

    no strict 'refs';
    *{"$context_class\::container"} = \&_container;
    *{"$context_class\::model"}     = \&_model;

    $ModelNameSpace = "$context_class\::Model";

    register_namespace model  => $ModelNameSpace;
}

sub _container { TileMapJP::TengModel->instance->get($_[1]) }
sub _model { TileMapJP::TengModel->instance->{_register_namespace}->{model}->($_[1]) }
sub _db {
    my $self = shift;
    #$self->load_class($ModelNameSpace);
    TileMapJP::TengModel->_loader(c()->config->{'DBI'});
}
sub _loader {
    my ($self, $connect_info) = @_;

    my $dbh = c()->dbh();

    my $teng = Teng::Schema::Loader->load(
        dbh       => $dbh,
        namespace => $ModelNameSpace,
    );
    #use Data::Dumper;warn(Dumper($teng));
    no strict 'refs'; @{"$ModelNameSpace\::ISA"} = ('TileMapJP::TengModel::Teng');
    return $teng;
}

register_default_container_name 'container';

register db => sub {
    return TileMapJP::TengModel->_db();
};

1;
