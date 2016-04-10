#!/usr/bin/expect

if {[llength $argv] == 0} {
	send_user "\nError: Incorrect usage of script\n\nDisplaying 'Help' section for correct usage ...\n"
	send_user "$ expect <script_name> <send/recv> <source_path> <destination_path> \[<file_name_pattern>\]\n\n"
	send_user "Note: <file_name_pattern> optional; wildcard characters (*) permitted\n"
	exit 1
}

set TRANSFER_CODE [lindex $argv 0]
set SRC_DIR [lindex $argv 1]
set DST_DIR [lindex $argv 2]
set FILE_NAME_PATTERN [lindex $argv 3]
send_user "\nAutomated SciNet SSH/SCP Connections Script\n"
send_user "Author: Abdullah Al Rashid\n"
send_user "Date Started: October 29, 2015\n"
send_user "Last Updated: October 29, 2015\n\n"
send_user "Status: Testing SSH connection for SciNet for user 'alrashid'\n\n"

stty -echo
send_user -- "alrashid@login.scinet.utoronto.ca's password:"
expect_user -re "(.*)\n"
send_user "\n\n"
set SCINET_PASSWORD $expect_out(1,string)

set timeout 5
spawn ssh -Y alrashid@login.scinet.utoronto.ca
expect "alrashid@login.scinet.utoronto.ca's password:" {
	send "$SCINET_PASSWORD\r"; 
	expect "alrashid@login.scinet.utoronto.ca's password:" {
		close; send_user "Error: Incorrect password\n\n"; exit 1
	};
}

send_user "SciNet Password validated\n\n"

if { [string equal $TRANSFER_CODE send] } {
	while { 1 } {
		spawn rsync -avzl -e ssh $SRC_DIR/$FILE_NAME_PATTERN alrashid@login.scinet.utoronto.ca:$DST_DIR;
		expect "alrashid@login.scinet.utoronto.ca's password:" {send "$SCINET_PASSWORD\r"}; 
		expect eof; catch wait result;
		set EXIT_CODE [lindex $result 3]
		if { $EXIT_CODE == 0} {
			send_user "Status: Transfer completed\n\n"; exit 0
		} elseif { $EXIT_CODE == 23 } {
			send_user "\nError: Invalid directory\n\n"; exit 1
		} else {
			send_user "Status: Transfer interrupted [exit code: $EXIT_CODE]; retrying in 20 seconds ...\n\n"; spawn sleep 20;
		}
	}

} elseif { [string equal $TRANSFER_CODE recv] } {
	while { 1 } {
		spawn rsync -avzl -e ssh  alrashid@login.scinet.utoronto.ca:$SRC_DIR/$FILE_NAME_PATTERN $DST_DIR;
		expect "alrashid@login.scinet.utoronto.ca's password:" {send "$SCINET_PASSWORD\r"};
		expect eof; catch wait result;
		set EXIT_CODE [lindex $result 3]
		if { $EXIT_CODE == 0} {
			send_user "\nInformation: Transfer completed\n\n"; exit 0
		} elseif { $EXIT_CODE == 23 } {
			send_user "\nError: Invalid directory\n\n"; exit 1
		} else {
			send_user "\nInformation: Transfer interrupted  [exit code: $EXIT_CODE]; retrying in 20 seconds ...\n\n"; spawn sleep 20	
		}
	}

} else	{
	send_user "\nError: Invalid transfer code '$TRANSFER_CODE'\n"
}
