# puppet-psgi
Puppet module to create service files for PSGI (Perl Web Server Gateway Interface) apps.

This module sets up a systemd service file for each application passed to it.

It has been designed to fit in nicely with our NGINX module: [qtechnologies/nginx](https://github.com/Q-Technologies/puppet-nginx.git).  If this Nginx module is installed, this module grabs some parameters from it - things are less likely to break if there's only one source of data - especially for the shared sockets locations.

##### Please note the following items:
* This module does not deploy Perl or the PSGI applications themselves - just the service file to make sure the app starts at boot and providing an easy and consistent way to start and stop it.
* The default settings assume an OS provided Perl with some extra modules installed into a local library.  However, any Perl installation can be used, you just need to configure the correct `binary` (usually path to `plackup`) and `perl5lib` in your hiera data.
* If you define a website as PSGI, then change it to something else later (e.g. PHP), the service file will be left orphaned unless you have otherwise decided to manage `/etc/systemd/system` fully with Puppet.
* Currently only tested on SUSE, but other platforms should work with the right hiera data.
* Also, only tested on Dancer2 PSGI applications, but, again, other deployment types should work with the right hiera data.

## Instructions
### Global Settings
The following is the module internal hiera data - feeding the module parameters.  These defaults can be overridden, if required:
```yaml
psgi::service_dir: /etc/systemd/system
psgi::binary: /usr/bin/plackup
psgi::server: Starman
psgi::app_environment: production
psgi::perl5lib: /usr/local/perl/lib/perl5
psgi::app_lib: lib
psgi::app_script: bin/app.pl
psgi::umask: '0077'
psgi::user: 'root'
psgi::group: 'root'
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
Simply use the `psgi::service` resource, like this:
```puppet
psgi::service { 'www.example.com': 
  binary => '/usr/bin/plackup',
  server => 'Twiggy',
}
```
You can also use `create_resources` if you have a hash of config items in hiera:
```puppet
create_resources( psgi::service, { $web_server_name => $config['psgi'] }, {} )
```

Also, see our [nginx module](https://github.com/Q-Technologies/puppet-nginx.git) for how to call it through the nginx hiera definitions.

This will create a `systemd` service for the specific web server name based on the module's internal template.

It takes the following paramters:
* `web_server_name` - web server name name to use (*i.e. the domain name you are serving on*), otherwise use the resource name
* `socket_dir` - specify a different socket directory, just for this web server name - overriding what's specified in Nginx
* `app_environment` - specify a different application deployment environment - defaults to production
* `binary` - the full path to the PSGI binary (`plackup`)
* `server` - the PSGI server to use - defaults to `Starman`
* `workers` - the number of workers to start - defaults to `2`
* `enabled` - whether the service should be set to running always and enabled on boot.  Defaults to `true` for `production` and *not controlled* otherwise.
* `web_root` - specify a different web root, just for this web server name - overriding the default which is the concatenation of `$web_root_parent` and `web_server_name`
* `perl5lib` - any additional library path to search for Perl modules
* `app_script` - path to the main PSGI application script, relative to the `web_root`.  Defaults to `bin/app.pl`.
* `app_lib` - path to the PSGI application libraries, relative to the `web_root`.  Defaults to `lib`.
* `umask` - umask to use when running the PSGI application.  Important for the socket creation. Defaults to `000`.
* `user` - the user to run the PSGI application as.  Defaults to `root`.
* `group` - the group to run the PSGI application as.  Defaults to `root`.

## Issues
This module is using hiera data that is embedded in the module rather than using a params class.  This may not play nicely with other modules using the same technique unless you are using hiera 3.0.6 and above (PE 2015.3.2+).

It has only been tested on SUSE systems, using SUSE paths - patches for other platforms are welcome - we just need to create internal hiera data for the OS family.
