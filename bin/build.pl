#!/usr/bin/env perl

use Cwd qw/getcwd chdir/ ;
use Getopt::Long ;

chop ($hostname = `uname -n`) ;
chop ($arch = `uname -p`) ;

# Setup global varibales available later

$eis_puppet_version = '0.3.3' ;
my ($os, $rev) = (`uname -s`, `uname -r`) ;
chomp ($os, $rev) ;
$platform_os = "$os-$rev" ;
my $arch = `uname -p` ;
chomp $arch ;
$platform_arch = $arch ;
$platform = "$platform_os-$platform_arch" ;
$src = 'src.' . $hostname ;
$top = getcwd ;
$prefix = '/opt/puppet' ;

# ---

sub logprint {
    print LOG @_ ;
}


sub packup {
    my $p = shift ;
    return if -d $p->{'srcdir'} ;
    chdir $src ;
    ($foo = $p->{'packup'}) =~ s/%([A-Z]+)%/$p->{lc $1}/eg ;
    system $foo ;
    chdir $top ;
}

sub expand {
    my $ref = shift ;
    my $what = shift ;
    my $res ;

    ($res = $ref->{$what}) =~ s/%([A-Z]+)%/$ref->{lc $1}/eg ;
    return $res ;
}

sub build {
    my $p = shift ;
    
    mkdir "${top}/logs", 0755 unless -d "${top}/logs" ;
    chdir $p->{ 'srcdir' } ;
    
    while (($k, $v) = each %{$p->{ 'env' }}) {
	$remember {$k} = $v ;
	$ENV{$k} = $v ;
	logprint "setenv $k $v\n" ;
    }
    logprint "Configure: " . $p->{'configure'}, "\n" ;
    
    $cmd = expand ($p, 'configure') ;
    open CMD, "$cmd |" ;
    while (<CMD>) {
	logprint $_ ;
	print $_ if /fatal|error/i ;
    }
    close CMD ;

    logprint "make: " . $p->{'make'}, "\n" ;
    $cmd = expand ($p, 'make') ;
    open CMD, "$cmd |" ;
    while (<CMD>) {
	logprint $_ ;
	print $_ if /fatal|error/i ;
    }
    close CMD ;
    
    logprint "Install: " . $p->{'install'}, "\n" ;
    $cmd = expand ($p, 'install') ;
    open CMD, "$cmd |" ;
    while (<CMD>) {
	logprint $_ ;
	print $_ if /fatal|error/i ;
    }
    close CMD ;
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

    logprint $name, " ",  $group, "\n" ;

    grep ( { s/$name/bin/g ; s/$group/bin/g } @proto ) ;

    unshift @proto, ("d none /etc/puppet 0755 bin bin\n", 
		     "d none /opt/puppet 0755 bin bin\n",
		     "d none /var/lib/puppet 0755 bin bin\n") ;
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

sub debit {
    
    mkdir "${prefix}/DEBIAN", 0755 unless -d "${prefix}/DEBIAN" ;
    open CTRL, "> ${prefix}/DEBIAN/control" ;
    print CTRL join ("\n", @debinfo), "\n" ;
    close CTRL ;
}


# --- 

$dump = 0 ;
GetOptions (
	    'top=s'      => \$top, 
	    'prefix=s'   => \$prefix,
	    'packages=s' => \@pac,
	    'dump'       => \$dump
	    ) ;

open LOG, "> $top/logs/build.$hostname-$$" ;

logprint "settings\n" ;
require "$top/bin/settings.pl" ;
if (-f "$top/bin/settings.$platform_os.pl") {
    logprint "$platform_os settings\n" ;
    require "$top/bin/settings.$platform_os.pl" ;
}
if (-f "$top/bin/settings.$hostname.pl") {
    logprint "$hostname settings\n" ;
    require "$top/bin/settings.$hostname.pl" ;
}


@packages = split (/,/, join (',', @pac)) if @pac ;

print join (", ", @packages), "\nDUmp=$dump\n" ;

if ($dump) {
    foreach $name (@packages) {
	$p = ${$name} ; 
        print $name, "\n" ;
        foreach (keys %{$p}) {    
	    print "\t$_ => $p->{$_} \n" ; # if ref \{$p->{$_}} eq 'SCALAR' ;
	    if (ref $p->{$_} eq 'HASH') {
		print "\t", $p->{$_}, "\n" ;
		while (($k, $v) = each %{$p->{$_}}) {
		    print "\t\t$k => $v \n" ;
		}
	    }
	}
    }
    exit 0 ;
}

mkdir $src, 0755 unless -d $src ;
foreach $name (@packages) {
    $_ = ${$name} ;
    logprint $_->{'name'}, "\n" ;
    packup ($_) unless -d $_->{'srcdir'} ;
    chdir $_->{'srcdir'} ;
    build ($_) ;
    chdir $top ;
}

if (1) {
    packit () ;
}
