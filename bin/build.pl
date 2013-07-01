#!/usr/bin/env perl

use Cwd qw/getcwd chdir/ ;

chop ($hostname = `uname -n`) ;
chop ($arch = `uname -p`) ;
$src = 'src.' . $hostname ;
$top = getcwd ; 
$prefix = '/opt/puppet' ;




require "$top/bin/settings.pl" ;

sub packup {
    my $p = shift ;
    return if -d $p->{'srcdir'} ;
    chdir $src ;
    ($foo = $p->{'packup'}) =~ s/%([A-Z]+)%/$p->{lc $1}/eg ;
    system $foo ;
    chdir $top ;
}

sub build {
    my $p = shift ;
    
    open LOG, "> $top/logs/build." . $p->{'name'} ;
    chdir $p->{ 'srcdir' } ;
    
    while (($k, $v) = each %{$p->{ 'env' }}) {
	$remember {$k} = $v ;
	$ENV{$k} = $v ;
	print LOG "setenv $k $v\n" ;
    }
    print LOG "Configure: " . $p->{'configure'}, "\n" ;
    system $p->{ 'configure' } ;
    print LOG "make: " . $p->{'make'}, "\n" ;
    system $p->{ 'make' } ;
    print LOG "Install: " . $p->{'install'}, "\n" ;
    system $p->{ 'install' } ;
    while (($k, $v) = each %remember) {
	$ENV{$k} = $v ;
    }
}

sub packit {

    # cleanup old files
    foreach (qw/prototype pkginfo postinstall/) {
	unlink "${prefix}/$_" ;
    }
    
    my @proto = `cd ${prefix} ; find . -print | pkgproto` ;

    #chop (my $name = `id -n -u`) ;
    #chop (my $group = `id -n -g`) ;
    my $id = `id -a` ;
    (my $name, $group) = ($id =~ m/\((\w+?)\).*?\((\w+)\)/) ;

    print $name, " ",  $group, "\n" ;

    grep ( { s/$name/bin/g ; s/$group/bin/g } @proto ) ;

    if ($postinstall) {
	unshift @proto, "i postinstall=./postinstall\n" ;
	open PI, "> ${prefix}/postinstall" ;
	print PI $postinstall ;
        close PI ;
    }
    unshift @proto, "i pkginfo=./pkginfo\n" ;
    open PROTO, "> ${prefix}/prototype" ;
    print PROTO @proto ;
    close PROTO ;

    open PKGINFO, "> ${prefix}/pkginfo" ;
    print PKGINFO join ("\n", @pkginfo) ;
    close PKGINFO ;

    system "cd ${prefix} ; pkgmk -o -r ${prefix}" ;
    system "cd /var/spool/pkg ; pkgtrans -s /var/spool/pkg ${target} EISpuppet" ;
}

mkdir $src, 0755 unless -d $src ;
foreach (@packages) {
    print $_->{'name'}, "\n" ;
    packup ($_) unless -d $_->{'srcdir'} ;
    chdir $_->{'srcdir'} ;
    build ($_) ;
    chdir $top ;
}
packit () ;
