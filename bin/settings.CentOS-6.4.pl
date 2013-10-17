$bits = `uname -m` ;
if ($bits eq 'i686') {
  $syst = 'linux-elf' ;
} else {
  $syst = 'linux-x86_64' ;
}
$openssl098w = { 
    %{$openssl098w},
    'configure' => "./Configure  -L${prefix}/lib -I${prefix}/include shared zlib-dynamic --prefix=${prefix} --openssldir=${prefix} ${syst} -static-libgcc",
} ;
		 
$ruby187p358 = {
    %{$ruby187p358},
    'configure' => "./configure --prefix=${prefix} LDFLAGS=\'-static-libgcc -L${prefix}/lib -Wl,-rpath,${prefix}/lib \' CPPFLAGS=-I${prefix}/include",
} ;

$augeas110 = {
    %{$augeas110},
    'configure' => "./configure --prefix=${prefix} CPPFLAGS=-I${prefix}/include LDFLAGS=\'-L${prefix}/lib -Wl,-rpath,${prefix}/lib\' CFLAGS=\'-static-libgcc -lncurses\'",
} ;
