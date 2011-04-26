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
requires 'POE::Component::Metabase::Relay::Server' => '0.20';
if ( !( can_use('Event') and can_use('POE::XS::Queue::Array') ) and can_cc() ) {
print <<NOTICE;

\a--------------------------------------------------------------
Hey,

You appear to have a working compiler. I can include 'Event'
and 'POE::XS::Queue::Array' which will make POE work a lot
faster.

--------------------------------------------------------------

NOTICE

my $prompt = prompt( 'Do you want to install \'Event\' and \'POE::XS::Queue::Array\' [Y/n]?', 'Y' );

if ( $prompt =~ /^Y/i ) {
  requires 'POE::Loop::Event' => 0;
  requires 'Event' => 1.11;
  requires 'POE::XS::Queue::Array' => 0.005;
}

}
makemaker_args(dist => { PREOP => "$^X ./tools/git-log.pl > ./Changes" });
auto_provides;
githubmeta;
WriteAll();
