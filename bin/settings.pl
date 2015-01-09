#
#
#

$eis_puppet_version = '3.3.1-7' ;

%pathmap = (
  'SunOS-5.9'  =>  "/opt/sfw/gcc-3/bin:/usr/ccs/bin:/usr/local/bin:/usr/bin:/bin:/usr/sfw/bin",
  'SunOS-5.10' =>  "/usr/sfw/bin:/usr/ccs/bin:/usr/bin:/bin",
  'SunOS-5.11' =>  "/usr/sfw/bin:/usr/ccs/bin:/usr/bin:/bin",
);

$zlib128 = {
  'name'      => 'zlib 1.2.8',
  'fetch'     => 'wget http://dfn.dl.sourceforge.net/project/libpng/zlib/1.2.8/zlib-1.2.8.tar.gz',
  'pkgsrc'    => $build_dir . '/tgzs/zlib-1.2.8.tar.gz',
  'srcdir'    => $src . '/zlib-1.2.8',
  'extract'    => 'gunzip -c  %PKGSRC% | tar xvf -',
  'configure' => 'make clean; ./configure --prefix=' . $prefix,
  'make'      => 'make',
  'install'   => 'make install',
  'env'       => {
    'LDFLAGS' => '-static-libgcc',
    'PATH'    => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$openssl101g = {
  'name'      => 'openssl 1.0.1k',
  'fetch'     => 'wget http://www.openssl.org/source/openssl-1.0.1k.tar.gz',
  'pkgsrc'    => $build_dir . '/tgzs/openssl-1.0.1k.tar.gz',
  'srcdir'    => $src . '/openssl-1.0.1k',
  'extract'    => 'gunzip -c  %PKGSRC% | tar xvf -',
# requires the compiler label for the platform and must be os/platform specific
#  'configure' => "./Configure  -L${prefix}/lib -I${prefix}/include -R${prefix}/lib shared zlib-dynamic --prefix=${prefix} --openssldir=${prefix} solaris-x86-gcc -static-libgcc",
  'make'      => 'make',
  'install'   => 'make install',
  'env'       => {
    'LDFLAGS' => '-static-libgcc',
    'PATH'    => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$libxml2291 = {
  'name'	=> 'libxml2-2.9.1',
  'fetch'	=> 'wget wget ftp://xmlsoft.org/libxml2/libxml2-2.9.1.tar.gz',
  'pkgsrc'	=> $build_dir . '/tgzs/libxml2-2.9.1.tar.gz',
  'srcdir'	=> "${src}/libxml2-2.9.1",
  'extract'    => "gunzip -c  %PKGSRC% | tar xvf -",
  'configure' => "make clean; ./configure --prefix=${prefix} LDFLAGS=-static-libgcc ",
  'make'      => 'make',
  'install'   => 'make install',
  'env' => {
    'PATH' => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$libiconv114 = {
  'name'      => 'libiconv-1.14',
  'fetch'     => 'wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz',
  'pkgsrc'    => $build_dir . '/tgzs/libiconv-1.14.tar.gz',
  'srcdir'    => "${src}/libiconv-1.14",
  'extract'    => 'gunzip -c  %PKGSRC% | tar xvf -',
  'configure' => "make clean; ./configure --prefix=${prefix} LDFLAGS=-static-libgcc ",
  'make'      => 'make',
  'install'   => 'make install',
  'env' => {
    'PATH' => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$ncurses59 = {
  'name'      => 'ncurses-5.9',
  'fetch'     => 'wget http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.9.tar.gz',
  'pkgsrc'    => $build_dir . '/tgzs/ncurses-5.9.tar.gz',
  'srcdir'    => "${src}/ncurses-5.9",
  'extract'    => 'gunzip -c  %PKGSRC% | tar xvf -',
  'configure'	=> "make clean; ./configure --prefix=${prefix} --with-terminfo-dirs=/usr/share/lib/terminfo --enable-termcap CFLAGS=-fPIC LDFLAGS=-static-libgcc ",
  'make'	    => 'make',
  'install'   => 'make install',
  'env' => {
    'PATH' => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$ruby187p358 = {
  'name'      => 'ruby-1.8.7',
  'fetch'     => 'wget ftp://ftp.ruby-lang.org/pub/ruby/ruby-1.8.7-p358.tar.gz',
  'pkgsrc'    => $build_dir . '/tgzs/ruby-1.8.7-p358.tar.gz',
  'srcdir'    => "${src}/ruby-1.8.7-p358",
  'extract'    => 'gunzip -c  %PKGSRC% | tar xvf -',
  'configure' => "make clean; ./configure --prefix=${prefix} LDFLAGS=\'-static-libgcc -L${prefix}/lib -R${prefix}/lib\' CPPFLAGS=-I${prefix}/include",
  'make'      => 'make',
  'install'   => 'make install',
  'env' => {
    'PATH' => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

#
# Testing. Not actually in use.
#
$ruby193p448 = {
  'name'      => 'ruby-1.9.3',
  'fetch'     => 'wget ftp://ftp.ruby-lang.org/pub/ruby/ruby-1.9.3-p448.tar.gz',
  'pkgsrc'    => $build_dir . '/tgzs/ruby-1.9.3-p448.tar.gz',
  'srcdir'    => "${src}/ruby-1.9.3-p448",
  'extract'    => 'gunzip -c  %PKGSRC% | tar xvf -',
  'configure' => "make clean; ./configure --prefix=${prefix} LDFLAGS=\'-static-libgcc -L${prefix}/lib -R${prefix}/lib\' CPPFLAGS=-I${prefix}/include",
  'make'      => 'make',
  'install'   => 'make install',
  'env' => {
    'PATH' => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$readline62 = {
  'name'      => 'Readline 6.2',
  'fetch'     => 'wget http://ftp.gnu.org/gnu/readline/readline-6.2.tar.gz',
  'pkgsrc'    => "${build_dir}/tgzs/readline-6.2.tar.gz",
  'srcdir'    => "${src}/readline-6.2",
  'extract'   => 'gunzip -c  %PKGSRC% | tar xvf -',
  'configure' => "make clean; ./configure --with-curses --prefix=${prefix} CFLAGS=-static-libgcc",
  'make'      => 'make',
  'install'   => 'make install',
  'env' => {
    'PATH' => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$augeas110 = {
  'name'      => 'Augeas 1.1.0',
  'fetch'     => 'wget http://download.augeas.net/augeas-1.1.0.tar.gz',
  'pkgsrc'    => "${build_dir}/tgzs/augeas-1.1.0.tar.gz",
  'srcdir'    => "${src}/augeas-1.1.0",
  'extract'   => 'gunzip -c  %PKGSRC% | tar xvf -',
  'configure' => "make clean; ./configure --prefix=${prefix} CPPFLAGS=-I${prefix}/include LDFLAGS=\"-L${prefix}/lib -R${prefix}/lib -lcurses\" CFLAGS=-static-libgcc",
  'make'      => 'gmake',
  'install'   => 'gmake install',
  'env' => {
    'PATH'          => $pathmap {$platform_os} || '/bin:/usr/bin',
    'LIBXML_CFLAGS' => "-I${prefix}/include/libxml2",
    'LIBXML_LIBS'   => '-lxml2',
  },
};

$ruby_augeas050 = {
  'name'      => 'Ruby-augeas 0.5.0',
  'fetch'     => 'wget http://download.augeas.net/ruby/ruby-augeas-0.5.0.tgz',
  'pkgsrc'    => "${build_dir}/tgzs/ruby-augeas-0.5.0.tgz",
  'srcdir'    => "${src}/ruby-augeas-0.5.0",
  'extract'   => 'gunzip -c  %PKGSRC% | tar xvf -',
  'configure' => "cd ext/augeas ; echo \"require 'mkmf' ; extension_name = '_augeas' ; create_makefile(extension_name)\" > ee2.rb ; ${prefix}/bin/ruby ee2.rb ; cd ../..",
  'make'      => "cd ext/augeas ; gmake CC=\"gcc -I${prefix}/include/libxml2 -laugeas\" ; cd ../..",
  'install'   => "cp lib/augeas.rb ${prefix}/lib/ruby/site_ruby/1.8 ; cd ext/augeas ; gmake install; ",
  'env' => {
    'PATH'          => $pathmap {$platform_os} || '/bin:/usr/bin',
    "LIBXML_CFLAGS" => "-I${prefix}/include/libxml2",
    'LIBXML_LIBS'   => '-lxml2',
  },
};

$rubyshadow214 = {
  'name'      => 'ruby-shadow 2.1.4',
  'fetch'     => 'git clone https://github.com/apalmblad/ruby-shadow.git && cd ruby-shadow && git checkout 2.1.4',
  'pkgsrc'    => $build_dir . '/tgzs/ruby-shadow',
  'srcdir'    => "${src}/ruby-shadow",
#  'extract'    => "cp -r ${build_dir}/tgzs/ruby-shadow ${src}/ruby-shadow",
  'extract'    => "rsync -avp ${build_dir}/tgzs/ruby-shadow/ ${src}/ruby-shadow/",
  'configure' => "make clean; ${prefix}/bin/ruby extconf.rb",
  'make'      => 'gmake CC=\'gcc -static-libgcc\'',
  'install'   => 'gmake install',
  'env' => {
    'CFLAGS' => '-static-libgcc',
    'PATH'   => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$facter173 = {
  'name'    => 'Facter 1.7.3',
  'fetch'   => 'wget http://downloads.puppetlabs.com/facter/facter-1.7.3.tar.gz',
  'pkgsrc'  => $build_dir . '/tgzs/facter-1.7.3.tar.gz',
  'srcdir'  => "${src}/facter-1.7.3",
  'extract' => 'gunzip -c  %PKGSRC% | tar xf -',
  'install' => "${prefix}/bin/ruby install.rb",
};

$hiera121 = {
  'name'    => 'Hiera 1.2.1',
  'fetch'   => 'wget http://downloads.puppetlabs.com/hiera/hiera-1.2.1.tar.gz',
  'pkgsrc'  => $build_dir . '/tgzs/hiera-1.2.1.tar.gz',
  'srcdir'  => "${src}/hiera-1.2.1",
  'extract' => "gunzip -c %PKGSRC% | tar xf -",
  'install' => "test -f install.rb || cp ${top}/patches/hiera/install.rb . ; ${prefix}/bin/ruby install.rb --no-configs",
};

$puppet331 = {
  'name'    => 'Puppet 3.3.1',
  'fetch'   => 'wget http://downloads.puppetlabs.com/puppet/puppet-3.3.1.tar.gz',
  'pkgsrc'  => $build_dir . '/tgzs/puppet-3.3.1.tar.gz',
  'srcdir'  => "${src}/puppet-3.3.1",
  'extract' => 'gunzip -c  %PKGSRC% | tar xvf -',
  'install' => "${prefix}/bin/ruby install.rb --no-configs",
};

@packages = qw/
  libiconv114
  zlib128
  ncurses59
  readline62
  openssl101k
  ruby187p358
  rubyshadow214
  augeas110
  ruby_augeas050
  hiera121
  facter173
  puppet331
/;

$target = $build_dir . "/packages/eisuppet-$platform-$eis_puppet_version.pkg" ;

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

# GH: remove since using fpm_root
#$postinstall = <<EOT;
##!/bin/sh
#
#if [ ! -f /etc/puppet/puppet.conf ] ; then
#  if [ ! -d /etc/puppet ] ; then
#    mkdir -p /etc/puppet
#    chown bin /etc/puppet
#    chgrp bin /etc/puppet
#    chmod 755 /etc/puppet
#  fi
#
#  mv /opt/puppet/puppet.conf /etc/puppet/puppet.conf
#fi
#EOT

if ($ostype eq 'solaris-9') {
  $postinstall .= <<EOT;
if [ ! -f /etc/init.d/puppetd ] ; then
  cp /opt/puppet/puppetd /etc/init.d/puppetd
  chmod +x /etc/init.d/puppetd
fi
EOT
}
elsif ($ostype eq 'solaris-10') {
  $postinstall .= <<EOT;
if [ ! -f /etc/init.d/puppetd ] ; then
  cp /opt/puppet/puppetd /etc/init.d/puppetd
  chmod +x /etc/init.d/puppetd
fi
# TODO: This part is not working as expected
if [ ! -f /var/svc/manifest/network/puppetd.xml -a ! -f /lib/svc/method/svc-puppetd ] ; then
  cp /opt/puppet/puppetd.xml /var/svc/manifest/network/puppetd.xml
  cp /opt/puppet/svc-puppetd /lib/svc/method/svc-puppetd
  svccfg validate /var/svc/manifest/network/puppetd.xml
  svccfg import /var/svc/manifest/network/puppetd.xml
  chmod +x /lib/svc/method/svc-puppetd
fi
EOT
}

1;
