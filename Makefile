
ruby_version = 1.8.7-p358
puppet
prefix = /home/qnilpau/workarea/build

all:  ${prefix}/bin/ruby

fetch:
	bin/fetch
clean: 
	rm -f ${prefix}/bin/ruby

${prefix}/bin/ruby: ${ruby_src}
	#bin/build.`uname -s` ${ruby_src} ${prefix}
	cd ${ruby_src} ; ./configure --prefix=${prefix} --without-gcc ; make ; make install

${ruby_src}: ${ruby_tgz}
	gunzip -c ${ruby_tgz} | (cd src ; tar xf -)

${ruby_tgz}: 
	echo wget -O ${ruby_tgz} ${ruby_url}

${zlib_src}: ${zlib_tgz}
	gunzip -c ${zlib_tgz} | (cd src ; tar xf -)

${zlib_tgz}: 
	wget -O ${zlib_tgz} ${zlib_url}

${openssl_src}: ${openssl_tgz}
	gunzip -c ${openssl_tgz} | (cd src ; tar xf -)

${openssl_tgz}: 
	wget -O ${openssl_tgz} ${openssl_url}

