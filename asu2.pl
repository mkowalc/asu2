#!/usr/bin/perl

use strict;
use warnings;
use Switch;
use Getopt::Std;

my %options=();
getopts("hj:ln:s:", \%options);

if ($options{h})
{
  print_help();
}


sub print_help {
  print "POMOC\n";
}
