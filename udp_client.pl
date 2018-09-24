#!/usr/bin/perl -w

use IO::Socket::INET;

# Flush after every write.
$| = 1;

my ($socket, $data);

# Create UPD Socket and bound to a peer address.
$socket = new IO::Socket::INET (
	PeerAddr 	=> '192.168.133.7:4021',
	Proto		=> 'udp',
	) or die "ERROR in Socket Creation : $!\n";

# Send operation.
$data = "data from client";
$socket->send($data);

# Read operation.
$data = <$socket>;
print "Data received from socket : $data\n";

$socket->close();

