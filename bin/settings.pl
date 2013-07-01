
$zlib128 = {
    'name' => 'zlib 1.2.8',
    'pkgsrc' => $top . '/tgzs/zlib-1.2.8.tar.gz',
    'srcdir' => $top . '/' . $src . '/zlib-1.2.8',
    'packup' => 'gunzip -c  %PKGSRC% | tar xvf -',
    'configure' => './configure --prefix=' . $prefix,
    'make' => 'make',
    'install' => 'make install',
    'env' => { 'LDFLAGS', '-static-libgcc' },
} ;

$openssl098w = {
    'name' => 'openssl 0.9.8w',
    'pkgsrc' => $top . '/tgzs/openssl-0.9.8w.tar.gz',
    'srcdir' => $top . '/' . $src . '/openssl-0.9.8w',
    'packup' => 'gunzip -c  %PKGSRC% | tar xvf -',
    'configure' => "./Configure  -L${prefix}/lib -I${prefix}include -R${prefix}/lib shared zlib-dynamic --prefix=${prefix} --openssldir=${prefix} solaris-x86-gcc -static-libgcc",
    'make' => 'make',
    'install' => 'make install',
    'env' => { 'LDFLAGS', '-static-libgcc' },
} ;

$ruby187p358 = {
    'name' => 'ruby-1.8.7',
    'pkgsrc' => $top . '/tgzs/ruby-1.8.7-p358.tar.gz',
    'srcdir' => "${top}/${src}/ruby-1.8.7-p358",
    'packup' => 'gunzip -c  %PKGSRC% | tar xvf -',
    'configure' => "./configure --prefix=${prefix} LDFLAGS=\'-static-libgcc -L${prefix}/lib -R${prefix}/lib\' CPPFLAGS=-I${prefix}/include",
    'make' => 'make',
    'install' => 'make install',
#    'env' => { 
#	'LDFLAGS' => '-static-libgcc', 
#	'CFLAGS' => "-I${prefix}/include -L${prefix}/lib -R${prefix}/lib" 
#    },
} ;
    
$rubyshadow214 = {
    'name' => 'ruby-shadow 2.1.4',
#    'pkgsrc' => $top . '/tgzs/ruby-1.8.7-p358.tar.gz',
    'srcdir' => "${top}/${src}/ruby-shadow",
    'packup' => 'test -d  %SRCDIR% || git clone https://github.com/apalmblad/ruby-shadow.git ruby-shadow ; cd %SRCDIR% ; git checkout 2.1.4 ',
    'configure' => "${prefix}/bin/ruby extconf.rb",
    'make' => 'make CC=\'gcc -static-libgcc\'',
    'install' => 'make install',
    'env' => { 'CFLAGS' => '-static-liggcc' },
} ;

$facter171 = {
    'name' => 'Facter 1.7.1',
    'pkgsrc' => $top . '/tgzs/facter-1.7.1.tar.gz',
    'srcdir' => "${top}/${src}/facter-1.7.1",
    'packup' => 'gunzip -c  %PKGSRC% | tar xvf -',
    'install' => "${prefix}/bin/ruby install.rb",
} ;

$puppet322 = {
    'name' => 'Facter 3.2.2',
    'pkgsrc' => $top . '/tgzs/puppet-3.2.2.tar.gz',
    'srcdir' => "${top}/${src}/puppet-3.2.2",
    'packup' => 'gunzip -c  %PKGSRC% | tar xvf -',
    'install' => "${prefix}/bin/ruby install.rb --no-configs",

} ;


# @packages = ( $zlib128 ) ;
# @packages = ( $openssl098w ) ;
# @packages = ( $ruby187p358 ) ;
# @packages = ( $rubyshadow214 ) ;
# @packages = ( $facter171, $puppet322 ) ;

if (0) {
@packages = ( $zlib128,
	      $openssl098w,
	      $ruby187p358,
	      $rubyshadow214,
	      $facter171,
	      $puppet322,
    ) ;
} else {
    @packages = () ;
}

$target = $top . "/packages/eisuppet-solaris-0.3.1.pkg" ;
# print $target, "debug\n" ;
@pkginfo = (
    'PKG="EISpuppet"',
    'NAME="eispuppet"',
    'ARCH="' . $arch . '"',
    'VERSION="0.3.1"',
    'CATEGORY="application"',
    'VENDOR="EIS Global Team"',
    'EMAIL="nils.olof.xo.paulsson@ericsson.com"',
    'PSTAMP="Nils Olof Paulsson"',
    'BASEDIR="/opt/puppet"',
    'CLASSES="none"',
    );

$postinstall = <<EOT;
#!/bin/sh

test -f /usr/bin/puppet || ln -s /opt/puppet/bin/puppet /usr/bin
test -f /usr/bin/facter || ln -s /opt/puppet/bin/facter /usr/bin
if [ ! -d /etc/puppet ] ; then
  mkdir -p /etc/puppet
  cat > /etc/puppet/puppet.conf <<EOF
# This is a template file for puppet
# EDIT at least all lines with server names

[main]
    # The Puppet log directory.
    # The default value is '$vardir/log'.
    logdir = /var/log/puppet

    # Where Puppet PID files are kept.
    # The default value is '$vardir/run'.
    rundir = /var/run/puppet

    # Where SSL certificates are kept.
    # The default value is '$confdir/ssl'.
    ssldir = $vardir/ssl

    archive_files = true
    archive_file_server = puppet.rnd.ericsson.se

[agent]
    # The file in which puppetd stores a list of the classes
    # associated with the retrieved configuratiion.  Can be loaded in
    # the separate ``puppet`` executable using the ``--loadclasses``
    # option.
    # The default value is '$confdir/classes.txt'.
    classfile = $vardir/classes.txt

    # Where puppetd caches the local configuration.  An
    # extension indicating the cache format is added automatically.
    # The default value is '$confdir/localconfig'.
    localconfig = $vardir/localconfig

    certname = puppet.rnd.ericsson.se
    server = puppet.rnd.ericsson.se
    ca_server = puppetca.rnd.ericsson.se
    report = true
    graph = true
    pluginsync = true

EOF

fi
test -f /etc/puppet/NO-POSTINSTALL-RUN || /opt/puppet/bin/puppet -t
EOT

