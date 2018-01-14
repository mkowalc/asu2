#!/usr/bin/perl

use strict;
use warnings;
use Switch;
use Getopt::Std;
use IPC::Run 'run';

#OBSLUGA Z POZIOMU TERMINALA

my %options=();
getopts("ahi", \%options);

if ($options{h})
{
  print_help();
}

if ($options{a})
{
  add_user();
}

if ($options{i}){
  get_all_uids();

}

sub add_user {
  my ($username, $uid) = @ARGV;

  if((not defined $username) or (not defined $uid)) {
    die "Invalid parameters were given\n";
  }

  print "'$username' and '$uid'\n";
}

# sub test_ls {
#   my ($command) = @ARGV;
#
#   system($command);
# }

sub print_help {
  print "POMOC\n";
}

sub get_users {
	my @unames;
	my $key;
	open PASSWD, "/etc/passwd";
		while(<PASSWD>) {
    	my @f = split /:/;
			push @unames, $f[0];
    }
	return @unames;
}

sub get_uid {
    my $uid;
    #$uid = system("id -u '$_[0]'");
    run [ "id", "-u", "$_[0]" ], ">", \my $uid;
    print ("DEBUG GETUID: $uid\n");
    return $uid;
}

sub get_all_uids {

  my @users;
  @users = get_users();
  my $uidxd;
  for my $i (0 .. $#users)
  {
      $uidxd = get_uid($users[$i]);
      
  }
}


# sub display {
# 	my @values;
# 	my $key;
# 	foreach $key (param) {
# 		push @values, param($key);
# 	}
#   print ("processes of '$values[0]'...");
# 		 system("ps -U $values[0]");
#
# }
sub get_uids {
  #TODO
}
