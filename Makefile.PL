use strict;
use inc::Module::Install;
name 'metabase-relayd';
author 'Chris Williams <chris@bingosnet.co.uk>';
version_from 'lib/App/Metabase/Relayd.pm';
abstract 'A relay server for Metabase';
readme_from 'bin/metabase-relayd';
install_script 'bin/metabase-relayd';
license 'perl';
auto_license holder => 'Chris Williams';
perl_version '5.006';
build_requires 'Test::More' => 0.47;
requires 'Config::Tiny' => 2.12;
requires 'File::Spec' => 0;
requires 'File::Path' => 0;
requires 'Module::Load::Conditional' => '0.38';
requires 'Pod::Usage' => '1.00';
requires 'POE' => '1.310';
requires 'unless' => 0;
requires 'POE::Component::Metabase::Relay::Server' => '0.34';
if ( can_cc() ) {
  requires 'POE::XS::Queue::Array' => 0.005;
  if ( $^O eq 'linux' ) {
    requires 'POE::XS::Loop::EPoll' => 1.001;
  }
  # Problem with POE::XS::Loop::Poll on MacOSX use Event
  # [rt.cpan.org #68608]
  elsif ( $^O =~ /^(MSWin32|darwin)$/ ) {
    requires 'Event' => 0;
    requires 'POE::Loop::Event' => 0;
  }
  else {
    requires 'POE::XS::Loop::Poll' => 1.000;
  }
}
makemaker_args(dist => { PREOP => "$^X ./tools/git-log.pl > ./Changes" });
auto_provides;
githubmeta;
dynamic_config 1;
WriteAll();
