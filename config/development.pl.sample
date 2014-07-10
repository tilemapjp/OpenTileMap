use File::Spec;
use File::Basename qw(dirname);
#my $basedir = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
#my $dbpath = File::Spec->catfile($basedir, 'db', 'otmdevelop.db');
$dbpath = '<SqliteDbFilePath>';
my $conf = +{
    'DBD' => +{
        select => 'sqlite',
        pg => [
            "dbi:Pg:dbname=<PostgresDbName>;host=<PostgresHost>;", '<PostgresUser>', '<PostgresPassword>',
            +{
                AutoCommit=>1,
                RaiseError=>1,
                pg_utf8_strings=>1,
            }
        ],
        mysql => [
            "dbi:mysql:dbname=<MysqlDbName>", '<MysqlUser>', '<MysqlPassword>',
            +{
                AutoCommit=>1,
                RaiseError=>1,
                ShowErrorStatement=>1, 
                mysql_enable_utf8=>1,
                on_connect_do => [
                    "SET NAMES 'utf8'",
                    "SET CHARACTER SET 'utf8'"
                ],
            }
        ],
        sqlite => [
            "dbi:SQLite:dbname=$dbpath", '', '',
            +{
                sqlite_unicode => 1,
            }
        ],
    },
    'Auth' => +{
        Twitter => +{
            consumer_key    => '<TwitterConsumerKey>',
            consumer_secret => '<TwitterConsumerSecret>',
        },
        Facebook => {
            client_id       => '<FacebookClientId>', 
            client_secret   => '<FacebookClientSecret>',
            scope           => '', #http://developers.facebook.com/docs/reference/login/#permissions
        },
    },
};

$conf->{DBI} = $conf->{DBD}->{$conf->{DBD}->{select}};

$conf;
