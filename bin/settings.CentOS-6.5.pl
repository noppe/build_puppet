$bits = `uname -m`;
if ($bits =~ /i686/) {
  $openssl_compiler = 'linux-elf';
} else {
  $openssl_compiler = 'linux-x86_64';
}

$libxml2291 = {
  'name'      => 'libxml2-2.9.1',
  'fetch'     => 'wget ftp://xmlsoft.org/libxml2/libxml2-2.9.1.tar.gz',
  'pkgsrc'    => $build_dir . '/tgzs/libxml2-2.9.1.tar.gz',
  'srcdir'    => "${src}/libxml2-2.9.1",
  'extract'   => 'gunzip -c  %PKGSRC% | tar xvf - ',
  'configure' => "make clean; ./configure --prefix=${prefix} LDFLAGS=-static-libgcc --without-python",
  'make'      => 'make',
  'install'   => 'make install',
  'env' => {
    'PATH'          => $pathmap {$platform_os} || '/bin:/usr/bin',
    'LIBXML_CFLAGS' => "-I${prefix}/libxml2",
    'LIBXML_LIBS'   => '-lxml2',
  },
};

unshift @packages, 'libxml2291',;

$openssl101g = {
  %{$openssl101g},
  'configure' => "make clean; ./Configure  -L${prefix}/lib -I${prefix}/include shared zlib-dynamic --prefix=${prefix} --openssldir=${prefix} ${openssl_compiler} -static-libgcc",
};

$ruby187p358 = {
  %{$ruby187p358},
  'configure' => "make clean; ./configure --prefix=${prefix} LDFLAGS=\'-static-libgcc -L${prefix}/lib -Wl,-rpath,${prefix}/lib \' CPPFLAGS=-I${prefix}/include",
};

$augeas110 = {
  %{$augeas110},
  'configure' => "make clean; ./configure --prefix=${prefix} CPPFLAGS=-I${prefix}/include LDFLAGS=\'-L${prefix}/lib -Wl,-rpath,${prefix}/lib\' CFLAGS=\'-static-libgcc -lncurses\'",
};
