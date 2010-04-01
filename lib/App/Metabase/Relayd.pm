package App::Metabase::Relayd;

use strict;
use warnings;
use Pod::Usage;
use Config::Tiny;
use File::Spec;
use Cwd;
use Getopt::Long;
use POE;
use POE::Component::Metabase::Relay::Server;

use vars qw($VERSION);

$VERSION = '0.06';

sub _metabase_dir {
  return $ENV{PERL5_MBRELAYD_DIR} 
     if  exists $ENV{PERL5_MBRELAYD_DIR} 
     && defined $ENV{PERL5_MBRELAYD_DIR};

  my @os_home_envs = qw( APPDATA HOME USERPROFILE WINDIR SYS$LOGIN );

  for my $env ( @os_home_envs ) {
      next unless exists $ENV{ $env };
      next unless defined $ENV{ $env } && length $ENV{ $env };
      return $ENV{ $env } if -d $ENV{ $env };
  }

  return cwd();
}

sub _read_config {
  my $metabase_dir = File::Spec->catdir( _metabase_dir(), '.metabase' );
  return unless -d $metabase_dir;
  my $conf_file = File::Spec->catfile( $metabase_dir, 'relayd' );
  return unless -e $conf_file;
  my $Config = Config::Tiny->read( $conf_file );
  my @config;
  if ( defined $Config->{_} ) {
    my $root = delete $Config->{_};
	  @config = map { $_, $root->{$_} } grep { exists $root->{$_} }
		              qw(debug url idfile dbfile address port multiple);
  }
  return @config;
}

sub _display_version {
  print "metabase-relayd version ", $VERSION, 
    ", powered by POE::Component::Metabase::Relay::Server ", POE::Component::Metabase::Relay::Server->VERSION, "\n\n";
  print <<EOF;
Copyright (C) 2010 Chris 'BinGOs' Williams
This module may be used, modified, and distributed under the same terms as Perl itself. 
Please see the license that came with your Perl distribution for details.
EOF
  exit;
}

sub run {
  my $package = shift;
  my %config = _read_config();
  my $version;
  GetOptions(
    "help"      => sub { pod2usage(1); },
    "version"   => sub { $version = 1 },
    "debug"     => \$config{debug},
    "address=s" => \$config{address},
    "port=s"    => \$config{port},
    "url=s"	    => \$config{url},
    "dbfile=s"  => \$config{dbfile},
    "idfile=s"	=> \$config{idfile},
    "multiple"	=> \$config{multiple},
  ) or pod2usage(2);

  _display_version() if $version;

  print "Running metabase-relayd with options:\n";
  printf("%-20s %s\n", $_, $config{$_}) 
	  for grep { defined $config{$_} } qw(debug url dbfile idfile address port multiple);

  my $self = bless \%config, $package;

  $self->{relayd} = POE::Component::Metabase::Relay::Server->spawn(
    ( defined $self->{address} ? ( address => $self->{address} ) : () ),
    ( defined $self->{port} ? ( port => $self->{port} ) : () ),
    id_file  => $self->{idfile},
    dsn      => 'dbi:SQLite:dbname=' . $self->{dbfile},
    uri      => $self->{url},
    debug    => $self->{debug},
    multiple => $self->{multiple},
  );


  $poe_kernel->run();
  return 1;
}


'Relay it!';

__END__

=head1 NAME

App::Metabase::Relayd - the guts of the metabase-relayd command

=head1 SYNOPSIS

  #!/usr/bin/perl
  use strict;
  use warnings;
  BEGIN { eval "use Event;"; }
  use App::Metabase::Relayd;
  App::Metabase::Relayd->run();

=head2 run

This method is called by L<metabase-relayd> to do all the work.

=head1 AUTHOR

Chris C<BinGOs> Williams <chris@bingosnet.co.uk>

=head1 LICENSE

Copyright E<copy> Chris Williams

This module may be used, modified, and distributed under the same terms as Perl itself. Please see the license that came with your Perl distribution for details.

=cut
