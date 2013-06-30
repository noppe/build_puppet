
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

# @packages = ( $zlib128,
# 	      $openssl098w,
# 	      $ruby187p358,
# 	      $rubyshadow214,
# 	      $facter171,
# 	      $puppet322,
#     ) ;
# 
chop ($arch = `uname -p`) ;
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
