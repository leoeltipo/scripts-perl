#!/usr/bin/perl

use IO::Socket::INET;

# Flush after every write.
$| = 1;

my ($socket, $data);

# Create UPD Socket and bound to a peer address.
$socket = new IO::Socket::INET (
	PeerAddr 	=> '192.168.133.107:2001',
	Proto		=> 'udp',
	) or die "ERROR in Socket Creation : $!\n";

# Set receive timeout.
$socket->setsockopt(SOL_SOCKET, SO_RCVTIMEO, pack('l!l!', 1, 0)) or die "setsockopt $!";

## Burst Destination IP.
$rw = 1;
$nw = 1;
$addr_low = 0x6;
$addr_high = 1;
$ip0 = 100;
$ip1 = 133;
$ip2 = 168;
$ip3 = 192;
$dummy = 0;

# Send operation.
$data = pack("C2 L2 C4 L",$rw,$nw,$addr_low,$addr_high,$ip0,$ip1,$ip2,$ip3,$dummy);
$socket->send($data);

## Burst Destination MAC.
$rw = 1;
$nw = 1;
$addr_low = 0x7;
$addr_high = 1;
$mac0 = 0x43;
$mac1 = 0x15;
$mac2 = 0x96;
$mac3 = 0x27;
$mac4 = 0x00;
$mac5 = 0x08;

# Send operation.
$data = pack("C2 L2 C6",$rw,$nw,$addr_low,$addr_high,$mac0,$mac1,$mac2,$mac3,$mac4,$mac5);
$socket->send($data);

## Burst Destination Port.
$rw = 1;
$nw = 1;
$addr_low = 0x8;
$addr_high = 1;
$port0 = 0xCE;
$port1 = 0x56;

# Send operation.
$data = pack("C2 L2 C2",$rw,$nw,$addr_low,$addr_high,$port0,$port1);
$socket->send($data);

## 1-byte packet for configuring burst mode.
$val = 2;

# Send operation.
$data = pack("C",$val);
$socket->send($data);

# Enable burst mode.
$rw = 1;
$nw = 1;
$addr_low = 0x9;
$addr_high = 1;
$data = 1;

# Send operation.
$data = pack("C2 L2 Q",$rw,$nw,$addr_low,$addr_high,$data);
$socket->send($data);

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
