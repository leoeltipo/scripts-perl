#!/usr/bin/perl -w

use IO::Socket::INET;

# Flush every time.
$| = 1;

my ($socket, $received_data);
my ($peer_address, $peer_port);

# Create UPD Socket and bound to a specific port. There is 
# no need to provide LocalAddr explicitly.
$socket = new IO::Socket::INET (
	LocalPort 	=> 4131,
	Proto		=> 'udp',
	) or die "ERROR in Socket Creation : $!\n";

while(1)
{
	# Read data.
	$socket->recv($received_data, 1500);

	# Get the address and port.
	$peer_address 	= $socket->peerhost();
	$peer_port	= $socket->peerport();
	print "\n($peer_address, $peer_port) said : $received_data";

	## Send message back to client.
	#$data = "data from server\n";

	#$socket->send($data);

}

# Close socket.
$socket->close();

