#!/usr/bin/perl

# firewall-conf.pl  v1.5
#############################################################################
#                                                                           #
#  Copyright 2002 Jerome Nokin                                              #
#                                                                           #
#   This program is free software; you can redistribute it and/or modify    #
#   it under the terms of the GNU General Public License as published by    #
#   the Free Software Foundation; either version 2 of the License, or       #
#   (at your option) any later version.                                     #
#                                                                           #
#   This program is distributed in the hope that it will be useful,         #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of          #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           #
#   GNU General Public License for more details.                            #
#                                                                           #
#   You should have received a copy of the GNU General Public License       #
#   along with this program; if not, write to the Free Software             #
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston,                   #
#   MA  02111-1307  USA                                                     #
#                                                                           #
#############################################################################

use Fcntl;


#---------------------------------------------------
# Config
#--------------------------------------------------

$CONFIGURATOR_VERSION	= "1.5";
$CONFIGURATOR_DATE	= "13/08/2005";
$FIREWALL_VERSION	= "1.0.5";
$FIREWALL_WEBPAGE	= "http://firewall-jay.sourceforge.net";
$IFCONFIG 		= `which ifconfig`;
$GREP			= `which grep`;
$CONFIG_FILE_DEFAULT	= "/etc/firewall-jay/firewall.config";
$LOG_FILE       	= "test.log";
$MY_EMAIL		= "jerome\@wallaby.be";
$SERVICE_FILE           = "/etc/services";



# dialog
#--------
$DIALOG				= `which dialog`;
$DIALOG_VERSION         	= "0.9a-20020309a";
$DIALOG_BACKTITLE		= "--backtitle \"SilentBob Iptables Firewall Configurator v$CONFIGURATOR_VERSION ($CONFIGURATOR_DATE)\"";
$DIALOG_CANCEL_LABEL_BACK       = "--cancel-label 'Back'";
$DIALOG_CANCEL_LABEL_QUIT       = "--cancel-label 'Quit'";
$DIALOG_HELP_LABEL_ADD_NEW      = "--help-label 'Undetected'";
$DIALOG_OK_LABEL_DELETE         = "--ok-label 'Delete'";
$DIALOG_OK_LABEL_MODIFY         = "--ok-label 'Modify'";
$DIALOG_HELP_BUTTON             = "--help-button";
$DIALOG_TRIM                    = "--trim";
$INFO_DIALOG                    = "";

@options_needed = (
        '\[--cancel-label <str>\]',
        '\[--clear\]',
        '\[--defaultno\]',
        '\[--help-button\]',
        '\[--help-label <str>\]',
        '\[--item-help\]',
        '\[--no-cancel\]',
        '\[--ok-label <str>\]',
        '\[--separate-output\]',
        '\[--separate-widget <str>\]',
        '\[--stderr\]',
        '\[--stdout\]',
        '\[--tab-correct\]',
        '\[--tab-len <n>\]',
        '\[--title <title>\]',
        '\[--trim\]',
        '\[--version\]',
        '--checklist',
        '--fselect',
        '--inputbox',
        '--menu',
        '--msgbox',
        '--textbox',
	'--yesno');



# Arguments
#------------
@MY_ARGUMENTS=(
	'-h','--help',
	'-c','--config',
	'-g','--generate',
	'-n','--new',
	'-u','--update',
	'-y','--yes');


# names of variables in config file
#----------------------------------
@config_name  = (
	'INT_IFACE', 
	'EXT_IFACE',
	'DNS',
	'DHCP_SERVER',
	'TCP_EXT_IN',
	'UDP_EXT_IN',
	'TCP_INT_IN',
	'UDP_INT_IN',
	'TCP_FORWARD',
	'UDP_FORWARD',
	'POST_START',
	'PRE_START',
      	'POST_STOP',
      	'PRE_STOP',
	'DYN_IP',
	'NAT',
	'IRC',
	'USE_DHCP_SERVER',
	'PROXY_HTTP',
	'PROXY_FTP',
	'PING_FOR_ALL',
	'ALLOWED_PING',
        'TCP_CONTROL',
        'ICMP_CONTROL',
        'ICMP_TO_DENY',
        'SPOOFING_CONTROL',
	'alias ECHO',
	'LOGLEVEL',
	'LOG_DROPPED',
	'LOG_MARTIANS',
	'LOG_SYNFLOOD',
	'LOG_PINGFLOOD',
	'LOG_SPOOFED',
	'LOG_ECHO_REPLY_TO_OUTSIDE',
	'LOG_INVALID',
	'LOG_ULOG_NLGROUP',
	'DENY_DIR',
	'DENY_ULOG_NLGROUP',
	'DENY_IP_IN',
	'DENY_IP_IN_FILES',
	'DENY_IP_IN_LOG',
	'DENY_IP_OUT',
	'DENY_IP_OUT_FILES',
	'DENY_IP_OUT_LOG',
	'DENY_MAC_IN',
	'DENY_MAC_IN_FILES',
	'DENY_MAC_IN_LOG',
	'TOS',
	'TCP_MIN_DELAY',
	'UDP_MIN_DELAY',
	'TCP_MAX_THROUGHPUT',
	'UDP_MAX_THROUGHPUT',
	'TUN_IFACE',
	'TUN_SUBNET',
	'TUN_TCP',
	'TUN_UDP',
	'PPTP_LOCALHOST',
	'PPTP_LOCALHOST_PORT',
	'PPTP_LOCALHOST_IFACES',
	'PPTP_LOCALHOST_SUBNET_VPN',
	'PPTP_LOCALHOST_SUBNET_ALLOWED',
	'PPTP_LOCALHOST_ACCESS_LAN',
	'PPTP_LOCALHOST_ACCESS_INET',
	'PPTP_LAN',
	'PPTP_LAN_IP',
	'PPTP_LAN_PORT',	
	'IPSEC_LOCALHOST',
	'IPSEC_LOCALHOST_IFACES',
	'IPSEC_LOCALHOST_PORT',
	'IPSEC_LOCALHOST_SUBNET_VPN',
	'IPSEC_LAN',
        'IPSEC_LAN_IP',
        'IPSEC_LAN_PORT',
	'ZORBIPTRAFFIC',
	'ZORBIPTRAFFIC_NET',
	'ZORBIPTRAFFIC_IPS',
	'MARK',
	'MARK_IP',
	'MARK_TCP',
	'MARK_UDP',
	'CUSTOM_RULES',
	'CUSTOM_RULES_FILE',
	'PRIV_PORTS',
	'UPRIV_PORTS',
        'IPTABLES',
        'IFCONFIG',
        'GREP',
        'SED',
        'FIREWALL_RULES_DIR',
	'RESERVED_IP',
	'PING_LIMIT',
	'LOG_LIMIT',
	'SYN_LIMIT',
	'SYN_LIMIT_BURST',
	'UNDETECTED_IFACES',
	'FIREWALL_VERSION');


# values of variables
#--------------------
$config_value = "";


# Old variable name (wich must be updated)
#--------------------------------------
@config_name_old =('DENY_HOSTS_IN',
		   'DENY_HOSTS_IN_FILES',
		   'DENY_HOSTS_IN_LOG',
		   'DENY_HOSTS_OUT',
		   'DENY_HOSTS_OUT_FILES',
		   'DENY_HOSTS_OUT_LOG',
		   'DENY_HOSTS_DIR');

# New name of OLD variables
#----------------------------
@config_name_old{'DENY_HOSTS_DIR'}       = "DENY_DIR";
@config_name_old{'DENY_HOSTS_IN'}        = "DENY_IP_IN";
@config_name_old{'DENY_HOSTS_IN_FILES'}  = "DENY_IP_IN_FILES";
@config_name_old{'DENY_HOSTS_IN_LOG'}    = "DENY_IP_IN_LOG";
@config_name_old{'DENY_HOSTS_OUT'}       = "DENY_IP_OUT";
@config_name_old{'DENY_HOSTS_OUT_FILES'} = "DENY_IP_OUT_FILES";
@config_name_old{'DENY_HOSTS_OUT_LOG'}   = "DENY_IP_OUT_LOG";



#-------------------------------------------
# Some Tests
#-------------------------------------------


$DIALOG =~ s/\n//g;
if(! -e $DIALOG ){
	print "\n";
	print "Error: firewall-conf.pl: 'dialog' not found at '$DIALOG'\n";
	print "       please edit '/usr/sbin/firewall-conf.pl'\n";
	print "\n";
        exit;
}

$IFCONFIG =~ s/\n//g;
if(! -e $IFCONFIG){
	print "\n";
	print "Error: firewall-conf.pl: 'ifconfig' not found at '$IFCONFIG'\n";
	print "       please edit '/usr/sbin/firewall-conf.pl'\n";
	print "\n";
	exit;
}

$GREP =~ s/\n//g;
if(! -e $GREP){
	print "\n";
        print "Error: firewall-conf.pl: 'grep' not found at '$GREP'\n";
	print "       please edit '/usr/sbin/firewall-conf.pl'\n";
	print "\n";
	exit;
}



#####################################################
#            SCRIPT   FUNCTIONS
#####################################################
## See the bottom of the page 


# Display HELP
sub display_help {}

# Init defaults values of variables in config file
sub init_default_values {}

# Parse config file
sub parse_config_file {}

# Save config to file
sub save_config_to_file {}

# Create help messages for config file
sub create_help_config_file {}

# Update Old variables names
sub update_old_variable_name {}

# Update the config file
sub update_config_file {}

# Generate a empty config file
sub generate_config_file {}

# Check for dialog
sub check_for_dialog {}

# Read arguments
sub read_arguments {}

# Search for an other config file location (argument test)
sub search_c_argument {}


###############################################
#  DIALOG FUNCTIONS  (see below)
###############################################
sub select_a_interface {}


sub open_tcp_inet {}
sub open_tcp_inet_for_iface {}
sub open_tcp_inet_for_iface_view {}
sub open_tcp_inet_for_iface_modify {}

sub open_udp_inet {}
sub open_udp_inet_for_iface {}
sub open_udp_inet_for_iface_view {}
sub open_udp_inet_for_iface_modidy {}

sub open_tcp_lan {}
sub open_tcp_lan_select_iface {}
sub open_tcp_lan_for_iface {}
sub open_tcp_lan_for_iface_view {}
sub open_tcp_lan_for_iface_modify {}

sub open_udp_lan {}
sub open_udp_lan_select_iface {}
sub open_udp_lan_for_iface {}
sub open_udp_lan_for_iface_view {}
sub open_udp_lan_for_iface_modidy {}



sub features_vpn {}

sub features_vpn_vtund {}
sub features_vpn_vtund_ifaces {}
sub features_vpn_vtund_subnets {}
sub features_vpn_vtund_tcp {}
sub features_vpn_vtund_udp {}



sub features_vpn_pptp {}
sub features_vpn_pptp_serveronbox {}
sub features_vpn_pptp_serveronbox_enable {}
sub features_vpn_pptp_serveronbox_port {}
sub features_vpn_pptp_serveronbox_ifaces {}
sub features_vpn_pptp_serveronbox_subvpn {}
sub features_vpn_pptp_serveronbox_subother {}
sub features_vpn_pptp_serveronbox_accesslan {}
sub features_vpn_pptp_serveronbox_accessinet {}



sub features_vpn_pptp_serverbehind {}
sub features_vpn_pptp_serverbehind_enable {}
sub features_vpn_pptp_serverbehind_ip {}
sub features_vpn_pptp_serverbehind_port {}

sub features_vpn_ipsec {}
sub features_vpn_ipsec_serveronbox {}
sub features_vpn_ipsec_serveronbox_enable {}
sub features_vpn_ipsec_serveronbox_port {}

sub features_vpn_ipsec_serverbehind {}
sub features_vpn_ipsec_serverbehind_enable {}
sub features_vpn_ipsec_serverbehind_ip {}
sub features_vpn_ipsec_serverbehind_port {}




##############################################################################
#                               BEGIN                                        ##
##############################################################################

#------------------------------------------------
# Testing arguments
#------------------------------------------------
$generate_file=0;
$update_config=0;
$yes_to_all=0;

# default location ?
search_c_argument;

# What must I do ?
read_arguments;



#-----------------------------------
# Init
#-----------------------------------

# init defaults values (if variable is not found in config file)
init_default_values;



#-------------------------------------
# Generate empty file ?
#-------------------------------------
if($generate_file == 1){
    generate_config_file;
    exit;
}

#--------------------------------------
# Update Config file ?
#--------------------------------------

if($update_config == 1){
    update_config_file;
    exit;
}



# If we don't need to generate or update a config file, 
# => we must use dialog


#------------------------------------
# Testing dialog
#------------------------------------
check_for_dialog;

# add some default parameters
$DIALOG                         = "$DIALOG --stdout";


#---------------------------------------------------
# Not a new file ?, we must parse the config's file
#---------------------------------------------------

if($new_file == 0){
	parse_config_file;
}



#--------------------------------------
# Welcome message
#-------------------------------------

if($new_file == 1){
	`$DIALOG $DIALOG_BACKTITLE --title "SilentBob Firewall Configuration" --msgbox "\nYou are about to enter in SilentBob Firewall Configurator.\n\n$INFO_DIALOG\A new file will be create ($CONFIG_FILE)\n\nPress <Enter> to continue or <Esc> to cancel." 15 70`;
	$exit=$?;
}
else{
	`$DIALOG $DIALOG_BACKTITLE --title "SilentBob Firewall Configuration" --msgbox "\nYou are about to enter in SilentBob Firewall Configurator.\n\n$INFO_DIALOG\Current configuration will be read from '$CONFIG_FILE'\n\nPress <Enter> to continue or <Esc> to cancel." 15 70`;
	$exit=$?;
}

# Return status of non-zero indicates cancel
if ("$exit" != "0" ){
    # Quit
 
   $clear_string = `clear`;
   print $clear_string;
   exit 0;
}


#-------------------------------------------------------------------------------------------
#   MENU   (Welcome to the jungle)
#--------------------------------------------------------------------------------------------
while(1){
  
# Enter MENU
############


#$menu = `$DIALOG $DIALOG_BACKTITLE --clear --title "Configuration Menu" $DIALOG_CANCEL_LABEL_QUIT --menu "" 0 48 13 "1" "Internal Interfaces (LAN)" "2" "External Interfaces (Internet)"  '' '' "3" "Allowed TCP ports from Inet" "4" "Allowed UDP ports from Inet" "5" "Forwarding TCP Ports to LAN" "6" "Forwarding UDP Ports to LAN" '7' 'DMZ configuration' '' ''  "8" "Configuration (required)" "9" "Features (optional)" '' '' "10" "About" 2>&1 1>/dev/null`;

$menu = `$DIALOG $DIALOG_BACKTITLE --clear --title "Configuration Menu" $DIALOG_CANCEL_LABEL_QUIT --menu "" 0 48 13 "1" "Internal Interfaces (LAN)" "2" "External Interfaces (Internet)"  '' '' "3" "Open TCP ports for Inet" "4" "Open UDP ports for Inet" "5" "Open TCP ports for LAN" "6" "Open UDP ports for LAN"  "7" "Forwarding TCP Ports to LAN" "8" "Forwarding UDP Ports to LAN" '' ''  "9" "Configuration (required)" "10" "Features (optional)"  "11" "About"`;



    if($? != 0){
   	######################
	#  QUIT              #
	######################

	`$DIALOG $DIALOG_BACKTITLE --title "Quit" --clear --yesno "\nWould you like to save to '$CONFIG_FILE' ?" 8 60 `;

	#save
	if($? == 0){

		create_help_config_file;	
		save_config_to_file;
	}

#	`/usr/bin/clear`;
	$clear_string = `clear`;
           print $clear_string;
#`$DIALOG $DIALOG_BACKTITLE --title "Quit" --infobox "bye" 5 10`;

	exit 0;

   }   

   if($menu == '1'){

       ######################
       # INTERNAL INTERFACE #
       ######################

        
       #do{
	   $int_iface =  select_a_interface ('Select LAN interface(s)','Choose your LAN interface(s)',"$config_value{'INT_IFACE'}");
print "int_iface: $int_iface\n";
      
	   #while syntax error
       #}while($int_iface =~ /^$/ && $? == 0);
	




	# if no CANCEL presed, we must save the new config
	if($? == 0){
	        # format return
		$int_iface =~ s/ \([0-9.]*\)|\(no ip found\)//g;  #remove ip
       		$int_iface =~ s/\"//g;
       		$int_iface =~ s/ $//g;
		$int_iface =~ s/^ //g;
		$int_iface =~ s/ +/ /g;

	  
                # test if interface is already used in external interface
                @iface_int = split (/ +/,$int_iface);
		@iface_ext = split(/ +/,$config_value{'EXT_IFACE'});
                foreach $if (@iface_int){
		   
		    if (grep(/^$if$/, @iface_ext)){
			`$DIALOG $DIALOG_BACKTITLE --title "Internal Interfaces" --msgbox "Error: '$if' is already used for external interfaces, please choose the good one" 8 60`;
			#remove
			#$int_iface =~ s/$if//g;
		    }
                }

                # reformat
                $int_iface =~ s/ +/ /g;
		$int_iface =~ s/ $//g;
		$int_iface =~ s/^ //g;
		# save
       		$config_value{'INT_IFACE'}=$int_iface;
	

	   }
	
   }

   if($menu =~ /2/){
       ######################
       # EXTERNAL INTERFACE #
       ######################
        
       #do{
	   $ext_iface =  select_a_interface ('Select Internet interface(s)','Choose your internet interface(s)',"$config_value{'EXT_IFACE'}");
      
	   #while syntax error
       #}while($ext_iface =~ /^$/ && $? == 0);
	


       # if no CANCEL presed, we must save the new config
       if($? == 0){
	   # format return
	   $ext_iface =~ s/ \([0-9.]*\)|\(no ip found\)//g;  #remove ip
	   $ext_iface =~ s/\"//g;
	   $ext_iface =~ s/ $//g;
	   $ext_iface =~ s/^ //g;
	   $ext_iface =~ s/ +/ /g;
	   

	   
	   # test if interface is already used in internal interface
	   @iface_ext = split (/ +/,$ext_iface);
	   @iface_int = split(/ +/,$config_value{'INT_IFACE'});
	   foreach $if (@iface_ext){
	       
	       if (grep(/^$if$/, @iface_int)){
		   `$DIALOG $DIALOG_BACKTITLE --title "External Interfaces" --msgbox "Error: '$if' is already used for internal interfaces, please choose the good one" 8 60`;
		   #remove
		   # $ext_iface =~ s/$if//g;
	       }
	   }
	   
	   # reformat
	   $ext_iface =~ s/ +/ /g;
	   $ext_iface =~ s/ $//g;
	   $ext_iface =~ s/^ //g;
	   # save
	   $config_value{'EXT_IFACE'}=$ext_iface;
	   
	   
	   
       }
       
   }


   
   ################################
   # ALLOWED TCP PORTS            #
   ################################
   if($menu == '3'){	

	open_tcp_inet;

   }






   ################################
   # ALLOWED UDP PORTS            #
   ################################
    if($menu == '4'){
   	open_udp_inet;
    }


   ################################
   # ALLOWED TCP PORTS            #
   ################################
   if($menu == '5'){

        open_tcp_lan;

   }






   ################################
   # ALLOWED UDP PORTS            #
   ################################
    if($menu == '6'){
        open_udp_lan;
    }

   ################################
   # FORWARDING TCP PORTS        #
   ################################
    if($menu == '7'){
	$exit_save=1;
	do{
	    
	    $menu_fwd_tcp = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "Forwarding TCP Port(s)" 10 40 3 "1" "Views TCP forward(s) rule(s)" "2" "Add TCP forward rule" "3" "Delete TCP forward(s) rule(s)" `;
	    
	    # remember output
	    # where is the 'break;' in perl ?
	    $exit_save=$?;
	    
	    
#  --checklist    <text> <height> <width> <list height> <tag1> <item1> <status1>...
	    
	    
	    # Delete rules
	    ###############
	    if($menu_fwd_tcp == '3' && $exit_save==0){
		
		
		# if we have tcp forward rules
		if($config_value{'TCP_FORWARD'} !~ /^$/){
		    
		    # create items list
		    @forward_array = split (/ |\n/,$config_value{'TCP_FORWARD'});
		    $i=0;
		    $item="";
		    foreach $fwd (@forward_array){
			$i++;
			$item="$item '$fwd' '' 'off' ";
		    }
		    
		    $forward_tcp = `$DIALOG $DIALOG_BACKTITLE $DIALOG_OK_LABEL_DELETE $DIALOG_CANCEL_LABEL_BACK --checklist "Delete TCP Forward(s) rule(s)" 15 40 $i $item `;
		    
		    
		    
		    # if no CANCEL presed
		    if($? == 0 && $forward_tcp !~ /^$/){
			
			`$DIALOG $DIALOG_BACKTITLE --title "Delete TCP Forward Port(s)" --yesno "Are you sur to want to delete ?" 5 40`;
			
			# Sur ?
			if($? == 0){
			    
			    # for each checked rules
			    $forward_tcp =~ s/\"|\n//g;
			    $forward_tcp =~ s/ +/ /g;
			    
			    @rules = split(/ /,$forward_tcp);
			    foreach $fwd (@rules){
				
				#print LOG_FILE $fwd;
				
				$config_value{'TCP_FORWARD'} =~ s/$fwd// ;
			    }
			    $config_value{'TCP_FORWARD'} =~ s/ $// ;
			    $config_value{'TCP_FORWARD'} =~ s/^ // ;
			    $config_value{'TCP_FORWARD'} =~ s/ +/ /g;
			}
			
		    }
		}
		else{
		    $forward_tcp = `$DIALOG $DIALOG_BACKTITLE --title "Delete TCP Forward(s) rule(s)" --msgbox "Nothing to delete" 10 40 `;
		}
	    }
	    
	    # View currents forward
	    ######################
	    if($menu_fwd_tcp == '1' && $exit_save==0){
		# there is no ports ?
		if($config_value{'TCP_FORWARD'} =~ /^$/){
		    `$DIALOG $DIALOG_BACKTITLE --title "TCP Forwarded Port(s)" --msgbox "none" 5 40`;
		}
		else{
		    
		    
		    # create items list
		    @forward_array = split (/ +/,$config_value{'TCP_FORWARD'});
		    $i=0;
		    $items="Iface(s)      >      Port(s)      >      Destination\n";
		    foreach $fwd (@forward_array){
			
			($ifaces,$port,$dst) = split(/>/,$fwd);
			
			if ($dst =~ /^$/){
			    $item="$items\nUPDATE THIS RULE:$ifaces    >    $port";
			}
			else{
			    $items="$items\n$ifaces      >      $port      >      $dst";
			    
			}
		    }
		    
		    `$DIALOG $DIALOG_BACKTITLE --title "TCP Forwarded Port(s)" --msgbox "$items" 20 60`;
		}
	    }
	    
	    # Add new forward
	    #################
	    $new_fwd="";
	    if($menu_fwd_tcp == '2' && $exit_save==0){
		do{
		    
		    # input: interface 
		    #-------------------
		    $new_fwd1 =  select_a_interface ('Add a TCP forward rule (1 of 4)','From wich interface would you like to forward ?');
		    $exit_add_fwd = $?;
		    
#			print $new_fwd1;
		    if($exit_add_fwd == 0){
			
			$new_fwd1 =~ s/ +/ /g;
			$new_fwd1 =~ s/^ //g;
			$new_fwd1 =~ s/ $//g;
			$new_fwd1 =~ s/ /,/g;
			
			
			# input: port to forward
			#-----------------------
			$new_fwd2 = `$DIALOG $DIALOG_BACKTITLE --title "Add a TCP forward rule (2 of 4)" --inputbox "Enter port(s) to forward\nExample: 21 or 2020:2030" 10 50 `;				
			# remember output
			$exit_add_fwd=$?;
			
			# no cancel
			if($exit_add_fwd == 0){
			    # input: ip destination
			    #------------------------
			    $new_fwd3 = `$DIALOG $DIALOG_BACKTITLE --title "Add a TCP forward rule (3 of 4)" --inputbox "Enter destination host\nExample: 192.168.4.3" 10 50 `;
			    $exit_add_fwd=$?;
			    
			    # no cancel
			    if($exit_add_fwd == 0){
				# input : modified destination port
				#----------------------------------
				$new_fwd4 = `$DIALOG $DIALOG_BACKTITLE --title "Add a TCP forward rule (4 of 4)" --inputbox "Modify destination port (optional)\nExample: 21 or 3020:3030" 10 50 `;
				$exit_add_fwd=$?;
				
				# keep iptable syntax
				$new_fwd4 =~ s/:/-/g;
				
			    }
			}
			
			
			
			
			# if no CANCEL presed
			if($exit_add_fwd == 0){
			    
			    $new_fwd = "$new_fwd1 $new_fwd2 $new_fwd3 $new_fwd4";
			    
			    #print $new_fwd;
			    #exit;
			    
			    # format
			    $new_fwd =~ s/\n|\"//g;
			    if($new_fwd =~ /^(.+) (.+) (.+) (.+)$/){
				# new port was given
				$new_fwd =~ s/^(.*) (.*) (.*) (.*)$/$1>$2>$3:$4/g;
			    }
			    else {
				if($new_fwd =~ /^(.+) (.+) (.+) $/){
				    $new_fwd =~ s/^(.*) (.*) (.*) .*$/$1>$2>$3/g;
				}
			    }
			    
			    
			    #print $new_fwd;
			    #exit;
			    
			    # Test rule
			    if($new_fwd !~ /^[a-zA-Z0-9,]+>[0-9]+(:[0-9]+)?>[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]+(-[0-9]+)?)?$/){
				`$DIALOG $DIALOG_BACKTITLE --title "Add TCP Forward Port(s)" --msgbox "Error in forward syntax" 5 40`;
			    }
			    else{
				
				if($config_value{'TCP_FORWARD'} !~ /^$/){
				    $config_value{'TCP_FORWARD'}="$config_value{'TCP_FORWARD'} $new_fwd";
				}
				else{
				    $config_value{'TCP_FORWARD'}="$new_fwd";
				}
				#print LOG_FILE $config_value{'TCP_FORWARD'};
				$exit_add_fwd=1;
			    }
			}
		    }
		}while($exit_add_fwd == 0);
	    }
	    
	}while($exit_save == 0);
    }	



   ################################
   # FORWARDING UDP PORTS        #
   ################################
   if($menu == '8'){
    $exit_save=1;
    do{

	$menu_fwd_udp = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "Forwarding UDP Port(s)" 10 40 3 "1" "Views UDP forward(s) rule(s)" "2" "Add UDP forward rule" "3" "Delete UDP forward(s) rule(s)" `;

        # remember output
        # where is the 'break;' in perl ?
	$exit_save=$?;


#  --checklist    <text> <height> <width> <list height> <tag1> <item1> <status1>...


        # Delete rules
        ###############
	if($menu_fwd_udp == '3' && $exit_save==0){


            # if we have udp forward rules
	    if($config_value{'UDP_FORWARD'} !~ /^$/){

                # create items list
		@forward_array = split (/ |\n/,$config_value{'UDP_FORWARD'});
		$i=0;
		$item="";
		foreach $fwd (@forward_array){
		    $i++;
		    $item="$item '$fwd' '' 'off' ";
		}

		$forward_udp = `$DIALOG $DIALOG_BACKTITLE $DIALOG_OK_LABEL_DELETE $DIALOG_CANCEL_LABEL_BACK --checklist "Delete UDP Forward(s) rule(s)" 15 40 $i $item `;

                # if no CANCEL presed
		if($? == 0  && $forward_udp !~ /^$/){

		    `$DIALOG $DIALOG_BACKTITLE --title "Delete UDP Forward Port(s)" --yesno "Are you sur to want to delete ?" 5 40`;

                    # Sur ?
		    if($? == 0){

                        # for each checked rules
			$forward_udp =~ s/\"|\n//g;
			$forward_udp =~ s/ +/ /g;

			@rules = split(/ /,$forward_udp);
			foreach $fwd (@rules){
			    $config_value{'UDP_FORWARD'} =~ s/$fwd// ;
			}
			$config_value{'UDP_FORWARD'} =~ s/ $// ;
			$config_value{'UDP_FORWARD'} =~ s/^ // ;
			$config_value{'UDP_FORWARD'} =~ s/ +/ /g;
		    }

		}

	    }
	    else{
		$forward_udp = `$DIALOG $DIALOG_BACKTITLE --title "Delete UDP Forward(s) rule(s)" --msgbox "Nothing to delete" 10 40 `;
	    }
	}


        # View currents forward
        ######################
	if($menu_fwd_udp == '1' && $exit_save==0){
            # there is no ports ?
	    if($config_value{'UDP_FORWARD'} =~ /^$/){
		`$DIALOG $DIALOG_BACKTITLE --title "UDP Forwarded Port(s)" --msgbox "none" 5 40`;
	    }
	    else{

                # create items list
		@forward_array = split (/ +/,$config_value{'UDP_FORWARD'});
		$i=0;
		
		$items="Iface(s)      >      Port(s)      >      Destination\n";
		foreach $fwd (@forward_array){

					
		    ($ifaces,$port,$dst) = split(/>/,$fwd);
					
		    $items="$items\n$ifaces      >       $port      >      $dst";
		    
		}

		`$DIALOG $DIALOG_BACKTITLE --tab-correct --tab-len 10 --title "UDP Forwarded Port(s)" --msgbox "$items" 20 60`;
	    }
	}



        # Add new forward
        #################
	$new_fwd="";
	if($menu_fwd_udp == '2' && $exit_save==0){
	    do{


	      $new_fwd1 =  select_a_interface ('Add a UDP forward rule (1 of 4)','From wich interface would you like to forward ?');
	      $exit_add_fwd = $?;

#			print $new_fwd1;
	      if($exit_add_fwd == 0){
			    
	        $new_fwd1 =~ s/ +/ /g;
		$new_fwd1 =~ s/^ //g;
		$new_fwd1 =~ s/ $//g;
	        $new_fwd1 =~ s/ /,/g;
		       


		# input: port to forward
                #-----------------------
                $new_fwd2 = `$DIALOG $DIALOG_BACKTITLE --title "Add a UDP forward rule (2 of 4)" --inputbox "Enter port(s) to forward\nExample: 21 or 2020:2030" 10 50 `;
                
		# remember output
                $exit_add_fwd=$?;

                # no cancel
                if($exit_add_fwd == 0){
                	# input: ip destination
                        #------------------------
                        $new_fwd3 = `$DIALOG $DIALOG_BACKTITLE --title "Add a UDP forward rule (3 of 4)" --inputbox "Enter destination host\nExample: 192.168.4.3" 10 50 `;
                        $exit_add_fwd=$?;

                        # no cancel
                        if($exit_add_fwd == 0){
                        	# input : modified destination port
                                #----------------------------------
                                $new_fwd4 = `$DIALOG $DIALOG_BACKTITLE --title "Add a UDP forward rule (4 of 4)" --inputbox "Modify destination port (optional)\nExample: 21 or 3020:3030" 10 50 `;
                                $exit_add_fwd=$?;

				# keep iptable syntax  ()
				$new_fwd4 =~ s/:/-/g;
                        }
                }



                # if no CANCEL presed
		if($exit_add_fwd == 0){

			$new_fwd = "$new_fwd1 $new_fwd2 $new_fwd3 $new_fwd4";

			# format
              		$new_fwd =~ s/\n|\"//g;
       			if($new_fwd =~ /^(.+) (.+) (.+) (.+)$/){
			    # new port was given
			    $new_fwd =~ s/^(.*) (.*) (.*) (.*)$/$1>$2>$3:$4/g;
		      	}else {
			    if($new_fwd =~ /^(.+) (.+) (.+) $/){
				$new_fwd =~ s/^(.*) (.*) (.*) .*$/$1>$2>$3/g;
			    }
		      	}



                    # Test rule
		    if($new_fwd !~ /^[a-zA-Z0-9,]+>[0-9]+(:[0-9]+)?>[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]+(-[0-9]+)?)?$/){
			`$DIALOG $DIALOG_BACKTITLE --title "Add UDP Forward Port(s)" --msgbox "Error in forward syntax" 5 40`;
		    }
		       else{

			   if($config_value{'UDP_FORWARD'} !~ /^$/){
			       $config_value{'UDP_FORWARD'}="$config_value{'UDP_FORWARD'} $new_fwd";
			   }
			   else{
			       $config_value{'UDP_FORWARD'}="$new_fwd";
			   }
			   
			   #exit
			   $exit_add_fwd=1;
		       }
		   }
	  }     
	       }while($exit_add_fwd == 0);
	  
          }
        }while($exit_save == 0);
    }





#------------------------------------------------------------------
#------------------------ DMZ      ---------------------------------
#------------------------------------------------------------------
#if ($menu == '7'){
#   do{
#
#       $dmz_menu=`$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --title "DMZ Configuration" --menu '' 12 40 5 "1" "View config" "2" "Add a Host" "3" "Modify a Host" "4" "Delete a Host" "5" "DNS mode" `;
#       $dmz_menu_exit=$?;

       #---------------------
       # View current config
       #---------------------
       
#       if($dmz_menu == '1' && $dmz_menu_exit == 0){


	   # create a temp file
#	   if(open (TMP_FILE,'>',"/tmp/firewall-jay-dmz-config") == 0){
#	       print ("Error: can't create a tempory file in /tmp/'\n\n");
#	       exit 1;
#	   }


	   # format list
#	   $list =  $config_value{'DMZ'};
#	   $list =~ s/ +/\n/g;
#	   $list =~ s/(.*);(.*);(.*);(.*);(.*);(.*);(.*);(.*);(.*);(.*);(.*)\n?/description   : $1\niface_inet    : $2\niface_lan     : $3\niface_dmz     : $4\nhost          : $5\ntcp_from_inet : $6\nudp_from_inet : $7\ntcp_to_inet   : $8\nudp_to_inet   : $9\ntcp_from_lan  : $10\nudp_from_lan  : $11\n\n----\n\n/g;

#	   print TMP_FILE "$list";

	   #print "coucou $config_value{'DMZ'}";
	   #exit;

#	  `$DIALOG $DIALOG_BACKTITLE  --title "Current configuration" --textbox /tmp/firewall-jay-dmz-config 20 60 `;


#	   close (TMP_FILE);

	   # rm tmp file
#	   unlink "/tmp/firewall-jay-dmz-config";

#       }

       #---------------------
       # ADD A HOST
       #---------------------
       
#       if($dmz_menu == '2' && $dmz_menu_exit == 0){


	   # input: description
	   #--------------------
#	   do{
#	       $msg ="Enter a description for your host (no ';'quote or spaces allowed)\nEx: ftp-server";
#	       $new1 = `$DIALOG $DIALOG_BACKTITLE  --title "Add a host (1/11) : Description" --inputbox "$msg" 10 40 `;

	       # already used ?
#	       if(grep(/^$new1;| $new1;/,$config_value{'DMZ'})){
#		   `$DIALOG $DIALOG_BACKTITLE --title "Add a host (1/11)" --msgbox "Error: Description already exist" 5 40`;
#		   $new1="";
#	       }
#	   }while($new1 =~ /^$|[;\" ]/ && $? ==0);
	 

	   # input: internet interface 
	   #----------------------------
	   # no cancel
#	   if($?==0){
#	       do{
#		   $new2 =  select_a_interface ('Add a host (2/11) : Internet interface(s)','Choose the internet interface(s) allowed in the DMZ ?');
		   
		   #while syntax error
#	       }while($new2 =~ /^$/ && $? == 0);
	   
      
	       # convert syntax of list
#	       $new2=~s/ +/,/g;
#	   }
	   
	   # input: lan interface 
	   #----------------------------
	   # no cancel
#	   if($?==0){       
#	       $new3 =  select_a_interface ('Add a host (3/11) : Lan interface(s)','Choose the LAN interface(s) allowed in the DMZ ? (optional)');
		 
	       # convert syntax of list
#	       $new3=~s/ +/,/g;
#	   }
	   
	   # input: dmz interface 
	   #----------------------------
	   # no cancel
#	   if($?==0){
#	       do{
#		   $new4 =  select_a_interface ('Add a host (4/11) : DMZ interface','Choose the DMZ interface (only ONE interface)');
		  
		   #while syntax error
#	       }while($new4 =~ /^$| / && $? == 0);
	   
	       
#	       $new4=~s/ +//g;
#	   }

	   # input: HOST on the dmz 
	   #----------------------------
	   # no cancel
#	   if($?==0){  
#	       do{
#		   $msg ="Enter the IP of the host on the DMZ\nEx: 192.168.5.2";
#		   $new5 = `$DIALOG $DIALOG_BACKTITLE  --title "Add a host (5/11) : IP of host" --inputbox "$msg" 10 40 `;
		   # while syntax error
#	       }while($new5 !~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/ && $? ==0);  
	       
	       
#	       $new5=~s/ +//g;
#	   }

	   # input: TCP from inet 
	   #----------------------------
	   # no cancel
#	   if($?==0){  
#	       do{
#		   $msg ="Enter spaces separate TCP port(s) allowed FROM Internet\nEx for a smtp/pop server : 25 110";
#		   $new6 = `$DIALOG $DIALOG_BACKTITLE  --title "Add a host (6/11) : TCP from Inet" --inputbox "$msg" 10 40 `;
		   # while syntax error
#	       }while($new6 !~ /^[0-9]*( +[0-9]+)*$/ && $? ==0);  
	   
	       # convert syntax of list
#	       $new6=~s/ +/,/g;
#	   }

	   # input: UDP from inet 
	   #----------------------
	   # no cancel
#	   if($?==0){  
#	       do{
#		   $msg ="Enter spaces separate UDP port(s) allowed FROM Internet";
#		   $new7 = `$DIALOG $DIALOG_BACKTITLE  --title "Add a host (7/11) : UDP from Inet" --inputbox "$msg" 10 40 `;
		   # while syntax error
#	       }while($new7 !~ /^[0-9]*( +[0-9]+)*$/ && $? ==0);  
	   
	       # convert syntax of list
#	       $new7=~s/ +/,/g;
#	   }

	   
	   # input: TCP to inet 
	   #----------------------
	   # no cancel
#	   if($?==0){  
#	       do{
#		   $msg ="Enter spaces separate TCP port(s) allowed TO Internet";
		   
#		   $new8 = `$DIALOG $DIALOG_BACKTITLE  --title "Add a host (8/11) : TCP to Inet" --inputbox "$msg" 10 40 `;
		
		   
		   # while syntax error
#	       }while($new8 !~ /^[0-9]*( +[0-9]+)*$/ && $? ==0);  
	       
	       # convert syntax of list
#	       $new8=~s/ +/,/g;
#	   }

	   # input: UDP to inet 
	   #----------------------
	   # no cancel
#	   if($?==0){  
#	       do{
#		   $msg ="Enter spaces separate UDP port(s) allowed TO Internet";
#		   $new9 = `$DIALOG $DIALOG_BACKTITLE  --title "Add a host (9/11) : UDP to Inet" --inputbox "$msg" 10 40 `;
		   # while syntax error
		   
#	       }while($new9 !~ /^[0-9]*( +[0-9]+)*$/ && $? ==0);  
	  
	       # convert syntax of list
#	       $new9=~s/ +/,/g;
	       
#	   }


	   # input: TCP from LAN 
	   #----------------------------
	   # no cancel
#	   if($?==0){  
#	       do{
#		   $msg ="Enter spaces separate TCP port(s) allowed from LAN";
#		   $new10 = `$DIALOG $DIALOG_BACKTITLE  --title "Add a host (10/11) : TCP from Lan" --inputbox "$msg" 10 40 `;
		   # while syntax error
#	       }while($new10 !~ /^[0-9]*( +[0-9]+)*$/ && $? ==0);  
	   
	       # convert syntax of list
#	       $new10=~s/ +/,/g;
#	   }

	   # input: UDP from inet 
	   #----------------------
	   # no cancel
#	   if($?==0){  
#	       do{
#		   $msg ="Enter spaces separate UDP port(s) allowed from LAN";
#		   $new11 = `$DIALOG $DIALOG_BACKTITLE  --title "Add a host (11/11) : UDP from Inet" --inputbox "$msg" 10 40 `;
		   # while syntax error
#	       }while($new11 !~ /^[0-9]*( +[0-9]+)*$/ && $? ==0);  
	   
#	       # convert syntax of list
#	       $new11=~s/ +/,/g;
#	   }

	   

	   ###########
	   # SAVE
	   ######### 

	   # no cancel
#	   if($?==0){
	   
#	       `$DIALOG $DIALOG_BACKTITLE  --title "Add a host" --msgbox "\nHost Added" 10 40`;
	       
#	       $new_dmz="$new1;$new2;$new3;$new4;$new5;$new6;$new7;$new8;$new9;$new10;$new11";
	       
#	       if ($config_value{'DMZ'} =~ /^$/){ $config_value{'DMZ'}="$new_dmz";}
#	       else  { $config_value{'DMZ'}="$config_value{'DMZ'} $new_dmz"; }

#	   }

 #      }

       #---------------------
       # Modify a Host
       #---------------------
       
#       if($dmz_menu == '3' && $dmz_menu_exit == 0){


#	   if($config_value{'DMZ'} !~ /^$/){
	       
	       # create items list
#	       @array_dmz = split (/ |\n/,$config_value{'DMZ'});
#	       $i=0;
#	       $item="";
#	       foreach $description (@array_dmz){
#		   $i++;
		   
		   # keep only description
#		   $description =~ s/^(.*);.*;.*;.*;.*;.*;.*;.*;.*;.*;.* ?/$1/g;
#		   $item="$item '$description' '' ";
#	       }
	       
#	       $old_dmz = `$DIALOG $DIALOG_BACKTITLE $DIALOG_OK_LABEL_MODIFY $DIALOG_CANCEL_LABEL_BACK --menu "Modify DMZ host" 15 40 $i $item `;
	       
	       
	       
	       # if no CANCEL presed
#	       if($? == 0 && $old_dmz !~ /^$/){
		   
		   # extract dmz config
#		   $new_dmz = $config_value{'DMZ'};
#print "$old_dmz\n";
#		   $new_dmz =~ s/^.*($old_dmz[^ ]*).*$/$1/g ;

		   # get all values
#		   ($desc,$iface_inet,$iface_lan,$iface_dmz,$host,$tcp_from_inet,$udp_from_inet,$tcp_to_inet,$udp_to_inet,$tcp_from_lan,$udp_from_lan) = split(/;/,$new_dmz);  
		   

		   # input: description
		   #--------------------
#		   do{
		       
#		       $msg ="Enter a description for your host (no ';'quote or spaces allowed)\nEx: ftp-server";
#		       $new1 = `$DIALOG $DIALOG_BACKTITLE  --title "Modify a host (1/11) : Description" --inputbox "$msg" 10 40 "$desc" `;
		  
		       # already used ?     
#		       if($new1 !~ /^$desc$/ && grep(/^$new1;| $new1;/,"$config_value{'DMZ'}")){
#			   `$DIALOG $DIALOG_BACKTITLE --title "Add a host (1/11)" --msgbox "Error: Description already exist" 5 40`;
#			   $new1="";
#		       }
#		   }while($new1 =~ /^$|[;\" ]/ && $? ==0);
		   
		   

		   # input: internet interface 
		   #----------------------------
		   # no cancel
#		   if($?==0){
#		       do{
#			   $new2 =  select_a_interface ('Modify a host (2/11) : Internet interface(s)','Choose the internet interface(s) allowed in the DMZ ?',$iface_inet);
			   
#			   #while syntax error
#		       }while($new2 =~ /^$/ && $? == 0);
		       
		       
		       # convert syntax of list
#		       $new2=~s/ +/,/g;
#		   }
		   
		   # input: lan interface 
		   #----------------------------
		   # no cancel
#		   if($?==0){
		       
#		       $new3 =  select_a_interface ('Modify a host (3/11) : Lan interface(s)','Choose the LAN interface(s) allowed in the DMZ ? (optional)',$iface_lan);
		       
		       # convert syntax of list
#		       $new3=~s/ +/,/g;
#		   }
		   
		   # input: dmz interface 
		   #----------------------------
		   # no cancel
#		   if($?==0){
#		       do{
#			   $new4 =  select_a_interface ('Modify a host (4/11) : DMZ interface','Choose the DMZ interface (choose only ONE interface)',$iface_dmz);
			   
#			   #while syntax error
#		       }while($new4 =~ /^$| / && $? == 0);
		       
		       
#		       $new4=~s/ +//g;
#		   }
		   
		   # input: HOST on the dmz 
		   #----------------------------
		   # no cancel
#		   if($?==0){  
#		       do{
#			   $msg ="Enter the IP of the host on the DMZ\nEx: 192.168.5.2";
#			   $new5 = `$DIALOG $DIALOG_BACKTITLE  --title "Modify a host (5/11) : IP of host" --inputbox "$msg" 10 40 "$host" `;
#			   # while syntax error
#		       }while($new5 !~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/ && $? ==0);  
		       
#		       
#		       $new5=~s/ +//g;
#		   }
		   
		   # input: TCP from inet 
		   #----------------------------
		   # no cancel
#		   if($?==0){  
#		       do{
#			   $msg ="Enter spaces separate TCP port(s) allowed FROM Internet\nEx for a smtp/pop server : 25 110";

#			   $tcp_from_inet =~ s/,/ /g;
#			   $new6 = `$DIALOG $DIALOG_BACKTITLE  --title "Modify a host (6/11) : TCP from Inet" --inputbox "$msg" 10 40 "$tcp_from_inet" `;
#			   # while syntax error
#		       }while($new6 !~ /^[0-9]*( +[0-9]+)*$/ && $? ==0);  
		       
		       # convert syntax of list
#		       $new6=~s/ +/,/g;
#		   }
		   
		   # input: UDP from inet 
		   #----------------------
		   # no cancel
#		   if($?==0){  
#		       do{
#			   $msg ="Enter spaces separate UDP port(s) allowed FROM Internet";
#			   $udp_from_inet =~ s/,/ /g;
#			   $new7 = `$DIALOG $DIALOG_BACKTITLE  --title "Modify a host (7/11) : UDP from Inet" --inputbox "$msg" 10 40 "$udp_from_inet" `;
			   # while syntax error
#		       }while($new7 !~ /^[0-9]*( +[0-9]+)*$/ && $? ==0);  
		       
		       # convert syntax of list
#		       $new7=~s/ +/,/g;
#		   }
		   
		   # input: TCP to inet 
		   #----------------------
		   # no cancel
#		   if($?==0){  
#		       do{
#			   $msg ="Enter spaces separate TCP port(s) allowed TO Internet";
#			   $tcp_to_inet =~ s/,/ /g;
#			   $new8 = `$DIALOG $DIALOG_BACKTITLE  --title "Modify a host (8/11) : TCP to Inet" --inputbox "$msg" 10 40 "$tcp_to_inet" `;
#			   # while syntax error
#		       }while($new8 !~ /^[0-9]*( +[0-9]+)*$/ && $? ==0);  
		       
		       # convert syntax of list
#		       $new8=~s/ +/,/g;
#		   }
		   
		   # input: UDP to inet 
		   #----------------------
		   # no cancel
#		   if($?==0){  
#		       do{
#			   $msg ="Enter spaces separate UDP port(s) allowed TO Internet";
#			   $udp_to_inet =~ s/,/ /g;
#			   $new9 = `$DIALOG $DIALOG_BACKTITLE  --title "Modify a host (9/11) : UDP to Inet" --inputbox "$msg" 10 40 "$udp_to_inet" `;
			   # while syntax error
#		       }while($new9 !~ /^[0-9]*( +[0-9]+)*$/ && $? ==0);  
		       
		       # convert syntax of list
#		       $new9=~s/ +/,/g;
	       
#		   }
		   
		   
		   # input: TCP from LAN 
		   #----------------------------
#		   # no cancel
#		   if($?==0){  
#		       do{
#			   $msg ="Enter spaces separate TCP port(s) allowed from LAN";
#			   $tcp_from_lan =~ s/,/ /g;
#			   $new10 = `$DIALOG $DIALOG_BACKTITLE  --title "Modify a host (10/11) : TCP from Lan" --inputbox "$msg" 10 40 "$tcp_from_lan" `;
#			   # while syntax error
#		       }while($new10 !~ /^[0-9]*( +[0-9]+)*$/ && $? ==0);  
		       
		       # convert syntax of list
#		       $new10=~s/ +/,/g;
#		   }
		   
		   # input: UDP from LAN
		   #----------------------
#		   # no cancel
#		   if($?==0){  
#		       do{
#			   $msg ="Enter spaces separate UDP port(s) allowed from LAN";
#			   $udp_from_lan =~ s/,/ /g;
#			   $new11 = `$DIALOG $DIALOG_BACKTITLE  --title "Modify a host (11/11) : UDP from Inet" --inputbox "$msg" 10 40 "$udp_from_lan" `;
#			   # while syntax error
#		       }while($new11 !~ /^[0-9]*( +[0-9]+)*$/ && $? ==0);  
		       
		       # convert syntax of list
#		       $new11=~s/ +/,/g;
#		   }
#		   




		   ###########
		   # SAVE
		   ######### 

		   # no cancel
#		   if($?==0){
		       
#		       `$DIALOG $DIALOG_BACKTITLE  --title "Modify a host" --msgbox "\nHost Modified" 10 40`;
		       
#		       $new_dmz="$new1;$new2;$new3;$new4;$new5;$new6;$new7;$new8;$new9;$new10;$new11";
		

		       # remove old values
#		       $config_value{'DMZ'} =~ s/$old_dmz[^ ]+//g ;

		       # reformat 
#		       $config_value{'DMZ'} =~ s/ $// ;
#		       $config_value{'DMZ'} =~ s/^ // ;
#		       $config_value{'DMZ'} =~ s/ +/ /g;

		       # add new 
#		       if ($config_value{'DMZ'} =~ /^$/){ $config_value{'DMZ'}="$new_dmz";}
#		       else  { $config_value{'DMZ'}="$config_value{'DMZ'} $new_dmz"; }
		       
		       # reformat 
#		       $config_value{'DMZ'} =~ s/ $// ;
#		       $config_value{'DMZ'} =~ s/^ // ;
#		       $config_value{'DMZ'} =~ s/ +/ /g;
		      
#		   }
		  
#	       }
#	   }
 #      }   




       #---------------------
       # Delete a Host
       #---------------------
       
#       if($dmz_menu == '4' && $dmz_menu_exit == 0){


#	   if($config_value{'DMZ'} !~ /^$/){
	       
#	       # create items list
#	       @array_dmz = split (/ |\n/,$config_value{'DMZ'});
#	       $i=0;
#	       $item="";
#	       foreach $description (@array_dmz){
#		   $i++;
		   
		   # keep only description
#		   $description =~ s/^(.*);.*;.*;.*;.*;.*;.*;.*;.*;.*;.* ?/$1/g;
#		   $item="$item '$description' '' ";
#	       }
	       
#	       $delete_dmz = `$DIALOG $DIALOG_BACKTITLE $DIALOG_OK_LABEL_DELETE $DIALOG_CANCEL_LABEL_BACK --menu "Delete DMZ host" 15 40 $i $item `;
	       
	       
	       
	       # if no CANCEL presed
#	       if($? == 0 && $delete_dmz !~ /^$/){
		   
#		   `$DIALOG $DIALOG_BACKTITLE --title "Delete DMZ host" --yesno "Are you sur to want to delete ?" 5 40`;
		   
		   # Sur ?
#		   if($? == 0){
		       
		       # for each checked dmz
#		       $delete_dmz =~ s/\"|\n//g;
#		       $delete_dmz =~ s/ +/ /g;
		       
		     
		  
#		       $config_value{'DMZ'} =~ s/$delete_dmz[^ ]+//g ;
		       
#		       $config_value{'DMZ'} =~ s/ $// ;
#		       $config_value{'DMZ'} =~ s/^ // ;
#		       $config_value{'DMZ'} =~ s/ +/ /g;
#		   }
		   
#	       }
#	   }
 #      }


       #---------------------
       # DNS MODE
       #---------------------
      
#       if($dmz_menu == '5' && $dmz_menu_exit == 0){


	   # get current config value
	   #------------------------
#	   if ($config_value{'DMZ_DNS_MODE'} == '0'){
#	       $items = "'0' 'No dns' on '1' 'Internet dns' off '2' 'Local dns' off";
#	   }elsif($config_value{'DMZ_DNS_MODE'} == '1') {
#	        $items = "'0' 'No dns' off '1' 'Internet dns' on '2' 'Local dns' off";
#	   }elsif($config_value{'DMZ_DNS_MODE'} == '2') {
#	        $items = "'0' 'No dns' off '1' 'Internet dns' off '2' 'Local dns' on";
#	   }

#	   do{
#	       $msg="Choose your dns mode for the DMZ\
#\
#(0)  Do not allow the dns traffic from the DMZ to anywhere,\
#     Much more secure mode ! (ex: your DNS server is on the DMZ)\
#\
#(1)  Allow the dns traffic between the dmz and internet\
#    (when your dmz hosts are configured with the dns ip of \
#     your ISP)\
#\
#(2)  Allow the dns traffic between the dmz and your linux server\
#    (when your firewall box is also your dns server)\
#";
	
 #              $mode=`$DIALOG $DIALOG_BACKTITLE --title "DNS mode for DMZ zone" --radiolist "$msg" 20 70 3 $items  `;

  #        }while($mode !~ /1|2|3/ && $? ==0);

         # save
#          if($? == 0){
 #             $config_value{'DMZ_DNS_MODE'} = "$mode";
  #         }
#       }
#   }while($dmz_menu_exit == 0);
#}

#------------------------------------------------------------------
#------------------------ OPTIONS ---------------------------------
#------------------------------------------------------------------
if ($menu == '9'){
   do{
        # Menu OPTIONS
        ################
        $options = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "Configuration (required)" 16 40 9 " " "----- network ------" "1" "Internet" "2" "LAN" "3" "ISP Config" "4" "ICMP to deny" " " "------ others ------" "5" "Log Options" "6" "ULog Options" "7" "Verbose" `;
        $options_exit = $?;
	
        # Menu OPTIONS -> INTERNET
        ###########################
        if($options == '1' && $options_exit == 0){

                # build items

                # Dynamic IP ?
                $items = "'Dynamic IP' ''";
                if($config_value{'DYN_IP'}=='1'){ $items="$items on "; } else { $items="$items off"; }

                # Ping ?
                $items = "$items 'Can be pinged' ''";
                if($config_value{'PING_FOR_ALL'}=='1'){ $items="$items on "; } else { $items="$items off"; }

                # TCP control ?
                $items = "$items 'TCP Control' ''";
                if($config_value{'TCP_CONTROL'}=='1'){ $items="$items on "; } else { $items="$items off"; }

                # ICMP control ?
                $items = "$items 'ICMP Control' ''";
                if($config_value{'ICMP_CONTROL'}=='1'){ $items="$items on "; } else { $items="$items off"; }

                # Spoofing control ?
                $items = "$items 'Spoofing Control' ''";
                if($config_value{'SPOOFING_CONTROL'}=='1'){ $items="$items on "; } else { $items="$items off"; }


                do{

                        # display menu
                        ##############
                        $server_options = `$DIALOG $DIALOG_BACKTITLE $DIALOG_HELP_BUTTON --checklist "Internet side" 13 40 5 $items `;
                        $server_options_exit=$?;
                        $server_options =~ s/\"|\\//g;

                        # display help ?
                        if($server_options =~ /HELP/){
                                $help="DYNAMIC IP : Enable this option if you use a dialup connection like IDSN/DSL/Cable/...\n
CAN BE PINGED: This option allow everyone to ping your server.\n
TCP CONTROL: Control TCP headers (for bad flags, invalid packets, ...)\n
ICMP CONTROL: Control type of ICMP, soon configurable.\n
SPOOFING CONTROL: Control for bad Ips, like reserved networks and your own ips.";

                                `$DIALOG $DIALOG_BACKTITLE --title "Server Options Help" --msgbox "$help" 20 60`;
                        }

                }while($server_options =~ /HELP/);

                # save
                #######
                if ($server_options_exit == '0'){
                        # no cancel

                        if($server_options =~ /Dynamic IP/){$config_value{'DYN_IP'}='1';}
                        else{$config_value{'DYN_IP'}='0';}

                        if($server_options =~ /Can be pinged/){$config_value{'PING_FOR_ALL'}='1';}
                        else{$config_value{'PING_FOR_ALL'}='0';}

                        if($server_options =~ /TCP Control/){$config_value{'TCP_CONTROL'}='1';}
                        else{$config_value{'TCP_CONTROL'}='0';}

                        if($server_options =~ /ICMP Control/){$config_value{'ICMP_CONTROL'}='1';}
                        else{$config_value{'ICMP_CONTROL'}='0';}

                        if($server_options =~ /Spoofing Control/){$config_value{'SPOOFING_CONTROL'}='1';}
                        else{$config_value{'SPOOFING_CONTROL'}='0';}

                }
        }

        # Menu OPTIONS -> LAN
        #########################
        if($options == '2' && $options_exit == 0){

                # build items

                # NAT ?
                $items="'Masquerading/NAT' ''";
                if($config_value{'NAT'}=='1'){ $items="$items on ";} else { $items="$items off"; }

                # DHCP ?
                $items = "$items 'DHCP Server' ''";
                if($config_value{'USE_DHCP_SERVER'}=='1'){ $items="$items on "; } else { $items="$items off"; }

                # IRC ?
                $items = "$items 'IRC' ''";
                if($config_value{'IRC'}=='1'){ $items="$items on "; } else { $items="$items off"; }

                do{

                        # display menu
                        ##############
                        $server_options = `$DIALOG $DIALOG_BACKTITLE $DIALOG_HELP_BUTTON --checklist "LAN side" 10 40 3 $items `;
                        $server_options_exit=$?;
			$server_options =~ s/\"|\\//g;

                        # display help ?
                        if($server_options =~ /HELP/){
                                $help="MASQUERADING : Enable this options if you share a internet connection over a LAN.\n
DHCP : Enable this option if your server is a DHCP server for your LAN.\n
IRC : Enable this option if you want to use IRC on your LAN.";

                                `$DIALOG $DIALOG_BACKTITLE --title "Server Options Help" --msgbox "$help" 13 60`;
                        }

                }while($server_options =~ /HELP/);


                # save
                #######
                if ($server_options_exit == '0'){
                        # no cancel

                        if($server_options =~ /Masquerading/){$config_value{'NAT'}='1';}
                        else{$config_value{'NAT'}='0';}

                        if($server_options =~ /DHCP Server/){$config_value{'USE_DHCP_SERVER'}='1';}
                        else{$config_value{'USE_DHCP_SERVER'}='0';}
			
			if($server_options =~ /IRC/){$config_value{'IRC'}='1';}
                        else{$config_value{'IRC'}='0';}

		}
	}


        # Menu OPTIONS -> ISP CONFIG
        ############################
        if($options == '3' && $options_exit == 0){
		do{
        		$menu_isp = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "ISP Config" 10 40 2 "1" "Domain Name Server (DNS)" "2" "DHCP Server" `;

        		$exit_isp = $?;

        		# DNS
        		######
        		if($menu_isp == '1'){
           			$new_dns = $config_value{'DNS'};
           			do{
                			$new_dns = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify DNS" --inputbox "Syntax: <ip dns 1> <ip dns 2> ..." 10 40 "$new_dns"  `;

                			$exit_dns=$?;

                			# no cancel
                			if($exit_dns == '0'){
                        			# valid ?
			                        $new_dns =~ s/\"|\n//g;
                        			$new_dns =~ s/ +/ /g;
			                        $new_dns =~ s/^ //;
                        			$new_dns =~ s/ $//;

			                        if($new_dns =~ /^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ?)*$/){

                        			        # save
			                                $config_value{'DNS'}=$new_dns;
                        			        $exit_dns=1;
			                        }
                        			else{
			                                `$DIALOG $DIALOG_BACKTITLE --title "Modify DNS ip" --msgbox "Error: Dns are not valids \n(example: 1.1.1.1 2.2.2.2)" 8 40`;
                        			}
                			}	
           			}while($exit_dns == '0');
        		}



        		# DHCP
		        ######
		        if($menu_isp == '2'){
				$new_dhcp = $config_value{'DHCP_SERVER'};
            			do{
			                $new_dhcp = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify DHCP Server" --inputbox "If you have one, enter the IP of your DHCP server (IPS side)" 10 40 "$new_dhcp" `;

			                $exit_dhcp=$?;

			                # no cancel
			                if($exit_dhcp == '0'){
						# valid ?
			                    	$new_dhcp =~ s/\"|\n| //g;
			                    	if($new_dhcp =~ /^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ?)*$/){

                        				# save
                        				$config_value{'DHCP_SERVER'}=$new_dhcp;
                        				$exit_dhcp=1;
                    				}
                    				else{
                        				`$DIALOG $DIALOG_BACKTITLE --title "Modify DHCP Server" --msgbox "Error: DHCP are not a valid ip" 8 40`;
                    				}
                			}
            			}while($exit_dhcp == '0');
        		}
   		}while($exit_isp == '0');

	} # end of ISP




	#
	# Menu OPTIONS -> LOG OPTIONS
	#####################################
        if($options == '5' && $options_exit == 0){

       		# build items
	        ##############

	        # DROPPED ?
	        $items="'Dropped Packets' ''";
	        if($config_value{'LOG_DROPPED'}=='1'){ $items="$items on ";} else { $items="$items off"; }

	        # SMURF ?
	        $items = "$items 'Smurf Activity' ''";
	        if($config_value{'LOG_ECHO_REPLY_TO_OUTSIDE'}=='1'){ $items="$items on "; } else { $items="$items off"; }

	        # Invalids Packets ?
	        $items = "$items 'Invalids Packets' ''";
	        if($config_value{'LOG_INVALID'}=='1'){ $items="$items on "; } else { $items="$items off"; }
	
       		# MARTIANS ?
	        $items = "$items 'Martians Packets' ''";
	        if($config_value{'LOG_MARTIANS'}=='1'){ $items="$items on "; } else { $items="$items off"; }

	        # PING FLOOD ?
	        $items = "$items 'Ping Flood Activity' ''";
	        if($config_value{'LOG_PINGFLOOD'}=='1'){ $items="$items on "; } else { $items="$items off"; }

	        # Spoof ?
	        $items = "$items 'Spoofed Packets' ''";
	        if($config_value{'LOG_SPOOFED'}=='1'){ $items="$items on "; } else { $items="$items off"; }

	        # SYNFLOOD ?
	        $items = "$items 'Syn Flood Activity' ''";
	        if($config_value{'LOG_SYNFLOOD'}=='1'){ $items="$items on "; } else { $items="$items off"; }

     	           do{

	        	# display menu
	        	##############
	            	$log_options = `$DIALOG $DIALOG_BACKTITLE $DIALOG_HELP_BUTTON --checklist "Log Options" 15 40 7 $items `;
			$log_options_exit=$?;
	            	$log_options =~ s/\"|\\//g;


      			if($log_options =~ /HELP/){
               			$help = "DROPPED PACKETS: Denyed TCP or UDP ports.\n\
SMURF: When your Lan take part to flood a victim (send echo-reply to a external host without recieved echo-request by him).\n\
INVALIDS: Packets with bad values (flags control).\n\
MARTIANS: Packets on a bad interface (invalid subnet).\n\
PING FLOOD: Too much ping by sec.\n\
SPOOFED PACKETS: Invalids ip source (reserved network, your own ips/subnet).\n\
SYN FLOOD: Too much connections by sec.";

				`$DIALOG $DIALOG_BACKTITLE --title "Server Options Help" --msgbox "$help" 20 60`;
            		}

        	    }while($log_options =~ /HELP/);


	        # save
	        #######
	        if ($log_options_exit == '0'){
               		# no cancel

	            if($log_options =~ /Dropped Packets/){$config_value{'LOG_DROPPED'}='1';}
	            else{$config_value{'LOG_DROPPED'}='0';}

	            if($log_options =~ /Martians Packets/){$config_value{'LOG_MARTIANS'}='1';}
	            else{$config_value{'LOG_MARTIANS'}='0';}

	            if($log_options =~ /Syn Flood/){$config_value{'LOG_SYNFLOOD'}='1';}
	            else{$config_value{'LOG_SYNFLOOD'}='0';}

	            if($log_options =~ /Ping Flood/){$config_value{'LOG_PINGFLOOD'}='1';}
	            else{$config_value{'LOG_PINGFLOOD'}='0';}

	            if($log_options =~ /Smurf/){$config_value{'LOG_ECHO_REPLY_TO_OUTSIDE'}='1';}
	            else{$config_value{'LOG_ECHO_REPLY_TO_OUTSIDE'}='0';}

	            if($log_options =~ /Spoofed Packets/){$config_value{'LOG_SPOOFED'}='1';}
	            else{$config_value{'LOG_SPOOFED'}='0';}

	            if($log_options =~ /Invalids/){$config_value{'LOG_INVALID'}='1';}
	            else{$config_value{'LOG_INVALID'}='0';}
                #exit

	
	        }			
	} # end of 'Log option'


	# Menu OPTIONS -> ULOG
        ###################################
	if($options == '6' && $options_exit == 0){
		my $new;
		my $exit;
		
		do{
			$new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "ULog Options" --inputbox "If you don't want to write all dropped packets to your syslog files, you can use ULOGD. Give only the 'nlgroup' value of your ulogd.conf. Leave blank if you don't want to use ULOGD" 14 50 "$config_value{'LOG_ULOG_NLGROUP'}" `;

			$exit = $?;
	
			if($exit == 0){

				$new =~ s/\"//g;
				$new =~ s/\'//g;
				$new =~ s/\n//g;
				if($new =~ /^[0-9]{1,2}$|^$/ ){
					# save
					$config_value{'LOG_ULOG_NLGROUP'} = $new;
					$exit=1;	
				}else{
					# error syntax
					`$DIALOG $DIALOG_BACKTITLE --title "ULog Options" --msgbox "Syntax error" 5 40`;
				}

			}
		}while($exit == 0);
	}	


	# Menu OPTIONS -> VERBOSE
       	###################################
       	if($options == '7' && $options_exit == 0){
			
		# Are we actually Verbose ?
               	if($config_value{'alias ECHO'} =~ /^echo.*$/){ $DEFAULTNO = "";} 
		else { $DEFAULTNO = "--defaultno"; }
	
		# ask for verbose
		`$DIALOG $DIALOG_BACKTITLE $DEFAULTNO --yesno "This option display all details at the launch of the firewall.\n\nEnable Verbose mode ?" 10 50 `;

		# yes ?
		if($? == '0'){
			$config_value{'alias ECHO'}="echo ";
		}else{
			$config_value{'alias ECHO'}="#echo ";
		}

	} # end of 'if Verbose'






        # Menu OPTIONS -> ICMP TO DENY
        ##############################
        if($options == '4' && $options_exit == 0){

                # define all icmp
                @icmp_all = ('echo-reply','destination-unreachable','network-unreachable','host-unreachable','protocol-unreachable','port-unreachable','fragmentation-needed','source-route-failed','network-unknown','host-unknown','network-prohibited','host-prohibited','TOS-network-unreachable','TOS-host-unreachable','communication-prohibited','host-precedence-violation','precedence-cutoff','source-quench','redirect','network-redirect','host-redirect','TOS-network-redirect','TOS-host-redirect','echo-request','router-advertisement','router-solicitation','time-exceeded','ttl-zero-during-transit','ttl-zero-during-reassembly','parameter-problem','ip-header-bad','required-option-missing','timestamp-request','timestamp-reply','address-mask-request','address-mask-reply');


                #  nb for icmp
                $nb_icmp_all = @icmp_all;


                # build items
                #############

                # get array of icmp to deny
                @icmp_user = split(' ',$config_value{'ICMP_TO_DENY'});

                $items = "";

                # create list
                foreach $icmp (@icmp_all){
                        $items = "$items '$icmp' ''";

                        #  selected or not ?
                        if(grep(/^$icmp$/,@icmp_user)){ $items="$items on "; } else { $items="$items off"; }

                }

                # display list
                $new_icmp = `$DIALOG $DIALOG_BACKTITLE --title "ICMP to deny" --checklist "Select wich ICMP you want to drop" 17 40 10 $items `;

                # no cancel ?
                if ($? == 0) {
                        # save new list
                        ###############

                        # format list
                        $new_icmp =~ s/\"//g;
                        $new_icmp =~ s/ +$//g;

                        # save
                        $config_value{'ICMP_TO_DENY'} = $new_icmp;
                }


	} # end of 'ICMP to deny'

   }while($options_exit == '0');
}


#######################
# ABOUT
########################
if($menu == '11'){

	$msg ="\
firewall-config.pl version $CONFIGURATOR_VERSION ($CONFIGURATOR_DATE)
Author : Jerome nokin <$MY_EMAIL>\
Web    : $FIREWALL_WEBPAGE\
\
\
This is a configurations's tool for SilentBob Firewall v$FIREWALL_VERSION \
Please send me all your problems/comments about this tool.\
I hope that you enjoy it.\
\
\
Jerome Nokin";
	`$DIALOG $DIALOG_BACKTITLE --msgbox "$msg" 18 50`;

}

#------------------------------------------------------------------------------------
# -------------------------------------- SPECIAL FEATURES -------------------------
#-----------------------------------------------------------------------------------

if($menu == '10'){
do{
    $menu_list ="'1' 'Custom Rules' '2' 'Denying Hosts (ex: spywares)' '3' 'Packets Tagging' '4' 'Pre / Post Scripts' '5' 'Transparent Proxy (HTTP)' '6' 'Transparent Proxy (FTP)' '7' 'Type Of Service (ToS)' '8' 'Virtual Private Network (VPN)' '9' 'ZorbIPTraffic'";

   	$menu_specials = `$DIALOG $DIALOG_BACKTITLE --title "Features (optional)" $DIALOG_CANCEL_LABEL_BACK --menu "" 0 40 10 $menu_list ` ;
	$menu_specials_exit = $?;


   ###########################
   # Custom Rules
   ###########################
   if($menu_specials == '1'){
    	
	# custom rules are actually used ?
	if($config_value{'CUSTOM_RULES'} == '1'){ $DEFAULTNO = "";}
        else { $DEFAULTNO = "--defaultno"; }


	# display menu
	$menu_custom_enable = `$DIALOG $DIALOG_BACKTITLE $DEFAULTNO --yesno "Enable Custom Rules ?\n\nSet 'Yes' to enable the custom rules. Give the path of the custom rules file in the next screen.\n\n(default is /var/lib/firewall-jay/firewall-custom.rules)" 12 65 `;	

	# enable ?
	if($? == 0){
	  do{
		# path menu
		$menu_custom_file = `$DIALOG $DIALOG_BACKTITLE --inputbox "Enter path to the custom rules file" 8 60 "$config_value{'CUSTOM_RULES_FILE'}" `;

		$exit_save=$?;
	
		# no cancel ?
		if($exit_save == 0){

			# custom file exist ?
			if(-e $menu_custom_file){
				$config_value{'CUSTOM_RULES'} 	   = '1';
				$config_value{'CUSTOM_RULES_FILE'} = $menu_custom_file;
				$exit_save=1;  
			}else{
				#file not exist
				`$DIALOG $DIALOG_BACKTITLE --title "Custom rules file" --msgbox "Error: File not exist" 5 40`;		
			}
		}else{
			#Disable custom rules
			$config_value{'CUSTOM_RULES'} = '0';
		}
	   # while file not exist
	   }while($exit_save  == 0)

	}else{
		#Disable custom rules
		$config_value{'CUSTOM_RULES'} = '0';
	}	
     
   }


   ############################
   # Denying HOSTs
   ###########################
   if($menu_specials == '2'){
   do{
       $menu_deny = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "Denying Hosts" 12 40 5 "1" "From IP  src" "2" "From IP  dst (spywares)" '3' "From MAC src" "4" "Directory path" "5" "ULog Options" `;


       # remember output
       # where is the 'break;' in perl ?
       $exit_save=$?;



       # Modify IP input
       if($menu_deny == '1' && $exit_save==0){

                #build item
                if($config_value{'DENY_IP_IN'} == '1'){ $items="Enable '' on ";}
                else{$items="Enable '' off ";}

                if($config_value{'DENY_IP_IN_LOG'} == '1'){ $items="$items 'Log Activity' '' on ";}
                else{$items="$items 'Log Activity' '' off ";}


                $items = "$items '--- Select blocking files ---' '' '' ";

                # build blocking files
                $block_files=`cd $config_value{'DENY_DIR'} ;ls block-ip-in.*`;
                @files = split(/ |\n/,$block_files);

                $i=3;
                foreach $f (@files){
                        $i++;
                        if($config_value{'DENY_IP_IN_FILES'} =~ /$f/) { $items="$items '$f' '' on ";}
                        else{$items="$items '$f' '' off ";}
                }

                # display menu
                $menu_deny_in=`$DIALOG $DIALOG_BACKTITLE --title 'Blocking traffic 'from' ips' --checklist "You will find here all your 'block-ip-in.*' files\nFor enable this option, you must select at least one blocking file." 20 50 $i $items `;

                # no cancel
                if($? == 0){

                        $menu_deny_in =~ s/--- Select blocking files ---//g;

                        #Enable ?
                        if($menu_deny_in =~ /Enable/){
                                # file selected ?
                                if($menu_deny_in =~ /block-ip-in/){
                                        $config_value{'DENY_IP_IN'}='1';
                                }else{
                                        `$DIALOG $DIALOG_BACKTITLE --msgbox "Error: No blocking file selected, can't enable option." 10 40`;
                                        $config_value{'DENY_IP_IN'}='0';
                                }
                        }else{
                                $config_value{'DENY_IP_IN'}='0';
                        }

                        # Log ?
                        if($menu_deny_in =~ /Log/){$config_value{'DENY_IP_IN_LOG'}='1';}
                        else{$config_value{'DENY_IP_IN_LOG'}='0';}


                        # files
                        if($menu_deny_in =~ /block/){
                                $block = $menu_deny_in;
                                $block =~ s/\"| {2,}//g;
                                $block =~ s/Enable |Log Activity //g;
                                $block =~ s/ $//g;

                                # add path
                                #$SPY_DIR="/var/lib/firewall-jay";
                                #$block =~ s/^(block-ip\.[a-zA-Z0-9]+)*$/$SPY_DIR\/$1/g;

                                $config_value{'DENY_IP_IN_FILES'}="$block";
                        }else{
                                $config_value{'DENY_IP_IN_FILES'}="";
                        }
                }
       }

       # Modify IP output
       ###############
       if($menu_deny == '2' && $exit_save==0){
           
		#build item
        	if($config_value{'DENY_IP_OUT'} == '1'){ $items="Enable '' on ";}
        	else{$items="Enable '' off ";}

        	if($config_value{'DENY_IP_OUT_LOG'} == '1'){ $items="$items 'Log Activity' '' on ";}
        	else{$items="$items 'Log Activity' '' off ";}


        	$items = "$items '--- Select blocking files ---' '' '' ";

        	# build blocking files
        	$block_files=`cd $config_value{'DENY_DIR'} ;ls block-ip-out.*`;
        	@files = split(/ |\n/,$block_files);
        	
		$i=3;
        	foreach $f (@files){
                	$i++;
	                if($config_value{'DENY_IP_OUT_FILES'} =~ /$f/) { $items="$items '$f' '' on ";}
        	        else{$items="$items '$f' '' off ";}
        	}

        	# display menu
        	$menu_deny_out=`$DIALOG $DIALOG_BACKTITLE --title "Blocking traffic 'to' ips" --checklist "You will find here all your 'block-ip-out.*' files\nFor enable this option, you must select at least one blocking file." 20 50 $i $items `;

	        # no cancel
        	if($? == 0){

	                $menu_deny_out =~ s/--- Select blocking files ---//g;

        	        #Enable ?
                	if($menu_deny_out =~ /Enable/){
                        	# file selected ?
	                        if($menu_deny_out =~ /block-ip-out/){
        	                        $config_value{'DENY_IP_OUT'}='1';
                	        }else{
                        	        `$DIALOG $DIALOG_BACKTITLE --msgbox "Error: No blocking file selected, can't enable option." 10 40`;
                                	$config_value{'DENY_IP_OUT'}='0';
	                        }
        	        }else{
                	        $config_value{'DENY_IP_OUT'}='0';
                	}

	                # Log ?
        	        if($menu_deny_out =~ /Log/){$config_value{'DENY_IP_OUT_LOG'}='1';}
                	else{$config_value{'DENY_IP_OUT_LOG'}='0';}


	                # files
        	        if($menu_deny_out =~ /block/){
                	        $block = $menu_deny_out;
                        	$block =~ s/\"| {2,}//g;
	                        $block =~ s/Enable |Log Activity //g;
        	                $block =~ s/ $//g;

                	        # add path
	                        #$SPY_DIR="/var/lib/firewall-jay";
        	                #$block =~ s/^(block-ip\.[a-zA-Z0-9]+)*$/$SPY_DIR\/$1/g;

                	        $config_value{'DENY_IP_OUT_FILES'}="$block";
	                }else{
        	                $config_value{'DENY_IP_OUT_FILES'}="";
                	}
	        }

		# end of copy-paste

	}



       # Modify MAC input
       if($menu_deny == '3' && $exit_save==0){

                #build item
                if($config_value{'DENY_MAC_IN'} == '1'){ $items="Enable '' on ";}
                else{$items="Enable '' off ";}

                if($config_value{'DENY_MAC_IN_LOG'} == '1'){ $items="$items 'Log Activity' '' on ";}
                else{$items="$items 'Log Activity' '' off ";}


                $items = "$items '--- Select blocking files ---' '' '' ";

                # build blocking files
                $block_files=`cd $config_value{'DENY_DIR'} ;ls block-mac-in.*`;
                @files = split(/ |\n/,$block_files);

                $i=3;
                foreach $f (@files){
                        $i++;
                        if($config_value{'DENY_MAC_IN_FILES'} =~ /$f/) { $items="$items '$f' '' on ";}
                        else{$items="$items '$f' '' off ";}
                }

                # display menu
                $menu_deny_in=`$DIALOG $DIALOG_BACKTITLE --title "Blocking traffic 'from' mac address" --checklist "You will find here all your 'block-mac-in.*' files\nFor enable this option, you must select at least one blocking file." 20 50 $i $items `;

                # no cancel
                if($? == 0){

                        $menu_deny_in =~ s/--- Select blocking files ---//g;

                        #Enable ?
                        if($menu_deny_in =~ /Enable/){
                                # file selected ?
                                if($menu_deny_in =~ /block-mac-in/){
                                        $config_value{'DENY_MAC_IN'}='1';
                                }else{
                                        `$DIALOG $DIALOG_BACKTITLE --msgbox "Error: No blocking file selected, can't enable option." 10 40`;
                                        $config_value{'DENY_MAC_IN'}='0';
                                }
                        }else{
                                $config_value{'DENY_MAC_IN'}='0';
                        }

                        # Log ?
                        if($menu_deny_in =~ /Log/){$config_value{'DENY_MAC_IN_LOG'}='1';}
                        else{$config_value{'DENY_MAC_IN_LOG'}='0';}


                        # files
                        if($menu_deny_in =~ /block/){
                                $block = $menu_deny_in;
                                $block =~ s/\"| {2,}//g;
                                $block =~ s/Enable |Log Activity //g;
                                $block =~ s/ $//g;

                                # add path
                                #$SPY_DIR="/var/lib/firewall-jay";
                                #$block =~ s/^(block-ip\.[a-zA-Z0-9]+)*$/$SPY_DIR\/$1/g;

                                $config_value{'DENY_MAC_IN_FILES'}="$block";
                        }else{
                                $config_value{'DENY_MAC_IN_FILES'}="";
                        }
                }
       }







	# Change directory of blocking files
	if($menu_deny == '4' && $exit_save==0){
	   do{	

		$menu_deny_dir = `$DIALOG $DIALOG_BACKTITLE --inputbox "Enter the directory where we can found the blocking ips/mac files\n(block-ip-in.* , block-ip-out.* and block-mac-in.*)" 10 50 "$config_value{'DENY_DIR'}" `;
		
		$menu_deny_dir_exit = $?;

		# no cancel
		if($menu_deny_dir_exit == 0){
			# if directory exist
			if( -e $menu_deny_dir){
				$config_value{'DENY_DIR'} = $menu_deny_dir;
				$menu_deny_dir_exit = 1;
			}else{
				`$DIALOG $DIALOG_BACKTITLE --msgbox "Error: The directory not exist." 10 40`;
			}
		}

	   }while($menu_deny_dir_exit == 0)
	}


        # Menu OPTIONS -> ULOG
        ###################################
        if($menu_deny == '5' && $exit_save == 0){
                my $new;
                my $exit;

                do{
                        $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "ULog Options" --inputbox "If you don't want to write all denied hosts to your syslog files, you can use ULOGD. Give only the 'nlgroup' value of your ulogd.conf. Leave blank if you don't want to use ULOGD" 14 50 "$config_value{'DENY_ULOG_NLGROUP'}" `;

                        $exit = $?;

                        if($exit == 0){

                                $new =~ s/\"//g;
                                $new =~ s/\'//g;
                                $new =~ s/\n//g;
                                if($new =~ /^[0-9]{1,2}$|^$/ ){
                                        # save
                                        $config_value{'DENY_ULOG_NLGROUP'} = $new;
                                        $exit=1;
                                }else{
                                        # error syntax
                                        `$DIALOG $DIALOG_BACKTITLE --title "ULog Options" --msgbox "Syntax error" 5 40`;
                                }

                        }
                }while($exit == 0);
        }



   }while($exit_save == 0);
   } #end if
   	



########################
# Packets taging
########################
	
if($menu_specials == '3'){
	`$DIALOG $DIALOG_BACKTITLE --msgbox "Soon \n\nAvaivable in firewall.config directly by hand." 10 50`;
}


########################
# PRE / POST SCRIPT
########################

if($menu_specials == '4'){

    do{
	
	$menu_scripts = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "Pre / Post Scripts" 12 25 4 "1" "Post Start" "2" "Pre  Start" "3" "Post Stop" "4" "Pre  Stop" `;
	$menu_scripts_exit = $?;
	

	
	# Post Start
	if ($menu_scripts == '1'){
	    $new = `$DIALOG $DIALOG_BACKTITLE --title "Post start scripts" --inputbox "Enter a list of scripts separated by a ; "  8 45 "$config_value{'POST_START'}" `;
	    # no cancel
	    if ($? == '0'){
		$new =~ s/\"|\n|^ +| +$//g;
		$new =~ s/ +/ /g;
		$config_value{'POST_START'}=$new;
	    }
	}
	
	# Pre Start
	if ($menu_scripts == '2'){
	    $new = `$DIALOG $DIALOG_BACKTITLE --title "Pre start scripts" --inputbox "Enter a list of scripts separated by a ; " 8 45 "$config_value{'PRE_START'}" `;
	    # no cancel
	    if ($? == '0'){
		$new =~ s/\"|\n|^ +| +$//g;
		$new =~ s/ +/ /g;
	        $config_value{'PRE_START'}=$new;
	    }
	}
	
	
	
	
	# Post Stop
	if ($menu_scripts == '3'){
	    $new = `$DIALOG $DIALOG_BACKTITLE --title "Post stop scripts" --inputbox "Enter a list of scripts separated by a ;" 8 45 "$config_value{'POST_STOP'}" `;
	    # no cancel
	    if ($? == '0'){
		$new =~ s/\"|\n|^ +| +$//g;
		$new =~ s/ +/ /g;
		$config_value{'POST_STOP'}=$new;
	    }	
	}
	
	# Pre Stop
	if ($menu_scripts == '4'){
	    $new = `$DIALOG $DIALOG_BACKTITLE --title "Pre stop scripts" --inputbox "Enter a list of scripts separated by a ;" 8 45 "$config_value{'PRE_STOP'}" `;
	    # no cancel
	    if ($? == '0'){
		$new =~ s/\"|\n|^ +| +$//g;
		$new =~ s/ +/ /g;
		
		$config_value{'PRE_STOP'}=$new;
	    }
	}
	
    }while($menu_scripts_exit == '0');
    
} #end of 'pre / post scripts'
    

########################
# TRANSPARENT PROXY HTTP
########################
if($menu_specials == '5'){
  do{
	$proxy_http = `$DIALOG $DIALOG_BACKTITLE --title "HTTP Proxy" --inputbox "Enter your HTTP proxy port\nAll requests on port 80 will be redirected on it\nex: 8080" 10 55 "$config_value{'PROXY_HTTP'}" `;
	$proxy_http_exit = $?;

	# no cancel
	if($proxy_http_exit == 0){
		$proxy_http =~ s/ +|\"//g;

		# valid ?
		if($proxy_http =~ /^[0-9]+|$/){
			# save
			$config_value{'PROXY_HTTP'} = $proxy_http;
			
			# exit
			$proxy_http_exit = 1;
		}else{
			`$DIALOG $DIALOG_BACKTITLE --title "HTTP Proxy" --msgbox "Error: Port Invalid" 10 40`;
		}
	}
  }while ($proxy_http_exit == 0);
}


########################
# TRANSPARENT PROXY FTP
########################
if($menu_specials == '6'){
  do{
        $proxy_ftp = `$DIALOG $DIALOG_BACKTITLE --title "FTP Proxy" --inputbox "Enter your FTP proxy port\nAll requests on port 21 will be redirected on it\nex: 2121" 10 55 "$config_value{'PROXY_FTP'}" `;
        $proxy_ftp_exit = $?;

        # no cancel
        if($proxy_ftp_exit == 0){
                $proxy_ftp =~ s/ +|\"//g;

                # valid ?
                if($proxy_ftp =~ /^[0-9]+|$/){
                        # save
                        $config_value{'PROXY_FTP'} = $proxy_ftp;

                        # exit
                        $proxy_ftp_exit = 1;
                }else{
                        `$DIALOG $DIALOG_BACKTITLE --title "FTP Proxy" --msgbox "Error: Port Invalid" 10 40`;
                }
        }
  }while ($proxy_ftp_exit == 0);
}

######################
# TOS
######################
if($menu_specials == '7'){
	do{
	    $menu_tos = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --title "Type Of Service" --menu '' 12 40 4 "1" "Minimum Delay TCP" "2" "Minimum Delay UDP" "3" "Maximum Throughput TCP" "4" "Maximum Throughput UDP" `;


	    # remember output
            # where is the 'break;' in perl ?
	    $exit_save=$?;


 	    #-----
            # Minimum Delay TCP
	    #-------------------
	    if($menu_tos == '1' && $exit_save==0){
		do{
		    if($config_value{'TCP_MIN_DELAY'} == ""){
			$new_tos = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify TCP Minimum delay" --inputbox "Write ports list separate with spaces" 10 40  `;
		    }
		    else{
			$new_tos = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify TCP Minimum delay" --inputbox "Write ports list separate with spaces" 10 40 "$config_value{'TCP_MIN_DELAY'}" `;
		    }

		    $exit_new_tos=$?;

		    $new_tos =~ s/\n//g;
		    $new_tos =~ s/ +/ /g;
		    $new_tos =~ s/ $//g;
		    $new_tos =~ s/^ //g;


		    if($new_tos =~ /^([0-9]+(:[0-9]+)? ?)*$/ ){

                        # if no CANCEL presed
                        if($exit_new_tos == '0'){
                                # save
			    $config_value{'TCP_MIN_DELAY'}=$new_tos;

                                #exit loop;
			    $exit_new_tos=1;
                        }
		    }
		    else{
			`$DIALOG $DIALOG_BACKTITLE --title "Modify TCP Minimum delay" --msgbox "Error: List of Ports is not valid" 5 40`;
		    }
		}while($exit_new_tos == 0);
	    }

	    #---
	    # Minimum Delay UDP
	    #---------------------
	    
	    if($menu_tos == '2' && $exit_save==0){
                do{
                    if($config_value{'UDP_MIN_DELAY'} == ""){
                        $new_tos = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify UDP Minimum delay" --inputbox "Write ports list separate with spaces" 10 40  `;
                    }
                    else{
                        $new_tos = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify UDP Minimum delay" --inputbox "Write ports list separate with spaces" 10 40 "$config_value{'UDP_MIN_DELAY'}" `;
                    }

                    $exit_new_tos=$?;

                    $new_tos =~ s/\n//g;
                    $new_tos =~ s/ +/ /g;
                    $new_tos =~ s/ $//g;
                    $new_tos =~ s/^ //g;

		    if($new_tos =~ /^([0-9]+(:[0-9]+)? ?)*$/ ){

                        # if no CANCEL presed
                        if($exit_new_tos == '0'){
                                # save
                            $config_value{'UDP_MIN_DELAY'}=$new_tos;

                                #exit loop;
                            $exit_new_tos=1;
                        }
                    }
                    else{
                        `$DIALOG $DIALOG_BACKTITLE --title "Modify UDP Minimum delay" --msgbox "Error: List of Ports is not valid" 5 40`;
                    }
                }while($exit_new_tos == 0);
            }

            #---
            # Max Throughput TCP
            #---------------------

            if($menu_tos == '3' && $exit_save==0){
                do{
                    if($config_value{'TCP_MAX_THROUGHPUT'} == ""){
                        $new_tos = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify TCP Max Throughput" --inputbox "Write ports list separate with spaces" 10 40  `;
                    }
                    else{
                        $new_tos = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify TCP Max Throughput" --inputbox "Write ports list separate with spaces" 10 40 "$config_value{'TCP_MAX_THROUGHPUT'}" `;
                    }

                    $exit_new_tos=$?;

                    $new_tos =~ s/\n//g;
                    $new_tos =~ s/ +/ /g;
                    $new_tos =~ s/ $//g;
                    $new_tos =~ s/^ //g;
		    if($new_tos =~ /^([0-9]+(:[0-9]+)? ?)*$/ ){

                        # if no CANCEL presed
                        if($exit_new_tos == '0'){
                                # save
                            $config_value{'TCP_MAX_THROUGHPUT'}=$new_tos;

                                #exit loop;
                            $exit_new_tos=1;
                        }
                    }
                    else{
                        `$DIALOG $DIALOG_BACKTITLE --title "Modify TCP Max Throughput" --msgbox "Error: List of Ports is not valid" 5 40`;
                    }
                }while($exit_new_tos == 0);
            }



            #---
            # Max Throughput UDP
            #---------------------

            if($menu_tos == '4' && $exit_save==0){
                do{
                    if($config_value{'UDP_MAX_THROUGHPUT'} == ""){
                        $new_tos = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify UDP Max Throughput" --inputbox "Write ports list separate with spaces" 10 40  `;
                    }
                    else{
                        $new_tos = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify UDP Max Throughput" --inputbox "Write ports list separate with spaces" 10 40 "$config_value{'UDP_MAX_THROUGHPUT'}" `;
                    }

                    $exit_new_tos=$?;

                    $new_tos =~ s/\n//g;
                    $new_tos =~ s/ +/ /g;
                    $new_tos =~ s/ $//g;
                    $new_tos =~ s/^ //g;
		  
		if($new_tos =~ /^([0-9]+(:[0-9]+)? ?)*$/ ){

                        # if no CANCEL presed
		if($exit_new_tos == '0'){
                                # save
		    $config_value{'UDP_MAX_THROUGHPUT'}=$new_tos;

                                #exit loop;
		    $exit_new_tos=1;
		}
	    }
	    else{
		`$DIALOG $DIALOG_BACKTITLE --title "Modify UDP Max Throughput" --msgbox "Error: List of Ports is not valid" 5 40`;
	    }
	}while($exit_new_tos == 0);
    }

   	}while($exit_save == 0);

	if($config_value{'TCP_MIN_DELAY'} != "" || $config_value{'UDP_MIN_DELAY'} != "" || $config_value{'TCP_MAX_THROUGHPUT'} != "" || $config_value{'UDP_MAX_THROUGHPUT'} != "") 
	{$config_value{'TOS'} = '1';} 
	else{$config_value{'TOS'} = '0';}
}




##################
# VPN
######################
if($menu_specials == '8'){
 	features_vpn;

}

##########
# ZORBIPTRAFFIC
##############################
if($menu_specials == '9'){

   do{
        $menu_zorb = `$DIALOG $DIALOG_BACKTITLE --title "ZorbIPTraffic" $DIALOG_CANCEL_LABEL_BACK --menu '' 8 30 2 '1' "Subnets" '2' "Ips" `;

        $exit_menu_zorb = $?;

        # SUBNET
        ########
        if($menu_zorb =='1' && $exit_menu_zorb == '0'){
           do{
                $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify ZorbIPTraffic Subnets" --inputbox "Write subnets list separate with spaces. Example: '192.168.2.0/24 192.168.30.0/21'" 10 60  "$config_value{'ZORBIPTRAFFIC_NET'}" `;

                $exit_sub=$?;

                $new =~ s/\n//g;
                $new =~ s/ +/ /g;
                $new =~ s/\"//g;
                $new =~ s/^ //g;

                # if no CANCEL presed
                if($exit_sub == '0'){
                        if($new =~ /^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9.]+ ?)*$/){
                                # save
                                $config_value{'ZORBIPTRAFFIC_NET'}=$new;
                                $exit_sub=1;

                        }else{
                                `$DIALOG $DIALOG_BACKTITLE --title "Modify ZorbIPTraffic Subnets" --msgbox "Error: No valids Subnets" 5 40`;
                        }
                }
           }while($exit_sub == 0)
        }	


        # IPS
        ########
        if($menu_zorb =='2' && $exit_menu_zorb == '0'){
           do{
                $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify ZorbIPTraffic Ips" --inputbox "Write subnets list separate with spaces. Example: '192.168.2.1 192.168.2.3 192.168.2.7'" 10 60  "$config_value{'ZORBIPTRAFFIC_IPS'}" `;

                $exit_ips=$?;

                $new =~ s/\n//g;
                $new =~ s/ +/ /g;
                $new =~ s/\"//g;
                $new =~ s/^ //g;

                # if no CANCEL presed
                if($exit_ips == '0'){
                        if($new =~ /^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ?)*$/){
                                # save
                                $config_value{'ZORBIPTRAFFIC_IPS'}=$new;
                                $exit_ips=1;

                        }else{
                                `$DIALOG $DIALOG_BACKTITLE --title "Modify ZorbIPTraffic Ips" --msgbox "Error: No valids IPs" 5 40`;
                        }
                }
           }while($exit_ips == 0)
        }

	# Enable Zorb ?
	if($config_value{'ZORBIPTRAFFIC_IPS'} != "" && $config_value{'ZORBIPTRAFFIC_NET'} != ""){
		$config_value{'ZORBIPTRAFFIC'}=1;
	}
	else{
		 $config_value{'ZORBIPTRAFFIC'}=0;
	}

   }while($exit_menu_zorb == '0')	
}

} while($menu_specials_exit == '0');

}# end of menu = specials features



}


##################################################################################
##################################################################################
##################################################################################

####################################################################
#  SCRIPT FONCTIONS
####################################################################

#--------------------------------------------------------
# Display HELP
#--------------------------------------------------------

sub display_help
{
        print("firewall-config.pl Version $CONFIGURATOR_VERSION\n*Configurator for SilentBob Firewall*\n\n");


	print("Usage:  firewall-config.pl\n");
	print("        firewall-config.pl [-c|--config <filename>]\n");
	print("        firewall-config.pl [-n|--new]\n");
	print("        firewall-config.pl [-g|--generate]\n");
	print("        firewall-config.pl [-u|--update]\n");
	print("        firewall-config.pl [-h|--help]\n\n");

	print("Options:\n");
        print("   --config    -c  <filename>  Use another location for the configuration's file.\n");
        print("   --new       -n              Create and configure a new configuration's file (may be used with '-c')\n");
	print("                               (default: $CONFIG_FILE_DEFAULT).\n");
        print("   --generate  -g              Generate a empty configuration's file (may be used with '-c')\n"); 
	print("                               (default: $CONFIG_FILE_DEFAULT).\n");
	print("   --update    -u              Update the configuration's file to version $FIREWALL_VERSION\n");
	print("                               (may be used with '-c').\n");
	print("   --yes       -y              Say 'yes' to all questions.\n");
        print("   --help      -h              Show this help.\n\n");
}

#---------------------------------------------------------
#  Save Function
#----------------------------------------------------------
sub save_config_to_file
{
        # open file
        sysopen(CONFIG_FILE, "$CONFIG_FILE", O_WRONLY|O_TRUNC|O_CREAT, 0600) or die "ErrorD: can't open '$CONFIG_FILE'\n";
              

	# header of file
        print CONFIG_FILE $begin_of_config_file;


	# force to latest version
	$config_value{'FIREWALL_VERSION'} = "$FIREWALL_VERSION";


	# for all VAR in @config_name
        for ($i=0; $i<@config_name ; $i++){
                # special for internals interfaces
                if (@config_name[$i] =~ /INT_IFACE/){
                        print CONFIG_FILE "$config_help{@config_name[$i]}";
                        print CONFIG_FILE "@config_name[$i]=($config_value{@config_name[$i]})\n";
                }
                else{
                        print CONFIG_FILE "$config_help{@config_name[$i]}";
                        print CONFIG_FILE "@config_name[$i]=\"$config_value{@config_name[$i]}\"\n";
                }
        }

	close(CONFIG_FILE);
}


#---------------------------------------------------------
# Update Old variable name
#---------------------------------------------------------
sub update_old_variable_name {

    # Open the file
    if(open (CONFIG_FILE,'<',$CONFIG_FILE) == 0){
	print ("Error: can't open '$CONFIG_FILE'\n\n");
       	print ("Use '-n' for create a new configuration's file with dialog\n");
	print ("    '-g' for generate an empty configuration's file\n");
	print ("    '-c' for give path to an existing file\n");
       	print ("See '--help'\n\n");
        exit 1;
    }
    
    #----------
    # parse
    #-----------
    while (<CONFIG_FILE>){
	#  not a comments
        if(/^[^#]/) {
	      ($name,$value) = split('=');
              $value=~ s/\"//g;
              $value=~ s/\(//g;
              $value=~ s/\)//g;
              $value=~ s/\n//g;
	      
              # old variable found ?
              if(grep(/^$name$/,@config_name_old)){
		  # keep it
                  $config_value{@config_name_old{$name}}=$value;
              }
	}
    }
	
	
    close(CONFIG_FILE);
}
    
#-----------------------------------------------------------
# Parse Config file
#-------------------------------------------------------------

sub parse_config_file{
    if(open (CONFIG_FILE,'<',$CONFIG_FILE) == 0){
	print ("Error: can't open '$CONFIG_FILE'\n\n");
        print ("Use '-n' for create a new configuration's file with dialog\n");
        print ("    '-g' for generate an empty configuration's file\n");
        print ("    '-c' for give path to an existing file\n");
        print ("See '--help'\n\n");
	exit 1;
    }
    
    
    
    # ----------
    # parse
    #-----------
    while (<CONFIG_FILE>){

	#  no comments
	if(/^[^\#\n].*$/) {
	      ($name,$value) = split('=');

		# if the value is on more than one lines
		# ex: TMP="ttt \
		#           uuu"
	      
	      if($value !~ /^[\"|\(].*[\"|\)] *$/){	
		  $tmp = $value;
		  $tmp=~ s/\"|\(|\)|\n//g;
		  $tmp=~ s/\t+/ /g;
		  $tmp=~ s/ +/ /g;

		  #print "$value\n";
		  $stop=0;
		  while (<CONFIG_FILE>){
		      
#		      print "$_ \n";
		      $tmp = "$tmp $_";
		      last if ($_ =~ /^[^\"]*[\"\(\)] *$/);
		      
		        
		  }
		  $value = $tmp;
#		  print "1$name => $value\n";
              }else{
#		  print "2$name => $value\n";
	      }
	      
	      	$value=~ s/\"|\(|\)|\n|\\//g;
	      	$value=~ s/\t+/ /g;
	      	$value=~ s/ +/ /g;
	      	$value=~ s/^ +| +$//g;

	

		##################
		# CHANGING SYNTAX
		##################
	
	      	# if TCP_FORWARD or UDP_FORWARD
	      	if($name =~ /^TCP_FORWARD|UDP_FORWARD$/){
			# bad syntax ?
		  	if($value !~ /^([a-zA-Z0-9,]+>[0-9]+(:[0-9]+)?>[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]+(-[0-9]+)?)? *)+$/  && $value !~ /^$/){
		      
		      		# Message
		     	 	print("\n\n");
		      		print("WARNING: The Tcp/Udp Forwarding rules has changed of syntax to be able to select an incoming interface\n");
		      		print("         Please rewrite it with the new syntax\n");
		      		print("\n");
				print("         These rules have been removed from your config\n");
			      	print("         $name=\"$value\"\n");
			     	print("\n");
			      	
		      
		      		# print rules
			      	#@rules = split(/ +/,$value);
			      	#foreach $r(@rules){
			      	#	  print("             $r\n");
		      		#}
			      	#print("\n");
		      
		      
			      	# removes 
			      	$value = "";
			}
		}
	      


                ##################
                # CHANGING SYNTAX
                ##################

                # if TCP_EXT_IN or UDP_EXT_IN
                if($name =~ /^TCP_EXT_IN|UDP_EXT_IN$/){
                        # bad syntax ?
                        if($value !~ /^([a-zA-Z0-9]+;([0-9]+(:[0-9]+)?,?)+ *)+$/  && $value !~ /^$/){


				# build a new syntax	
				my @ifaces    = split (/ +/,$config_value{'EXT_IFACE'});
				my $new_value = "";
				my $old_value = $value;

				$old_value=~ s/ /,/g;

				foreach $if (@ifaces){
					$new_value="$new_value $if;$old_value";
				}
                		$new_value =~ s/^ +//g;

		                # Message
                                print("\n\n");
                                print("WARNING: The Tcp/Udp Allowed Ports has changed of syntax to be able to select an incoming interface.\n");
                                print("         This tool will update your config for you, please verify the new syntax below.\n");
                                print("\n");
                                print("         $name=\"$value\"\n");
				print("             become\n");
				print("         $name=\"$new_value\"\n");
                                print("\n");


                                # removes
                                $value = $new_value;
                        }
                }




                ##################
                # INFO
                ##################

                # if DENY_IP_OUT_FILES & DENY_IP_OUT
                if($name =~ /^DENY_IP_OUT_FILES$/){
                        # bad syntax ?
                        if($value =~ /spywares/  && $config_value{'DENY_IP_OUT'} =~ /^1$/ ){



                                # Message
                                print("\n\n");
                                print("INFO:    Spywares. There is a new Spywares update script named 'firewall-spy-update.pl'.\n");
                                print("         See README.Spywares.\n");
                                print("\n");

                        }
                }


		#################
		# SYN LIMIT BURST
		#################
		if($name =~ /^SYN_LIMIT$/){

			# if value = default ("4/s"), we can updated it
			if($value =~ /^4\/s$/){
				$value = "12/s";
			}
		}

	      	# good variable ?
	      	if(grep(/^$name$/,@config_name)){
			# get it
#print "$name\n";
		  	$config_value{$name}=$value;
	      	}
	  }
       }
	
	close(CONFIG_FILE);

#	exit;
    }
    
    
    
#--------------------------------------------------------------
# Test dialog function
#--------------------------------------------------------------
sub check_for_dialog
{
	# dialog is installed ?
	if(`$DIALOG --version 2>&1` !~ /^.*Version.*|.*version.*$/){
		print "\n";
        	print "Error: You have a very very older version of '$DIALOG'\n";
		print "       Please upgrade 'dialog' to $DIALOG_VERSION\n";
		print "\n";
        	exit 1;
	}


	# testing options
	$options_found = `$DIALOG --help 2>&1`;


	foreach $need (@options_needed){
        	if ($options_found !~ /$need/){
                	$need =~ s/\\|\[|\]//g;
	                print "Error: Option '$need' was not found in your dialog version\n\nPlease update dialog to version '$DIALOG_VERSION'\n\n";
			exit 1;
        	}
	}

}

#------------------------------------------------------------
#  Create Init Values
#------------------------------------------------------------
sub init_default_values
{
        # some default values
        #-----------------------
	$config_value{'TCP_INT_IN'}	= "*";
	$config_value{'UDP_INT_IN'}     = "*";

	$config_value{'FIREWALL_VERSION'} = "$FIREWALL_VERSION";
        $config_value{'IPTABLES'}       ="`which iptables`";
        $config_value{'IFCONFIG'}       ="`which ifconfig`";
        $config_value{'GREP'}           ="`which grep`";
        $config_value{'SED'}            ="`which sed`";

        $config_value{'PRIV_PORTS'}     ="0:1023";
        $config_value{'UPRIV_PORTS'}    ="1024:65535";
        $config_value{'RESERVED_IP'}    ="0.0.0.0/8 10.0.0.0/8 127.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.0.2.0/24 192.168.0.0/16 224.0.0.0/4 240.0.0.0/5 248.0.0.0/5 255.255.255.255/32";

        $config_value{'DYN_IP'}         ='1';
        $config_value{'NAT'}            ='1';
	$config_value{'IRC'}            ='0';
        $config_value{'PING_FOR_ALL'}   ='1';
        $config_value{'alias ECHO'}     ="#echo ";
        $config_value{'USE_DHCP_SERVER'}='0';

	$config_value{'DMZ_DNS_MODE'}='0';

	$config_value{'LOGLEVEL'}       	='info';
        $config_value{'LOG_DROPPED'}            ='0';
        $config_value{'LOG_MARTIANS'}           ='0';
        $config_value{'LOG_SYNFLOOD'}           ='0';
        $config_value{'LOG_PINGFLOOD'}          ='0';
        $config_value{'LOG_SPOOFED'}            ='1';
        $config_value{'LOG_ECHO_REPLY_TO_OUTSIDE'}='1';
        $config_value{'LOG_INVALID'}            ='0';


        $config_value{'PING_LIMIT'}             ="1/s";
        $config_value{'LOG_LIMIT'}              ="1/s";
        $config_value{'SYN_LIMIT'}              ="12/s";
	$config_value{'SYN_LIMIT_BURST'}        ="24";	

	$config_value{'MARK'}			='0';
	
	$config_value{'DENY_IP_IN'}		="0";
	$config_value{'DENY_IP_OUT'}		="0";
	$config_value{'DENY_IP_IN_LOG'}         ="0";
	$config_value{'DENY_IP_OUT_LOG'}	="0";

	$config_value{'DENY_MAC_IN'}		="0";
	$config_value{'DENY_MAC_IN_LOG'}       	="0";

        $config_value{'DENY_DIR'}		="/var/lib/firewall-jay";

	$config_value{'TCP_CONTROL'}		="1";
	$config_value{'ICMP_CONTROL'}		="1";
	$config_value{'SPOOFING_CONTROL'}	="1";

	$config_value{'ICMP_TO_DENY'}		="address-mask-request network-redirect host-redirect network-redirect TOS-network-redirect TOS-host-redirect timestamp-request timestamp-reply";

	$config_value{'CUSTOM_RULES'}		="0";
	$config_value{'CUSTOM_RULES_FILE'}	="/var/lib/firewall-jay/firewall-custom.rules";


	$config_value{'PPTP_LOCALHOST'}          	="0";
	$config_value{'PPTP_LOCALHOST_PORT'}    	="1723";
        $config_value{'PPTP_LOCALHOST_ACCESS_LAN'}      ="0";
        $config_value{'PPTP_LOCALHOST_ACCESS_INET'}     ="0";


       	$config_value{'PPTP_LAN'}           	="0";
	$config_value{'PPTP_LAN_IP'}		="";
        $config_value{'PPTP_LAN_PORT'}      	="1723";



        $config_value{'IPSEC_LOCALHOST'}          ="0";
        $config_value{'IPSEC_LOCALHOST_PORT'}    ="500";
        $config_value{'IPSEC_LAN'}               ="0";
        $config_value{'IPSEC_LAN_IP'}            ="";
        $config_value{'IPSEC_LAN_PORT'}          ="500";


        $config_value{'TOS'}                    ="0";
        $config_value{'ZORBIPTRAFFIC'}          ="0";
        $config_value{'FIREWALL_RULES_DIR'}     ="/var/lib/firewall-jay";


}


#------------------------------------------------
# Testing arguments
#------------------------------------------------

# SEARCH FOR A OTHER CONFIG FILE
sub search_c_argument{

        # search for '-c <filename>'
        $nb_arg=@ARGV;
        $new_location="";
        for ($i=0;$i<$nb_arg;$i++){
                if (@ARGV[$i] =~ /-c|--config/){
                        $new_location = @ARGV[$i+1];
                }
        }



        # default location of config's file ?
        if($new_location =~ /^$/){
                $CONFIG_FILE = $CONFIG_FILE_DEFAULT;
        }else{
                $CONFIG_FILE = $new_location;
        }
}

#-----------------------------------------------------
#   READ ARGUMENTS
#-----------------------------------------------------

sub read_arguments {

    $nb_arg= @ARGV;


    # ARG EXIST ?
    $count_arg=0;
    foreach $arg (@ARGV){

	# for all arguments given

	# if unknown AND not a -c argument part
        if(! grep(/$arg/,@MY_ARGUMENTS) && @ARGV[$count_arg-1] !~ /^-c|--config$/){
		print "Error: '$arg' unknown argument\n\n";
		display_help;
		exit 0;
	}

	$count_arg++;
    }
    



    # HELP ?
    if(grep (/-h|--help/,@ARGV)){
	display_help;
	exit 0;
    }
 
    # YES TO ALL ?
    if(grep (/-y|--yes/,@ARGV)){
        $yes_to_all=1;
    }

    # NEW FILE ?
    if(grep (/-n|--new/,@ARGV)){
	# test for denied options
	if(grep (/-g|--generate|-h|--help/,@ARGV)){
	        display_help;
		exit 0;
	}

        # create a new file
        $new_file =1;
    }

    # GENERATE EMPTY ?
    elsif(grep (/-g|--generate/,@ARGV)){
        # test for denied options
        if(grep (/-n|--new|-h|--help/,@ARGV)){
                display_help;
                exit 0;
        }

        # generate a empty file
        $generate_file=1;
    }

    # UPDATE ?
    elsif(grep (/-u|--update/,@ARGV)){

        # test for denied options
        if(grep (/-n|--new|-g|--generate|-h|--help/,@ARGV)){
                display_help;
                exit 0;
        }

	# update a config file
	$update_config=1;
	
    }
}

#-------------------------------------
# Generate empty file ?
#-------------------------------------
sub generate_config_file {

    # While bad answer
    do{
        print("Generate a empty configuration's file $FIREWALL_VERSION (file: $CONFIG_FILE) [Y/n] ? ");
        if($yes_to_all == 1){
                print ("\n");
                $rep = "y";
        }else{
                $rep = <STDIN>;
        }
    }while($rep !~ /^$/ && $rep !~ /^(Y|y|N|n){1}$/);    
    
    # if "Yes"
    if($rep =~ /^(Y|y){1}$/ || $rep =~ /^$/){
	
	create_help_config_file;
	save_config_to_file;
	
	print("The file has been generated\n");
    }else{
	print("The file has not been generated\n");
    }
    
}




#--------------------------------------
# Update Config file ?
#---------------------------------------

sub update_config_file {

    # While bad answer
    do{
        print("Update your configuration's file to version $FIREWALL_VERSION (file: $CONFIG_FILE) [Y/n] ? ");
        if($yes_to_all == 1){
                print ("\n");
                $rep = "y";
        }else{
                $rep = <STDIN>;
        }
    }while($rep !~ /^$/ && $rep !~ /^(Y|y|N|n){1}$/);    
    
    # if "Yes"
    if($rep =~ /^(Y|y){1}$/ || $rep =~ /^$/){
	
	create_help_config_file;
	parse_config_file;
	update_old_variable_name;
	save_config_to_file;
	
	print("The file has been updated\n");
    }else{
	print("The file has not been updated\n");
    }
}    



##################################################################
##################################################################
##                  DIALOG FUNCTIONS                            ##
##################################################################
##################################################################


#-------------------------------------------------------
#  open_tcp_inet
#--------------------------------------------------------
sub open_tcp_inet {
	my $exit;		
	my $menu;
	my $items;
	

	# get internet ifaces
	@ifaces = split(/ +/,$config_value{'EXT_IFACE'} );
	$nb_iface = @ifaces;

	# buid list
#	$items=" '0' '-All-' ";
	$items="";
	$i=1;
	foreach $if (@ifaces){
        	$items = "$items '$i' '$if'";
		$i++;
	}
       
	do{ 
		# display
#		$menu = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "Choose an internet interface and open tcp port(s). Choose -All- for open the same tcp port(s) for all your interfaces" 12 40 $nb_iface $items `;
		$menu = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "Choose an internet interface and open tcp port(s)." 12 40 $nb_iface $items `;

      
		$exit = $?;
		# translate the num of the interface in name
	        if ($menu =~ /^0$/){
			$menu_iface = "-All-";
		}else{
			my $j=1;

			# Sorry, this is a temporary function
			foreach $if (@ifaces){
				if ($j == $menu){
					$menu_iface = $if;
				}
				$j++;
        		}
		}

		if($exit == 0){
			open_tcp_inet_for_iface ($menu_iface);
		}

	}while($exit == 0);
	
}




#-------------------------------------------------------
#  open_tcp_inet_for_iface
#--------------------------------------------------------
sub open_tcp_inet_for_iface {
	my $menu;
	my $iface = shift;


        do{
                $menu = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "TCP Port(s) for '$iface'" 10 40 2 "1" "Views currents port(s)" "2" "Modify TCP port" `;

                # remember output
                $exit_save=$?;


		if($menu == '1' && $exit_save==0){
			open_tcp_inet_for_iface_view ($iface);
		}elsif($menu == '2' && $exit_save==0){
			open_tcp_inet_for_iface_modify ($iface);
		}

	 }while($exit_save == 0);
}




#-------------------------------------------------------
#  open_tcp_inet_for_iface_view
#--------------------------------------------------------
sub open_tcp_inet_for_iface_view {
        my $menu;
        my $iface = shift;
	my $list_ports ;


	# Syntax valid ?
	if($config_value{'TCP_EXT_IN'} !~ /^([a-zA-Z0-9]+;([0-9]+(:[0-9]+)?( +|,)?)+ *)+$|^$/ ){
		`$DIALOG $DIALOG_BACKTITLE --title "View TCP Port(s) for '$iface'" --msgbox "Syntax error in TCP_EXT_IN" 5 40`;
		return 0;
	}

        # there is no ports ?
        if($config_value{'TCP_EXT_IN'} !~ /$iface/){
	        `$DIALOG $DIALOG_BACKTITLE --title "View TCP Port(s) for '$iface'" --msgbox "none" 5 40`;
        }
        else{
        	# build list
                $list_ports="";
                $nb_ports=0;
		
		# port config for all iface or selected iface ?
		if($config_value{'TCP_EXT_IN'} =~ /;/ && $config_value{'TCP_EXT_IN'} =~ /$iface/){
			my $tmp = $config_value{'TCP_EXT_IN'};
			$tmp =~ s/^.*$iface;([0-9:,]+).*$/$1/g;
			@ports = split(/,/,$tmp);
                }else{
                        @ports="";
                }
		#else{
                #	@ports = split(/ /,$config_value{'TCP_EXT_IN'});
		#}
		

                foreach $p (@ports){

#print "$p\n";

                	# Get the name of service
                        $name_of_port = `cat $SERVICE_FILE |grep -e "\t$p/tcp" -e " $p/tcp"`;
                        $name_of_port =~ s/^([a-zA-Z0-9]+).*$/$1/g;
                        $name_of_port =~ s/\n//g;


                        if ($name_of_port !~ /^$/){
                        	if($list_ports =~ /^$/){
                                	$list_ports="'$p' '($name_of_port)'";
                                }else{
                                        $list_ports="$list_ports '$p' '($name_of_port)'";
                                }
                        }else{
                                if($list_ports =~ /^$/){
                        		$list_ports="'$p' '' ";
                                }else{
                                        $list_ports="$list_ports '$p' ''";
                                }
                        }
                        $nb_ports++;
		}

                if ($nb_ports > 12){
                	$nb_ports=12;
                }
                `$DIALOG $DIALOG_BACKTITLE --title "View TCP Port(s) for '$iface'" --menu "" 0 40 $nb_ports $list_ports`;
	}

}



#-------------------------------------------------------
#  open_tcp_inet_for_iface_modify
#--------------------------------------------------------
sub open_tcp_inet_for_iface_modify {
        my $menu;
        my $iface = shift;
        my $ports;
	my $syntax_error=0;

        # Syntax valid ?
        if($config_value{'TCP_EXT_IN'} =~ /^([a-zA-Z0-9]+;([0-9]+(:[0-9]+)?( +|,)?)+ *)+$|^$/ ){
       
       		 # get port config of this iface
	        if($config_value{'TCP_EXT_IN'} =~ /$iface/){
        	        $ports = $config_value{'TCP_EXT_IN'};
	                $ports =~ s/^.*$iface;([0-9:,]+).*$/$1/g;
        	        $ports =~ s/,/ /g;
	        }else{
        	        $ports ="";
	        }
	}else{
		$syntax_error = 1;
		$ports ="syntax error";
	}


        do{
		$new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify TCP port(s) for '$iface'" --inputbox "Write list separate with spaces" 8 40 '$ports' `;


                $exit=$?;

                $new =~ s/\n//g;
                $new =~ s/ +/ /g;
                $new =~ s/ $//g;
                $new =~ s/^ //g;

		if($new =~ /^([0-9]+(:[0-9]+)? ?)+$|^$/ ){
                	# if no CANCEL presed
                        if($? == 0){
                        	# save
                
				if($syntax_error == 0){
	 		               	# remove old config
        	                        if($config_value{'TCP_EXT_IN'} =~ /$iface/){
                	                        my $tmp = $config_value{'TCP_EXT_IN'};
                        	                $tmp =~ s/^.*($iface;[0-9:,]+).*$/$1/g;
                                	        $config_value{'TCP_EXT_IN'}=~ s/$tmp//g;
	                                }	
				}else{ 
					$syntax_error = 0;
					$config_value{'TCP_EXT_IN'}="";
				}


				
				# build new one
				if($new !~ /^$/){
					$new =~ s/ /,/g;
					$new = "$iface;$new";
					# add new one
					$config_value{'TCP_EXT_IN'} = "$config_value{'TCP_EXT_IN'} $new";
				}
                		$config_value{'TCP_EXT_IN'} =~ s/ +/ /g;
                		$config_value{'TCP_EXT_IN'} =~ s/ $//g;
                		$config_value{'TCP_EXT_IN'} =~ s/^ //g;

                                #exit loop;
                                $exit=1;
                        }
		}
                else{
                        `$DIALOG $DIALOG_BACKTITLE --title "Modify TCP Ports for '$iface'" --msgbox "Error: Ports are not valids" 5 40`;
                }
	}while($exit == 0);


}






#-------------------------------------------------------
#  open_udp_inet
#--------------------------------------------------------
sub open_udp_inet {
        my $exit;
        my $menu;
        my $items;


        # get internet ifaces
        @ifaces = split(/ +/,$config_value{'EXT_IFACE'} );
        $nb_iface = @ifaces;

        # buid list
#       $items=" '0' '-All-' ";
        $items="";
        $i=1;
        foreach $if (@ifaces){
                $items = "$items '$i' '$if'";
                $i++;
        }

        do{
                # display
#               $menu = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "Choose an internet interface and open tcp port(s). Choose -All- for open the same tcp port(s) for all your interfaces" 12 40 $nb_iface $items `;
                $menu = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "Choose an internet interface and open udp port(s)." 12 40 $nb_iface $items `;


                $exit = $?;
                # translate the num of the interface in name
                if ($menu =~ /^0$/){
                        $menu_iface = "-All-";
                }else{
                        my $j=1;

                        # Sorry, this is a temporary function
                        foreach $if (@ifaces){
                                if ($j == $menu){
                                        $menu_iface = $if;
                                }
                                $j++;
                        }
                }

                if($exit == 0){
                        open_udp_inet_for_iface ($menu_iface);
                }

        }while($exit == 0);

}





#-------------------------------------------------------
#  open_udp_inet_for_iface
#--------------------------------------------------------
sub open_udp_inet_for_iface {
        my $menu;
        my $iface = shift;


        do{
                $menu = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "UDP Port(s) for '$iface'" 10 40 2 "1" "Views currents port(s)" "2" "Modify UDP port" `;

                # remember output
                $exit_save=$?;


                if($menu == '1' && $exit_save==0){
                        open_udp_inet_for_iface_view ($iface);
                }elsif($menu == '2' && $exit_save==0){
                        open_udp_inet_for_iface_modify ($iface);
                }

         }while($exit_save == 0);
}



#-------------------------------------------------------
#  open_udp_inet_for_iface_view
#--------------------------------------------------------
sub open_udp_inet_for_iface_view {
        my $menu;
        my $iface = shift;
        my $list_ports ;
        
	# Syntax valid ?
        if($config_value{'UDP_EXT_IN'} !~ /^([a-zA-Z]+[0-9]*;([0-9]+(:[0-9]+)?( +|,)?)+ *)+$|^$/ ){
                `$DIALOG $DIALOG_BACKTITLE --title "View UDP Port(s) for '$iface'" --msgbox "Syntax error in UDP_EXT_IN" 5 40`;
                return 0;
        }


        # there is no ports ?
        if($config_value{'UDP_EXT_IN'} !~ /$iface/){
                `$DIALOG $DIALOG_BACKTITLE --title "View UDP Port(s) for '$iface'" --msgbox "none" 5 40`;
        }
        else{
                # build list
                $list_ports="";
                $nb_ports=0;

                # port config for all iface or selected iface ?
                if($config_value{'UDP_EXT_IN'} =~ /;/ && $config_value{'UDP_EXT_IN'} =~ /$iface/){
                        my $tmp = $config_value{'UDP_EXT_IN'};
                        $tmp =~ s/^.*$iface;([0-9:,]+).*$/$1/g;
                        @ports = split(/,/,$tmp);
                }else{
			@ports="";
		}
                #else{
                #       @ports = split(/ /,$config_value{'UDP_EXT_IN'});
                #}


                foreach $p (@ports){

                        # Get the name of service
                        $name_of_port = `cat $SERVICE_FILE |grep -e "\t$p/udp" -e " $p/udp"`;
                        $name_of_port =~ s/^([a-zA-Z0-9]+).*$/$1/g;
                        $name_of_port =~ s/\n//g;


                        if ($name_of_port !~ /^$/){
                                if($list_ports =~ /^$/){
                                        $list_ports="'$p' '($name_of_port)'";
                                }else{
                                        $list_ports="$list_ports '$p' '($name_of_port)'";
                                }
                        }else{
                                if($list_ports =~ /^$/){
                                        $list_ports="'$p' '' ";
                                }else{
                                        $list_ports="$list_ports '$p' ''";
                                }
                        }
                        $nb_ports++;
                }

                if ($nb_ports > 12){
                        $nb_ports=12;
                }

                `$DIALOG $DIALOG_BACKTITLE --title "View UDP Port(s) for '$iface'" --menu "" 0 40 $nb_ports $list_ports`;
        }

}




#-------------------------------------------------------
#  open_udp_inet_for_iface_modify
#--------------------------------------------------------
sub open_udp_inet_for_iface_modify {
        my $menu;
        my $iface = shift;
	my $ports;
        my $syntax_error=0;

        # Syntax valid ?
        if($config_value{'UDP_EXT_IN'} =~ /^([a-zA-Z0-9]+;([0-9]+(:[0-9]+)?( +|,)?)+ *)+$|^$/ ){

	        # get port config of this iface
		if($config_value{'UDP_EXT_IN'} =~ /$iface/){
			$ports = $config_value{'UDP_EXT_IN'};
		        $ports =~ s/^.*$iface;([0-9:,]+).*$/$1/g;
        		$ports =~ s/,/ /g;
		}else{
			$ports ="";
		}
        }else{
		$syntax_error = 1;
                $ports ="syntax error";
        }


        do{
                $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify UDP port(s) for '$iface'" --inputbox "Write list separate with spaces" 8 40 '$ports' `;


                $exit=$?;

                $new =~ s/\n//g;
                $new =~ s/ +/ /g;
                $new =~ s/ $//g;
                $new =~ s/^ //g;

		if($new =~ /^([0-9]+(:[0-9]+)? ?)+$|^$/ ){
                #if($new =~ /^([0-9]+(:[0-9]+)? ?)*$/ ){
                        # if no CANCEL presed
                        if($? == 0){
                                # save

				if($syntax_error == 0){		
	                                # remove old config
					if($config_value{'UDP_EXT_IN'} =~ /$iface/){
	        	                        my $tmp = $config_value{'UDP_EXT_IN'};
                        	        	$tmp =~ s/^.*($iface;[0-9:,]+).*$/$1/g;
	                        	        $config_value{'UDP_EXT_IN'}=~ s/$tmp//g;
					}
                                }else{
                                        $syntax_error = 0;
                                        $config_value{'UDP_EXT_IN'}="";
                                }


                                # build new one
				if($new !~ /^$/){
                                	$new =~ s/ /,/g;
                                	$new = "$iface;$new";
                                	# add new one
                                	$config_value{'UDP_EXT_IN'} = "$config_value{'UDP_EXT_IN'} $new";
				}

                                $config_value{'UDP_EXT_IN'} =~ s/ +/ /g;
                                $config_value{'UDP_EXT_IN'} =~ s/ $//g;
                                $config_value{'UDP_EXT_IN'} =~ s/^ //g;

                                #exit loop;
                                $exit=1;
                        }
                }
                else{
                        `$DIALOG $DIALOG_BACKTITLE --title "Modify UDP Ports for '$iface'" --msgbox "Error: Ports are not valids" 5 40`;
                }
        }while($exit == 0);


}









#-------------------------------------------------------
#  open_tcp_lan
#--------------------------------------------------------
sub open_tcp_lan {

	my $menu;
        my $exit_menu;
	my $radio_restricted_status;
	my $radio_all_status;

#print $config_value{'TCP_INT_IN'};
#exit;

	# get atual config. All opened or not
	if($config_value{'TCP_INT_IN'} =~ /^\*$/ ){
		#$radio_restricted_status	= "off";
		#$radio_all_status		= "on";
		$DEFAULTNO = "--defaultno";
	}else{
		#$radio_restricted_status        = "on";
                #$radio_all_status               = "off";
		$DEFAULTNO = "";
	}



	$msg="Enable Restricted Access for the LAN ?\n\nChoose 'yes' if you want to limit TCP connections from your LAN to some specifics ports\n\nChoose 'no' to have full access from your LAN";
        $menu = `$DIALOG $DIALOG_BACKTITLE $DEFAULTNO --title "Open TCP for LAN" --yesno "$msg" 12 65 `;
	#$menu = `$DIALOG $DIALOG_BACKTITLE --title "Open TCP for LAN" $DIALOG_CANCEL_LABEL_BACK --menu "$msg" 12 50 2 '1' 'All TCP access for the LAN' $radio_all_status '2' 'Restricted TCP access for the LAN' $radio_restricted_status  `;
        $exit_menu = $?;

        # All
        #-------------
        if($exit_menu != 0){

        	$config_value{'TCP_INT_IN'} = "*";
        }else{

	# Restricted
	#------------
        
		#reset ?
		if($config_value{'TCP_INT_IN'} =~ /^\*$/){
			$config_value{'TCP_INT_IN'} = "";
		}
		open_tcp_lan_select_iface;
	}
}









#-------------------------------------------------------
#  open_tcp_lan_select_iface
#--------------------------------------------------------
sub open_tcp_lan_select_iface {
        my $exit;
        my $menu;
        my $items;


        # get lan ifaces
        @ifaces = split(/ +/,$config_value{'INT_IFACE'} );
        $nb_iface = @ifaces;

        # buid list
#       $items=" '0' '-All-' ";
        $items="";
        $i=1;
        foreach $if (@ifaces){
                $items = "$items '$i' '$if'";
                $i++;
        }

        do{
                # display
#               $menu = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "Choose an internet interface and open tcp port(s). Choose -All- for open the same tcp port(s) for all your interfaces" 12 40 $nb_iface $items `;
                $menu = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --title "Restricted TCP Ports" --menu "Choose an LAN interface and open tcp port(s)." 12 40 $nb_iface $items `;


                $exit = $?;
                # translate the num of the interface in name
                if ($menu =~ /^0$/){
                        $menu_iface = "-All-";
                }else{
                        my $j=1;

                        # Sorry, this is a temporary function
                        foreach $if (@ifaces){
                                if ($j == $menu){
                                        $menu_iface = $if;
                                }
                                $j++;
                        }
                }
                if($exit == 0){
                        open_tcp_lan_for_iface ($menu_iface);
                }

        }while($exit == 0);

}




#-------------------------------------------------------
#  open_tcp_lan_for_iface
#--------------------------------------------------------
sub open_tcp_lan_for_iface {
        my $menu;
        my $iface = shift;


        do{
                $menu = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --title "Restrited TCP Ports" --menu "TCP Port(s) for '$iface'" 10 40 2 "1" "Views currents port(s)" "2" "Modify TCP port" `;

                # remember output
                $exit_save=$?;


                if($menu == '1' && $exit_save==0){
                        open_tcp_lan_for_iface_view ($iface);
                }elsif($menu == '2' && $exit_save==0){
                        open_tcp_lan_for_iface_modify ($iface);
                }

         }while($exit_save == 0);
}




#-------------------------------------------------------
#  open_tcp_lan_for_iface_view
#--------------------------------------------------------
sub open_tcp_lan_for_iface_view {
        my $menu;
        my $iface = shift;
        my $list_ports ;


        # Syntax valid ?
        if($config_value{'TCP_INT_IN'} !~ /^([a-zA-Z0-9]+;(\*|[0-9]+(:[0-9]+)?( +|,)?)+ *)+$|^$|^\*$/ ){
                `$DIALOG $DIALOG_BACKTITLE --title "View TCP Port(s) for '$iface'" --msgbox "Syntax error in TCP_INT_IN" 5 40`;
                return 0;
        }


        # there is no ports ?
#print "$iface\n$config_value{'TCP_INT_IN'}\n";
#exit;
        if($config_value{'TCP_INT_IN'} !~ /$iface/ ){
                `$DIALOG $DIALOG_BACKTITLE --title "View TCP Port(s) for '$iface'" --msgbox "none" 5 40`;
        }
        else{
                # build list
                $list_ports="";
                $nb_ports=0;


                # get ports
       	        if($config_value{'TCP_INT_IN'} =~ /;/ && $config_value{'TCP_INT_IN'} =~ /$iface/){
                        my $tmp = $config_value{'TCP_INT_IN'};
       	                $tmp =~ s/^.*$iface;([0-9:,*]+).*$/$1/g;
               	        @ports = split(/,/,$tmp);
                }else{
       	                @ports="";
               	}

		# All ports for this iface ?
		if( @ports[0] =~ /^\*$/){
               	        $list_ports = "'' 'All' ";
                        $nb_ports = 1;		
		}else{
	                foreach $p (@ports){

        	                # Get the name of service
       	        	        $name_of_port = `cat $SERVICE_FILE |grep -e "\t$p/tcp" -e " $p/tcp"`;
        	                $name_of_port =~ s/^([a-zA-Z0-9]+).*$/$1/g;
       	        	        $name_of_port =~ s/\n//g;


                	        if ($name_of_port !~ /^$/){
       	                	        if($list_ports =~ /^$/){
        	                                $list_ports="'$p' '($name_of_port)'";
       	        	                }else{
               	        	                $list_ports="$list_ports '$p' '($name_of_port)'";
                       	        	}
	                        }else{
       		                        if($list_ports =~ /^$/){
                	                        $list_ports="'$p' '' ";
       	                	        }else{
        	                                $list_ports="$list_ports '$p' ''";
       	        	                }
               	        	}
                        	$nb_ports++;
	                }
        

		        if ($nb_ports > 12){
       	        	        $nb_ports=12;
               		}
		}
		

                `$DIALOG $DIALOG_BACKTITLE --title "View TCP Port(s) for '$iface'" --menu "" 0 40 $nb_ports $list_ports`;
        }

}



#-------------------------------------------------------
#  open_tcp_lan_for_iface_modify
#--------------------------------------------------------
sub open_tcp_lan_for_iface_modify {
        my $menu;
        my $iface = shift;
        my $ports;
	my $syntax_error=0;


        # Syntax valid ?

        if($config_value{'TCP_INT_IN'} =~ /^([a-zA-Z0-9]+;(\*|[0-9]+(:[0-9]+)?( +|,)?)+ *)+$|^$|^\*$/ ){

	        # get port config of this iface
	        if($config_value{'TCP_INT_IN'} =~ /$iface/){
        	        $ports = $config_value{'TCP_INT_IN'};
                	$ports =~ s/^.*$iface;([0-9:,*]+).*$/$1/g;
	                $ports =~ s/,/ /g;
        	}else{
	                $ports ="";
        	}
        }else{
		$syntax_error=1;
                $ports ="syntax error";
        }

        do{
                $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify TCP port(s) for '$iface'" --inputbox "Write a list ports separate with spaces or only * for open all tcp port on this interface." 10 40 '$ports' `;
		

                $exit=$?;

                $new =~ s/\n//g;
                $new =~ s/ +/ /g;
                $new =~ s/ $//g;
                $new =~ s/^ //g;

		if($new =~ /^([0-9]+(:[0-9]+)? ?)+$|^$|^\*$/ ){
                        # if no CANCEL presed
                        if($? == 0){
                                # save

				if($syntax_error == 0){
	                                # remove old config
        	                        if($config_value{'TCP_INT_IN'} =~ /$iface/){
                		                my $tmp = $config_value{'TCP_INT_IN'};
                                	        $tmp =~ s/^.*($iface;[0-9:*,]+).*$/$1/g;
						
						if($tmp =~ /\*/){
							$config_value{'TCP_INT_IN'}=~ s/$iface;\*//g;
						}else{
	        	                                $config_value{'TCP_INT_IN'}=~ s/$tmp//g;
						}
	                               	}
                                }else{
                                        $syntax_error = 0;
                                        $config_value{'TCP_INT_IN'}="";
                                }


				# build new one
                                if($new !~ /^$/){
                                        $new =~ s/ /,/g;
                                        $new = "$iface;$new";
                                        # add new one
                                        $config_value{'TCP_INT_IN'} = "$config_value{'TCP_INT_IN'} $new";
                                }

                                $config_value{'TCP_INT_IN'} =~ s/ +/ /g;
                                $config_value{'TCP_INT_IN'} =~ s/ $//g;
                                $config_value{'TCP_INT_IN'} =~ s/^ //g;

                                #exit loop;
                                $exit=1;
                        }
                }
                else{
                        `$DIALOG $DIALOG_BACKTITLE --title "Modify TCP Ports for '$iface'" --msgbox "Error: Ports are not valids" 5 40`;
                }
        }while($exit == 0);


}













#-------------------------------------------------------
#  open_udp_lan
#--------------------------------------------------------
sub open_udp_lan {

        my $menu;
        my $exit_menu;
        my $radio_restricted_status;
        my $radio_all_status;


        # get atual config. All opened or not
        if($config_value{'UDP_INT_IN'} =~ /^\*$/ ){
                #$radio_restricted_status       = "off";
                #$radio_all_status              = "on";
                $DEFAULTNO = "--defaultno";
        }else{
                #$radio_restricted_status        = "on";
                #$radio_all_status               = "off";
                $DEFAULTNO = "";
        }



        $msg="Enable Restricted Access for the LAN ?\n\nChoose 'yes' if you want to limit UDP connections from your LAN to only some specifics ports\n\nChoose 'no' to have full access from your LAN";
        $menu = `$DIALOG $DIALOG_BACKTITLE $DEFAULTNO --title "Open UDP for LAN" --yesno "$msg" 12 65 `;



#        $msg = "Choose if you want to allow all UDP connections from your LAN or only some specifics ports";
#        $menu = `$DIALOG $DIALOG_BACKTITLE --title "Open UDP for LAN" $DIALOG_CANCEL_LABEL_BACK --radiolist "$msg" 12 50 2 '1' 'All UDP access for the LAN' $radio_all_status '2' 'Restricted UDP access for the LAN' $radio_restricted_status  `;
        $exit_menu = $?;

        # All
        #-------------
        if($exit_menu != '0'){
                $config_value{'UDP_INT_IN'} = "*";
        }else{

        # Restricted
        #------------
                #reset ?
                if($config_value{'UDP_INT_IN'} =~ /^\*$/){
                        $config_value{'UDP_INT_IN'} = "";
                }
                open_udp_lan_select_iface;
        }
}

#-------------------------------------------------------
#  open_udp_lan_select_iface
#--------------------------------------------------------
sub open_udp_lan_select_iface {
        my $exit;
        my $menu;
        my $items;


        # get lan ifaces
        @ifaces = split(/ +/,$config_value{'INT_IFACE'} );
        $nb_iface = @ifaces;

        # buid list
#       $items=" '0' '-All-' ";
        $items="";
        $i=1;
        foreach $if (@ifaces){
                $items = "$items '$i' '$if'";
                $i++;
        }

        do{
                # display
#               $menu = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "Choose an internet interface and open tcp port(s). Choose -All- for open the same tcp port(s) for all your interfaces" 12 40 $nb_iface $items `;
                $menu = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --title "Restricted UDP Ports" --menu "Choose an LAN interface and open udp port(s)." 12 40 $nb_iface $items `;


                $exit = $?;
                # translate the num of the interface in name
                if ($menu =~ /^0$/){
                        $menu_iface = "-All-";
                }else{
                        my $j=1;

                        # Sorry, this is a temporary function
                        foreach $if (@ifaces){
                                if ($j == $menu){
                                        $menu_iface = $if;
                                }
                                $j++;
                        }
                }
                if($exit == 0){
                        open_udp_lan_for_iface ($menu_iface);
               }

        }while($exit == 0);

}




#-------------------------------------------------------
#  open_udp_lan_for_iface
#--------------------------------------------------------
sub open_udp_lan_for_iface {
        my $menu;
        my $iface = shift;


        do{
                $menu = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --title "Restrited UDP Ports" --menu "UDP Port(s) for '$iface'" 10 40 2 "1" "Views currents port(s)" "2" "Modify UDP port" `;

                # remember output
                $exit_save=$?;


                if($menu == '1' && $exit_save==0){
                        open_udp_lan_for_iface_view ($iface);
                }elsif($menu == '2' && $exit_save==0){
                        open_udp_lan_for_iface_modify ($iface);
                }

         }while($exit_save == 0);
}




#-------------------------------------------------------
#  open_udp_lan_for_iface_view
#--------------------------------------------------------
sub open_udp_lan_for_iface_view {
        my $menu;
        my $iface = shift;
        my $list_ports ;

        # Syntax valid ?
        if($config_value{'UDP_INT_IN'} !~ /^([a-zA-Z0-9]+;(\*|[0-9]+(:[0-9]+)?( +|,)?)+ *)+$|^$|^\*$/ ){
                `$DIALOG $DIALOG_BACKTITLE --title "View UDP Port(s) for '$iface'" --msgbox "Syntax error in UDP_INT_IN" 5 40`;
                return 0;
        }


        # there is no ports ?
#print "$iface\n$config_value{'TCP_INT_IN'}\n";
        if($config_value{'UDP_INT_IN'} !~ /$iface/ ){
                `$DIALOG $DIALOG_BACKTITLE --title "View UDP Port(s) for '$iface'" --msgbox "none" 5 40`;
        }
        else{
                # build list
                $list_ports="";
                $nb_ports=0;


                # get ports
                if($config_value{'UDP_INT_IN'} =~ /;/ && $config_value{'UDP_INT_IN'} =~ /$iface/){
                        my $tmp = $config_value{'UDP_INT_IN'};
                        $tmp =~ s/^.*$iface;([0-9:,*]+).*$/$1/g;
                        @ports = split(/,/,$tmp);
                }else{
                        @ports="";
                }

                # All ports for this iface ?
                if( @ports[0] =~ /^\*$/){
                        $list_ports = "'' 'All' ";
                        $nb_ports = 1;
                }else{
                        foreach $p (@ports){

                                # Get the name of service
                                $name_of_port = `cat $SERVICE_FILE |grep -e "\t$p/udp" -e " $p/udp"`;
                                $name_of_port =~ s/^([a-zA-Z0-9]+).*$/$1/g;
                                $name_of_port =~ s/\n//g;


                                if ($name_of_port !~ /^$/){
                                        if($list_ports =~ /^$/){
                                                $list_ports="'$p' '($name_of_port)'";
                                        }else{
                                                $list_ports="$list_ports '$p' '($name_of_port)'";
                                        }
                                }else{
                                        if($list_ports =~ /^$/){
                                                $list_ports="'$p' '' ";
                                        }else{
                                                $list_ports="$list_ports '$p' ''";
                                        }
                                }
                                $nb_ports++;
                        }


                        if ($nb_ports > 12){
                                $nb_ports=12;
                        }
                }


                `$DIALOG $DIALOG_BACKTITLE --title "View UDP Port(s) for '$iface'" --menu "" 0 40 $nb_ports $list_ports`;
        }

}



#-------------------------------------------------------
#  open_udp_lan_for_iface_modify
#--------------------------------------------------------
sub open_udp_lan_for_iface_modify {
        my $menu;
        my $iface = shift;
        my $ports;
	my $syntax_error=0;

        # Syntax valid ?
        if($config_value{'UDP_INT_IN'} =~ /^([a-zA-Z0-9]+;(\*|[0-9]+(:[0-9]+)?( +|,)?)+ *)+$|^$|^\*$/ ){

	        # get port config of this iface
	        if($config_value{'UDP_INT_IN'} =~ /$iface/){
        	        $ports = $config_value{'UDP_INT_IN'};
                	$ports =~ s/^.*$iface;([0-9:,*]+).*$/$1/g;
	                $ports =~ s/,/ /g;
        	}else{
	                $ports ="";
        	}
        }else{
		$syntax_error=1;
                $ports ="syntax error";
        }


        do{
                $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify UDP port(s) for '$iface'" --inputbox "Write a list ports separate with spaces or only * for open all udp port on this interface." 10 40 '$ports' `;


                $exit=$?;

                $new =~ s/\n//g;
                $new =~ s/ +/ /g;
                $new =~ s/ $//g;
               $new =~ s/^ //g;

                if($new =~ /^([0-9]+(:[0-9]+)? ?)+$|^$|^\*$/ ){
                        # if no CANCEL presed
                        if($? == 0){
                                # save


				if($syntax_error == 0){
	                                # remove old config
        	                        if($config_value{'UDP_INT_IN'} =~ /$iface/){
                	                        my $tmp = $config_value{'UDP_INT_IN'};
                        	                $tmp =~ s/^.*($iface;[0-9:*,]+).*$/$1/g;
	
        	                                if($tmp =~ /\*/){
                	                                $config_value{'UDP_INT_IN'}=~ s/$iface;\*//g;
                        	                }else{
                                	                $config_value{'UDP_INT_IN'}=~ s/$tmp//g;
                                        	}
	                                }
                                }else{
                                        $syntax_error = 0;
                                        $config_value{'UDP_INT_IN'}="";
                                }


                                # build new one
                                if($new !~ /^$/){
                                        $new =~ s/ /,/g;
                                        $new = "$iface;$new";
                                        # add new one
                                        $config_value{'UDP_INT_IN'} = "$config_value{'UDP_INT_IN'} $new";
                                }

                                $config_value{'UDP_INT_IN'} =~ s/ +/ /g;
                                $config_value{'UDP_INT_IN'} =~ s/ $//g;
                                $config_value{'UDP_INT_IN'} =~ s/^ //g;

                                #exit loop;
                                $exit=1;
                        }
                }
                else{
                        `$DIALOG $DIALOG_BACKTITLE --title "Modify UDP Ports for '$iface'" --msgbox "Error: Ports are not valids" 5 40`;
                }
        }while($exit == 0);


}





















#-------------------------------------------------------
#  features_vpn
#--------------------------------------------------------
sub features_vpn {

	my $menu_vpn;
	my $exit_menu_vpn;

	do{

		$menu_vpn = `$DIALOG $DIALOG_BACKTITLE --title "Virtuals Privates Networks" $DIALOG_CANCEL_LABEL_BACK --menu '' 10 30 3 '1' "vtund" '2' "ipsec" '3' "pptp"  `;

		$exit_menu_vpn = $?;

	        # VTUND
        	#-------------
	        if($menu_vpn == '1' && $exit_menu_vpn == '0'){
        	        features_vpn_vtund ;
	        }


                # IPSEC
                #-------------
                if($menu_vpn == '2' && $exit_menu_vpn == '0'){
                        features_vpn_ipsec ;
                }

                # PPTP
                #-------------
                if($menu_vpn == '3' && $exit_menu_vpn == '0'){
                        features_vpn_pptp ;
                }

	}while($exit_menu_vpn == 0);
}

#-------------------------------------------------------
#  features_vpn_vtund
#--------------------------------------------------------
sub features_vpn_vtund {
	my $menu_vpn;
	my $exit_menu_vpn ;

   do{
        $menu_vpn = `$DIALOG $DIALOG_BACKTITLE --title "VPN - vtund" $DIALOG_CANCEL_LABEL_BACK --menu '' 10 30 4 '1' "Vpn Interfaces" '2' "Allowed Subnets" '3' "Allowed TCP Ports" '4' "Allowed UDP Ports" `;

        $exit_menu_vpn = $?;

        # INTERFACES
        #-------------
        if($menu_vpn == '1' && $exit_menu_vpn == '0'){
		features_vpn_vtund_ifaces ;
	}

        # SUBNET
        ########
        if($menu_vpn =='2' && $exit_menu_vpn == '0'){
		features_vpn_vtund_subnets;
        }

        # TCP PORTS
        ############
        if($menu_vpn =='3' && $exit_menu_vpn == '0'){
        	features_vpn_vtund_tcp;
	}



        # UDP PORTS
        ############
        if($menu_vpn =='4' && $exit_menu_vpn == '0'){
		features_vpn_vtund_udp;
        }
   }while($exit_menu_vpn == '0')


}


#-------------------------------------------------------
#  features_vpn_vtund_ifaces
#--------------------------------------------------------

sub features_vpn_vtund_ifaces {

	my $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify vtund Interfaces" --inputbox "Write interfaces list separate with spaces. Example: 'tun0 tun1'" 10 40  "$config_value{'TUN_IFACE'}" `;

        my $exit_tun=$?;

        $new =~ s/\n//g;
        $new =~ s/ +/ /g;
        $new =~ s/\"//g;
        $new =~ s/^ //g;

        # if no CANCEL presed
        if($exit_tun == '0'){
                # save
                $config_value{'TUN_IFACE'}=$new;
        }

}



#-------------------------------------------------------
#  features_vpn_vtund_subnets
#--------------------------------------------------------
sub features_vpn_vtund_subnets {
	my $new;
	my $exit_tun;

           do{
                $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify Allowed vtund Subnets" --inputbox "Write subnets list separate with spaces. Example: '192.168.2.0/24 192.168.30.0/21'" 10 40  "$config_value{'TUN_SUBNET'}" `;

                $exit_tun=$?;

                $new =~ s/\n//g;
                $new =~ s/ +/ /g;
                $new =~ s/\"//g;
                $new =~ s/^ //g;

                # if no CANCEL pressed
                if($exit_tun == '0'){
                        if($new =~ /^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9.]+ ?)*$/){
                                # save
                                $config_value{'TUN_SUBNET'}=$new;
                                $exit_tun=1;

                        }else{
                                `$DIALOG $DIALOG_BACKTITLE --title "Modify Allowed vtund Subnets" --msgbox "Error: No valids Subnets" 5 40`;
                        }
                }
           }while($exit_tun == 0)

}


#-------------------------------------------------------
#  features_vpn_vtund_tcp
#--------------------------------------------------------
sub features_vpn_vtund_tcp {
	my $new;
	my $exit_tun;

           do{
                $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify Allowed TCP ports" --inputbox "Write ports list separate with spaces. Enter * for open all ports." 10 40  "$config_value{'TUN_TCP'}" `;

                $exit_tun=$?;

                $new =~ s/\n//g;
                $new =~ s/ +/ /g;
                $new =~ s/\"//g;
                $new =~ s/^ //g;

                # if no CANCEL presed
                if($exit_tun == '0'){
                        if($new =~ /^([0-9]+(:[0-9]+)? ?)*|\*$/){
                                # save
                                $config_value{'TUN_TCP'}=$new;
                                $exit_tun =1;
                        }else{
                                `$DIALOG $DIALOG_BACKTITLE --title "Modify vtund TCP ports" --msgbox "Error: No valids ports" 5 40`;
                        }
                }
           }while($exit_tun == 0)

}


#-------------------------------------------------------
#  features_vpn_vtund_udp
#--------------------------------------------------------
sub features_vpn_vtund_udp {
           do{
                my $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify Allowed UDP ports" --inputbox "Write ports list separate with spaces. Enter * for open all ports." 10 40  "$config_value{'TUN_UDP'}" `;

                my $exit_tun=$?;

                $new =~ s/\n//g;
                $new =~ s/ +/ /g;
                $new =~ s/\"//g;
                $new =~ s/^ //g;

                # if no CANCEL presed
                if($exit_tun == '0'){
                        if($new =~ /^([0-9]+(:[0-9]+)? ?)*|\*$/){
                                # save
                                $config_value{'TUN_UDP'}=$new;
                                $exit_tun=1;
                        }
                        else{
                                `$DIALOG $DIALOG_BACKTITLE --title "Modify vtund UDP ports" --msgbox "Error: No valids ports" 5 40`;
                        }
                }
           }while($exit_tun == 0)

}


#---------------------------------------------------------
#  features_vpn_pptp
#---------------------------------------------------------
sub features_vpn_pptp {
        my $menu;
        my $exit_menu ;

   do{
        $menu = `$DIALOG $DIALOG_BACKTITLE --title "VPN - pptp" $DIALOG_CANCEL_LABEL_BACK --menu 'Choose if you want to configure a pptp server on this localhost, or in a LAN behind it.' 10 50 2 '1' "Pptp server on localhost" '2' "Pptp server on a LAN"  `;

        $exit_menu = $?;

        # LOCALHOST
        #-------------
        if($menu == '1' && $exit_menu == '0'){
                features_vpn_pptp_serveronbox ;
        }

        # ON LAN
        ########
        if($menu =='2' && $exit_menu == '0'){
                features_vpn_pptp_serverbehind;
        }

   }while($exit_menu == '0')




}


#---------------------------------------------------------
#  features_vpn_pptp_serveronbox
#---------------------------------------------------------
sub features_vpn_pptp_serveronbox {

        my $menu;
        my $exit_menu ;

   do{

        $menu = `$DIALOG $DIALOG_BACKTITLE --title "VPN - pptp - localhost" $DIALOG_CANCEL_LABEL_BACK --menu ' ' 16 40 7 '1' "Enable" '2' "Port" "3" "Incoming Interfaces" '4' "Subnet - VPN" '5' "Others Subnets (optional)" '6' "LAN access" '7' "Internet sharing" `;

        $exit_menu = $?;

        # ENABLE
        #-------------
        if($menu == '1' && $exit_menu == '0'){
                features_vpn_pptp_serveronbox_enable ;
        }

        # PORT
        ########
        if($menu =='2' && $exit_menu == '0'){
                features_vpn_pptp_serveronbox_port;
        }


        # IFACES
        ########
        if($menu =='3' && $exit_menu == '0'){
                features_vpn_pptp_serveronbox_ifaces;
        }

        # VPN SUB
        #########
        if($menu =='4' && $exit_menu == '0'){
                features_vpn_pptp_serveronbox_subvpn;
        }

        # OTHER SUB
        ############
        if($menu =='5' && $exit_menu == '0'){
                features_vpn_pptp_serveronbox_subother;
        }

        # ACCES LAN
        ############
        if($menu =='6' && $exit_menu == '0'){
                features_vpn_pptp_serveronbox_accesslan;
        }


        # ACCES INET
        ############
        if($menu =='7' && $exit_menu == '0'){
                features_vpn_pptp_serveronbox_accessinet;
        }

   }while($exit_menu == '0')

}


#---------------------------------------------------------
#  features_vpn_pptp_serveronbox_enable
#---------------------------------------------------------
sub features_vpn_pptp_serveronbox_enable {
                # Are we actually Verbose ?
                if($config_value{'PPTP_LOCALHOST'} == '1'){ $DEFAULTNO = "";}
                else { $DEFAULTNO = "--defaultno"; }

                # ask for verbose
                `$DIALOG $DIALOG_BACKTITLE $DEFAULTNO --title "VPN - pptp - localhost" --yesno "Chose Yes to enable a pptp server on the localhost.\n\nEnable pptp server on localhost ?" 10 50 `;

                # yes ?
                if($? == '0'){
                        $config_value{'PPTP_LOCALHOST'}="1";
                }else{
                        $config_value{'PPTP_LOCALHOST'}="0";
                }

}


#---------------------------------------------------------
#  features_vpn_pptp_serveronbox_port
#---------------------------------------------------------
sub features_vpn_pptp_serveronbox_port {
        my $new;
        my $exit;

           do{
                $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "VPN - pptp - localhost - port" --inputbox "Enter on which port listen the pptp server (default 1723/tcp)." 10 50  "$config_value{'PPTP_LOCALHOST_PORT'}" `;

                $exit=$?;

                $new =~ s/\n//g;
                $new =~ s/ +//g;
                $new =~ s/\"//g;
                

                # if no CANCEL presed
                if($exit == '0'){
                        if($new =~ /^[0-9]+$/){
                                # save
                                $config_value{'PPTP_LOCALHOST_PORT'}=$new;
                                $exit =1;
                        }else{
                                `$DIALOG $DIALOG_BACKTITLE --title "VPN - pptp - localhost - port" --msgbox "Error: Not a valid port" 5 40`;
                        }
                }
           }while($exit == 0)
}





#---------------------------------------------------------
#  features_vpn_pptp_serveronbox_ifaces
#---------------------------------------------------------
sub features_vpn_pptp_serveronbox_ifaces {
             do{
                $new =  select_a_interface ('VPN - pptp - localhost - internet interface(s)','Choose the internet interface(s) from where the clients can access to the server.',"$config_value{'PPTP_LOCALHOST_IFACES'}");

                   #while syntax error
              }while($new =~ /^$/ && $? == 0);


                # if no CANCEL presed
                if($? == '0'){
                                # save
                                $config_value{'PPTP_LOCALHOST_IFACES'}=$new;
                                $exit =1;
                }

}



#---------------------------------------------------------
#  features_vpn_pptp_serveronbox_subvpn
#---------------------------------------------------------
sub features_vpn_pptp_serveronbox_subvpn {
        my $new;
        my $exit;

           do{
                $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "VPN - pptp - localhost - VPN subnet" --inputbox "What is the VPN subnet. Example: '192.168.2.0/24'" 10 40  "$config_value{'PPTP_LOCALHOST_SUBNET_VPN'}" `;

                $exit=$?;

                $new =~ s/\n//g;
                $new =~ s/ +/ /g;
                $new =~ s/\"//g;
                $new =~ s/^ //g;

                # if no CANCEL pressed
                if($exit == '0'){
                        if($new =~ /^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9.]+ ?)*$/){
                                # save
                                $config_value{'PPTP_LOCALHOST_SUBNET_VPN'}=$new;
                                $exit=1;

                        }else{
                                `$DIALOG $DIALOG_BACKTITLE --title "VPN - pptp - localhost - VPN subnet" --msgbox "Error: Not a valid Subnet" 5 40`;
                        }
                }
           }while($exit == 0)
}


#---------------------------------------------------------
#  features_vpn_pptp_erveronbox_subother
#---------------------------------------------------------
sub features_vpn_pptp_serveronbox_subother {
        my $new;
        my $exit;

           do{
                $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "VPN - pptp - localhost - other subnets" --inputbox "Sometimes you want to allow the entire subnet of your client or other subnet comming from your client side (separate the subnets with spaces). \n\n Example: '192.168.2.0/24 192.168.3.0/24'" 12 50  "$config_value{'PPTP_LOCALHOST_SUBNET_ALLOWED'}" `;

                $exit=$?;

                $new =~ s/\n//g;
                $new =~ s/ +/ /g;
                $new =~ s/\"//g;
                $new =~ s/^ //g;

                # if no CANCEL pressed
                if($exit == '0'){
                        if($new =~ /^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9.]+ ?)*$/){
                                # save
                                $config_value{'PPTP_LOCALHOST_SUBNET_ALLOWED'}=$new;
                                $exit=1;

                        }else{
                                `$DIALOG $DIALOG_BACKTITLE --title "VPN - pptp - localhost - VPN subnet" --msgbox "Error: Not a valid Subnet" 5 40`;
                        }
                }
           }while($exit == 0)

}


#---------------------------------------------------------
#  features_vpn_pptp_serveronbox_accesslan
#---------------------------------------------------------
sub features_vpn_pptp_serveronbox_accesslan {
                # Are we actually On ?
                if($config_value{'PPTP_LOCALHOST_ACCESS_LAN'} == '1'){ $DEFAULTNO = "";}
                else { $DEFAULTNO = "--defaultno"; }

                # ask for verbose
                `$DIALOG $DIALOG_BACKTITLE $DEFAULTNO --title "VPN - pptp - localhost - Access to LAN" --yesno "Chose Yes to allow the VPN to access to your LAN.\n\nEnable LAN access from VPN ?" 10 50 `;

                # yes ?
                if($? == '0'){
                        $config_value{'PPTP_LOCALHOST_ACCESS_LAN'}="1";
                }else{
                        $config_value{'PPTP_LOCALHOST_ACCESS_LAN'}="0";
                }

}


#---------------------------------------------------------
#  features_vpn_pptp_serveronbox_accessinet
#---------------------------------------------------------
sub features_vpn_pptp_serveronbox_accessinet {
                # Are we actually On ?
                if($config_value{'PPTP_LOCALHOST_ACCESS_INET'} == '1'){ $DEFAULTNO = "";}
                else { $DEFAULTNO = "--defaultno"; }

                # ask for verbose
               `$DIALOG $DIALOG_BACKTITLE $DEFAULTNO --title "VPN - pptp - localhost - Sharing Internet to VPN" --yesno "Chose Yes to allow the VPN to use your internet connection.\n\nEnable Internet Sharing for the VPN ?" 10 50 `;

                # yes ?
                if($? == '0'){
                        $config_value{'PPTP_LOCALHOST_ACCESS_INET'}="1";
                }else{
                        $config_value{'PPTP_LOCALHOST_ACCESS_INET'}="0";
                }

}





#---------------------------------------------------------
#  features_vpn_pptp_serverbehind
#---------------------------------------------------------
sub features_vpn_pptp_serverbehind {
        my $menu;
        my $exit_menu ;

   do{
        $menu = `$DIALOG $DIALOG_BACKTITLE --title "VPN - pptp - LAN" $DIALOG_CANCEL_LABEL_BACK --menu 'NOT IMPLEMENTED YET\n\nYou ar about to configure a pptp server on a LAN, give the ip and the port of the serveur.' 12 50 3 '1' "Enable" '2' "IP" '3' "Port"  `;

        $exit_menu = $?;

        # ENABLE
        #-------------
        if($menu == '1' && $exit_menu == '0'){
                features_vpn_pptp_serverbehind_enable ;
        }


        # IP
        #-------
        if($menu == '2' && $exit_menu == '0'){
                features_vpn_pptp_serverbehind_ip ;
        }

        # PORT
        ########
        if($menu =='3' && $exit_menu == '0'){
                features_vpn_pptp_serverbehind_port;
        }

   }while($exit_menu == '0')



}


#---------------------------------------------------------
#  features_vpn_pptp_serverbehind_enable
#---------------------------------------------------------
sub features_vpn_pptp_serverbehind_enable {
                # Are we actually Yes ?
                if($config_value{'PPTP_LAN'} == '1'){ $DEFAULTNO = "";}
                else { $DEFAULTNO = "--defaultno"; }

                # ask for verbose
                `$DIALOG $DIALOG_BACKTITLE $DEFAULTNO --title "VPN - pptp - LAN" --yesno "Chose Yes to enable a pptp server on the LAN, behind your firewall.\n\nEnable pptp server on LAN ?" 10 50 `;

                # yes ?
                if($? == '0'){
                        $config_value{'PPTP_LAN'}="1";
                }else{
                        $config_value{'PPTP_LAN'}="0";
                }

}


#---------------------------------------------------------
#  features_vpn_pptp_serverbehind_ip
#---------------------------------------------------------
sub features_vpn_pptp_serverbehind_ip {
        my $new;
        my $exit;

           do{
                $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "VPN - pptp - LAN - IP" --inputbox "Enter th IP of the pptp server on the LAN. Example: '192.168.2.4'" 10 50  "$config_value{'PPTP_LAN_IP'}" `;

                $exit=$?;

                $new =~ s/\n//g;
                $new =~ s/ +//g;
                $new =~ s/\"//g;

                # if no CANCEL pressed
                if($exit == '0'){
                        if($new =~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/){
                                # save
                                $config_value{'PPTP_LAN_IP'}=$new;
                                $exit=1;

                        }else{
                                `$DIALOG $DIALOG_BACKTITLE --title "VPN - pptp - LAN - IP" --msgbox "Error: Not a valid IP" 5 40`;
                        }
                }
           }while($exit == 0)


}


#---------------------------------------------------------
#  features_vpn_pptp_serverbehind_port
#---------------------------------------------------------
sub features_vpn_pptp_serverbehind_port {
        my $new;
        my $exit;

           do{
                $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "VPN - pptp - LAN - port" --inputbox "Enter on which port listen the pptp server (default 1723/tcp)." 10 50  "$config_value{'PPTP_LAN_PORT'}" `;

                $exit=$?;

                $new =~ s/\n//g;
                $new =~ s/ +//g;
                $new =~ s/\"//g;


                # if no CANCEL presed
                if($exit == '0'){
                        if($new =~ /^[0-9]+$/){
                                # save
                                $config_value{'PPTP_LAN_PORT'}=$new;
                                $exit =1;
                        }else{
                                `$DIALOG $DIALOG_BACKTITLE --title "VPN - pptp - LAN - port" --msgbox "Error: Not a valid port" 5 40`;
                        }
                }
           }while($exit == 0)

}














#---------------------------------------------------------
#  features_vpn_ipsec
#---------------------------------------------------------
sub features_vpn_ipsec {
        my $menu;
        my $exit_menu ;

   do{
        $menu = `$DIALOG $DIALOG_BACKTITLE --title "VPN - ipsec" $DIALOG_CANCEL_LABEL_BACK --menu 'NOT IMPLEMENTED YET\n\nChoose if you want to configure a ipsec server on this localhost, or in a LAN behind it.' 11 50 2 '1' "Ipsec server on localhost" '2' "Ipsec server on a LAN"  `;

        $exit_menu = $?;

        # LOCALHOST
        #-------------
        if($menu == '1' && $exit_menu == '0'){
                features_vpn_ipsec_serveronbox ;
        }

        # ON LAN
        ########
        if($menu =='2' && $exit_menu == '0'){
                features_vpn_ipsec_serverbehind;
        }

   }while($exit_menu == '0')

}



#---------------------------------------------------------
#  features_vpn_ipsec_serveronbox
#---------------------------------------------------------
sub features_vpn_ipsec_serveronbox {

        my $menu;
        my $exit_menu ;

   do{

        $menu = `$DIALOG $DIALOG_BACKTITLE --title "VPN - ipsec - localhost" $DIALOG_CANCEL_LABEL_BACK --menu '' 8 40 2 '1' "Enable" '2' "Port"  `;

        $exit_menu = $?;

        # ENABLE
        #-------------
        if($menu == '1' && $exit_menu == '0'){
                features_vpn_ipsec_serveronbox_enable ;
        }

        # PORT
        ########
        if($menu =='2' && $exit_menu == '0'){
                features_vpn_ipsec_serveronbox_port;
        }

   }while($exit_menu == '0')

}



#---------------------------------------------------------
#  features_vpn_ipsec_serveronbox_enable
#---------------------------------------------------------
sub features_vpn_ipsec_serveronbox_enable {
                # Are we actually Verbose ?
                if($config_value{'IPSEC_LOCALHOST'} == '1'){ $DEFAULTNO = "";}
                else { $DEFAULTNO = "--defaultno"; }

                # ask for verbose
                `$DIALOG $DIALOG_BACKTITLE $DEFAULTNO --title "VPN - ipsec - localhost" --yesno "Chose Yes to enable a ipsec server on the localhost.\n\nEnable ipsec server on localhost ?" 10 50 `;

                # yes ?
                if($? == '0'){
                        $config_value{'IPSEC_LOCALHOST'}="1";
                }else{
                        $config_value{'IPSEC_LOCALHOST'}="0";
                }

}


#---------------------------------------------------------
#  features_vpn_ipsec_serveronbox_port
#---------------------------------------------------------
sub features_vpn_ipsec_serveronbox_port {
        my $new;
        my $exit;

           do{
                $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "VPN - ipsec - localhost - port" --inputbox "Enter on which tcp port listen the ipsec server (default 500/udp)." 10 50  "$config_value{'IPSEC_LOCALHOST_PORT'}" `;

                $exit=$?;

                $new =~ s/\n//g;
                $new =~ s/ +//g;
                $new =~ s/\"//g;


                # if no CANCEL presed
                if($exit == '0'){
                        if($new =~ /^[0-9]+$/){
                                # save
                                $config_value{'IPSEC_LOCALHOST_PORT'}=$new;
                                $exit =1;
                        }else{
                                `$DIALOG $DIALOG_BACKTITLE --title "VPN - ipsec - localhost - port" --msgbox "Error: Not a valid port" 5 40`;
                        }
                }
           }while($exit == 0)
}



#---------------------------------------------------------
#  features_vpn_ipsec_serverbehind
#---------------------------------------------------------
sub features_vpn_ipsec_serverbehind {
        my $menu;
        my $exit_menu ;

   do{
        $menu = `$DIALOG $DIALOG_BACKTITLE --title "VPN - ipsec - LAN" $DIALOG_CANCEL_LABEL_BACK --menu 'NOT IMPLEMENTED YET\n\nYou ar about to configure a ipsec server on a LAN, please give the ip and the port of the serveur, and enable it.' 12 50 3  '1' "Enable" '2' "IP" '3' "Port"  `;

        $exit_menu = $?;

        # ENABLE
        #----
        if($menu == '1' && $exit_menu == '0'){
                features_vpn_ipsec_serverbehind_enable ;
        }

        # IP
        #----
        if($menu == '2' && $exit_menu == '0'){
                features_vpn_ipsec_serverbehind_ip ;
        }

        # PORT
        ########
        if($menu =='3' && $exit_menu == '0'){
                features_vpn_ipsec_serverbehind_port;
        }

   }while($exit_menu == '0')



}


#---------------------------------------------------------
#  features_vpn_ipsec_serverbehind_enable
#---------------------------------------------------------
sub features_vpn_ipsec_serverbehind_enable {
                # Are we actually Yes ?
                if($config_value{'IPSEC_LAN'} == '1'){ $DEFAULTNO = "";}
                else { $DEFAULTNO = "--defaultno"; }

                # ask for verbose
                `$DIALOG $DIALOG_BACKTITLE $DEFAULTNO --yesno "Chose Yes to enable a ipsec server on the LAN, behind your firewall.\n\nEnable ipsec server on LAN ?" 10 50 `;

                # yes ?
                if($? == '0'){
                        $config_value{'IPSEC_LAN'}="1";
                }else{
                        $config_value{'IPSEC_LAN'}="0";
                }

}



#---------------------------------------------------------
#  features_vpn_ipsec_serverbehind_ip
#---------------------------------------------------------
sub features_vpn_ipsec_serverbehind_ip {
        my $new;
        my $exit;

           do{
                $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "VPN - ipsec - LAN - IP" --inputbox "Enter th IP of the ipsec server on the LAN. Example: '192.168.2.4'" 10 50  "$config_value{'IPSEC_LAN_IP'}" `;

                $exit=$?;

                $new =~ s/\n//g;
                $new =~ s/ +//g;
                $new =~ s/\"//g;
                

                # if no CANCEL pressed
                if($exit == '0'){
                        if($new =~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/){
                                # save
                                $config_value{'IPSEC_LAN_IP'}=$new;
                                $exit=1;

                        }else{
                                `$DIALOG $DIALOG_BACKTITLE --title "VPN - ipsec - LAN - IP" --msgbox "Error: Not a valid IP" 5 40`;
                        }
                }
           }while($exit == 0)


}

#---------------------------------------------------------
#  features_vpn_ipsec_serverbehind_port
#---------------------------------------------------------
sub features_vpn_ipsec_serverbehind_port {
        my $new;
        my $exit;

           do{
                $new = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "VPN - ipsec - LAN - port" --inputbox "Enter on which tcp port listen the ipsec server (default 500/udp)." 10 50  "$config_value{'IPSEC_LAN_PORT'}" `;

                $exit=$?;

                $new =~ s/\n//g;
                $new =~ s/ +//g;
                $new =~ s/\"//g;


                # if no CANCEL presed
                if($exit == '0'){
                        if($new =~ /^[0-9]+$/){
                                # save
                                $config_value{'IPSEC_LAN_PORT'}=$new;
                                $exit =1;
                        }else{
                                `$DIALOG $DIALOG_BACKTITLE --title "VPN - ipsec - LAN - port" --msgbox "Error: Not a valid port" 5 40`;
                        }
                }
           }while($exit == 0)

}










sub select_a_interface
{
    $title = shift;
    $selection_text     = shift;
    $ifaces    = shift;

    @selected_ifaces = split(/ |,/,$ifaces);
    

    
    # build interfaces list
    #######################
    
    # get iface from /proc
    ######################
    $IFACE_PROC = `cat /proc/net/dev | $GREP ':'`;
    
    $IFACE_PROC =~ s/:.*//g;
    $IFACE_PROC =~ s/lo//g;
    $IFACE_PROC =~ s/ //g;
    $IFACE_PROC =~ s/\n/ /g;
    $IFACE_PROC =~ s/^ *//g;
    $IFACE_PROC =~ s/ *$//g;
    
    # create /proc list items
    @iface_array_proc = split (/ |\n/,$IFACE_PROC);



    # get iface from ifconfig (for alias)
    #####################################
    $IFACE_IFCONFIG = `$IFCONFIG | $GREP -e "^[^ ]\\+"`;
    @tmp = split (/\n/,$IFACE_IFCONFIG);

    # build list
    $IFACE_IFCONFIG ="";
    foreach $truc (@tmp){
	$truc =~ s/^([^ ]+).*$/$1/g;
	if ($IFACE_IFCONFIG =~ /^$/){$IFACE_IFCONFIG = $truc;}
	else {$IFACE_IFCONFIG = "$IFACE_IFCONFIG $truc"; }
    }

    # remove loopback
    $IFACE_IFCONFIG =~ s/lo//g;
    $IFACE_IFCONFIG =~ s/^ *//g;
    $IFACE_IFCONFIG =~ s/ *$//g;
    
    # format an array
    @iface_array_ifconfig = split(/ +/,$IFACE_IFCONFIG);

    # add iface from ifconfig not found in /proc/net/dev
    foreach $iface (@iface_array_ifconfig){
	if(!grep(/^$iface$/,@iface_array_proc)){
	    
	    @iface_array_proc=($iface,@iface_array_proc);
	}
    }

    
    # for interfaces found in /proc/net/dev and ifconfig
    ####################################################
    $i=0;
    $item_proc="";
    foreach $if (@iface_array_proc){
	
	$i++;
	# get ip
	$ip = `$IFCONFIG $if | $GREP inet`;
	
	$ip =~ s/\n//g;
	$ip =~ s/ {2,}/ /g;
	
	$ip =~ s/^.*:([0-9.]+).*:.*:.*$/$1/;
	$ip =~ s/ //g;
	
	# no ip ?
	if($ip =~ /^$/){
	    $ip="no ip found";
	}

	# if interface as already be ckecked 
	if (grep(/^$if$/,@selected_ifaces)){
	    $item_proc="$item_proc '$if ($ip)' '' 'on' ";
	}else{
	    $item_proc="$item_proc '$if ($ip)' '' 'off' ";
	}

	
    }

    @iface_array_undetected = split (/ +/,$config_value{'UNDETECTED_IFACES'});
    
    # Search for iface in EXT_IFACE which was not detected (and add it in UNDETECTED_IFACES)
    ######################################################################################
    @iface_array_ext = split (/ +/,$config_value{'EXT_IFACE'});
    for $if (@iface_array_ext){

	# iface not found in /proc and in UNDETECTED_IFACES ?
	if(!grep(/^$if$/,@iface_array_proc) && !grep(/^$if$/,@iface_array_undetected)){

	    # add it to UNDETECTED_IFACES
	    if($config_value{'UNDETECTED_IFACES'} =~ /^$|^ +$/){
		$config_value{'UNDETECTED_IFACES'}="$if";
	    }else{
		$config_value{'UNDETECTED_IFACES'}="$config_value{'UNDETECTED_IFACES'} $if";
	    }
	}
    }

    # Search for iface in INT_IFACE which was not detected (and add it in UNDETECTED_IFACES)
    #########################################################################################
    @iface_array_int = split (/ +/,$config_value{'INT_IFACE'});
    for $if (@iface_array_int){

	# iface not found in /proc and in UNDETECTED_IFACES ?
	if(!grep(/^$if$/,@iface_array_proc) && !grep(/^$if$/,@iface_array_undetected)){

	    # add it to UNDETECTED_IFACES
	    if($config_value{'UNDETECTED_IFACES'} =~ /^$|^ +$/){
		$config_value{'UNDETECTED_IFACES'}="$if";
	    }else{
		$config_value{'UNDETECTED_IFACES'}="$config_value{'UNDETECTED_IFACES'} $if";
	    }
	}
   }
    
    
    do{
	# get iface from  'undetected ifaces"
	#####################################
	@iface_array_undetected = split (/ +/,$config_value{'UNDETECTED_IFACES'});
	$item_undetected="";
	for $if (@iface_array_undetected){

	    # if not detected 			
	    if(!grep(/^$if$/,@iface_array_proc)){

		# if interface as already be ckecked in
		if (grep(/^$if$/,@selected_ifaces)){
		    $item_undetected="$item_undetected '$if (no ip found)' '' 'on' ";
		}else{
		    $item_undetected="$item_undetected '$if (no ip found)' '' 'off' ";
		}
	      
	    }
	}

	# put undetected ifaces in first position
	#########################################
	$item = "$item_undetected $item_proc";
	
	
	# Display interface selection
	#############################
	$select_iface = `$DIALOG $DIALOG_BACKTITLE $DIALOG_HELP_BUTTON $DIALOG_HELP_LABEL_ADD_NEW --title '$title' --checklist "$selection_text\nIf you cannot find it in the list below, go in <Undetected> to add it manually.\n(ex: ppp0 when the interface is not UP)" 17 55 5 $item `;
	$select_iface_exit=$?;

	# modify undetected interface (ppp0, ...)
	if( $select_iface =~ /HELP/){
	    $new_iface = `$DIALOG $DIALOG_BACKTITLE --inputbox 'Enter undetected interfaces (ex: ppp0, ...) separate with spaces.' 10 50  "$config_value{'UNDETECTED_IFACES'}" `;
	    
	    # no cancel => save
	    if($? ==0){
		# clean list (too much spaces , ...)
		$new_iface =~ s/ +/ /g;
		$new_iface =~ s/^ +//g;
		$new_iface =~ s/ +$//g;
		$new_iface =~ s/\"//g;
		
		$config_value{'UNDETECTED_IFACES'}=$new_iface;
	    }
	}
	
    }while($select_iface =~ /HELP/);  # while we enter undetected iface


    # if no CANCEL presed, we must return the selected interfaces
    if($select_iface_exit == 0){
	# format return
	$select_iface =~ s/\\//g;  	
	$select_iface =~ s/ \([0-9.]*\)|\(no ip found\)//g;  	# remove ip
	$select_iface =~ s/\"//g;
	$select_iface =~ s/ +$//g;
	$select_iface =~ s/^ +//g;
	$select_iface =~ s/ +/ /g;

	return $select_iface;
	
    }else{ return "";}
    
}

#---------------------------------------------------------
#  Create HELP in configuration's file
#----------------------------------------------------------

sub create_help_config_file
{

$config_help{'POST_START'}="




#####################################################################
#  POST / PRE Scripts                                               # 
#####################################################################

### POST START script (run after the 'start')
# Add a list of scripts separated by a ;
# ps: 'restart' = 'stop' + 'start'
";

$config_help{'PRE_START'}="
### PRE START script (run before the 'start')
";

$config_help{'POST_STOP'}="
### POST STOP script (run after the 'stop')
";

$config_help{'PRE_STOP'}="
### PRE STOP script (run before the 'stop')
";

$config_help{'INT_IFACE'}="




#####################################################################
#  INTERFACES                                                       #  
#####################################################################

### LAN Interfaces
# May be more than one (ex: (eth0 eth1))
# Please leave interfaces between () and no \"\"
# Interfaces must be up for ip dection
";

$config_help{'EXT_IFACE'}="
### External Interface
# May be more than one (ex: \"eth2 eth3\")
# Interfaces must be up for ip dection
";

$config_help{'DNS'}="




#####################################################################
#           TRAFFIC                                                 #
#####################################################################

### Your Friends
# DHCP_SERVER is the DHCP of your IPS, leave blank if don't know it 
# or if you don't use DHCP.
# (you can find it in your \"pump\" log)
# DNS is the DNS of your ISP (separated with spaces)
";

$config_help{'DHCP_SERVER'}="";

$config_help{'TCP_EXT_IN'}="

### Allow connections from the World ..
# Give the list of TCP/UDP ports that you want to allow 
# on your box (and for which interface).
# Syntax: \"<iface1>;port1,port2,port3 <iface2>;<port1>,<port2>\"
# 
# Example: \"ppp0;22,80 ppp1;25,110\"
";


$config_help{'TCP_INT_IN'}="

### Allow connections from the LAN ..
# Leave TCP_INT_IN=\"*\" for allow all TCP connections from 
# youur LAN (idem for UDP), if not :  
#
# Give the list of TCP/UDP ports that you want to allow on your 
# box (and for which interface). '*' mean all ports
#
# Syntax: \"<iface1>;<port1>,<port2>,<port3> <iface2>;<port1>,<port2>\"
#
# Example: \"eth0;22,80,8080 eth1;*\"
#
# Remeber that allowing ssh connections is always a good idea 
# when you're testing this feature ... ;)
";


$config_help{'TCP_FORWARD'}="

### TCP & UDP Forward
# ( separated with spaces, 
#   ex: \"eth0>20100:21100>192.168.0.4 eth1>21>192.168.0.6\" )
# syntax:
#   iface[,iface]>dport[:dport]>dest-ip[:dport]   
#   
#
# example:
#  - redirect port 21 from eth0 and eth1 to 192.168.0.3
#     \"eth0,eth1>21>192.168.0.3\"
#
#  - redirect port 2121 from ppp0 to 192.168.0.3 on port 21
#     \"ppp0>2121>192.168.0.3:21\"
";

$config_help{'DMZ'}="




##############################################
#                    DMZ                     #
##############################################
#
#  Write your dmz entry list. A dmz entry is a host on a dmz
#  wich can be recieve/send connections on some tcp/udp port(s) from/to inet ,
#  and recieve some tcp/udp port(s) from the lan.
#
#  Syntax of a dmz entry:
#  ----------------------
#
#     DMZ=\"<Description>;
#          <Allowed Inet ifaces>;
#          <Allowed LAN ifaces>;
#          <DMZ ifaces>;
#          <host on the DMZ>;
#          <tcp from inet>;
#          <udp from inet>;
#          <tcp to inet>;
#          <udp to inet>;
#          <tcp from lan>;
#          <udp from lan>\"
#
#     All dmz entry are separate with spaces in DMZ variable.
#     All items in a dmz entry are separate by ';'.
#     In an item, a list is performed with ','.
#
#     !! Do not leave break line, it's only for example !!
#
#     Example: 
#     --------
#
#     DMZ=\"my-ftp;eth2;eth0;eth1;192.168.5.2;21;;;;21,22;  my-www;eth2:1;;eth1:1;192.168.5.7;80;;;;22;
#
";

$config_help{'DMZ_DNS_MODE'}="

### DNS Mode for the DMZ
#  (0) : Do not allow the dns traffic from the DMZ to anywhere,
#        Much more secure mode ! (ex: your DNS server is on the DMZ)
#  (1) : Allow the dns traffic between the dmz and internet
#        (when your dmz hosts are configured with the dns ip of your ISP)
#  (2) : Allow the dns traffic between the dmz and your linux server
#        (when your firewall box is also your dns server)
#
";

$config_help{'DYN_IP'}="




#####################################################################
# OPTIONS                                                           #
#####################################################################

### Do you have ADSL/Cable/IDSN/... ?
# Enable this option if you have a dynamic ip.
# Your established connections will not be lost
# during a reconnection .
";

$config_help{'NAT'}="
### Share Internet over your LAN ?
";

$config_help{'IRC'}="
### This option is necessary if you want to use IRC on your LAN 
";

$config_help{'PROXY_HTTP'}="
### Transparents Proxy
# Write the proxies ports of your LAN
";



$config_help{'PING_FOR_ALL'}="
### Can we be pinged by the world ?
# remember that the LAN can Always ping the server
";

$config_help{'ALLOWED_PING'}="
### Hosts allowed to ping the linux box (only if PING_FOR_ALL = \"0\")
";

$config_help{'alias ECHO'}="
### Set firewall in verbose mode ?
";


$config_help{'USE_DHCP_SERVER'}="
### Your Linux box is a DHCP server for the LAN ?
";


$config_help{'LOGLEVEL'}="
### Logging Options
";


$config_help{'LOG_ULOG_NLGROUP'}="
### ULOG
# If you don't want to write all dropped packets to your syslog files,
# you can use ULOGD. Give only the 'nlgroup' value of your ulogd.conf.
# Leave blank if you don't want to use ULOGD.
";


$config_help{'TCP_CONTROL'}="
### Enable TCP control
";

$config_help{'ICMP_CONTROL'}="
### Enable ICMP Control
";

$config_help{'SPOOFING_CONTROL'}="
### Enable Spoofing control (bad ips)
";

$config_help{'ICMP_TO_DENY'}="

### Give wich ICMP you want to drop (separate with spaces)
# Please enter the real name of the icmp type
# ex: network-unreachable, host-unreachable, ... 
# (see 'iptables -p icmp --help' for the list)
";



$config_help{'DENY_DIR'}="




#####################################################################
#       Hosts Blocking List                                         #
#####################################################################
# IP and MAC control                                                #
# Reject spyware, doubleclick and co.                               #
# Give the target of a (or more) ip file                            #
#                                                                   #
# (SEE README & SPYWARES!)                                          #
#####################################################################


####### Directory where input and output files are located
# default /var/lib/firewall-jay/
";


$config_help{'DENY_ULOG_NLGROUP'}="
####### ULOG
# If you don't want to write all dropped packets to your syslog files,
# you can use ULOGD. Give only the 'nlgroup' value of your ulogd.conf. 
# Leave blank if you don't want to use ULOGD.
";


$config_help{'DENY_IP_IN'}="


####### Incoming traffic 'from' IPs
# Enable (1) / Disable (0)
";

$config_help{'DENY_IP_IN_FILES'}="
# Filename of ip files (in DENY_DIR directory)
# You can enter more than one file, leave a space between them.
";

$config_help{'DENY_IP_IN_LOG'}="
# Log activity
";

$config_help{'DENY_IP_OUT'}="


####### Outgoing traffic 'to' IPs
";

$config_help{'DENY_IP_OUT_FILES'}="
# Filename of ip files (in DENY_DIR directory)
# You can enter more than one file, leave a space between them.
";

$config_help{'DENY_IP_OUT_LOG'}="
# Log activity
";


$config_help{'DENY_MAC_IN'}="


####### Incoming traffic 'from' MACs
# Enable (1) / Disable (0)
";

$config_help{'DENY_MAC_IN_FILES'}="
# Filename of mac files (in DENY_DIR directory)
# You can enter more than one file, leave a space between them.
";

$config_help{'DENY_MAC_IN_LOG'}="
# Log activity
";


$config_help{'TOS'}="




#####################################################################
#    Type Of Service (TOS)                                          #
# Set better performance to your bandwidth                          #
#####################################################################

# Enable (1) / Disable (0)
";

$config_help{'TCP_MIN_DELAY'}="
# Give services which require minimum delay like 
# interactives services (ssh , telnet, ...)
";

$config_help{'TCP_MAX_THROUGHPUT'}="
# Give services which require maximum throughput (ftp-data, ...)
";

$config_help{'TUN_IFACE'}="




#####################################################################
#  VPN  - VTUND                                                     #
#####################################################################

### Give the devices used for tunneling
# (separated with spaces, ex: \"tun0 tun1\")
";

$config_help{'TUN_SUBNET'}="
### Give the subnet allowed in your LAN
# (separated with spaces, ex:\"192.168.2.0/24 192.168.4.0/24\")
";

$config_help{'TUN_TCP'}="
### Give the ports allowed for TUN_SUBNET
# (separated with spaces)
# \"*\" give access to all ports
";



$config_help{'IPSEC_LOCALHOST'}="




#####################################################################
#  VPN  - IPSEC                                                     #
#                                                                   #
# Your are able to set up a ipsec server on this localhost,         #
# or on a LAN behind this firewall                                  # 
#####################################################################

# IPSEC server on LOCALHOST
# NOT IMPLEMENTED YET
###########################
# Enable (1) / Disable (0)
";

$config_help{'IPSEC_LOCALHOST_PORT'}="
### Port of Ipsec server (default 500)
";

$config_help{'IPSEC_LAN'}="



# IPSEC server on LAN
# NOT IMPLEMENTED YET
######################
# Enable (1) / Disable (0)
";

$config_help{'IPSEC_LAN_PORT'}="
### Port of Ipsec server (default 500)
";

$config_help{'IPSEC_LAN_IP'}="
### Ip of Ipsec server (ex: 192.168.2.2)
";




$config_help{'PPTP_LOCALHOST'}="





#####################################################################
#  VPN  - PPTP                                                      #
#                                                                   #
#  --- Only PPTP server on localhost work for this time ----        #
#                                                                   #
# Your are able to set up a pptp server on this                     #
# localhost, or on a LAN behind this firewall                       #
#####################################################################

# PPTP server on LOCALHOST
##########################
# Enable (1) / Disable (0)
";

$config_help{'PPTP_LOCALHOST_PORT'}="
### Port of Pptp server (default 1723)
";


$config_help{'PPTP_LOCALHOST_IFACES'}="
### Incoming connections from clients are on which interface(s) ?
";


$config_help{'PPTP_LOCALHOST_SUBNET_VPN'}="
### Give the subnet of your VPN (ex: 192.168.10.0/24)
";

$config_help{'PPTP_LOCALHOST_SUBNET_ALLOWED'}="
### Which subnets except your new Virtual Network can use 
# the VPN connection (ex: the local subnet of your client)
";


$config_help{'PPTP_LOCALHOST_ACCESS_LAN'}="
### Do you want to allow the access to your LAN from the VPN ?
";


$config_help{'PPTP_LOCALHOST_ACCESS_INET'}="
### Do you want to allow the access to your Internet connection from the VPN ?
";



$config_help{'PPTP_LAN'}="


# PPTP server on LAN 
# NOT IMPLEMENTED YET
#####################
# Enable (1) / Disable (0)
";

$config_help{'PPTP_LAN_PORT'}="
### Port of Pptp server (default 1723)
";

$config_help{'PPTP_LAN_IP'}="
### Ip of Ipsec server (ex: 192.168.2.2)
";




$config_help{'ZORBIPTRAFFIC'}="




#####################################################################
# ZORBIPTRAFFIC                                                     #
#                                                                   #
# ZorbIPtraffic shows the IP traffic on a network interface         #
# in real time. It can display (by the web) traffic statistics      #
# for each IP on your internal network.                             #
#                                                                   #
# See exemple & download on http://www.atout.be                     #
#                                                                   #
# You can insert multiple Subnets & IPs like                        #
#                                                                   #
# ZORBIPTRAFFIC_NET=\"192.168.3.0/24 192.168.5.0/24\"                 # 
# ZORBIPTRAFFIC_IPS=\"192.168.3.1 192.168.5.4\"                       #
#                                                                   #
#####################################################################

# Enable (1) / Disable (0)
";

$config_help{'ZORBIPTRAFFIC_NET'}="
# ZorbIPTraffic subnets
";

$config_help{'ZORBIPTRAFFIC_IPS'}="
# ZorbIPTraffic specifics ips
";



$config_help{'CUSTOM_RULES'}="




#####################################################################
# CUSTOM RULES FILE                                                 #
#####################################################################
# Give the path to the custom rules file                            #
# The file will be started like a script in                         #
# the beginning of the firewall                                     #
#                                                                   #
# Default : /var/lib/firewall-jay/firewall-custom.rules             #
#####################################################################

# 1 (enable) / 0 (disable) 
";

$config_help{'CUSTOM_RULES_FILE'}="
# Path to custom file
";

$config_help{'MARK'}="




#####################################################################
# NETFILTER & IPROUTE                                               #
#####################################################################
# If you want to mark packets for playing                           #
# with iproute2, give port/ip to be marked                          #
#                                                                   #
#       MARK_TCP=\"port1>mark1 port2>mark2 ...\"                      #
#  ex.  MARK_TCP=\"110>1 30000:30100>2\"                              #
#                                                                   #
# MARK_IP  -> mark packets comming \"from\" IP                        #
# MARK_TCP -> mark packets destined \"to\" tcp port                   #
# MARK_UDP -> mark packets destined \"to\" udp port                   #
##################################################################### 

# Enable (1) / Disable (0)
";

$config_help{'PRIV_PORTS'}="




#####################################################################
##---------------------- DON'T EDIT BELOW -------------------------##
#####################################################################

";


$begin_of_config_file="#!/bin/sh
######################################################################
#                                                                    #
#  This file was generated by 'firewall-config.pl' tool.             #
#  You can edit it by hands or use the script configuration.         #
#  Lines begining with '#' are regarded as comments.                 #
#                                                                    #
######################################################################

######################################################################
#                                                                    #
# firewall.config   $FIREWALL_VERSION   by Jay                                   #
#                                                                    #
#  Copyright 2002 Jerome Nokin                                       #
#                                                                    #
#This program is free software; you can redistribute it and/or modify#
#it under the terms of the GNU General Public License as published by#
#the Free Software Foundation; either version 2 of the License, or   #
#(at your option) any later version.                                 #
#                                                                    #
#This program is distributed in the hope that it will be useful,     #
#but WITHOUT ANY WARRANTY; without even the implied warranty of      #
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       #
#GNU General Public License for more details.                        #
#                                                                    #
#You should have received a copy of the GNU General Public License   #
#along with this program; if not, write to the Free Software         #
#Foundation, Inc., 59 Temple Place, Suite 330, Boston,               #
#MA  02111-1307  USA                                                 #
#                                                                    #
######################################################################

";


} # end function














#------------------------------------------------------
# MAIN MENU
#-----------------------------------------------------
sub main_menu{
    return `$DIALOG $DIALOG_BACKTITLE --clear --title "Configuration Menu" $DIALOG_CANCEL_LABEL_QUIT --menu "" 0 40 12 "1" "Internal Interfaces" "2" "External Interfaces"  '' '' "3" "Allowed TCP ports" "4" "Allowed UDP ports" "5" "Forwarding TCP Ports" "6" "Forwarding UDP Ports" '' ''  "7" "Configuration (required)" "8" "Features (optional)" '' '' "9" "About" `;

}


#------------------------------------------------------
# MAIN MENU EXIT
#-----------------------------------------------------

sub main_menu_exit{
       
	`$DIALOG $DIALOG_BACKTITLE --title "Quit" --clear --yesno "\nDo you want to save change to '$CONFIG_FILE' ?" 8 60 `;

	#save
	if($? == 0){

		create_help_config_file;	
		save_config_to_file;
	}

	`/usr/bin/clear`;
	exit ;
}


#-------------------------------------------------
#  main_menu_internal_interfaces
#-------------------------------------------------


sub main_menu_internal_interfaces{

    ######################
    # INTERNAL INTERFACE #
    ######################
    
    # build interfaces list
    #######################
    @iface_array_int        = split (/ +/,$config_value{'INT_IFACE'});
    
    # get iface from /proc
    ######################
    $IFACE_PROC = `cat /proc/net/dev | $GREP ':'`;
    
    $IFACE_PROC =~ s/:.*//g;
    $IFACE_PROC =~ s/lo//g;
    $IFACE_PROC =~ s/ //g;
    $IFACE_PROC =~ s/\n/ /g;
    $IFACE_PROC =~ s/^ *//g;
    $IFACE_PROC =~ s/ *$//g;
    
    # create /proc list items
    @iface_array_proc = split (/ |\n/,$IFACE_PROC);
    
    # for interfaces found in /proc/net/dev
    $i=0;
    $item_proc="";
    foreach $if (@iface_array_proc){
	
	$i++;
	# get ip
	$ip = `$IFCONFIG $if | $GREP inet`;
	
	$ip =~ s/\n//g;
	$ip =~ s/ {2,}/ /g;
	
	$ip =~ s/^.*:([0-9.]+).*:.*:.*$/$1/;
	$ip =~ s/ //g;
	
	# no ip ?
	if($ip =~ /^$/){
	    $ip="no ip found";
	}
	
	# if interface as already be ckecked in config
	if (grep(/^$if$/,@iface_array_int)){
	    $item_proc="$item_proc '$if ($ip)' '' 'on' ";
	}else{
	    $item_proc="$item_proc '$if ($ip)' '' 'off' ";
	}
    }
    
    
    # Search for iface in INT_IFACE which was not detected (and add it in UNDETECTED_IFACES)
    ######################################################################################
    @iface_array_undetected = split (/ +/,$config_value{'UNDETECTED_IFACES'});
    for $if (@iface_array_int){
	
	# iface not found in /proc and in UNDETECTED_IFACES ?
	if(!grep(/^$if$/,@iface_array_proc) && !grep(/^$if$/,@iface_array_undetected)){
	    # add it to UNDETECTED_IFACES
	    if($config_value{'UNDETECTED_IFACES'} =~ /^$|^ +$/){
		$config_value{'UNDETECTED_IFACES'}="$if";
	    }else{
		$config_value{'UNDETECTED_IFACES'}="$config_value{'UNDETECTED_IFACES'} $if";
	    }
	}
	
    }
    
    do{
	# get iface from  'undetected ifaces"
	#####################################
	@iface_array_undetected = split (/ +/,$config_value{'UNDETECTED_IFACES'});
	$item_undetected="";
	for $if (@iface_array_undetected){
	    
	    # if not detected
	    if(!grep(/^$if$/,@iface_array_proc)){  
		# if interface as already be ckecked in config
		@iface_array_int = split (/ +/,$config_value{'INT_IFACE'});
		if (grep(/^$if$/,@iface_array_int)){
		    $item_undetected="$item_undetected '$if (no ip found)' '' 'on' ";
		}else{
		    $item_undetected="$item_undetected '$if (no ip found)' '' 'off' ";
		}
	    }
	}
	
	# put undetected ifaces in first position
	$item = "$item_undetected $item_proc";
	
	# Display interface selection
	#############################
	$int_iface = `$DIALOG $DIALOG_BACKTITLE $DIALOG_HELP_BUTTON $DIALOG_HELP_LABEL_ADD_NEW --title 'Select Internal Interfaces' --checklist "Choose your Local network interface(s).\nIf you cannot find it in the list below, go in <Undetected> to add it manually.\n(ex: when the interface is not UP)" 15 50 5 $item `;
	$int_iface_exit=$?;
	
	
	# modify undetected interface (ppp0, ...)
	if( $int_iface =~ /HELP/){
	    $new_iface = `$DIALOG $DIALOG_BACKTITLE --inputbox 'Enter undetected interfaces (ex: ppp0) separate with spaces.' 10 50  "$config_value{'UNDETECTED_IFACES'}" `;
	    
	    # no cancel => save
	    if($? ==0){
				# clean list (too much spaces , ...)
		$new_iface =~ s/ +/ /g;
		$new_iface =~ s/^ +//g;
		$new_iface =~ s/ +$//g;
		$new_iface =~ s/\"//g;
		
		$config_value{'UNDETECTED_IFACES'}=$new_iface;
	    }
	}
	
    }while($int_iface =~ /HELP/);  # while we enter undetected iface
    
    
    # if no CANCEL presed, we must save the new config
    if($int_iface_exit == 0){
	        # format return
	$int_iface =~ s/ \([0-9.]*\)|\(no ip found\)//g;  #remove ip
	$int_iface =~ s/\"//g;
       		$int_iface =~ s/ $//g;
	$int_iface =~ s/^ //g;
	$int_iface =~ s/ +/ /g;
	
	
	
	# test if interface is already used in external interface
	@iface_int = split (/ +/,$int_iface);
	@iface_ext = split(/ +/,$config_value{'EXT_IFACE'});
	foreach $if (@iface_int){
	    
	    if (grep(/^$if$/, @iface_ext)){
		`$DIALOG $DIALOG_BACKTITLE --title "Internal Interfaces" --msgbox "Error: '$if' is already used for external interfaces, please choose the good one" 8 60`;
		#remove
		#$int_iface =~ s/$if//g;
	    }
	}
	
	# reformat
	$int_iface =~ s/ +/ /g;
	$int_iface =~ s/ $//g;
	$int_iface =~ s/^ //g;
	# save
	$config_value{'INT_IFACE'}=$int_iface;
	
	

    }
    
}






#-------------------------------------------------
#  main_menu_external_interfaces
#-------------------------------------------------


sub main_menu_external_interfaces{
    ######################
    # EXTERNAL INTERFACE #
    ######################
    

# build interfaces list
#######################
@iface_array_ext        = split (/ +/,$config_value{'EXT_IFACE'});

# get iface from /proc
   ######################
   $IFACE_PROC = `cat /proc/net/dev | $GREP ':'`;

   $IFACE_PROC =~ s/:.*//g;
   $IFACE_PROC =~ s/lo//g;
   $IFACE_PROC =~ s/ //g;
   $IFACE_PROC =~ s/\n/ /g;
   $IFACE_PROC =~ s/^ *//g;
   $IFACE_PROC =~ s/ *$//g;

   # create /proc list items
   @iface_array_proc = split (/ |\n/,$IFACE_PROC);

   # for interfaces found in /proc/net/dev
   $i=0;
   $item_proc="";
   foreach $if (@iface_array_proc){

       $i++;
       # get ip
       $ip = `$IFCONFIG $if | $GREP inet`;

       $ip =~ s/\n//g;
       $ip =~ s/ {2,}/ /g;

       $ip =~ s/^.*:([0-9.]+).*:.*:.*$/$1/;
       $ip =~ s/ //g;

       # no ip ?
       if($ip =~ /^$/){
	   $ip="no ip found";
       }

       # if interface as already be ckecked in config
       if (grep(/^$if$/,@iface_array_ext)){
	   $item_proc="$item_proc '$if ($ip)' '' 'on' ";
       }else{
	   $item_proc="$item_proc '$if ($ip)' '' 'off' ";
       }
   }


    # Search for iface in EXT_IFACE which was not detected (and add it in UNDETECTED_IFACES)
    ######################################################################################
    @iface_array_undetected = split (/ +/,$config_value{'UNDETECTED_IFACES'});
    for $if (@iface_array_ext){

	# iface not found in /proc and in UNDETECTED_IFACES ?
	if(!grep(/^$if$/,@iface_array_proc) && !grep(/^$if$/,@iface_array_undetected)){
	    # add it to UNDETECTED_IFACES
	    if($config_value{'UNDETECTED_IFACES'} =~ /^$|^ +$/){
		$config_value{'UNDETECTED_IFACES'}="$if";
	    }else{
		$config_value{'UNDETECTED_IFACES'}="$config_value{'UNDETECTED_IFACES'} $if";
	    }
	}

    }

    do{
	    # get iface from  'undetected ifaces"
	    #####################################
	    @iface_array_undetected = split (/ +/,$config_value{'UNDETECTED_IFACES'});
	    $item_undetected="";
	    for $if (@iface_array_undetected){

		# if not detected
		if(!grep(/^$if$/,@iface_array_proc)){  
		    # if interface as already be ckecked in config
		    @iface_array_ext = split (/ +/,$config_value{'EXT_IFACE'});
		    if (grep(/^$if$/,@iface_array_ext)){
			$item_undetected="$item_undetected '$if (no ip found)' '' 'on' ";
		    }else{
			$item_undetected="$item_undetected '$if (no ip found)' '' 'off' ";
		    }
		}
	    }

	    # put undetected ifaces in first position
	    $item = "$item_undetected $item_proc";

	    # Display interface selection
	    #############################
	    $ext_iface = `$DIALOG $DIALOG_BACKTITLE $DIALOG_HELP_BUTTON $DIALOG_HELP_LABEL_ADD_NEW --title 'Select External Interfaces' --checklist "Choose your Internet interface(s).\nIf you cannot find it in the list below, go in <Undetected> to add it manually.\n(ex: when the interface is not UP)" 15 50 5 $item `;
	    $ext_iface_exit=$?;


	    # modify undetected interface (ppp0, ...)
	    if( $ext_iface =~ /HELP/){
		    $new_iface = `$DIALOG $DIALOG_BACKTITLE --inputbox 'Enter undetected interfaces (ex: ppp0) separate with spaces.' 10 50  "$config_value{'UNDETECTED_IFACES'}" `;

		    # no cancel => save
		    if($? ==0){
			    # clean list (too much spaces , ...)
			    $new_iface =~ s/ +/ /g;
			    $new_iface =~ s/^ +//g;
			    $new_iface =~ s/ +$//g;
			    $new_iface =~ s/\"//g;

			    $config_value{'UNDETECTED_IFACES'}=$new_iface;
		    }
	    }

    }while($ext_iface =~ /HELP/);  # while we enter undetected iface


    # if no CANCEL presed, we must save the new config
    if($ext_iface_exit == 0){
	    # format return
	    $ext_iface =~ s/ \([0-9.]*\)|\(no ip found\)//g;  #remove ip
	    $ext_iface =~ s/\"//g;
	    $ext_iface =~ s/ $//g;
	    $ext_iface =~ s/^ //g;
	    $ext_iface =~ s/ +/ /g;



	    # test if interface is already used in internal interface
	    @iface_ext = split (/ +/,$ext_iface);
	    @iface_int = split(/ +/,$config_value{'INT_IFACE'});
	    foreach $if (@iface_ext){

		if (grep(/^$if$/, @iface_int)){
		    `$DIALOG $DIALOG_BACKTITLE --title "External Interfaces" --msgbox "Error: '$if' is already used for internal interfaces, please choose the good one" 8 60`;
		    #remove
		    # $ext_iface =~ s/$if//g;
		}
	    }

	    # reformat
	    $ext_iface =~ s/ +/ /g;
	    $ext_iface =~ s/ $//g;
	    $ext_iface =~ s/^ //g;
	    # save
	    $config_value{'EXT_IFACE'}=$ext_iface;



	}


}



#-------------------------------------------------
#  main_menu_allow_tcp
#-------------------------------------------------


sub main_menu_allow_tcp{

	return  `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "Allowed TCP Port(s)" 10 40 2 "1" "Views currents port(s)" "2" "Modify TCP port" `;
}

sub main_menu_allow_tcp_view{

		
		# View currents ports
		
			# there is no ports ?
			if($config_value{'TCP_EXT_IN'} == ""){
				 `$DIALOG $DIALOG_BACKTITLE --title "Allowed TCP Port(s)" --msgbox "none" 5 40`;
			}
			else{
			    # build list
			    $list_ports="";
			    $nb_ports=0;
			    @ports = split(/ /,$config_value{'TCP_EXT_IN'});
			    foreach $p (@ports){

				# Get the name of service
				$name_of_port = `cat $SERVICE_FILE |grep -e "	$p/tcp" -e " $p/tcp"`;
				$name_of_port =~ s/^([a-zA-Z0-9]+).*$/$1/g;
				$name_of_port =~ s/\n//g;

				
				if ($name_of_port !~ /^$/){
				    if($list_ports =~ /^$/){
					$list_ports="'$p' '($name_of_port)'";
				    }else{
					$list_ports="$list_ports '$p' '($name_of_port)'";
				    }
				}else{
				    if($list_ports =~ /^$/){
					$list_ports="'$p' '' ";
				    }else{
					$list_ports="$list_ports '$p' ''";
				    }
				}
				$nb_ports++;
			    }
			    #print $list_ports;
			    #exit;

			    if ($nb_ports > 12){
				$nb_ports=12;
			    }

			    `$DIALOG $DIALOG_BACKTITLE --title "Allowed TCP Port(s)" --menu "" 0 40 $nb_ports $list_ports`; 

			    
			}
}

sub main_menu_allow_tcp_modify{


			do{
				if($config_value{'TCP_EXT_IN'} == ""){
					$new_tcp = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify TCP port(s)" --inputbox "Write list separate with spaces" 8 40  `;
				}
				else{
					$new_tcp = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify TCP port(s)" --inputbox "Write list separate with spaces" 8 40 "$config_value{'TCP_EXT_IN'}" `;
				}

				$exit_add_port=$?;
				
                                $new_tcp =~ s/\n//g;
				$new_tcp =~ s/ +/ /g;
				$new_tcp =~ s/ $//g;
				 $new_tcp =~ s/^ //g;


				if($new_tcp =~ /^([0-9]+(:[0-9]+)? ?)*$/ ){
					# if no CANCEL presed
				        if($? == 0){
			        	        # save
			                	$config_value{'TCP_EXT_IN'}=$new_tcp;
		        			
						#exit loop;
						$exit_add_port=1;
					}
				}
				else{
					`$DIALOG $DIALOG_BACKTITLE --title "Modify TCP Ports" --msgbox "Error: Ports are not valids" 5 40`;
				}
			}while($exit_add_port == 0);
			
}





#-------------------------------------------------
#  main_menu_allow_udp
#-------------------------------------------------


sub main_menu_allow_udp{

	$exit_save=1;
   	do{
		$menu_tcp = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "Allowed TCP Port(s)" 10 40 2 "1" "Views currents port(s)" "2" "Modify TCP port" `;
		
		# remember output
		# where is the 'break;' in perl ? 
		$exit_save=$?;

			
		
		# View currents ports
		if($menu_tcp == '1' && $exit_save==0){
			# there is no ports ?
			if($config_value{'TCP_EXT_IN'} == ""){
				 `$DIALOG $DIALOG_BACKTITLE --title "Allowed TCP Port(s)" --msgbox "none" 5 40`;
			}
			else{
			    # build list
			    $list_ports="";
			    $nb_ports=0;
			    @ports = split(/ /,$config_value{'TCP_EXT_IN'});
			    foreach $p (@ports){

				# Get the name of service
				$name_of_port = `cat $SERVICE_FILE |grep -e "	$p/tcp" -e " $p/tcp"`;
				$name_of_port =~ s/^([a-zA-Z0-9]+).*$/$1/g;
				$name_of_port =~ s/\n//g;

				
				if ($name_of_port !~ /^$/){
				    if($list_ports =~ /^$/){
					$list_ports="'$p' '($name_of_port)'";
				    }else{
					$list_ports="$list_ports '$p' '($name_of_port)'";
				    }
				}else{
				    if($list_ports =~ /^$/){
					$list_ports="'$p' '' ";
				    }else{
					$list_ports="$list_ports '$p' ''";
				    }
				}
				$nb_ports++;
			    }
			    #print $list_ports;
			    #exit;

			    if ($nb_ports > 12){
				$nb_ports=12;
			    }

			    `$DIALOG $DIALOG_BACKTITLE --title "Allowed TCP Port(s)" --menu "" 0 40 $nb_ports $list_ports`; 

			    
			}
		}


		# Modify new port
		if($menu_tcp == '2' && $exit_save==0 ){
			do{
				if($config_value{'TCP_EXT_IN'} == ""){
					$new_tcp = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify TCP port(s)" --inputbox "Write list separate with spaces" 8 40  `;
				}
				else{
					$new_tcp = `$DIALOG $DIALOG_BACKTITLE $DIALOG_TRIM --title "Modify TCP port(s)" --inputbox "Write list separate with spaces" 8 40 "$config_value{'TCP_EXT_IN'}" `;
				}

				$exit_add_port=$?;
				
                                $new_tcp =~ s/\n//g;
				$new_tcp =~ s/ +/ /g;
				$new_tcp =~ s/ $//g;
				 $new_tcp =~ s/^ //g;


				if($new_tcp =~ /^([0-9]+(:[0-9]+)? ?)*$/ ){
					# if no CANCEL presed
				        if($? == 0){
			        	        # save
			                	$config_value{'TCP_EXT_IN'}=$new_tcp;
		        			
						#exit loop;
						$exit_add_port=1;
					}
				}
				else{
					`$DIALOG $DIALOG_BACKTITLE --title "Modify TCP Ports" --msgbox "Error: Ports are not valids" 5 40`;
				}
			}while($exit_add_port == 0);
		}
		
   	}while($exit_save == 0);
}



#-------------------------------------------------
#  main_menu_forward_tcp
#-------------------------------------------------


sub main_menu_forward_tcp{
    
    $exit_save=1;
    do{
	
	$menu_fwd_tcp = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "Forwarding TCP Port(s)" 10 40 3 "1" "Views TCP forward(s) rule(s)" "2" "Add TCP forward rule" "3" "Delete TCP forward(s) rule(s)" `;
	
	# remember output
	# where is the 'break;' in perl ?
	$exit_save=$?;
	
	
#  --checklist    <text> <height> <width> <list height> <tag1> <item1> <status1>...
	
	
	# Delete rules
	###############
	if($menu_fwd_tcp == '3' && $exit_save==0){
	    
	    
	    # if we have tcp forward rules
	    if($config_value{'TCP_FORWARD'} !~ /^$/){
		
		# create items list
		@forward_array = split (/ |\n/,$config_value{'TCP_FORWARD'});
		$i=0;
		$item="";
		foreach $fwd (@forward_array){
		    $i++;
		    $item="$item '$fwd' '' 'off' ";
		}
		
		$forward_tcp = `$DIALOG $DIALOG_BACKTITLE $DIALOG_OK_LABEL_DELETE $DIALOG_CANCEL_LABEL_BACK --checklist "Delete TCP Forward(s) rule(s)" 15 40 $i $item `;
		
		
		
		# if no CANCEL presed
		if($? == 0 && $forward_tcp !~ /^$/){
		    
		    `$DIALOG $DIALOG_BACKTITLE --title "Add TCP Forward Port(s)" --yesno "Are you sur to want to delete ?" 5 40`;
		    
		    # Sur ?
		    if($? == 0){
			
			# for each checked rules
			$forward_tcp =~ s/\"|\n//g;
			$forward_tcp =~ s/ +/ /g;
			
			@rules = split(/ /,$forward_tcp);
			foreach $fwd (@rules){
			    
			    #print LOG_FILE $fwd;
			    
			    $config_value{'TCP_FORWARD'} =~ s/$fwd// ;
			}
			$config_value{'TCP_FORWARD'} =~ s/ $// ;
			$config_value{'TCP_FORWARD'} =~ s/^ // ;
			$config_value{'TCP_FORWARD'} =~ s/ +/ /g;
		    }
		    
		}
	    }
	    else{
		$forward_tcp = `$DIALOG $DIALOG_BACKTITLE --title "Delete TCP Forward(s) rule(s)" --msgbox "Nothing to delete" 10 40 `;
	    }
	}
	
	# View currents forward
	######################
	if($menu_fwd_tcp == '1' && $exit_save==0){
	    # there is no ports ?
	    if($config_value{'TCP_FORWARD'} =~ /^$/){
		`$DIALOG $DIALOG_BACKTITLE --title "TCP Forwarded Port(s)" --msgbox "none" 5 40`;
	    }
	    else{
		
		
		# create items list
		@forward_array = split (/ +/,$config_value{'TCP_FORWARD'});
		$i=0;
		$items="Iface(s)      >      Port(s)      >      Destination\n";
		foreach $fwd (@forward_array){
		    
		    ($ifaces,$port,$dst) = split(/>/,$fwd);
		    
		    if ($dst =~ /^$/){
			$item="$items\nUPDATE THIS RULE:$ifaces    >    $port";
		    }
		    else{
			$items="$items\n$ifaces      >      $port      >      $dst";	
		    }
		}
		
		`$DIALOG $DIALOG_BACKTITLE --title "TCP Forwarded Port(s)" --msgbox "$items" 20 60`;
	    }
	}
	
	# Add new forward
	#################
	$new_fwd="";
	if($menu_fwd_tcp == '2' && $exit_save==0){
	    do{
		
		# input: interface 
		#-------------------
		$new_fwd1 =  select_a_interface ('Add a TCP forward rule (1 of 4)','From wich interface would you like to forward ?');
		$exit_add_fwd = $?;
		
#			print $new_fwd1;
		if($exit_add_fwd == 0){
		    
		    $new_fwd1 =~ s/ +/ /g;
		    $new_fwd1 =~ s/^ //g;
		    $new_fwd1 =~ s/ $//g;
		    $new_fwd1 =~ s/ /,/g;
		    
		    
		    # input: port to forward
		    #-----------------------
		    $new_fwd2 = `$DIALOG $DIALOG_BACKTITLE --title "Add a TCP forward rule (2 of 4)" --inputbox "Enter port(s) to forward\nExample: 21 or 2020:2030" 10 50 `;				
		    # remember output
		    $exit_add_fwd=$?;
		    
		    # no cancel
		    if($exit_add_fwd == 0){
			# input: ip destination
			#------------------------
			$new_fwd3 = `$DIALOG $DIALOG_BACKTITLE --title "Add a TCP forward rule (3 of 4)" --inputbox "Enter destination host\nExample: 192.168.4.3" 10 50 `;
			$exit_add_fwd=$?;
			
			# no cancel
			if($exit_add_fwd == 0){
			    # input : modified destination port
			    #----------------------------------
			    $new_fwd4 = `$DIALOG $DIALOG_BACKTITLE --title "Add a TCP forward rule (4 of 4)" --inputbox "Modify destination port (optional)\nExample: 21 or 3020:3030" 10 50 `;
			    $exit_add_fwd=$?;
			    
			    # keep iptable syntax
			    $new_fwd4 =~ s/:/-/g;
			    
			}
		    }
		    
		    
			
		    
		    # if no CANCEL presed
		    if($exit_add_fwd == 0){
			
			$new_fwd = "$new_fwd1 $new_fwd2 $new_fwd3 $new_fwd4";
			
			#print $new_fwd;
			#exit;
			    
			# format
			$new_fwd =~ s/\n|\"//g;
			if($new_fwd =~ /^(.+) (.+) (.+) (.+)$/){
			    # new port was given
			    $new_fwd =~ s/^(.*) (.*) (.*) (.*)$/$1>$2>$3:$4/g;
			}
			else {
			    if($new_fwd =~ /^(.+) (.+) (.+) $/){
				$new_fwd =~ s/^(.*) (.*) (.*) .*$/$1>$2>$3/g;
			    }
			}
			
			    
			#print $new_fwd;
			#exit;
			
			# Test rule
			if($new_fwd !~ /^[a-zA-Z0-9,]+>[0-9]+(:[0-9]+)?>[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]+(-[0-9]+)?)?$/){
			    `$DIALOG $DIALOG_BACKTITLE --title "Add TCP Forward Port(s)" --msgbox "Error in forward syntax" 5 40`;
			    }
			else{
			    
			    if($config_value{'TCP_FORWARD'} !~ /^$/){
				$config_value{'TCP_FORWARD'}="$config_value{'TCP_FORWARD'} $new_fwd";
			    }
			    else{
				$config_value{'TCP_FORWARD'}="$new_fwd";
			    }
			    #print LOG_FILE $config_value{'TCP_FORWARD'};
			    $exit_add_fwd=1;
			}
		    }
		}
	    }while($exit_add_fwd == 0);
	}
	
    }while($exit_save == 0);
}	


#-------------------------------------------------
#  main_menu_forward_udp
#-------------------------------------------------


sub main_menu_forward_udp{
    
    ################################
    # FORWARDING UDP PORTS        #
    ################################
    if($menu == '6'){
	$exit_save=1;
	do{
	    
	    $menu_fwd_udp = `$DIALOG $DIALOG_BACKTITLE $DIALOG_CANCEL_LABEL_BACK --menu "Forwarding UDP Port(s)" 10 40 3 "1" "Views UDP forward(s) rule(s)" "2" "Add UDP forward rule" "3" "Delete UDP forward(s) rule(s)" `;
	    
	    # remember output
	    # where is the 'break;' in perl ?
	    $exit_save=$?;
	    
	    
#  --checklist    <text> <height> <width> <list height> <tag1> <item1> <status1>...
	    
	    
	    # Delete rules
	    ###############
	    if($menu_fwd_udp == '3' && $exit_save==0){
		
		
		# if we have udp forward rules
		if($config_value{'UDP_FORWARD'} !~ /^$/){
		    
		    # create items list
		    @forward_array = split (/ |\n/,$config_value{'UDP_FORWARD'});
		    $i=0;
		    $item="";
		    foreach $fwd (@forward_array){
			$i++;
			$item="$item '$fwd' '' 'off' ";
		    }
		    
		    $forward_udp = `$DIALOG $DIALOG_BACKTITLE $DIALOG_OK_LABEL_DELETE $DIALOG_CANCEL_LABEL_BACK --checklist "Delete UDP Forward(s) rule(s)" 15 40 $i $item `;
		    
		    # if no CANCEL presed
		    if($? == 0  && $forward_udp !~ /^$/){
			
			`$DIALOG $DIALOG_BACKTITLE --title "Delete UDP Forward Port(s)" --yesno "Are you sur to want to delete ?" 5 40`;
			
			# Sur ?
			if($? == 0){
			    
			    # for each checked rules
			    $forward_udp =~ s/\"|\n//g;
			    $forward_udp =~ s/ +/ /g;
			    
			    @rules = split(/ /,$forward_udp);
			    foreach $fwd (@rules){
				$config_value{'UDP_FORWARD'} =~ s/$fwd// ;
			    }
			    $config_value{'UDP_FORWARD'} =~ s/ $// ;
			    $config_value{'UDP_FORWARD'} =~ s/^ // ;
			    $config_value{'UDP_FORWARD'} =~ s/ +/ /g;
			}
			
		    }
		    
		}
		else{
		    $forward_udp = `$DIALOG $DIALOG_BACKTITLE --title "Delete UDP Forward(s) rule(s)" --msgbox "Nothing to delete" 10 40 `;
		}
	    }
	    
	    
	    # View currents forward
	    ######################
	    if($menu_fwd_udp == '1' && $exit_save==0){
		# there is no ports ?
		if($config_value{'UDP_FORWARD'} =~ /^$/){
		    `$DIALOG $DIALOG_BACKTITLE --title "UDP Forwarded Port(s)" --msgbox "none" 5 40`;
		}
		else{
		    
		    # create items list
		    @forward_array = split (/ +/,$config_value{'UDP_FORWARD'});
		    $i=0;
		    
		    $items="Iface(s)      >      Port(s)      >      Destination\n";
		    foreach $fwd (@forward_array){
			
			
			($ifaces,$port,$dst) = split(/>/,$fwd);
			
			$items="$items\n$ifaces      >       $port      >      $dst";
			
		    }
		    
		    `$DIALOG $DIALOG_BACKTITLE --tab-correct --tab-len 10 --title "UDP Forwarded Port(s)" --msgbox "$items" 20 60`;
		}
	    }
	    
	    
	    
	    # Add new forward
	    #################
	    $new_fwd="";
	    if($menu_fwd_udp == '2' && $exit_save==0){
		do{
		    
		    
		    $new_fwd1 =  select_a_interface ('Add a UDP forward rule (1 of 4)','From wich interface would you like to forward ?');
		    $exit_add_fwd = $?;
		    
#			print $new_fwd1;
		    if($exit_add_fwd == 0){
			
			$new_fwd1 =~ s/ +/ /g;
			$new_fwd1 =~ s/^ //g;
			$new_fwd1 =~ s/ $//g;
			$new_fwd1 =~ s/ /,/g;
			
			
			
			# input: port to forward
			#-----------------------
			$new_fwd2 = `$DIALOG $DIALOG_BACKTITLE --title "Add a UDP forward rule (2 of 4)" --inputbox "Enter port(s) to forward\nExample: 21 or 2020:2030" 10 50 `;
			
			# remember output
			$exit_add_fwd=$?;
			
			# no cancel
			if($exit_add_fwd == 0){
			    # input: ip destination
			    #------------------------
			    $new_fwd3 = `$DIALOG $DIALOG_BACKTITLE --title "Add a UDP forward rule (3 of 4)" --inputbox "Enter destination host\nExample: 192.168.4.3" 10 50 `;
			    $exit_add_fwd=$?;
			    
			    # no cancel
			    if($exit_add_fwd == 0){
                        	# input : modified destination port
                                #----------------------------------
                                $new_fwd4 = `$DIALOG $DIALOG_BACKTITLE --title "Add a UDP forward rule (4 of 4)" --inputbox "Modify destination port (optional)\nExample: 21 or 3020:3030" 10 50 `;
                                $exit_add_fwd=$?;
				
				# keep iptable syntax  ()
				$new_fwd4 =~ s/:/-/g;
			    }
			}



			# if no CANCEL presed
			if($exit_add_fwd == 0){
			    
			    $new_fwd = "$new_fwd1 $new_fwd2 $new_fwd3 $new_fwd4";
			    
			    # format
			    $new_fwd =~ s/\n|\"//g;
			    if($new_fwd =~ /^(.+) (.+) (.+) (.+)$/){
				# new port was given
				$new_fwd =~ s/^(.*) (.*) (.*) (.*)$/$1>$2>$3:$4/g;
			    }else {
				if($new_fwd =~ /^(.+) (.+) (.+) $/){
				    $new_fwd =~ s/^(.*) (.*) (.*) .*$/$1>$2>$3/g;
				}
			    }

			    
			    
			    # Test rule
			    if($new_fwd !~ /^[a-zA-Z0-9,]+>[0-9]+(:[0-9]+)?>[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]+(-[0-9]+)?)?$/){
				`$DIALOG $DIALOG_BACKTITLE --title "Add UDP Forward Port(s)" --msgbox "Error in forward syntax" 5 40`;
			    }
			    else{
				
				if($config_value{'UDP_FORWARD'} !~ /^$/){
				    $config_value{'UDP_FORWARD'}="$config_value{'UDP_FORWARD'} $new_fwd";
				}
				else{
				    $config_value{'UDP_FORWARD'}="$new_fwd";
				}
				
				#exit
				$exit_add_fwd=1;
			    }
			}
		    }     
		}while($exit_add_fwd == 0);
		
	    }
        }while($exit_save == 0);
    }
    
}




















