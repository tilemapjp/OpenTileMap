package OTM::Web;
use strict;
use warnings;
use utf8;
use parent qw/OTM Amon2::Web/;
use File::Spec;

# dispatcher
use OTM::Web::Dispatcher;
sub dispatch {
    return (OTM::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# load plugins
__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
    'Web::CSRFDefender',
    'Web::JSON',
);
__PACKAGE__->load_plugin(
    'Web::Auth',
    {
        module      => 'Twitter',
        on_finished => sub {
            my ( $c, $access_token, $access_token_secret, $user_id, $screen_name ) = @_;
            $c->session->set( 'site'      => 'twitter');
            $c->session->set( 'site_id'   => $user_id );
            $c->session->set( 'site_name' => '@'.$screen_name );
            $c->session->set( 'token'     => $access_token );
            return $c->redirect('/');
        }
    }
);
__PACKAGE__->load_plugin(
    'Web::Auth',
    {
        module => 'Facebook',
        on_finished => sub {
            my ($c, $token, $user) = @_;
            my $name = $user->{username} || $user->{name} || die;
            $c->session->set( 'site'      => 'facebook' );
            $c->session->set( 'site_id'   => $user->{id} );
            $c->session->set( 'site_name' => $name );
            $c->session->set( 'token'     => $token );
            return $c->redirect('/');
        },
    }
);

sub user_id   { $_[0]->session->get('user_id') }
sub user_name { $_[0]->session->get('user_name') }
sub site      { $_[0]->session->get('site') }
sub site_id   { $_[0]->session->get('site_id') }
sub site_name { $_[0]->session->get('site_name') }
sub token     { $_[0]->session->get('token') }

sub res_403 {
    my ($self) = @_;
    my $content = <<'...';
<!doctype html>
<html>
    <head>
        <meta charset=utf-8 />
        <style type="text/css">
            body {
                text-align: center;
                font-family: 'Menlo', 'Monaco', Courier, monospace;
                background-color: whitesmoke;
                padding-top: 10%;
            }
            .number {
                font-size: 800%;
                font-weight: bold;
                margin-bottom: 40px;
            }
            .message {
                font-size: 400%;
            }
        </style>
    </head>
    <body>
        <div class="number">403</div>
        <div class="message">Forbidden</div>
    </body>
</html>
...
    $self->create_response(
        403,
        [
            'Content-Type' => 'text/html; charset=utf-8',
            'Content-Length' => length($content),
        ],
        [$content]
    );
}

# setup view
use OTM::Web::View;
{
    my $view = OTM::Web::View->make_instance(__PACKAGE__);
    sub create_view { $view }
}

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;

        # http://blogs.msdn.com/b/ie/archive/2008/07/02/ie8-security-part-v-comprehensive-protection.aspx
        $res->header( 'X-Content-Type-Options' => 'nosniff' );

        # http://blog.mozilla.com/security/2010/09/08/x-frame-options/
        $res->header( 'X-Frame-Options' => 'DENY' );

        # Cache control.
        $res->header( 'Cache-Control' => 'private' );
    },
);

__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
        my ( $c ) = @_;
        my $dbh = $c->dbh();

        if ( $c->site && $c->site_id ) {
            my $usr = $c->model('Users')->fetch_by_site_or_create( $c->site, $c->site_id, $c->site_name );

            if ( $usr ) {
                $c->session->set( 'user_id'   => $usr->user_id );
                $c->session->set( 'user_name' => $usr->user_name );
            } else {
                die 'Cannot find and create user!';
            }
        }        

        return;
    },
);

1;
