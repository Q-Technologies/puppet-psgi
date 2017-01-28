# puppet-psgi
Puppet module to create service files for PSGI (Perl Web Server Gateway Interface) apps.

This module sets up a systemd service file for each application passed to it.

It has been designed to fit in nicely with our NGINX module: [qtechnologies/nginx](https://github.com/Q-Technologies/puppet-nginx.git).  If this Nginx module is installed, this module grabs some parameters from it - things are less likely to break if there's only one source of data - especially for the shared sockets locations.

Currently only tested on SUSE, but other platforms should work with the right hiera data.

## Instructions
### Global Settings
The following is the module internal hiera data - feeding the module parameters.  These defaults can be overridden, if required:
```yaml
psgi::service_dir: /etc/systemd/system
psgi::binary: /usr/bin/plackup
psgi::server: Starman
psgi::environment: production
psgi::perl5lib: /usr/local/perl/lib/perl5
```
The following parameters default to Nginx settings, but can be overridden by your hiera data:
```puppet
  String $socket_dir = $nginx::socket_dir,
  String $web_root_parent = $nginx::web_root_parent,
```
e.g.:
```yaml
psgi::socket_dir: /var/sockets
psgi::web_root_parent: /websites

```
See below for a description of the parameters.
### Creating a PSGI systemd Service
Simply use the `phpfpm::pool` resource, like this:
```puppet
psgi::service { 'www.example.com': 
  binary => '/usr/bin/plackup',
  server => 'Twiggy',
}
```
You can also use `create_resources` if you have a hash of config items in hiera:
```puppet
create_resources( psgi::service, { $domain => $config['psgi'] }, {} )
```

This will create a `systemd` service for the specific domain based on the module's internal template.   

It also takes the following paramters:
* `domain` - domain name to use, otherwise use the name
* `socket_dir` - specify a different socket directory, just for this domain - overriding what's specified in Nginx
* `environment` - specify a different environment - defaults to production
* `binary` - the full path to the PSGI binary (`plackup`)
* `server` - the PSGI server to use - defaults to `Starman`
* `web_root` - specify a different web root, just for this domain - overriding the default which is the concatenation of `$web_root_parent` and domain name
* `perl5lib` - any additional library path to search for Perl modules

## Issues
This module is using hiera data that is embedded in the module rather than using a params class.  This may not play nicely with other modules using the same technique unless you are using hiera 3.0.6 and above (PE 2015.3.2+).

It has only been tested on SUSE systems, using SUSE paths - patches for other platforms are welcome - we just need to create internal hiera data for the OS family.
