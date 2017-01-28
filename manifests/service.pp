# Defined type to a service for a PSGI application
define psgi::service (
  # Class parameters are populated from module hiera data
  String $domain     = '',
  String $socket_dir = '',
  String $environment = 'production',
  String $binary = '',
  String $server = '',
  String $web_root = '',
  String $perl5lib = '',
){

  include psgi
  include stdlib

  if $name == '' {
    # Puppet won't let this happen anyway, but let's be explicit
    fail( 'Name cannot be blank' )
  }
  if $domain == '' {
    $domain_name = $name
  } else {
    $domain_name = $domain
  }

  $label = regsubst( $domain_name, '\.', '_', 'G' )
  $service = "$psgi_${label}"
  file { "${psgi::service_dir}/${service}.service":
    ensure        => file,
    owner         => 'root',
    group         => 'root',
    mode          => '0640',
    notify        => Exec['psgi-systemctl-daemon-reload'],
    content       => epp('psgi/psgi_service.epp', {
      domain      => $domain_name,
      socket_dir  => $socket_dir ? {
        ''      => $psgi::socket_dir,
        default => $socket_dir,
      },
      web_root    => $web_root ? {
        ''      => "${psgi::web_root_parent}/${domain_name}",
        default => $web_root,
      },
      environment => $environment ? {
        ''      => $psgi::environment,
        default => $environment,
      },
      server      => $server ? {
        ''      => $psgi::server,
        default => $server,
      },
      binary      => $binary ? {
        ''      => $psgi::binary,
        default => $binary,
      },
      perl5lib     => $perl5lib ? {
        ''      => $psgi::perl5lib,
        default => $perl5lib,
      },
    } ),
  }


}
