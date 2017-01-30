# Class to configure the PSGI web applications
class psgi (
  # Class parameters are populated from module hiera data - but can be overridden by global hiera
  String $service_dir,
  String $environment,
  String $binary,
  String $server,
  String $perl5lib,

  # These class parameters are populated from global hiera data
  String $socket_dir      = $nginx::socket_dir,
  String $web_root_parent = $nginx::web_root_parent,
){

  exec { 'psgi-systemctl-daemon-reload':
    path        => $::path,
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }
}
