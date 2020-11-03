#!/usr/bin/perl -w

# UCF template file.
my $base_name = "SLTA_Xilinx_Pinout";
my $csv_name = "$base_name.csv";
open(my $csv_file,  $csv_name)  or die "Could not open file '$csv_name' $!";
my @csv_lines = <$csv_file>;

%pins_h = ();
foreach my $line(@csv_lines) {
	$line =~ s/\r\n//g;
	# Pin Number, Pin name, Net, Type, Bank No., Bank Voltage
	if ($line =~ m/(.+?),(.+?),(.+?),(.+?),(.+?),(.+)/) {
		$pin = $1;
		$net = $3;
		$type = $4;
		$volt = $6;

		# Pin <-> net correspondance.
		$pins_h{$pin}{"net"} = $net;
		$pins_h{$pin}{"type"} = $type;

		# Volts.
		if ($volt eq "3.3V") {
			$pins_h{$pin}{"volts"} = "33";
		}
		elsif ($volt eq "2.5V" ) {
			$pins_h{$pin}{"volts"} = "25";
		}
		elsif ($volt eq "1.8V" ) {
			$pins_h{$pin}{"volts"} = "18";
		}
		elsif ($volt eq "1.0V" ) {
			$pins_h{$pin}{"volts"} = "10";
		}
		else {
			$pins_h{$pin}{"volts"} = $volt;
		}
		

	}
}

#@pins = keys %pins_h;
@pins = sort {$pins_h{$a} <=> $pins_h{$b}} keys %pins_h;
foreach my $pin (@pins) {

	# Get net.
	$net = $pins_h{$pin}{"net"};
	$type = $pins_h{$pin}{"type"};
	$volts = $pins_h{$pin}{"volts"};

	# Non-power nets only.
	if ($type ne "Power")
	{
		# Don't include GND and NC nets.
		if (($net ne "NC") and ($net ne "GND") )
		{
			# Replace \ in names (Not in Altium).
			if ($net =~ m/\\/) {
				$net =~ s/\\//g;
				$net = $net . "n";
			}

			# Print out.
			print "#set_property PACKAGE_PIN $pin [get_ports $net]\n";
			print "#set_property IOSTANDARD LVCMOS$volts [get_ports $net]\n";
		}
	}
}

