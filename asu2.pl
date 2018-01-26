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
  add_user_with_passwd();
}

if ($options{i}){
  generate_passwd_hash();

}



sub add_user_with_passwd {
  my ($username, $uid_xd) = @ARGV;

  if((not defined $username) or (not defined $uid_xd)) {
    die "Invalid parameters were given\n";
  }

  else {
    if(!check_if_user_exists($username)) {
      if(!check_if_uid_exists($uid_xd)) {
        my $password_hash_for_user = generate_passwd_hash();
        system("useradd -u $uid_xd -p $password_hash_for_user $username");
        print "user created\n";
        print "username: $username\n";
        print "uid: $uid_xd\n";
      }
      else {
        die "Given UID exists!\n";
      }
    }

    else {
      die "User exists! Try another username!\n";
    }
  }

}

sub check_if_user_exists {

  my @names = get_users();
  my $name = $_[0];
  my %params = map { $_ => 1 } @names;

  if(exists($params{$name})) {
    return 1;
  }

  else {
    return 0;
  }
}

sub check_if_uid_exists {

  my @user_ids = get_all_uids();
  my $user_id = $_[0];
  if ( grep( /^$user_id$/, @user_ids ) ) {
      return 1;
  }

  else { return 0; }
}

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
    run [ "id", "-u", "$_[0]" ], ">", \$uid;
    return $uid;
}

sub get_all_uids {

  my @users;
  @users = get_users();
  my @current_uids;
  my $single_uid;
  for my $i (0 .. $#users)
  {
      $single_uid = get_uid($users[$i]);
      push @current_uids, $single_uid;

  }

  return @current_uids;
}

sub generate_password {
	my $length_of_random_passwd=shift;

	my @chars=('a'..'z','A'..'Z','0'..'9');
	my $random_passwd;
	foreach (1..$length_of_random_passwd)
	{

		$random_passwd.=$chars[rand @chars];
	}
	return $random_passwd;
}

sub generate_passwd_hash {

  my $password1 = generate_password(6);
  my $encrypted_passwd = crypt($password1, "1337");
  print "user_passwd (unencrypted): $password1\n";
  return $encrypted_passwd;
}
