require "${top}/bin/settings.CentOS-6.4.pl" ;

$libxml2291 = {
  'name'      => 'libxml2-2.9.1',
  'fetch'     => 'wget https://git.gnome.org/browse/libxml2/snapshot/libxml2-2.9.1.tar.gz',
  'pkgsrc'    => $top . '/tgzs/libxml2-fix.tar.gz',
  'srcdir'    => "${top}/${src}/libxml2-2.9.1",
  'extract'   => "gunzip -c  %PKGSRC% | tar xvf - ",
  'configure' => "./configure --prefix=${prefix} LDFLAGS=-static-libgcc ",
  'make'      => 'make',
  'install'   => 'make install',
  'env' => {
    'PATH'    => $pathmap {$platform_os} || '/bin:/usr/bin',
    'LIBXML_CFLAGS' => "-I${prefix}/libxml2",
    'LIBXML_LIBS'   => '-lxml2',
  },
};

unshift @packages, 'libxml2291',;
1;
