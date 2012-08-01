#!/usr/bin/perl

###########################################################
#                                                         #
#  Create a new spyware file for Jay's Iptables Firewall  #
#                                                         #
#  By Jerome Nokin <jerome@wallaby.be>                    #
#  http://firewall-jay.sourceforge.net                    #
#                                                         #
###########################################################


#-------------------------------------------------------------------#
#      USER CONFIG                                                  #
#-------------------------------------------------------------------#


require "/etc/firewall-jay/firewall-spy-update.config" or die "Cant open firewall-spy-update.config\n";

#-------------------------------------------------------------------#
#      CONFIG                                                       #
#-------------------------------------------------------------------#


$SOFT_NAME			= "firewall-update-spy.pl";
$SPY_UPDATE_VERSION		= "0.2";
$WGET				= `which wget`;
$DOS2UNIX			= `which dos2unix`;
$INITIAL_BLOCK_FILE_URL		= "http://www.geocities.com/yosponge/blockips.txt";
$TMP_FILE			= "/tmp/spy.tmp";
$OUTPUT_DIR			= "/var/lib/firewall-jay";
$OUTPUT_FILE_DEFAULT		= "block-ip-out.spywares";
$OUTPUT_FILE			= "";
$DATE  				= `date`;


@IP_TO_IGNORES_2  = ('224.0.0.0','10.0.0.0','172.16.0.0','192.0.0.0','169.254.0.0');
# these default ips are located in the initial blockips.txt file and must be added here !


$TOP				="\
#############################################################################
#                 !!!!!!!!! READ THIS BEFORE !!!!!!!!!!!                    #
#                                                                           #
# This file was formated for \"Jay's firewall\" (see README) but was written  #
# by Sponge  (http://www.geocities.com/yosponge/) <yosponge\@yahoo.com>      #
#                                                                           #
#############################################################################";





# Arguments
#------------
@MY_ARGUMENTS=(
        '-h',
        '--help',
        '-o',
        '--output');


#-------------------------------------------------------------------#
#                    FUNCTIONS                                      #
#-------------------------------------------------------------------#


sub display_help
{
        print("$SOFT_NAME Version $SPY_UPDATE_VERSION\n*Update the Spywares list for Jay's Iptables Firewall*\n\n");

        print("Usage:  $SOFT_NAME [-o|--output <filename>]\n");
        print("        $SOFT_NAME [-h|--help]\n\n");

        print("Options:\n");
        print("   --output    -o  <filename>  Save the new list to <filename>.\n");
	print("                               (default $OUTPUT_DIR/$OUTPUT_FILE_DEFAULT)\n");
        print("   --help      -h              Show this help.\n\n");
}



# SEARCH FOR A OTHER CONFIG FILE
sub search_o_argument{

        # search for '-o <filename>'
        $nb_arg=@ARGV;
        $new_location="";
        for ($i=0;$i<$nb_arg;$i++){
                if (@ARGV[$i] =~ /^-o|--output$/){
                        $new_location = @ARGV[$i+1];
                }
        }



        # default location of output file ?
        if($new_location =~ /^$/){
	        $OUTPUT_FILE = "$OUTPUT_DIR/$OUTPUT_FILE_DEFAULT";
        }else{
                $OUTPUT_FILE = "$new_location";
	}
}


# There is maybe some spy that we don't want to block
sub ignore_spy {

        my $desc = shift;
        my $tmp;

        # get desc in lowercase
        $desc = lc($desc);


        foreach $spy (@SPY_TO_IGNORES) {
                $tmp = lc($spy);
                if ($desc =~ /$tmp/ ){
			return 1;
                }
        }
	return 0;
}



sub read_arguments {

    $nb_arg= @ARGV;


    # ARG EXIST ?
    $count_arg=0;
    foreach $arg (@ARGV){

        # for all arguments given

        # if unknown AND not a -c argument part
        if(! grep(/$arg/,@MY_ARGUMENTS) && @ARGV[$count_arg-1] !~ /-o|--output/){
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

}





##################
# Pre-Begin      #
##################


# default location ?
search_o_argument;

# What must I do ?
read_arguments;





#-------------------------------------------------------------------#
#                  SOME  TESTS                                      #
#-------------------------------------------------------------------#



$WGET =~ s/\n//g;
$DOS2UNIX =~ s/\n//g;




# WGET ?
if (! -e $WGET){
        print "\n";
        print "Error: 'wget' was not found\n\n";
        exit 1;
}


# DOS2UNIX
if (! -e $DOS2UNIX){
        print "\n";
        print "Warning: 'dos2unix' was not found, please install it if you don't want to see ^M char in descriptions of spywares.\n";
        $DOS2UNIX="";
}else{
	#test it
	`touch /tmp/jay-dos2unix.test`;
	`$DOS2UNIX /tmp/jay-dos2unix.test 2>&1 1>/dev/null`;
	if($? != 0){
		print "dos2unix doesn't work correctly ...\n";
		$DOS2UNIX="";
	}

	`rm -f /tmp/jay-dos2unix.test`;
}


if (! -e $OUTPUT_DIR){
        print "\n\n";
        print "Error: '$OUTPUT_DIR' was not found (did you have Jay's firewall installed ?. please use --output for another location\n\n"
;
        exit 1;
}






# download file
print "\n -> Downloading initial spywares list\n";
`$WGET  -O $TMP_FILE $INITIAL_BLOCK_FILE_URL 2>&1 1>/dev/null`;

if($? != 0){
	print "\n";
	print "Error: Could not download '$INITIAL_BLOCK_FILE_URL' with wget.";
	print "\n\n";
	exit 1;
}

# open the downloaded file
if(open (TMP_FILE,'<',$TMP_FILE) == 0){
        print ("\nError: can't open '$TMP_FILE' for reading , wget problem ?\n\n");
        exit 1;
}

# open the output file
if(open (OUTPUT_FILE,'>',"$OUTPUT_FILE") == 0){
        print ("\nError: can't open '$OUTPUT_FILE' for writing, disk space problem ?\n\n");
        exit 1;
}



print OUTPUT_FILE "#   CREATED : $DATE\n";

print OUTPUT_FILE "$TOP\n\n";

############
# Parse    #
############


print "\n -> Formating list for Jay's Iptables Firewall\n";
while (<TMP_FILE>){

	# if line begin by a ip
	if (/^[0-9.]{7,}( |\t)+.+$/){

		$new_line = $_;

		

		# format to "ip/mask:description"
		if($new_line =~ /^([0-9.]{7,})(\t| )+([0-9.]{7,})(\t| )+(.*)$/){

			$new_line =~ s/^([0-9.]{7,})(\t| )+([0-9.]{7,})(\t| )+(.*)$/$1\/$3:$5/g;

		}elsif ($new_line =~ /^([0-9.]{7,})(\t| )+(.|\t)*$/){

			$new_line =~ s/^([0-9.]{7,})(\t| )+(.*)$/$1:$3/g;

		}
		#else{
		#		print "Bad line\n";
		#}



		# remove space and cut too much long descriptions
		if($new_line !~ /DELETE/){
        		($ip,$desc) = split(':',$new_line);
			if(!grep (/^$ip$/,@IP_TO_IGNORES) && !grep (/^$ip$/,@IP_TO_IGNORES_2)){
			
				# ignore this spy ? => we only need to comment it out
				my $spy_ign=0;
				if(ignore_spy($desc)){
					$spy_ign=1;
				}

        			$desc =~ s/ +|\t+/-/g;
        			$desc =~ s/\n|\(|\)//g;
        			$desc = substr($desc,0,23);
        			$desc =~ s/\n//g;
				

				if ($spy_ign){
					$new_line = "# $ip:$desc\n";
				}else{
					$new_line = "$ip:$desc\n";
				}			

				# write the new line to the output file
				print OUTPUT_FILE $new_line ;
			}
		}
	}
#	else{
		# the line isn't a ip, write it with a '#' at the begin
#		 print OUTPUT_FILE "# $_";
#	}

}             

# convert to unix
if($DOS2UNIX !~ /^$/){
	`$DOS2UNIX $OUTPUT_FILE 2>&1 1>/dev/null`;
}

print "\n -> Here is the new file \"$OUTPUT_FILE\"\n\n";




# delete tempory file
`rm -f $TMP_FILE`;
