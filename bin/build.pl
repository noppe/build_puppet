#!/usr/bin/env perl

use Cwd qw/getcwd chdir/ ;
use Getopt::Long ;

chop ($hostname = `uname -n`) ;
chop ($arch = `uname -p`) ;

# Setup global varibales available later

my ($os, $rev) = (`uname -s`, `uname -r`) ;
chomp ($os, $rev) ;
if ($os eq 'Linux') {
  if ( -f "/etc/redhat-release" ) {
    open FH, "/etc/redhat-release" ;
    $x = <FH> ; close FH ;
    if ($x =~ /^Red Hat/ ) {
      if ($x =~ /release\s+(\d+)\.(\d+)/) {
        $maj = $1 ;
        $min = $2 ;
        $rel = $maj . '.' . $min ;
      }
      $platform_os = 'RedHat-' . $rel ;
      $ostype = 'redhat-' . $maj . '-compat' ;
    } elsif ($x =~ /(\w+)\s+release\s+(\d+)\.(\d+)/ ) {
      $maj = $2 ; $min = $3 ;
      $flavor = $1 . "-" . $maj . '.' . $min ;
      $platform_os = $flavor ;
      $ostype = 'redhat-' . $maj . '-compat' ;
    }
  } elsif ( -f "/etc/SuSE-release" ) {
    open FH, "/etc/SuSE-release" ;
    while (<FH>) {
      /^VERSION\s*=\s*(\d+)$/ && { $maj = $1 } ;
      /^PATCHLEVEL\s*=\s*(\d+)$/ && { $min = $1 } ;
    }
    close FH ;
    $ostype = "redhat-" . ($maj > 9 ? "6" : "5") . '-compat' ;
    $platform_os = "SuSE-$maj.$min" ;
  } elsif ( -f '/etc/lsb-release' ) {
    open FH, '/etc/lsb-release' ;
    while (<FH>) {
      if (/DISTRIB_RELEASE=(\d+)\.(\d+)/) { $maj = $1 ; $min = $2  ; } ;
    }
    close FH ;
    $ostype = 'redhat-' . ($maj > 12 ? "6" : "5") . '-compat' ;
    $platform_os = "Ubuntu-$maj.$min" ; # Wild guessing here. Fix!
  } else {
    my $flavor = `uname -v` ;
    chomp ($flavor) ;
    if ($flavor =~ /-(Ubuntu)/) {
      $platform_os = "$1-$rev" ;
      $ostype = 'redhat-5-compat' ;
    } else {
      $platform_os = "$flavor-$rev" ;
    }
  }
} elsif ($os eq 'SunOS') {
  ($srev = $rev) =~ s/^5\.// ;
  $ostype = 'solaris-' . $srev ;
}


my $arch = `uname -p` ;
chomp $arch ;
$platform_arch = $arch ;
$platform = "$platform_os-$platform_arch" ;
$src = 'src.' . $hostname ;
$top = getcwd ;
$prefix = '/opt/puppet' ;

# ---

sub logprint {
    print LOG1 @_ ;
    print LOG2 @_ ;
}


sub packup {
    my $p = shift ;
    return if -d $p->{'srcdir'} ;
    chdir $src ;
    ($foo = $p->{'packup'}) =~ s/%([A-Z]+)%/$p->{lc $1}/eg ;
    open (FOO, "$foo |") || die 'Packup fail' ;
    while (defined <FOO>) {
  logprint $_ ;
    }
    close FOO ;
    if ($?) {
  print "packup returned $?) \n" ;
    }
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

    chdir $p->{ 'srcdir' } ;

    while (($k, $v) = each %{$p->{ 'env' }}) {
  $remember {$k} = $v ;
  $ENV{$k} = $v ;
  logprint "setenv $k $v\n" ;
    }
    logprint "Configure: " . $p->{'configure'}, "\n" ;

    $cmd = expand ($p, 'configure') ;
    logprint "  Command: $cmd " ;
    open (CMD, "$cmd |") ;
    while (<CMD>) {
  logprint $_ ;
        print $_ if /fatal|error/i ;
    }
    close CMD ;
    #exit $? if $? ;

    logprint "make: " . $p->{'make'}, "\n" ;
    $cmd = expand ($p, 'make') ;
    open (CMD, "$cmd |") ;
    while (<CMD>) {
  logprint $_ ;
  print $_ if /fatal|error/i ;
    }
    close CMD ;
    #exit $? if $? ;

    logprint "Install: " . $p->{'install'}, "\n" ;
    $cmd = expand ($p, 'install') ;
    open (CMD, "$cmd |") ;
    while (<CMD>) {
  logprint $_ ;
  print $_ if /fatal|error/i ;
    }
    close CMD ;
    #exit $? if $? ;

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
  open (PI, "> ${prefix}/postinstall") ;
  print PI $postinstall ;
        close PI ;
    }
    unshift @proto, "i pkginfo=./pkginfo\n" ;
    open (PROTO, "> ${prefix}/prototype") ;
    print PROTO @proto ;
    close PROTO ;

    open (PKGINFO, "> ${prefix}/pkginfo") ;
    print PKGINFO join ("\n", @pkginfo) ;
    close PKGINFO ;

    system "cd ${prefix} ; pkgmk -o -r ${prefix}" ;
    system "cd /var/spool/pkg ; pkgtrans -s /var/spool/pkg ${target} EISpuppet" ;
}

sub rpmit {
    open (CTRL, "> /tmp/puppet.spec") ;
    print CTRL join ("\n", @rpminfo), "\n" ;
    close CTRL ;

    system "rpmbuild --define \"_rpmdir /tmp\" --buildroot=$top -bb /tmp/puppet.spec" ;
}

sub debit {
    mkdir "${prefix}/DEBIAN", 0755 unless -d "${prefix}/DEBIAN" ;
    open (CTRL, "> ${prefix}/DEBIAN/control") ;
    print CTRL join ("\n", @debinfo), "\n" ;
    close CTRL ;
}

sub fetch {
    my $p = shift ;
    my $cmd = $p->{'fetch'} ;
    chdir "${top}/tgzs" ;
    open (FETCH, "$cmd |") || die "Fetching " . $p->{'name'} . " failed" ;
    while (defined <FETCH>) {
  logprint $_ ;
    }
    close FETCH ;
    if ($?) {
  print "Fetch retval = $? \n" ;
    }
    chdir $top ;
}

# ---

$dump = 0 ;
$err = 'ignore' ;
$packit = "yes" ;
GetOptions (
    'top=s'      => \$top,
    'error=s'    => \$err,
    'prefix=s'   => \$prefix,
    'packages=s' => \@pac,
    'wrapit=s'   => \$packit,
    'dump'       => \$dump
    ) ;

mkdir "${top}/logs", 0755 unless -d "${top}/logs" ;
open (LOG1, "> $top/logs/build.$hostname-$$") ;
open (LOG2, "> $top/logs/latest") ;

logprint "Main settings\n" ;
require "$top/bin/settings.pl" ;
if (-f "$top/bin/settings.$platform_os.pl") {
    logprint "Platform: $platform_os settings\n" ;
    print "$platform_os settings\n" ;
    require "$top/bin/settings.$platform_os.pl" ;
}
if (-f "$top/bin/settings.$hostname.pl") {
    logprint "Host: $hostname settings\n" ;
    print "$hostname settings\n" ;
    require "$top/bin/settings.$hostname.pl" ;
}


@packages = split (/,/, join (',', @pac)) if @pac ;

print join (", ", @packages), "\n" ;
print "Platform_os = ${platform_os}\n" ;
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

chdir $top ;
mkdir 'tgzs', 0755 unless -d 'tgzs' ;
mkdir 'packages', 0755 unless -d 'packages' ;
mkdir $src, 0755 unless -d $src ;
foreach $name (@packages) {
    $_ = ${$name} ;
    logprint $_->{'name'}, "\n" ;
    print $_->{'name'}, "\n" ;
    fetch ($_) unless -f $_->{'pkgsrc'} ;
    packup ($_) unless -d $_->{'srcdir'} ;
    chdir $_->{'srcdir'} ;
    build ($_) ;
    chdir $top ;
}

if ($packit eq "yes") {
  if ($os =~ /solaris|sunos/) {
    @pkgtype = ('solaris') ;
  } else {
    @pkgtype = ('rpm', 'deb') ;
  }
  chdir 'fpmtop' ;
  foreach $pkgtype (@pkgtype) {
    system "/bin/rm -rf opt/puppet ; cp -r /opt/puppet opt" ;
    print "fpm -n eispuppet -v $eis_puppet_version -t $pkgtype -s dir --vendor EIS --category eis_cm --provides eis_cm --maintainer nils.olof.xo.paulsson@ericsson.com --description 'EIS CM puppet client' var etc opt\n" ;
    system "fpm -n eispuppet -v $eis_puppet_version -t $pkgtype -s dir --vendor EIS --category eis_cm --provides eis_cm --maintainer nils.olof.xo.paulsson@ericsson.com --description 'EIS CM puppet client' var etc opt" ;
    system "mv eispuppet*.$pkgtype $ostype" ;
  }
}
