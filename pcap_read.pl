#!/usr/bin/perl

$cmd = "tshark -x -V -r " . $ARGV[0] . " > tmp";
system($cmd);

open(FD,"<","tmp");
@lines = <FD>;

my $frame_started = 0;
foreach (@lines)
{
	chomp($_);
	
	if ($_ =~ m/^\d{4}\s+(([0-9a-zA-Z]{2}\s){1,16})/)
	{
		if (!$frame_started)
		{
			print "Frame Start\n";
			$frame_started = 1;
		}
		@bytes = split /\s+/, $1;
		foreach (@bytes)
		{
			print "$_\n";
		}
	}

	if ($frame_started)
	{
		if ($_ =~ m/^$/)
		{
			print "Frame End\n";
			$frame_started = 0;
		}
	}
}

$cmd = "rm tmp";
system($cmd);

