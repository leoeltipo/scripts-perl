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

%state_h = ();

$state_h{0}{type} = "ip";
$state_h{0}{msg} = "Self IP (higher bytes)";

$state_h{1}{type} = "ip";
$state_h{1}{msg} = "Self IP/MAC (lower byte)";

$state_h{2}{type} = "mac";
$state_h{2}{msg} = "Self MAC (higher bytes)";

$state_h{3}{type} = "ip";
$state_h{3}{msg} = "TX Control Destination IP";

$state_h{4}{type} = "mac";
$state_h{4}{msg} = "TX Control Destination MAC";

$state_h{5}{type} = "port";
$state_h{5}{msg} = "TX Control Destination Port";

$state_h{6}{type} = "ip";
$state_h{6}{msg} = "TX Data Destination IP";

$state_h{7}{type} = "mac";
$state_h{7}{msg} = "TX Data Destination MAC";

$state_h{8}{type} = "port";
$state_h{8}{msg} = "TX Data Destination Port";

$state_h{9}{type} = "bit";
$state_h{9}{msg} = "Burst Mode";

$state_h{10}{type} = "bit";
$state_h{10}{msg} = "Control Dynamic MAC Resolution";

$state_h{11}{type} = "bit";
$state_h{11}{msg} = "Data Dynamic MAC Resolution";

@addrs = sort {$a <=> $b} keys %state_h;
#@addrs = (5,8);

&read_state(@addrs);

## Control Destination IP.
#$rw = 1;
#$nw = 1;
#$addr_low = 0x3;
#$addr_high = 1;
#$ip0 = 102;
#$ip1 = 133;
#$ip2 = 168;
#$ip3 = 192;
#$dummy = 0;
#
## Send operation.
#$data = pack("C2 L2 C4 L",$rw,$nw,$addr_low,$addr_high,$ip0,$ip1,$ip2,$ip3,$dummy);
#$socket->send($data);

## Control Destination Port.
#$rw = 1;
#$nw = 1;
#$addr_low = 0x5;
#$addr_high = 1;
#$port = 9999;
#$port0 = $port & 0xFF;
#$port1 = $port/256;
#$port2 = 0;
#$port3 = 0;
#$dummy = 0;
#
## Send operation.
#$data = pack("C2 L2 C4 L",$rw,$nw,$addr_low,$addr_high,$port0,$port1,$port2,$port3,$dummy);
#$socket->send($data);

## Control Dynamic MAC Resolution.
#$rw = 1;
#$nw = 1;
#$addr_low = 0xA;
#$addr_high = 1;
#$data = 1;
#
## Send operation.
#$data = pack("C2 L2 Q",$rw,$nw,$addr_low,$addr_high,$data);
#$socket->send($data);

## data dynamic mac resolution.
#$rw = 1;
#$nw = 1;
#$addr_low = 0xB;
#$addr_high = 1;
#$data = 1;
#
## Send operation.
#$data = pack("C2 L2 Q",$rw,$nw,$addr_low,$addr_high,$data);
#$socket->send($data);


#for ($i=0;$i<100;$i++) {
#	# Ask for data at address.
#	$rw = 0;
#	$nw = 1;
#	$addr_low = 0x1;
#	$addr_high = 1;
#	
#	# Send operation.
#	$data = pack("C2 L2",$rw,$nw,$addr_low,$addr_high);
#	$socket->send($data);
#	
#	# Read operation.
#	$socket->recv($data_recv, 1024);
#	($pkg_id_high, $pkg_id_low, $addr, $data) = unpack("C2 L2", $data_recv);
#	$pkg_id = $pkg_id_low + 256*$pkg_id_high;
#
#	print "id = $id, pkg_id = $pkg_id\n";
#
#	if ($pkg_id==0)
#	{
#		print "Packet Lost\n"
#	}
#	else
#	{
#		print "Packet ID = $pkg_id, Packet ADDR = $addr, Packet Data = $data\n";
#	}
#	
#}


## Multiple word write test.
#$rw = 1;
#$nw = 2;
#$addr_low = 0;
#$addr_high = 0;
#$data = 123456;
#
#$data = pack("C2 L2 Q Q", 
#			$rw, $nw, 
#			1, $addr_high, 1000, 2000);
##$data = pack("C2 L2 Q", 
##			$rw, $nw, 
##			$addr_low, $addr_high, $data);
#$socket->send($data);

$socket->close();

sub get_id {
	my $id1 = shift;
	my $id2 = shift;

	return $id2 + $id1*8;
}

sub get_ip {
	return join(".", reverse(@_[0..3]));
}

sub get_mac {
	my @vals = reverse(@_[0..5]);
	my @mac;
	foreach $val (@vals) {
		push(@mac,sprintf("%.2x",$val));
	}
	return join("::", @mac);
}

sub get_port {
	return $_[0] + $_[1]*256;
}

sub get_bit {
	return $_[0];
}

sub read_state {
	my @addrs = @_;

	foreach $addr (@addrs)
	{
		$rw = 0;
		$nw = 1;
		$addr_low = $addr;
		$addr_high = 1;
	
		# Send operation.
		$data = pack("C2 L2", $rw, $nw, $addr_low, $addr_high);
		$socket->send($data);
	
		sleep(1);
	
		# Receive data back.
		$socket->recv($buffer, 128);
	
		$type = $state_h{$addr}{type};
		$msg = $state_h{$addr}{msg};
	
		# Unpack buffer.
		($id1, $id2, @data) = unpack("C2 C*", $buffer);
		$id = &get_id($id1, $id2);
	
		if ($type eq "ip")
		{
			$val = &get_ip(@data);
		}
		elsif ($type eq "mac")
		{
			$val = &get_mac(@data);
	
		}
		elsif ($type eq "port")
		{
			$val = &get_port(@data);
		}
		elsif ($type eq "bit")
		{
			$val = &get_bit(@data);
		}
		else
		{
			$val = "Not a valid type";	
		}
	
		print "\@$addr: $msg\n";
		print "ID = $id\n";
		print "Value = $val\n";
		print "\n";
	
		sleep(1);
	}
}
