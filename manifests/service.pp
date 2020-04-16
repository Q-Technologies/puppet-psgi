# Defined type to a service for a PSGI application
define psgi::service (
  # Class parameters are populated from module hiera data
  String    $web_server_name = '',
  String    $socket_dir      = '',
  String    $app_environment = '',
  String    $binary          = '',
  String    $server          = '',
  String    $web_root        = '',
  String    $perl5lib        = '',
  String    $app_lib         = '',
  String    $app_script      = '',
  String    $umask           = '',
  String    $user            = '',
  String    $group           = '',
  Optional[Integer] $workers = undef,
  Optional[Boolean] $start_service = undef,
  Optional[Boolean] $enable_service = undef,
  Data $options = {},
){

  include psgi
  include stdlib

  if $name == '' {
    # Puppet won't let this happen anyway, but let's be explicit
    fail( 'Name cannot be blank' )
  }
  if $web_server_name == '' {
    $web_server_name_mod = $name
  } else {
    $web_server_name_mod = $web_server_name
  }

  $socket_dir_mod      = pick( $options['socket_dir'], $socket_dir, $psgi::socket_dir )
  $web_root_mod        = pick( $options['web_root'], $web_root, "${psgi::web_root_parent}/${web_server_name_mod}")
  $app_environment_mod = pick( $options['app_environment'], $app_environment, $psgi::app_environment )
  $server_mod          = pick( $options['server'], $server, $psgi::server )
  $binary_mod          = pick( $options['binary'], $binary, $psgi::binary )
  $workers_mod         = pick( $options['workers'], $workers, $psgi::workers )
  $perl5lib_mod        = pick( $options['perl5lib'], $perl5lib, $psgi::perl5lib )
  $app_lib_mod         = pick( $options['app_lib'], $app_lib, $psgi::app_lib )
  $app_script_mod      = pick( $options['app_script'], $app_script, $psgi::app_script )
  $umask_mod           = pick( $options['umask'], $umask, $psgi::umask )
  $user_mod            = pick( $options['user'], $user, $psgi::user )
  $group_mod           = pick( $options['group'], $group, $psgi::group )
  $start_service_mod   = pick( $options['start_service'], $start_service, $psgi::start_service )
  $enable_service_mod  = pick( $options['enable_service'], $enable_service, $psgi::enable_service )

  $label = regsubst( $web_server_name_mod, '\.', '_', 'G' )
  $service = "psgi_${label}"
  file { "${psgi::service_dir}/${service}.service":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    notify  => Exec['psgi-systemctl-daemon-reload'],
    content => epp('psgi/psgi_service.epp', {
      web_server_name => $web_server_name_mod,
      socket_dir      => $socket_dir_mod,
      web_root        => $web_root_mod,
      app_environment => $app_environment_mod,
      server          => $server_mod,
      binary          => $binary_mod,
      workers         => $workers_mod,
      perl5lib        => $perl5lib_mod,
      app_lib         => $app_lib_mod,
      app_script      => $app_script_mod,
      umask           => $umask_mod,
      user            => $user_mod,
      group           => $group_mod,
    } ),
  }

  if $start_service_mod or $enable_service_mod {
    service { $service:
      ensure    => $start_service_mod,
      enable    => $enable_service_mod,
      subscribe => File["${psgi::service_dir}/${service}.service"],
    }
  }


}
