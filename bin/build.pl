#!/usr/bin/env perl

use lib './bin' ;
use Cwd qw/getcwd chdir/ ;

chop ($hostname = `uname -n`) ;
$src = 'src.' . $hostname ;
$top = getcwd ;
$prefix = '/opt/puppetz' ;

require 'settings.pl' ;

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

    my @proto = `cd ${prefix} ; find . -print | pkgproto` ;

    chop (my $name = `id -n -u`) ;
    chop (my $group = `id -n -g`) ;

    print $name, " ",  $group, "\n" ;

    grep ( { s/$name/bin/g ; s/$group/bin/g } @proto ) ;
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

mkdir $src unless -d $src ;
foreach (@packages) {
    print $_->{'name'}, "\n" ;
    packup ($_) unless -d $_->{'srcdir'} ;
    chdir $_->{'srcdir'} ;
    build ($_) ;
    chdir $top ;
}
packit () ;
