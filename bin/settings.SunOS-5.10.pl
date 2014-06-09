#
# Solaris settings
#


if ($platform_arch eq 'sparc') {
  $openssl101g = {
    %{$openssl101g},
    'configure' => "./Configure  -L${prefix}/lib -I${prefix}/include -R${prefix}/lib shared zlib-dynamic --prefix=${prefix} --openssldir=${prefix} solaris-sparcv9-gcc -static-libgcc",
  };
  $augeas110 = {
    %{$augeas110},
    'configure' => "./configure --prefix=${prefix} CPPFLAGS=-I${prefix}/include LDFLAGS=\"-L${prefix}/lib -R${prefix}/lib -lncurses\" CFLAGS=-static-libgcc",
    'env' => {
      'PATH'          => $pathmap {$platform_os} || '/bin:/usr/bin',
      'LIBXML_CFLAGS' => '-I/usr/include/libxml2',
      'LIBXML_LIBS'   => '-lxml2',
    },
  };
  $ruby_augeas050 = {
    %{$ruby_augeas050},
    'make'      => "cd ext/augeas ; gmake CC=\"gcc -I/usr/include/libxml2 -laugeas\" ; cd ../..",
    'env' => {
      'PATH'          => $pathmap {$platform_os} || '/bin:/usr/bin',
      'LIBXML_CFLAGS' => '-I/usr/include/libxml2',
      'LIBXML_LIBS'   => '-lxml2',
    },
  }
} else {
  $openssl101g = {
    %{$openssl101g},
    'configure' => "./Configure  -L${prefix}/lib -I${prefix}/include -R${prefix}/lib shared zlib-dynamic --prefix=${prefix} --openssldir=${prefix} solaris-x86-gcc -static-libgcc",
  };
  $augeas110 = {
    %{$augeas110},
    'configure' => "./configure --prefix=${prefix} CPPFLAGS=-I${prefix}/include LDFLAGS=\"-L${prefix}/lib -R${prefix}/lib\ -lcurses\" CFLAGS=-static-libgcc",
    'env' => {
      'PATH'          => $pathmap {$platform_os} || '/bin:/usr/bin',
      'LIBXML_CFLAGS' => '-I/usr/include/libxml2',
      'LIBXML_LIBS'   => '-lxml2',
    },
  };
  $ruby_augeas050 = {
    %{$ruby_augeas050},
    'make'      => "cd ext/augeas ; gmake CC=\"gcc -I/usr/include/libxml2 -laugeas\" ; cd ../..",
    'env' => {
      'PATH'          => $pathmap {$platform_os} || '/bin:/usr/bin',
      'LIBXML_CFLAGS' => '-I/usr/include/libxml2',
      'LIBXML_LIBS'   => '-lxml2',
    },
  }
}


1;
