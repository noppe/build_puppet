#!/usr/bin/env perl

use Cwd qw/getcwd chdir/;
use Getopt::Long;

chop ($hostname = `uname -n`);
chop ($arch = `uname -p`);

# Setup global varibales available later

# Ensure basic paths are in environment. This way we do not have to know
# exactly where binaries are on the different types of systems.
$ENV{PATH} = "$ENV{PATH}:/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin";

# used in FPM
my $fpm_name = 'eispuppet';
my $fpm_url = 'https://github.com/noppe/build_puppet';
my $fpm_vendor = 'EIS';
my $fpm_category = 'eis_cm';
my $fpm_provides = 'eis_cm';
my $fpm_maintainer = 'eis-nix-global-team@mailman.lmera.ericsson.se';
my $fpm_description = 'puppet agent and its prerequisites';

# directories which should exist under /
my $fpm_dirs = '/opt/puppet /etc/puppet /var/log/puppet /var/run/puppet /var/lib/puppet';

# build dir structure for fpm
system "for i in ${fpm_dirs}; do mkdir -p \$i; done";

my $fpm = 'fpm';
my ($os, $rev) = (`uname -s`, `uname -r`);
chomp ($os, $rev);
# if linux
if ($os eq 'Linux') {
  # if redhat
  # sample redhat-release files
  #   Red Hat Enterprise Linux Server release 5.9 (Tikanga)
  #   Red Hat Enterprise Linux Server release 6.4 (Santiago)
  #   CentOS release 6.4 (Final)
  if ( -f "/etc/redhat-release" ) {
    open FH, "/etc/redhat-release";
    $x = <FH> ; close FH;
    # If this is a real Red Hat system
    if ($x =~ /^Red Hat/ ) {
      if ($x =~ /release\s+(\d+)\.(\d+)/) {
        $maj = $1;
        $min = $2;
        $rel = $maj . '.' . $min;
      }
      $platform_os = 'RedHat-' . $rel;
      $ostype = 'redhat-' . $maj;
    # If this is a CentOS system
    } elsif ($x =~ /(\w+)\s+release\s+(\d+)\.(\d+)/ ) {
      $maj = $2 ; $min = $3;
      # TODO: flavor is a hack to get Ubuntu to work and should be refactored.
      $flavor = $1 . "-" . $maj . '.' . $min;
      $platform_os = $flavor;
      $ostype = 'redhat-' . $maj;
    }
  # if Suse
  } elsif ( -f "/etc/SuSE-release" ) {
    open FH, "/etc/SuSE-release";
    while (<FH>) {
      /^VERSION\s*=\s*(\d+)$/ && { $maj = $1 };
      /^PATCHLEVEL\s*=\s*(\d+)$/ && { $min = $1 };
    }
    close FH;
    $ostype = "redhat-" . ($maj > 9 ? "6" : "5");
    $platform_os = "suse-$maj.$min";
  # if Debian based
  } elsif ( -f '/etc/lsb-release' ) {
    open FH, '/etc/lsb-release';
    while (<FH>) {
      if (/DISTRIB_RELEASE=(\d+)\.(\d+)/) { $maj = $1 ; $min = $2  ; };
    }
    close FH;
    $ostype = 'redhat-' . ($maj > 12 ? "6" : "5");
    $platform_os = "ubuntu-$maj.$min" ; # Wild guessing here. Fix!
  } else {
    my $flavor = `uname -v`;
    chomp ($flavor);
    if ($flavor =~ /-(Ubuntu)/) {
      $platform_os = "$1-$rev";
      $ostype = 'redhat-5';
    } else {
      $platform_os = "$flavor-$rev";
    }
  }
} elsif ($os =~ /SunOS/) {
  ($srev = $rev) =~ s/^5\.//;
  $ostype = 'solaris-' . $srev;
  $platform_os = $os . '-' . $rev;
}


my $arch = `uname -p`;
chomp $arch;
$platform_arch = $arch;
$platform = "${platform_os}-${platform_arch}";
$top = getcwd;
$build_dir = $top . '/builds';
$src = $build_dir. '/src.' . $hostname;
$prefix = '/opt/puppet';

# set git_revision
chdir $top;
my $git_revision = `git rev-parse --short HEAD`;
chomp($git_revision);

# sub routine to log to both a file and stdout
sub logprint {
  print LOG1 @_;
  print LOG2 @_;
}

# sub routine to uncompress a tarball
sub extract {
  my $p = shift;
  my $retval;
  return if -d $p->{'srcdir'};
  chdir $src;
  ($unpack_command = $p->{'extract'}) =~ s/%([A-Z]+)%/$p->{lc $1}/eg;
  open (UNPACK_COMMAND_PIPE, "$unpack_command |") || die 'extract fail';
  while (defined <UNPACK_COMMAND_PIPE>) {
    logprint $_;
  }
  close UNPACK_COMMAND_PIPE;
  $retval = $?;
  return($retval);
}

# sub routine to expand variables. This is done by referencing a key in the same hash.
sub expand {
  my $ref = shift;
  my $what = shift;
  my $res;

  ($res = $ref->{$what}) =~ s/%([A-Z]+)%/$ref->{lc $1}/eg;
  return $res;
}

# sub routine to compile package
sub build {
  # set reference to package hash in settings.pl or settings-<platform>.pl
  my $p = shift;

  chdir $p->{ 'srcdir' };

  while (($k, $v) = each %{$p->{ 'env' }}) {
    $remember {$k} = $v;
    $ENV{$k} = $v;
    logprint "\n\nsetenv $ENV{$k} = $v\n";
  }

  logprint "\n\nConfigure: " . $p->{'configure'}, "\n";
  $cmd = expand ($p, 'configure');
  logprint "  Command: $cmd ";
  open (CMD, "$cmd |");
  while (<CMD>) {
    logprint $_;
    print $_;
  }
  close CMD;

  logprint "\n\nmake: " . $p->{'make'}, "\n";
  $cmd = expand ($p, 'make');
  open (CMD, "$cmd |");
  while (<CMD>) {
    logprint $_;
    print $_;
  }
  close CMD;

  logprint "\n\nInstall: " . $p->{'install'}, "\n";
  $cmd = expand ($p, 'install');
  open (CMD, "$cmd |");
  while (<CMD>) {
    logprint $_;
    print $_;
  }
  close CMD;

  while (($k, $v) = each %remember) {
    $ENV{$k} = $v;
  }
}

# sub routine to build package on Solaris
sub package_solaris {
  # cleanup old files
  foreach (qw/prototype pkginfo postinstall/) {
    unlink "${prefix}/$_";
  }

  my @proto = `cd ${prefix} ; find . -print | pkgproto`;

  #chop (my $name = `id -n -u`);
  #chop (my $group = `id -n -g`);
  my $id = `id -a`;
  (my $name, $group) = ($id =~ m/\((\w+?)\).*?\((\w+)\)/);

  logprint $name, " ",  $group, "\n";

  grep ( { s/(\s+)$name(\s+)/${1}bin${2}/g ; s/(\s+)$group(\s+)/${1}bin${2}/g } @proto );

  unshift @proto, ("d none /etc/puppet 0755 bin bin\n",
  "d none /opt/puppet 0755 bin bin\n",
  "d none /var/lib/puppet 0755 bin bin\n");

  if ($postinstall) {
    unshift @proto, "i postinstall=./postinstall\n";
    open (PI, "> ${prefix}/postinstall");
    print PI $postinstall;
    close PI;
  }

  unshift @proto, "i pkginfo=./pkginfo\n";
  open (PROTO, "> ${prefix}/prototype");
  print PROTO @proto;
  close PROTO;

  open (PKGINFO, "> ${prefix}/pkginfo");
  print PKGINFO join ("\n", @pkginfo);
  close PKGINFO;

  system "cd ${prefix} && pkgmk -o -r ${prefix}";
  system "cd /var/spool/pkg && pkgtrans -s /var/spool/pkg ${target} EISpuppet";
}

# sub routine to download packages
sub fetch {
  my $p = shift;
  my $cmd = $p->{'fetch'};
  my $retval;
  chdir "${build_dir}/tgzs";
  open (FETCH, "$cmd |") || die "Fetching " . $p->{'name'} . " failed";
  while (defined <FETCH>) {
    logprint $_;
  }
  close FETCH;
  $retval = $?;
  chdir $top;
  return($retval);
}

$dump = 0;
$err = 'ignore';
$packit = "yes";
GetOptions (
  'top=s'       => \$top,
  'build_dir=s' => \$build_dir,
  'error=s'     => \$err,
  'prefix=s'    => \$prefix,
  'packages=s'  => \@pac,
  'wrapit=s'    => \$packit,
  'osver=s'     => \$osver,
  'dump'        => \$dump
);

if (length($osver) == 0) {
  print "argument osver must be specified, such as \'-osver el6\'\n";
  exit 1
}

unless (-d "${build_dir}/logs") {
  mkdir "${build_dir}/logs", 0755;
}
open (LOG1, "> ${build_dir}/logs/build.${hostname}-$$");
open (LOG2, "> ${build_dir}/logs/latest");

logprint "Main settings\n";
require "${top}/bin/settings.pl";
if (-f "${top}/bin/settings.${platform_os}.pl") {
  logprint "Platform: ${platform_os} settings\n";
  print "${platform_os} settings\n";
  require "${top}/bin/settings.${platform_os}.pl";
}

if (-f "${top}/bin/settings.${hostname}.pl") {
  logprint "Host: ${hostname} settings\n";
  print "${hostname} settings\n";
  require "${top}/bin/settings.${hostname}.pl";
}

@packages = split (/,/, join (',', @pac)) if @pac;

print join (", ", @packages), "\n";
print "Platform_os = ${platform_os}\n";

# if -dump is specified on the command line, this will show all the variables on STDOUT
if ($dump) {
  foreach $name (@packages) {
    $p = ${$name};
    print $name, "\n";
    foreach (keys %{$p}) {
      print "\t$_ => $p->{$_} \n" ; # if ref \{$p->{$_}} eq 'SCALAR';
      if (ref $p->{$_} eq 'HASH') {
        print "\t", $p->{$_}, "\n";
        while (($k, $v) = each %{$p->{$_}}) {
          print "\t\t$k => $v \n";
        }
      }
    }
  }
  exit 0;
}

chdir $top;
unless (-d $build_dir) {
  mkdir $build_dir, 0755 ;
}
unless (-d "${build_dir}/tgzs") {
  mkdir "${build_dir}/tgzs", 0755 ;
}
unless (-d "${top}/packages") {
  mkdir "${top}/packages", 0755 ;
}
unless (-d "${top}/packages/${ostype}") {
  mkdir "${top}/packages/${ostype}", 0755;
}
unless (-d "${top}/packages/${ostype}/${git_revision}") {
  mkdir "${top}/packages/${ostype}/${git_revision}", 0755;
}
unless (-d $src) {
  mkdir $src, 0755 ;
}

# fetch, extract, and build (not package)
foreach $name (@packages) {
  chdir $build_dir;
  my $retval;
  $_ = ${$name};
  logprint $_->{'name'}, "\n";
  print "\n################### Fetching: ", $_->{'name'}, "\n";
  $retval = fetch ($_) unless -e $_->{'pkgsrc'};
  print "\n################### Extracting: ", $_->{'name'}, "\n";
  print "srcdir = $_->{'srcdir'}\n";
  $retval = extract ($_) unless -d $_->{'srcdir'};
  die ("extract returned $retval on package $name\n") if ($retval != 0);
  chdir $_->{'srcdir'};
  print "\n################### Building: ", $_->{'name'}, "\n";
  build ($_);
}

# Now we package
if ($packit eq "yes") {
  if ($os =~ /solaris|sunos/i) {
    @pkgtype = ('solaris');
    system "cp ${top}/fpmtop/etc/puppet/puppet.conf ${prefix}";
    if ($ostype eq 'solaris-9') {
      system "cp ${top}/fpmtop/init.d/Solaris/puppetd ${prefix}/puppetd";
    }
    if ($ostype eq 'solaris-10') {
      system "cp ${top}/fpmtop/init.d/Solaris/puppetd ${prefix}/puppetd";
      system "cp ${top}/fpmtop/init.d/Solaris/smf/puppetd.xml ${prefix}/puppetd.xml";
      system "cp ${top}/fpmtop/init.d/Solaris/smf/svc-puppetd ${prefix}/svc-puppetd";
    }
    system "cp ${top}/fpmtop/init.d/Solaris/smf/puppetd.xml ${top}/fpmtop/";
    package_solaris;
  } else {

    # if not RedHat, build deb. RHEL and Suse are both RPM based and Solaris is
    # caught above.
    if ($ostype !~ /RedHat/i) {
      $pkgtype = 'deb';
    } else {
      $pkgtype = 'rpm';
    }

    system "rsync -avp ${top}/fpmtop/etc/ /etc/";
    system "rsync -avp ${top}/fpmtop/${osver}/ /";
    chdir '/';

    $fpm_command = <<EOM;
${fpm} -n ${fpm_name} \\
  -v ${eis_puppet_version} \\
  -t ${pkgtype} \\
  -C / \\
  -s dir \\
  --url '${fpm_url}' \\
  --vendor '${fpm_vendor}' \\
  --category '${fpm_category}' \\
  --provides '${fpm_provides}' \\
  --maintainer '${fpm_maintainer}' \\
  --description '${fpm_description}' \\
 --directories /opt/puppet \\
 --directories /etc/puppet \\
 --directories /var/lib/puppet \\
 --exclude /etc/puppet/ssl/* \\
 -p ${top}/packages/${ostype}/${git_revision}/ \\
 $fpm_dirs /etc/init.d/puppet
EOM

    print "\n################### Packaging for ${pkgtype} with:\n$fpm_command\n";
    system $fpm_command;
  }
}
