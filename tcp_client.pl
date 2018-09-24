#!/usr/bin/perl -w

use IO::Socket::INET;
use IO::Socket::Timeout;

# Flush after every write.
$| = 1;

my ($socket, $client_socket);

# Create TCP Socket, bind and connect to the TCP
# Server running on the specific port.
$socket = new IO::Socket::INET (
	PeerHost	=> '192.168.133.7',
	#PeerHost	=> '192.168.56.1',
	PeerPort	=> '4020',
	Proto			=> 'tcp',
	) or die "ERROR in Socket Creation : $!\n";

print "TCP Socket successfully created\n";

# Write data to server.
$data = "get led2";
$socket->send($data);

# Read data back from server.
$socket->recv($data,1024);
print "Data from server $data\n";

# Close socket.
$socket->close();

