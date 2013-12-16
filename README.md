# Package Puppet for various OS's.

Guide to building Puppet agents.

# Why build?

Since any reasonable modern OS have puppet in the standard repositories, why do we build the puppet software ourselves?

There are several reasons for this:

* Ruby depends on dynamically loaded libraries, for example zlib and openssl. By including these into the EIS puppet package we eliminate the risk of an OS patch to break puppet

* Some OSes in EIS scope does not provide puppet at all, or an older version. We can build EIS puppet for these

* We get the same version of puppet on all EIS managed servers, implying that we can use the same puppet language features for all clients

* The EIS puppet package installs in /opt/puppet, thus it is possible to have the OS puppet package installed simultaneously

* A tailor-made package fits our requirements better

# Supported Distributions

* RedHat 5 x86_64, i386
* RedHat 6 x86_64, i386
* Solaris 9 sparc
* Solaris 10 x86_64, sparc
* Solaris 11.1 x86_64, sparc
* Suse 9 x86_64, i386
* Suse 10 x86_64, i386
* Suse 11 x86_64, i386
* Ubuntu 12.04 LTS x86_64

# Prerequisites

The following components are used.

## Sources

    facter-1.7.1
    hiera-1.2.1
    puppet-3.2.2
    ruby-1.8.7-p358
    ruby-shadow-2.1.4
    augeas-1.1.0
    ruby-augeas-0.5.0
    readline-6.2
    openssl-0.9.8w
    zlib-1.2.8

## Tools
    C compiler, usually gcc
    make and gmake
    perl
    fpm
    rpmbuild

### Solaris 10 x86:
    /usr/sfw/bin/gcc 3.4.3, patched with http://www.openssl.org/~appro/values.c to get usable openssl libs

### Solaris 10 sparc:
    /usr/sfw/bin/gcc 3.4.3

# Build Instructions
build.pl will auto detect the system that you are on and build for it.

    ./bin/build.pl

## To build without packaging

    ./bin/build.pl -wrap no

# repo layout

## bin/
scripts

### build.pl
main script that you run

### settings.pl
Default settings

### settings.<platform>.pl
Settings specific to that platform

## fpmtop/

## patches/
Patches to source code

# Packaging
Solaris builds its own packages without FPM

Everything else, uses FPM.

* build.pl builds everything in /opt/puppet
* copies /opt/puppet to fpmtop/
* copies fpmtop/init.d to fpmtop/etc/init.d
* produces package
