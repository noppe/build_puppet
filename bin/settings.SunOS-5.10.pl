#
# Solaris settings
#

#$zlib128 = {
#    %{$zlib128},
#    $zlib128->{'env'}->{'PATH'} = $solpath,
#} ;

if ($platform_arch eq 'sparc') {
    $openssl098w = {
	%{$openssl098w},
	'configure' => "./Configure  -L${prefix}/lib -I${prefix}/include -R${prefix}/lib shared zlib-dynamic --prefix=${prefix} --openssldir=${prefix} solaris-sparcv9-gcc -static-libgcc",
    } ;
} else {
    $openssl098w = {
	%{$openssl098w},
	'configure' => "./Configure  -L${prefix}/lib -I${prefix}/include -R${prefix}/lib shared zlib-dynamic --prefix=${prefix} --openssldir=${prefix} solaris-x86-gcc -static-libgcc",
    } ;
}

