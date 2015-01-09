#
# Solaris settings
#

if ($platform_arch =~ /sparc/) {
  $openssl101k = {
    %{$openssl101k},
    'configure' => "./Configure  -L${prefix}/lib -I${prefix}/include -R${prefix}/lib shared zlib-dynamic --prefix=${prefix} --openssldir=${prefix} solaris-sparcv9-gcc -static-libgcc",
  };
} else {
  $openssl101k = {
    %{$openssl101k},
    'configure' => "./Configure  -L${prefix}/lib -I${prefix}/include -R${prefix}/lib shared zlib-dynamic --prefix=${prefix} --openssldir=${prefix} solaris-x86-gcc -static-libgcc",
  };
}

1;
