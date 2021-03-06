# Class to configure the PSGI web applications
class psgi (
  # Class parameters are populated from module hiera data - but can be overridden by global hiera
  String $service_dir,
  Boolean $start_service,
  Boolean $enable_service,
  String $app_environment,
  String $binary,
  String $server,
  Integer $workers,
  String $perl5lib,
  String $app_lib,
  String $app_script,
  String $umask,
  String $user,
  String $group,

  # These class parameters are populated from global hiera data
  String $socket_dir      = $nginx::socket_dir,
  String $web_root_parent = $nginx::web_root_parent,
){

  include nginx

  exec { 'psgi-systemctl-daemon-reload':
    path        => $::path,
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }
}
