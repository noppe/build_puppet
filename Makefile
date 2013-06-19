

# Uncomment one of below sections
ruby_version = 1.8.7-p371
ruby_tgz = tgzs/ruby-${ruby_version}.tar.gz
ruby_url = ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-${ruby_version}.tar.gz
ruby_src = src/ruby-${ruby_version}
# ---
# ruby_version = 2.0.0-p195
# ruby_tgz = tgzs/ruby-${ruby_version}.tar.gz
# ruby_url = ftp://ftp.ruby-lang.org/pub/ruby/2.0/ruby-${ruby_version}.tar.gz
# ruby_src = src/ruby-${ruby_version}
# ===

#zlib_version = 1.2.6
zlib_version = 1.2.8
zlib_tgz = tgzs/zlib-${zlib_version}.tar.gz
zlib_url = http://dfn.dl.sourceforge.net/project/libpng/zlib/${zlib_version}/zlib-${zlib_version}.tar.gz
zlib_src = src/zlib-${zlib_version}
# ===

openssl_version = 0.9.8w
openssl_tgz = tgzs/openssl-${openssl_version}.tar.gz
openssl_url = http://www.openssl.org/source/openssl-${openssl_version}.tar.gz
openssl_src = src/openssl-${openssl_version}
# ===

prefix = /home/noppe/work/build

# fetch: ${ruby_src} ${zlib_src} ${openssl_src}

all: ${prefix}/lib/libz.so ${prefix}/bin/openssl ${prefix}/bin/ruby

clean: 
	rm -f ${prefix}/bin/ruby ${prefix}/bin/openssl  ${prefix}/lib/libz.so

${prefix}/bin/ruby:
	bin/build.`uname -s` ${ruby_src} ${prefix}

${prefix}/bin/openssl:
	bin/build.`uname -s` ${openssl_src} ${prefix}

${prefix}/lib/libz.so:
	bin/build.`uname -s` ${zlib_src} ${prefix}

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

