#
# Solaris settings
#


if ($platform_arch eq 'sparc') {
  $openssl101e = {
    %{$openssl101e},
    'configure' => "./Configure  -L${prefix}/lib -I${prefix}/include -R${prefix}/lib shared zlib-dynamic --prefix=${prefix} --openssldir=${prefix} solaris-sparcv9-gcc -static-libgcc",
  } ;
  $augeas110 = {
    %{$augeas110},
    'configure' => "./configure --prefix=${prefix} CPPFLAGS=-I${prefix}/include LDFLAGS=\"-L${prefix}/lib -R${prefix}/lib -lncurses\" CFLAGS=-static-libgcc",
  } ; 

} else {
  $openssl101e = {
    %{$openssl101e},
    'configure' => "./Configure  -L${prefix}/lib -I${prefix}/include -R${prefix}/lib shared zlib-dynamic --prefix=${prefix} --openssldir=${prefix} solaris-x86-gcc -static-libgcc",
  } ;
  $augeas110 = {
    %{$augeas110},
    'configure' => "./configure --prefix=${prefix} CPPFLAGS=-I${prefix}/include LDFLAGS=\"-L${prefix}/lib -R${prefix}/lib\ -lcurses\" CFLAGS=-static-libgcc",
  } ; 
}

1;
