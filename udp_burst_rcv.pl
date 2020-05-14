#!/usr/bin/perl -w

use IO::Socket::INET;

# Flush every time.
$| = 1;

my ($socket, $received_data);
my ($peer_address, $peer_port);

# Create UPD Socket and bound to a specific port. There is 
# no need to provide LocalAddr explicitly.
$socket = new IO::Socket::INET (
	LocalPort 	=> 22222,
	Proto		=> 'udp',
	) or die "ERROR in Socket Creation : $!\n";

my $id_last = 0;
while(1)
{
	# Read data.
	$socket->recv($received_data, 1500);

	# Get the address and port.
	$peer_address 	= $socket->peerhost();
	$peer_port	= $socket->peerport();
	($pkt_type,$id,@data) = unpack("C2 C*", $received_data);
	#print "$peer_address:$peer_port -> Type = $pkt_type, ID = $id\n";
	#print "@data\n";

	# Check id.
	if ( ($id-$id_last) != 1 )
	{
		print "Packet lost: Last = $id_last, Actual = $id\n";
	}
	$id_last = $id;	
}

# Close socket.
$socket->close();

