#!/usr/bin/env perl


use utf8;
use Encode qw(encode decode);
use feature 'say';
use locale;
use Switch;

use constant PI    => 4 * atan2(1, 1);

# Enables various levels of output.
our $verbose=1;
our $debug=0;


# This section locates the output data of interest in a
# psdlab output file.
if (!${^UTF8LOCALE}) {
    say encode($charset,"You are not using UTF-8 encoding. :(");
}
my $charset=$ENV{LANG};
our $outputfilename=decode($charset,$ARGV[0]);
open $outputfile,'<',$outputfilename or die $!;

my $star_linenum_1=0;
my $star_linenum_2=0;
my $star_bytenum_1=0;
my $star_bytenum_2=0;

my $linenum=0;
while(<$outputfile>) {
    $linenum++;
    if ($_ =~ /^\*+$/) {
        $star_linenum_1=$star_linenum_2;
        $star_linenum_2 = $linenum;
        $star_bytenum_1=$star_bytenum_2;
        #$star_bytenum_2 = $outputfile.tell();
        $star_bytenum_2 = tell($outputfile);
    }
}
if ($debug) {
    say encode($charset,"Final set found between lines "),
        $star_linenum_1,
        " and ",
        $star_linenum_2;

    say encode($charset,"Final set found between bytes "),
        $star_bytenum_1,
        " and ",
        $star_bytenum_2;
}
seek($outputfile,$star_bytenum_1,0);
<$outputfile>;
$bin_bounds_line = <$outputfile>;
#say $bin_bounds_line;
$bin_bounds_line =~ s/^#\s*(.*)$/$1/;
#$line =~ /
@bin_bounds = split /\s/,$bin_bounds_line;
if ($debug) {
    print encode($charset,"Found bin boundaries: ");
    foreach (@bin_bounds) {print encode($charset,"$_ ");}
    say encode($charset," ");
}



# This captures the frequency bins.
our %function_bin = ();

my $upper_bound = 0;
my $lower_bound = 0;
foreach (@bin_bounds) {
    $lower_bound = $upper_bound;
    $upper_bound = $_;
    if ($lower_bound == 0) {next}
    my $μ = ($upper_bound + $lower_bound)/2;
    my $Δ = ($upper_bound - $lower_bound)/2;
    #say ($μ,":",$Δ);
    # push(@freq_coords_mean,$μ);
    # push(@freq_coords_err,$Δ);
    $function_bin{$μ} = {"Δ" => $Δ};
}

$numbins = keys %function_bin;
say encode($charset,"$numbins frequency bins captured in output.");

if($verbose) {
    say encode($charset,"freq μ        freq σ");
    while (each %function_bin ) {
        say encode($charset,
            sprintf("%f      %f",$_,$function_bin{$_}{"Δ"}));
    }
}




=pod

    This section collects the various quantities. The mode counter
increments to designate the data being captured.

=cut

if ($verbose) {
    say encode($charset,"");
    say encode($charset,
        "           New Curve -- Reference Curve PSD");
    say encode($charset,
        "──────────────────────────────────────────────────");
}

foreach ( sort { $a <=> $b } keys %function_bin ) {
    my $μ = my $σ = <$outputfile>;
    $μ =~ s/^([\-\+e0-9\.]+)+\s+[\-\+e0-9\.]+\s*$/$1/;
    $σ =~ s/^[\-\+e0-9\.]+\s+([\-\+e0-9\.]+)\s*$/$1/;
#    if ($μ<0) {
#        $μ = abs($μ);
#        $function_bin{$_}{"φdiff_μ"} = PI;
#    }
    $function_bin{$_}{"ref_PSD_μ"} = $μ;
    $function_bin{$_}{"ref_PSD_σ"} = $σ;
    if ($verbose) {
        say encode($charset,
            "freq = " .
            sprintf('%.3f',$_) .
            ": μ = " .
            sprintf('%10.3e',$μ) .
            "; σ = " .
            sprintf('%10.3e',$σ));
    }
}

if ($verbose) {
    say encode($charset,"");
    say encode($charset,
        "          New Curve -- Reverberating Curve PSD");
    say encode($charset,
        "──────────────────────────────────────────────────");
}
foreach ( sort { $a <=> $b } keys %function_bin ) {
    my $μ = my $σ = <$outputfile>;
    $μ =~ s/^([\-\+e0-9\.]+)+\s+[\-\+e0-9\.]+\s*$/$1/;
    $σ =~ s/^[\-\+e0-9\.]+\s+([\-\+e0-9\.]+)\s*$/$1/;
#    if ($μ<0) {
#        $μ = abs($μ);
#        $function_bin{$_}{"φdiff_μ"} = PI;
#    }
    $function_bin{$_}{"echo_PSD_μ"} = $μ;
    $function_bin{$_}{"echo_PSD_σ"} = $σ;
    if ($verbose) {
        say encode($charset,
            "freq = " .
            sprintf('%.3f',$_) .
            ": μ = " .
            sprintf('%10.3e',$μ) .
            "; σ = " .
            sprintf('%10.3e',$σ));
    }
}


if ($verbose) {
    say encode($charset,"");
    say encode($charset,
        "          New Curve -- Cross Spectrum PSD");
    say encode($charset,
        "──────────────────────────────────────────────────");
}
foreach ( sort { $a <=> $b } keys %function_bin ) {
    my $μ = my $σ = <$outputfile>;
    $μ =~ s/^([\-\+e0-9\.]+)+\s+[\-\+e0-9\.]+\s*$/$1/;
    $σ =~ s/^[\-\+e0-9\.]+\s+([\-\+e0-9\.]+)\s*$/$1/;
#    if ($μ<0) {
#        $μ = abs($μ);
#        $function_bin{$_}{"φdiff_μ"} = PI;
#    }
    $function_bin{$_}{"crsspctrm_PSD_μ"} = $μ;
    $function_bin{$_}{"crsspctrm_PSD_σ"} = $σ;
    if ($verbose) {
        say encode($charset,
            "freq = " .
            sprintf('%.3f',$_) .
            ": μ = " .
            sprintf('%10.3e',$μ) .
            "; σ = " .
            sprintf('%10.3e',$σ));
    }
}

if ($verbose) {
    say encode($charset,"");
    say encode($charset,
        "         New Curve -- Phase Difference φ");
    say encode($charset,
        "──────────────────────────────────────────────────");
}
foreach ( sort { $a <=> $b } keys %function_bin ) {
    my $μ = my $σ = <$outputfile>;
    $μ =~ s/^([\-\+e0-9\.]+)+\s+[\-\+e0-9\.]+\s*$/$1/;
    $σ =~ s/^[\-\+e0-9\.]+\s+([\-\+e0-9\.]+)\s*$/$1/;
    if (exists $function_bin{$_}{"φdiff_μ"}) {
        $μ = $function_bin{$_}{"φdiff_μ"} + $μ;
    }
    $function_bin{$_}{"φdiff_μ"} = $μ;
    $function_bin{$_}{"φdiff_σ"} = $σ;
    if ($verbose) {
        say encode($charset,
            "freq = " .
            sprintf('%.3f',$_) .
            ": μ = " .
            sprintf('%10.3e',$μ) .
            "; σ = " .
            sprintf('%10.3e',$σ));
    }
    $μ = $μ/(2*PI*$_);
    $σ = $σ/(2*PI*$_);
    $function_bin{$_}{"timelag_μ"} = $μ;
    $function_bin{$_}{"timelag_σ"} = $σ;
    if ($verbose) {
        say encode($charset,
            "     timelag: μ = " .
            sprintf('%10.3e',$μ) .
            "; σ = " .
            sprintf('%10.3e',$σ)) .
            "\n";
    }
}

say encode($charset,"");

if($debug) {
    while (each %function_bin ) {
        print encode($charset,$_ . ": ");
        while ( my ($key,$value) = each %{$function_bin{$_}} ) {
            print encode($charset,$key . " => " . $value . ";  ");
        }
        say encode($charset,"");
    }
}

close($outputfile);

open($datafile,'>',"tmp.refPSD") or die $!;
while( each %function_bin) {
    say $datafile
        $_ . " " .
        $function_bin{$_}{"ref_PSD_μ"} . " " .
        $function_bin{$_}{"Δ"} . " " .
        $function_bin{$_}{"ref_PSD_σ"};
}
close($datafile);

open($datafile,'>',"tmp.echoPSD") or die $!;
while( each %function_bin) {
    say $datafile
        $_ . " " .
        $function_bin{$_}{"echo_PSD_μ"} . " " .
        $function_bin{$_}{"Δ"} . " " .
        $function_bin{$_}{"echo_PSD_σ"};
}
close($datafile);

open($datafile,'>',"tmp.crsspctrmPSD") or die $!;
while( each %function_bin) {
    say $datafile
        $_ . " " .
        $function_bin{$_}{"crsspctrm_PSD_μ"} . " " .
        $function_bin{$_}{"Δ"} . " " .
        $function_bin{$_}{"crsspctrm_PSD_σ"};
}
close($datafile);

open($datafile,'>',"tmp.timelag") or die $!;
while( each %function_bin) {
    say $datafile
        $_ . " " .
        $function_bin{$_}{"timelag_μ"} . " " .
        $function_bin{$_}{"Δ"} . " " .
        $function_bin{$_}{"timelag_σ"};
}
close($datafile);


#open($datafile,'>',"tmp.echoPSD") or die $!;
