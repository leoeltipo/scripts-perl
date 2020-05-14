#!/usr/bin/perl

# This script allows to decode the fields of
# ethernet frames. First use pcap_read.pl to
# dump the bytes for this script.

open(FD,"<","$ARGV[0]");
@lines = <FD>;

my $frame_started = 0;
my @data = ();
my @samples =();
foreach (@lines)
{
	chomp($_);

	# Wait until a new frame starts.
	if ($frame_started == 0)
	{
		# Start of frame.
		if ($_ =~ m/^Frame\s+Start/)
		{
			$frame_started = 1;
			@data = ();
		}
	}
	else
	{
		# Already inside a frame.
		# End of frame.
		if ($_ =~ m/^Frame\s+End/)
		{
			$frame_started = 0;
			
			# Decode frame.
			my @tmp = &decode_frame(@data);

			# Decode UDP data.
			@tmp = &decode_udp(@tmp);

			# Push data into output vector.
			push(@samples,@tmp);
		}
		else
		{
			# Normal bytes.
			push(@data,$_);
		}
	}
}

# Check results.
my $l = $#samples+1;
for ($i=0; $i<$l-1; $i++)
{
	$diff = $samples[$i+1] - $samples[$i];
	if ( $diff != 1 )
	{
		print "Difference not -1!!\n";
		print "$samples[$i]\n";
		print "$samples[$i+1]\n";
	}
}

sub decode_frame
{
	my @frame = @_;

	my @dest_mac	= @frame[0 .. 5];
	my @src_mac 	= @frame[6 .. 11];
	my @prot 		= @frame[12 .. 13];

	my @ip_opt 		= @frame[14 .. 25];
	my @ip_src 		= @frame[26 .. 29];
	my @ip_dst 		= @frame[30 .. 33];
	
	my @port_src	= @frame[34 .. 35];
	my @port_dst	= @frame[36 .. 37];
	my @udp_len		= @frame[38 .. 39];
	my @udp_cksum	= @frame[40 .. 41];
	my @data 		= @frame[42 .. $#frame];

	return @data;
}

sub decode_udp
{
	my @udp = @_;

	my $udp_id = hex($udp[0])*256 + hex($udp[1]);
	my @data = @udp[2 .. $#udp];

	my $len = $#data + 1;

	my $idx = 0;
	my @samples = ();
	# Data is 8 bytes long.
	for ($i=0; $i<$len/8; $i++)
	{
		$samples[$i] 	= hex($data[$i*8+0]) 
						+ hex($data[$i*8+1])*256
						+ hex($data[$i*8+2])*256*256
						+ hex($data[$i*8+3])*256*256*256
						+ hex($data[$i*8+4])*256*256*256*256
						+ hex($data[$i*8+5])*256*256*256*256*256
						+ hex($data[$i*8+6])*256*256*256*256*256*256
						+ hex($data[$i*8+7])*256*256*256*256*256*256*256;
	}

	return @samples;
}

