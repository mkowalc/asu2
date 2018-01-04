#!/usr/bin/perl

use strict;
use warnings;
use Switch;
use Getopt::Std;

#OBSLUGA Z POZIOMU TERMINALA

my %options=();
getopts("ht", \%options);

if ($options{h})
{
  print_help();
}

if ($options{t})
{
  test();
}


sub test {
  my ($name, $number) = @ARGV;

  if(not defined $name) {
    die "NEED NAME\n";
  }

  print "'$name' and '$number'\n";
}

sub print_help {
  print "POMOC\n";
}
