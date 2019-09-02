#!/usr/bin/perl

use IO::Socket::INET;

# Flush after every write.
$| = 1;

my ($socket, $data);

# Create UPD Socket and bound to a peer address.
$socket = new IO::Socket::INET (
	PeerAddr 	=> '192.168.133.7:2001',
	Proto		=> 'udp',
	) or die "ERROR in Socket Creation : $!\n";

# Set receive timeout.
$socket->setsockopt(SOL_SOCKET, SO_RCVTIMEO, pack('l!l!', 1, 0)) or die "setsockopt $!";


###############################
### Read state of the board ###
###############################

# Send operation.
#$data = pack("C2 L2 C4 L",$rw,$nw,$addr_low,$addr_high,$ip0,$ip1,$ip2,$ip3,$dummy);
$data = "hola";
$socket->send($data);

