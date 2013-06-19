#!/bin/sh

prefix=/opt/puppet
build=/var/tmp/build-puppet
#build=/proj/unixteam/puppet/src
ruby_version=1.8.7-p72
ruby_source=http://ftp.ruby-lang.org/pub/ruby/1.8/ruby-$ruby_version.tar.gz
zlib_version=1.2.6
zlib_source=http://dfn.dl.sourceforge.net/project/libpng/zlib/$zlib_version/zlib-$zlib_version.tar.gz
openssl_version=0.9.8w
openssl_source=http://www.openssl.org/source/openssl-$openssl_version.tar.gz
puppet_version=2.7.13
puppet_source=http://puppetlabs.com/downloads/puppet/puppet-$puppet_version.tar.gz
yaml_version=0.1.4
yaml_source=http://pyyaml.org/download/libyaml/yaml-$yaml_version.tar.gz
facter_version=1.6.8
facter_source=http://puppetlabs.com/downloads/facter/facter-$facter_version.tar.gz

get_source () {
  typeset sw=$1
  typeset srcdir=`eval echo ${sw}-'$'${sw}_version`
  typeset url=`eval echo '$'${sw}_source`
  test -d $srcdir && return
  test -f $srcdir || wget -O $srcdir.tar.gz $url
  gzip -dc $srcdir.tar.gz | tar xf -
}

test -d "$prefix" || mkdir -p $prefix
test -d "$build" || mkdir -p $build

cd $build
get_source zlib
get_source openssl
get_source yaml
get_source ruby
get_source facter
get_source puppet

# zlib
build_zlib() {
 echo Building zlib
 cd $build
 cd zlib-$zlib_version
 make clean
 case `uname -s` in
   'SunOS')
     PATH=/usr/sfw/bin:/usr/ccs/bin:$PATH
     export PATH
     ./configure --prefix=$prefix
     gmake && gmake test && gmake install
     break
   ;;
   'HP-UX')
     CC=/usr/local/bin/gcc
     export CC
     CFLAGS="-O2 -g -pthread -mlp64 -w -pipe -Wall"
     ./configure --prefix=$prefix
     export CFLAGS
     make && make test && make install
     break
   ;;
   'Linux')
      ./configure --prefix=$prefix
      make && make test && sudo make install
      break
   ;;
   *)
     echo Unsupported OS `uname -s`
     exit 1
     break
   ;;
 esac
}

# openssl
build_openssl() {
## NOTE! Probably need "shared" for Sol and HPUX below
 echo Building openssl
 cd $build
 cd openssl-$openssl_version
 make clean
 case `uname -s` in
   'SunOS')
     PATH=/usr/sfw/bin:/usr/ccs/bin:$PATH
     export PATH
     CFLAGS="-fPIC"
     export CFLAGS
     perl  Configure solaris-sparcv9-gcc --prefix=$prefix
     gmake && gmake test && gmake install
     break
   ;;
   'HP-UX')
     CC=/usr/local/bin/gcc
     export CC
     CFLAGS="-O2 -g -pthread -mlp64 -w -pipe -Wall"
     export CFLAGS
     perl Configure hpux64-ia64-gcc --prefix=$prefix
     make && make test && make install   
     break
   ;;
   'Linux')
     ./config --prefix=$prefix -fPIC shared
     make && make test && sudo make install   
     break
   ;;
   *)
     echo Unsupported OS `uname -s`
     exit 1
     break
   ;;
 esac
}

# yaml
build_yaml() {
## NOTE! Probably need "shared" for Sol and HPUX below
 echo Building yaml
 cd $build
 cd yaml-$yaml_version
 make clean
 case `uname -s` in
   'SunOS')
     PATH=/usr/sfw/bin:/usr/ccs/bin:$PATH
     export PATH
     CFLAGS="-fPIC"
     export CFLAGS
     ./configure --prefix=$prefix
     gmake && gmake install
   ;;
   'HP-UX')
     CC=/usr/local/bin/gcc
     export CC
     CFLAGS="-O2 -g -pthread -mlp64 -w -pipe -Wall"
     export CFLAGS
     ./configure --prefix=$prefix
     make && make install   
   ;;
   'Linux')
     ./configure --prefix=$prefix
     make && sudo make install   
   ;;
   *)
     echo Unsupported OS `uname -s`
     exit 1
   ;;
 esac
}

#  ruby
build_ruby() {
 echo Building ruby
 cd $build
 cd ruby-$ruby_version
 make clean
 case `uname -s` in
   'SunOS')
     PATH=/usr/sfw/bin:/usr/ccs/bin:$PATH
     export PATH
     CPPFLAGS="-I$prefix/include"
     export CPPFLAGS
     LDFLAGS="-L$prefix/lib"
     export LDFLAGS
     ./configure --prefix=$prefix
     gmake && gmake test && gmake install
     break
   ;;
   'HP-UX')
     PATH=/usr/local/bin:$PATH
     export PATH
     CC=/usr/local/bin/gcc
     export CC
     CFLAGS="-O2 -g -pthread -mlp64 -w -pipe -Wall"
     export CFLAGS
     
     CPPFLAGS "-DHAVE_HMAC_CTX_COPY -DHAVE_EVP_CHIPER_CTX_COPY -I/opt/puppet/in
clude"
     export CPPFLAGS
     LDFLAGS="-L$prefix/lib"
     export LDFLAGS
     ./configure --prefix=$prefix --with-gcc --enable-pthread --enable-shared -
-disable-rpath
     make && make test && make install
     break
   ;;
   'Linux')
     CPPFLAGS="-I$prefix/include -fPIC"
     export CPPFLAGS
     LDFLAGS="-L$prefix/lib -Wl,-rpath=/opt/puppet/lib"
     export LDFLAGS
     ./configure --prefix=$prefix  
     ## not working ./configure --prefix=$prefix --with-openssl=$prefix/lib --w
ith-openssl-includes=$prefix/include --with-zlib=$prefix/lib --with-zlib-include
s=$prefix/include
     make && make test && sudo make install
     cd ext/openssl
     /opt/puppet/bin/ruby extconf.rb
     make && sudo make install
     break
   ;;
   *)
     echo To be implemented
     exit 1
     break
   ;;
 esac
}

verify_ruby () {

 echo Testing ruby openssl
 $prefix/bin/ruby -ropenssl -e 'puts :OK'
 echo Testing ruby zlib
 $prefix/bin/ruby -rzlib -e 'puts :OK'
 echo Testing ruby md5
 $prefix/bin/ruby -rmd5 -e 'puts :OK'
 echo Tetsing ruby sha1
 $prefix/bin/ruby -rsha1 -e 'puts :OK'
 echo End test
}
 
#  facter
install_facter() {
 echo Installing Facter
 cd $build
 cd facter-$facter_version
 sudo /opt/puppet/bin/ruby install.rb
}

#  puppet
install_puppet() {
 echo Installing Puppet
 cd $build
 cd puppet-$puppet_version
 sudo /opt/puppet/bin/ruby install.rb
}

if [ -z "$1" ] ; then
 do_zlib=1
 do_openssl=1
 do_yaml=1
 do_ruby=1
 do_facter=1
 do_puppet=1
 do_verify=1
else
 do_zlib=0
 do_openssl=0
 do_yaml=0
 do_ruby=0
 do_facter=0
 do_puppet=0
 do_verify=0
 while [ -n "$1" ] ; do
   eval "do_$1=1"
   shift
 done
fi

if [ $do_zlib -eq 1    ] ; then build_zlib      ; fi
if [ $do_openssl -eq 1 ] ; then build_openssl   ; fi
if [ $do_yaml -eq 1    ] ; then build_yaml      ; fi
if [ $do_ruby -eq 1    ] ; then build_ruby      ; fi
if [ $do_verify -eq 1  ] ; then verify_ruby     ; fi
if [ $do_facter -eq 1  ] ; then install_facter  ; fi
if [ $do_puppet -eq 1  ] ; then install_puppet  ; fi

