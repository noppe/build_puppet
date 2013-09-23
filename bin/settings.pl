#
# 
#

%pathmap = (
	    'SunOS-5.10' =>  "/usr/sfw/bin:/usr/ccs/bin:/usr/bin:/bin",
	    'SunOS-5.11' =>  "/usr/sfw/bin:/usr/ccs/bin:/usr/bin:/bin",
	    );

$zlib128 = {
    'name'      => 'zlib 1.2.8',
    'fetch'     => 'wget http://dfn.dl.sourceforge.net/project/libpng/zlib/1.2.8/zlib-1.2.8.tar.gz',
    'pkgsrc'    => $top . '/tgzs/zlib-1.2.8.tar.gz',
    'srcdir'    => $top . '/' . $src . '/zlib-1.2.8',
    'packup'    => 'gunzip -c  %PKGSRC% | tar xvf -',
    'configure' => './configure --prefix=' . $prefix,
    'make'      => 'make',
    'install'   => 'make install',
    'env'       => { 
	'LDFLAGS' => '-static-libgcc',
	'PATH'    => $pathmap {$platform_os} || '/bin:/usr/bin',
    },
} ;

$openssl098w = {
    'name'      => 'openssl 0.9.8w',
    'fetch'     => 'wget http://www.openssl.org/source/openssl-0.9.8w.tar.gz',
    'pkgsrc'    => $top . '/tgzs/openssl-0.9.8w.tar.gz',
    'srcdir'    => $top . '/' . $src . '/openssl-0.9.8w',
    'packup'    => 'gunzip -c  %PKGSRC% | tar xvf -',
    'configure' => "./Configure  -L${prefix}/lib -I${prefix}/include -R${prefix}/lib shared zlib-dynamic --prefix=${prefix} --openssldir=${prefix} solaris-x86-gcc -static-libgcc",
    'make'      => 'make',
    'install'   => 'make install',
    'env'       => { 
	'LDFLAGS' => '-static-libgcc',
	'PATH'    => $pathmap {$platform_os} || '/bin:/usr/bin',
    },
} ;

$ruby187p358 = {
    'name'      => 'ruby-1.8.7',
    'fetch'     => 'wget ftp://ftp.ruby-lang.org/pub/ruby/ruby-1.8.7-p358.tar.gz',
    'pkgsrc'    => $top . '/tgzs/ruby-1.8.7-p358.tar.gz',
    'srcdir'    => "${top}/${src}/ruby-1.8.7-p358",
    'packup'    => 'gunzip -c  %PKGSRC% | tar xvf -',
    'configure' => "./configure --prefix=${prefix} LDFLAGS=\'-static-libgcc -L${prefix}/lib -R${prefix}/lib\' CPPFLAGS=-I${prefix}/include",
    'make'      => 'make',
    'install'   => 'make install',
    'env' => { 
	'PATH'    => $pathmap {$platform_os} || '/bin:/usr/bin',
#	'LDFLAGS' => '-static-libgcc', 
#	'CFLAGS' => "-I${prefix}/include -L${prefix}/lib -R${prefix}/lib" 
    },
} ;

$readline62 = {
    'name'      => 'Readline 6.2',
    'fetch'     => 'wget http://ftp.gnu.org/gnu/readline/readline-6.2.tar.gz',
    'pkgsrc'    => "${top}/tgzs/readline-6.2.tar.gz",
    'srcdir'    => "${top}/${src}/readline-6.2",
    'packup'    => 'gunzip -c  %PKGSRC% | tar xvf -',
    'configure' => "./configure --with-curses --prefix=${prefix} CFLAGS=-static-libgcc",
    'make'      => 'make',
    'install'   => 'make install',
    'env' => { 
	'PATH'    => $pathmap {$platform_os} || '/bin:/usr/bin',
    },
} ;


$augeas110 = {
    'name'      => 'Augeas 1.1.0',
    'fetch'     => 'wget http://download.augeas.net/augeas-1.1.0.tar.gz',
    'pkgsrc'    => "${top}/tgzs/augeas-1.1.0.tar.gz",
    'srcdir'    => "${top}/${src}/augeas-1.1.0",
    'packup'    => 'gunzip -c  %PKGSRC% | tar xvf -',
    'configure' => "./configure --prefix=${prefix} CPPFLAGS=-I${prefix}/include LDFLAGS=\"-L${prefix}/lib -R${prefix}/lib -lncurses\" CFLAGS=-static-libgcc",
    'make'      => 'gmake',
    'install'   => 'gmake install',
    'env' => { 
	'PATH'    => $pathmap {$platform_os} || '/bin:/usr/bin',
    },
} ;

$ruby_augeas050 = {
    'name'      => 'Ruby-augeas 0.5.0',
    'fetch'     => 'wget http://download.augeas.net/ruby/ruby-augeas-0.5.0.tgz',
    'pkgsrc'    => "${top}/tgzs/ruby-augeas-0.5.0.tgz",
    'srcdir'    => "${top}/${src}/ruby-augeas-0.5.0",
    'packup'    => 'gunzip -c  %PKGSRC% | tar xvf -',
    'configure' => "cd ext/augeas ; echo \"require 'mkmf' ; extension_name = '_augeas' ; create_makefile(extension_name)\" > ee2.rb ; ${prefix}/bin/ruby ee2.rb ; cd ../..",
    'make'      => 'cd ext/augeas ; gmake CC="gcc -I/usr/include/libxml2 -laugeas" ; cd ../..',
    'install'   => "cp lib/augeas.rb ${prefix}/lib/ruby/site_ruby/1.8 ; cd ext/augeas ; gmake install; ",
    'env' => { 
	'PATH'    => $pathmap {$platform_os} || '/bin:/usr/bin',
    },
} ;
    
$rubyshadow214 = {
    'name'      => 'ruby-shadow 2.1.4',
    'fetch'     => 'git clone https://github.com/apalmblad/ruby-shadow.git ; cd ruby_shadow; git checkout 2.1.4',
    'pkgsrc'    => $top . '/tgzs/ruby-shadow.tar.gz',
    'srcdir'    => "${top}/${src}/ruby-shadow",
    'packup'    => "cp -r ${top}/tgzs/ruby-shadow ${top}/${src}/ruby-shadow",
#    'packup'    => 'echo Workaround on systems without git; gunzip -c  %PKGSRC% | tar xvf -',
#    'packup'    => 'test -d  %SRCDIR% || git clone https://github.com/apalmblad/ruby-shadow.git ruby-shadow ; cd %SRCDIR% ; git checkout 2.1.4 ',
    'configure' => "${prefix}/bin/ruby extconf.rb",
    'make'      => 'gmake CC=\'gcc -static-libgcc\'',
    'install'   => 'gmake install',
    'env' => { 
	'CFLAGS' => '-static-libgcc',
	'PATH'    => $pathmap {$platform_os} || '/bin:/usr/bin',
    },
} ;

$facter171 = {
    'name'    => 'Facter 1.7.1',
    'fetch'   => 'wget http://downloads.puppetlabs.com/facter/facter-1.7.1.tar.gz', 
    'pkgsrc'  => $top . '/tgzs/facter-1.7.1.tar.gz',
    'srcdir'  => "${top}/${src}/facter-1.7.1",
    'packup'  => 'gunzip -c  %PKGSRC% | tar xf -',
    'install' => "${prefix}/bin/ruby install.rb",
} ;

$hiera121 = {
    'name'    => 'Hiera 1.2.1',
    'fetch'   => 'wget http://downloads.puppetlabs.com/hiera/hiera-1.2.1.tar.gz',
    'pkgsrc'  => $top . '/tgzs/hiera-1.2.1.tar.gz',
    'srcdir'  => "${top}/${src}/hiera-1.2.1",
    'packup'  => 'gunzip -c %PKGSRC% | tar xf -',
    'install' => "${prefix}/bin/ruby install.rb --no-configs",
} ;


$puppet322 = {
    'name'    => 'Puppet 3.2.2',
    'fetch'   => 'wget http://downloads.puppetlabs.com/puppet/puppet-3.2.2.tar.gz', 
    'pkgsrc'  => $top . '/tgzs/puppet-3.2.2.tar.gz',
    'srcdir'  => "${top}/${src}/puppet-3.2.2",
    'packup'  => 'gunzip -c  %PKGSRC% | tar xvf -',
    'install' => "${prefix}/bin/ruby install.rb --no-configs",

} ;

@packages = qw/
    zlib128
    openssl098w
    readline62
    ruby187p358
    augeas110
    ruby_augeas050
    rubyshadow214
    hiera121
    facter171
    puppet322
    / ;

$target = $top . "/packages/eisuppet-$platform-$eis_puppet_version.pkg" ;

@pkginfo = (
    'PKG="EISpuppet"',
    'NAME="eispuppet"',
    'ARCH="' . $platform_arch . '"',
    'VERSION="' . $eis_puppet_version . '"',
    'CATEGORY="application"',
    'VENDOR="EIS Global Team"',
    'EMAIL="nils.olof.xo.paulsson@ericsson.com"',
    'PSTAMP="Nils Olof Paulsson"',
    'BASEDIR="/opt/puppet"',
    'CLASSES="none"',
    );

@debinfo = (
    'Package: eis-puppet',
    'Version: ' . $eis_puppet_version,
    'Architecture: ' . ($platform_arch == "x86_64" ? "amd64" : $platform_arch),
    'Priority: optional',
    'Section: base',
    'Depends:',
    'Maintainer: nils.olof.xo.paulsson@ericsson.com',
    'Description: This is EIS CM puppet',
    ) ;

@rpminfo = (
    'Name: eis-puppet',
    'Version: ' . $eis_puppet_version,
    'Release: ' . $eis_puppet_version,
    'Licence: GPL',
    'Summary: EIS Puppet standalone package including tools and libs',
    'Group: Applications/System', 
    'Buildroot: ' . ${top},
    '',
    '%description',
    'This package includes ' . join (", ", @packages),
    '',
    '%files',
    '/opt/puppet',
    ) ;

$postinstall = <<EOT;
#!/bin/sh

test -f /usr/bin/puppet || ln -s /opt/puppet/bin/puppet /usr/bin
test -f /usr/bin/facter || ln -s /opt/puppet/bin/facter /usr/bin

if [ ! -f /etc/puppet/puppet.conf ] ; then
  if [ ! -d /etc/puppet ] ; then
    mkdir -p /etc/puppet
    chown bin /etc/puppet
    chgrp bin /etc/puppet
    chmod 755 /etc/puppet
  fi

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
    # the separate ''puppet'' executable using the ''--loadclasses''
    # option.
    # The default value is '$confdir/classes.txt'.
    classfile = $vardir/classes.txt

    # Where puppetd caches the local configuration.  An
    # extension indicating the cache format is added automatically.
    # The default value is '$confdir/localconfig'.
    localconfig = $vardir/localconfig
    report = true
    graph = true
    pluginsync = true
    # Insert server names below. For example:
    #     server = puppet.rnd.ericsson.se
    #     ca_server = puppetca.rnd.ericsson.se

EOF

fi
EOT

