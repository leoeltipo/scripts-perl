#!/usr/bin/perl -w

use IO::Socket::INET;

# Flush after every write.
$| = 1;

my ($socket, $client_data);
my ($peer_address, $peer_port);

# Create TCP Socket and bind it to a specific port.
$socket = new IO::Socket::INET (
	LocalHost	=> '127.0.0.1',
	#LocalHost	=> '192.168.133.101',
	LocalPort	=> '8888',
	Proto			=> 'tcp',
	Listen		=> 5,
	Reuse			=> 1,
	) or die "ERROR in Socket Creation : $!\n";

print "Server Waiting for client connection on port 8888\n";

while(1)
{
	# Wait for new client connection.
	$client_socket = $socket->accept();

	# Get the address and port.
	$peer_address 	= $client_socket->peerhost();
	$peer_port	= $client_socket->peerport();
	print "Accepted New Client Connection From : $peer_address, $peer_port\n";

	# Send message back to client.
	$data = "data from server\n";

	$client_socket->send($data);

	# Read data from the newly accepted client.
	$client_socket->recv($data,1024);
	print "Received from client : $data\n";

	# Close client socket.
	$client_socket->close();
}

# Close socket.
$socket->close();

