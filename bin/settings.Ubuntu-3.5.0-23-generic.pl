
$openssl098w = { 
    %{$openssl098w},
    'configure' => "./Configure  -L${prefix}/lib -I${prefix}/include shared zlib-dynamic --prefix=${prefix} --openssldir=${prefix} linux-x86_64 -static-libgcc",
} ;
		 
$ruby187p358 = {
    %{$ruby187p358},
    'configure' => "./configure --prefix=${prefix} LDFLAGS=\'-static-libgcc -L${prefix}/lib -Wl,-rpath,${prefix}/lib \' CPPFLAGS=-I${prefix}/include",
} ;

$augeas110 = {
    %{$augeas110},
    'configure' => "./configure --prefix=${prefix} CPPFLAGS=-I${prefix}/include LDFLAGS=\'-L${prefix}/lib -Wl,-rpath,${prefix}/lib\' CFLAGS=-static-libgcc",
} ;
