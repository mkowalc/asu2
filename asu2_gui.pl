use Tk;
use Tk::Text;
#use strict;
use warnings;
use Switch;
use Getopt::Std;
use IPC::Run 'run';


# Main Window
my $mw = new MainWindow;

#GUI Building Area
my $main_label = $mw -> Label(-text=>"Welcome to ASU Project 2 - user management");
my $frm_name = $mw -> Frame();
my $frm_uid = $mw -> Frame();
my $lab = $frm_name -> Label(-text=>"Username:");
my $ent = $frm_name -> Entry(
  -validate=>'key',
  -validatecommand=> sub{$_[1] =~ /[A-za-z0-9\/]/i}
  );
my $lab_2 = $frm_uid -> Label(-text=>"UID:");
my $ent_2 = $frm_uid -> Entry(
  -validate=>'key',
  -validatecommand=> sub{
    return 0 if $_[0]=~/\D/;;
    1;
  });
my $lab_3 = $mw -> Label(-text=>"Generate random password:");

my $but = $mw -> Button(-text=>"Add User", -command =>\&push_button);
my $but_pu = $mw -> Button(-text=>"Add User & Generate Password", -command =>\&push_button_1_1);
my $but_passwd = $mw -> Button(-text=>"Generate!", -command =>\&push_button_2);
#Text Area
my $textarea = $mw -> Frame();
my $txt = $textarea -> Text(-width=>25, -height=>6);

my $lab_4 = $mw -> Label(-text=>"Delete user (use responsibly:) ) :");

my $frm_del = $mw -> Frame();
my $ent_del = $frm_del -> Entry(
  -validate=>'key',
  -validatecommand=> sub{$_[1] =~ /[A-za-z0-9_\/]/i}
  );

my $del_button = $mw -> Button(-text=>"Delete user", -command =>\&del_usr);

#Geometry Management
$main_label -> grid(-row=>1, -column=>2);
$lab -> grid(-row=>2,-column=>1);
$ent -> grid(-row=>2,-column=>2);
$lab_2 -> grid(-row=>3,-column=>1);
$ent_2 -> grid(-row=>3,-column=>2);
$frm_name -> grid(-row=>2,-column=>1,-columnspan=>2);
$frm_uid -> grid(-row=>3,-column=>1,-columnspan=>2);

$but -> grid(-row=>4,-column=>3,-columnspan=>2);
$but_pu -> grid(-row=>4,-column=>1,-columnspan=>2);
$txt -> grid(-row=>1,-column=>1);
$lab_3 -> grid(-row=>6, -column=>1, -columnspan=>2);
$but_passwd -> grid(-row=>7,-column=>2,-columnspan=>2);
$textarea -> grid(-row=>8,-column=>1,-columnspan=>2);
$lab_4 -> grid(-row=>9, -column=>1, -columnspan=>2);
$frm_del -> grid(-row=>10,-column=>1,-columnspan=>2);
$ent_del -> grid(-row=>11,-column=>1,-columnspan=>2);
$del_button -> grid(-row=>12,-column=>1,-columnspan=>2);
MainLoop;

## Functions
#This function will be executed when the button is pushed
sub push_button_1_1 {
    $txt -> delete('0.0','end');
    my $name = $ent -> get();
    my $uid_of_user = $ent_2 -> get();
    $txt -> insert('end',"Creating user: username: $name\n UID: $uid_of_user\n");
    add_user_with_passwd($name, $uid_of_user);
}

sub push_button {
    $txt -> delete('0.0','end');
    my $name_2 = $ent -> get();
    my $uid_of_user_2 = $ent_2 -> get();
    $txt -> insert('end',"Creating user: username: $name_2\n UID: $uid_of_user_2\n");
    add_user($name_2, $uid_of_user_2);
}

sub push_button_2 {
  $txt -> delete('0.0','end');
  my $rand_passwd = generate_password(8);
  $txt -> insert('end',"Your new password is:\n\n$rand_passwd\n\nKeep it safe!\n");
}

sub del_usr {
    $txt -> delete('0.0','end');
    my $name_to_delete = $ent_del -> get();
    system("userdel $name_to_delete");
    $txt -> insert('end',"User:\n\n$name_to_delete\n\nwas successfully deleted!\n");
}

sub add_user_with_passwd {
  my $username = $_[0];
  my $uid_xd = $_[1];

  if((not defined $username) or (not defined $uid_xd)) {
    die "Invalid parameters were given\n";
  }

  else {
    if(!check_if_user_exists($username)) {
      if(!check_if_uid_exists($uid_xd)) {
        my $password_hash_for_user = generate_passwd_hash();
        system("useradd -u $uid_xd -p $password_hash_for_user $username");
      }
      else {
        $txt -> insert('end',"\nWARNING: Given UID exists!\n");
        die "Given UID exists!\n";
      }
    }

    else {
      $txt -> insert('end',"\nWARNING:Given user exists! Try another username!\n");
      die "User exists! Try another username!\n";
    }
  }

}

sub add_user {
  my $username = $_[0];
  my $uid_xd = $_[1];

  if((not defined $username) or (not defined $uid_xd)) {
    die "Invalid parameters were given\n";
  }

  else {
    if(!check_if_user_exists($username)) {
      if(!check_if_uid_exists($uid_xd)) {

        system("useradd -u $uid_xd $username");
      }
      else {
        $txt -> insert('end',"\nWARNING: Given UID exists!\n");
        die "Given UID exists!\n";
      }
    }

    else {
      $txt -> insert('end',"\nWARNING:Given user exists! Try another username!\n");
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
  $txt -> insert('end',"Random password is:\n\n$random_passwd\n\nKeep it safe!\n");
	return $random_passwd;
}

sub generate_salt {
	my $length_of_random_salt=shift;

	my @chars_salt=('a'..'z','A'..'Z','0'..'9');
	my $random_salt;
	foreach (1..$length_of_random_salt)
	{
		$random_salt.=$chars_salt[rand @chars_salt];
	}

	return $random_salt;
}

sub generate_passwd_hash {

  my $password1 = generate_password(6);
  my $encrypted_passwd = crypt($password1, generate_salt(10)); #other random string used as a salt
  return $encrypted_passwd;
}
