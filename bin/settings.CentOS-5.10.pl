$bits = `uname -m`;
if ($bits =~ /i686/) {
  $syst = 'linux-elf';
} else {
  $syst = 'linux-x86_64';
}

$pathmap{$platform_os} = "$ENV{PATH}:/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin";

unshift @packages, 'libxml2291',;

$zlib128 = {
  %{$zlib128},
  'env'       => {
    'CFLAGS' => '-fPIC',
    'LDFLAGS' => '-static-libgcc',
    'PATH'    => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$openssl101k = {
  %{$openssl101k},
  'configure' => "make clean ; ./Configure  -L${prefix}/lib -I${prefix}/include shared zlib-dynamic --prefix=${prefix} --openssldir=${prefix} ${syst} -static-libgcc",
  'env'       => {
    'CFLAGS' => '-fPIC',  
    'LDFLAGS' => '-static-libgcc',
    'PATH'    => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$libxml2291 = {
  %{$libxml2291},
  'configure' => "make clean; ./configure --prefix=${prefix} --without-python",
  'env' => {
    'CFLAGS' => '-fPIC',  
    'LDFLAGS' => '-static-libgcc',
    'LIBXML_CFLAGS' => "-I${prefix}/libxml2",
    'LIBXML_LIBS' => "-lxml2",
    'PATH' => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$libiconv114 = {
  %{$libiconv114},
  'configure' => "make clean; ./configure --prefix=${prefix} --with-libiconv-prefix=${prefix}",
  'make'      => 'make',
  'install'   => 'make install',
  'env' => {
    'CFLAGS' => '-fPIC',  
    'LDFLAGS' => "-static-libgcc -L${prefix}/lib -Wl,-rpath,${prefix}/lib",
    'PATH' => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$ncurses59 = {
  %{$ncurses59},
  'configure'	=> "make clean; ./configure --prefix=${prefix} --with-terminfo-dirs=/usr/share/lib/terminfo --enable-termcap",
  'env' => {
    'CFLAGS' => '-fPIC',  
    'LDFLAGS' => '-static-libgcc',
    'PATH' => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$ruby187p358 = {
  %{$ruby187p358},
  'configure' => "make clean; ./configure --prefix=${prefix}",
  'env' => {
    'CFLAGS' => '-fPIC',  
    'CPPFLAGS' => "-I${prefix}/include",
    'LDFLAGS' => "-static-libgcc -L${prefix}/lib -Wl,-rpath,${prefix}/lib",
    'PATH' => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$readline62 = {
  %{$readline62},
  'configure' => "make clean; ./configure --with-curses --prefix=${prefix}",
  'env' => {
    'CFLAGS' => '-fPIC -static-libgcc',  
    'LDFLAGS' => '-static-libgcc',
    'PATH' => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$augeas110 = {
  %{$augeas110},
  'configure' => "make clean; ./configure --prefix=${prefix}",
  'install'   => 'make install DESTDIR=${prefix}',
  'env' => {
    'CFLAGS' => '-fPIC -static-libgcc -lncurses',  
    'CPPFLAGS' => "-I${prefix}/include",
    'LDFLAGS' => "-static-libgcc -L${prefix}/lib -Wl,-rpath,${prefix}/lib",
    'LIBXML_CFLAGS' => "-I${prefix}/include/libxml2",
    'LIBXML_LIBS'   => '-lxml2',
    'PATH'          => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};

$ruby_augeas050 = {
  %{$ruby_augeas050},
  'env' => {
    'CFLAGS' => "-fPIC -static-libgcc",
    'LDFLAGS' => "-L${prefix}/lib -Wl,-rpath,${prefix}/lib",
    'PATH'          => $pathmap {$platform_os} || '/bin:/usr/bin',
    "LIBXML_CFLAGS" => "-I${prefix}/include/libxml2",
    'LIBXML_LIBS'   => '-lxml2',
  },
};

$rubyshadow214 = {
  %{$rubyshadow214},
  'install'   => "make install",
  'env' => {
    'CFLAGS' => '-static-libgcc',
    'LDFLAGS' => "-L${prefix}/lib -Wl,-rpath,${prefix}/lib",
    'PATH'   => $pathmap {$platform_os} || '/bin:/usr/bin',
  },
};
