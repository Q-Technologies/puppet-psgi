# Defined type to a service for a PSGI application
define psgi::service (
  # Class parameters are populated from module hiera data
  String    $web_server_name = '',
  String    $socket_dir      = '',
  String    $environment     = '',
  String    $binary          = '',
  String    $server          = '',
  Integer   $workers         = 0,
  String    $web_root        = '',
  String    $perl5lib        = '',
  String    $app_lib         = '',
  String    $app_script      = '',
  String    $umask           = '',
  String    $user            = '',
  String    $group           = '',
  Optional[Boolean]   $enabled         = undef,
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

  $socket_dir_mod  = $socket_dir ?  { '' => $psgi::socket_dir                                 , default => $socket_dir, }
  $web_root_mod    = $web_root ?    { '' => "${psgi::web_root_parent}/${web_server_name_mod}" , default => $web_root, }
  $environment_mod = $environment ? { '' => $psgi::environment                                , default => $environment, }
  $server_mod      = $server ?      { '' => $psgi::server                                     , default => $server, }
  $binary_mod      = $binary ?      { '' => $psgi::binary                                     , default => $binary, }
  $workers_mod     = $workers ?     { 0  => $psgi::workers                                    , default => $workers, }
  $perl5lib_mod    = $perl5lib ?    { '' => $psgi::perl5lib                                   , default => $perl5lib, }
  $app_lib_mod     = $app_lib ?     { '' => $psgi::app_lib                                    , default => $app_lib, }
  $app_script_mod  = $app_script ?  { '' => $psgi::app_script                                 , default => $app_script, }
  $umask_mod       = $umask ?       { '' => $psgi::umask                                      , default => $umask, }
  $user_mod        = $user ?        { '' => $psgi::user                                       , default => $user, }
  $group_mod       = $group ?       { '' => $psgi::group                                      , default => $group, }

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
      environment     => $environment_mod,
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

  if $enabled == undef {
    if $environment_mod == 'production' {
      service { $service:
        ensure  => true,
        enable  => true,
        subscribe => File["${psgi::service_dir}/${service}.service"],
      }
    }
  } else {
    service { $service:
      ensure  => $enabled,
      enable  => $enabled,
      subscribe => File["${psgi::service_dir}/${service}.service"],
    }
  }


}
