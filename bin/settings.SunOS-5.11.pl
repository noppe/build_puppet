#
# Solaris 11 settings
#

require "${top}/bin/settings.SunOS-5.10.pl";

$augeas110 = {
    %{$augeas110},
    'configure' => "./configure --prefix=${prefix} CPPFLAGS=\"-I${prefix}/include -I/usr/include/libxml2\" LDFLAGS=\"-L${prefix}/lib -R${prefix}/lib\" CFLAGS=-static-libgcc",
    'env'       =>  {
      'PATH'          => $pathmap {$platform_os},
      'LIBXML_CFLAGS' => '-I/usr/include/libxml2',
      'LIBXML_LIBS'   => '-lxml2',
    },
};
