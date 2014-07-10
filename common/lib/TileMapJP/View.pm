package TileMapJP::View;
use strict;
use warnings;
use utf8;
use Carp ();
use File::Spec ();

use Text::Xslate 1.6001;
use JavaScript::Value::Escape;

# setup view class
sub make_instance {
    my ($class, $context) = @_;
    Carp::croak("Usage: OTM::View->make_instance(\$context_class)") if @_!=2;

    my $view_conf = $context->config->{'Text::Xslate'} || +{};
    unless (exists $view_conf->{path}) {
        $view_conf->{path} = [ File::Spec->catdir($context->base_dir(), 'tmpl'), File::Spec->catdir($context->base_dir(), 'common', 'tmpl') ];
    }
    my $view = Text::Xslate->new(+{
        'syntax'   => 'TTerse',
        'module'   => [ 'Text::Xslate::Bridge::Star' ],
        'function' => {
            c => sub { Amon2->context() },
            uri_with => sub { Amon2->context()->req->uri_with(@_) },
            uri_for  => sub { Amon2->context()->uri_for(@_) },
            static_file => do {
                my %static_file_cache;
                sub {
                    my $fname = shift;
                    my $c = Amon2->context;
                    if (not exists $static_file_cache{$fname}) {
                        my $fullpath = File::Spec->catfile($c->base_dir(), $fname);
                        $static_file_cache{$fname} = (stat $fullpath)[9];
                    }
                    return $c->uri_for($fname, { 't' => $static_file_cache{$fname} || 0 });
                }
            },
            js => \&JavaScript::Value::Escape::js,
        },
        ($context->debug_mode ? ( warn_handler => sub {
            Text::Xslate->print( # print method escape html automatically
                '[[', @_, ']]', 
            );
        } ) : () ),
        %$view_conf
    });
    return $view;
}

1;
