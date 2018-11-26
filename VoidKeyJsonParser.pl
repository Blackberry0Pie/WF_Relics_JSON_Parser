#!/usr/bin/perl
#@file VoidKeyJsonParser.pl
#@author Shawn Shadrix
#Parses void Key info from raw_f.json
use strict;
use warnings;
use Math::Round;
use JSON::Parse ':all'; #'parse_json';  
use List::Util 'sum';
#use Data::Dump qw(dump); #for debuging
#use feature 'say'; # for debuging

#example dereferences--------------------------------
#dump(${$json}{'missionRewards'}{'Jupiter'}{'Io'}{'gameMode'});
#dump(${$json}{'missionRewards'}{'Jupiter'}{'Io'}{'isEvent'});
#dump(${$json}{'missionRewards'}{'Jupiter'}{'Io'}{'rewards'}{'A'}->[1]{'itemName'});
#dump(${$json}{'missionRewards'}{'Jupiter'}{'Io'}{'rewards'}{'A'}->[1]{'chance'});
#dump(${$json}{'missionRewards'}{'Jupiter'}{'Io'}{'rewards'}{'C'}->[5]{'itemName'});
#dump(${$json}{'missionRewards'}{'Jupiter'}{'Io'}{'rewards'}{'C'}->[5]{'chance'});
#end example dereferences-----------------------------

my $filename = "raw_f.json";
my $json = json_file_to_perl ($filename) or die "Could not open '$filename' $!\n";

open (OUTFILE,'>VoidKeyOut.txt') or die "Unable to access VoidKeyOut.txt";
my $buffer = "";
open my $fh, ">", \$buffer or die "$!\n";
select $fh;

my %litkeys;
my %meskeys;
my %neokeys;
my %axikeys;
my %missiontypes = (
    'Defense' => '1',
    'Interception' => '1',
    'Spy' => '1',
    'Infested Salvage' => '1',
    'Orokin Derelict Defense' => '1',
    'Orokin Derelict Survival' => '1',
    'Excavation' => '1',
    'Survival' => '1', #end old
    #'Exterminate' => '1',
    #'Capture' => '1',
    #'Sabotage' => '1',
    #'Mobile Defense' => '1',
);
my %missionnodes = (
    'Lith' => 'Defence L1',
    'Io' => 'Defence L2',
    'Kala-Azar' => 'Defence L3',
    'Gaia' => 'Intercept L1',
    'Callisto' => 'Intercept L2',
    'Xini' => 'Intercept L3',
    'Cambria' => 'Spy L1',
    'Laomedeia' => 'Spy L3',
    'Oestrus' => 'Infested Salvage',
    'Orokin Derelict Defense' => 'Orokin Derelict Defense',
    'Orokin Derelict Survival' => 'Orokin Derelict Survival',
    'Coba' => 'DS Defence',
    'Tikal' => 'Excavation L1',
    'Cholistan' => 'Excavation L2',
    'Hieracon' => 'Excavation L3',
    'V Prime' => 'Survival L1',
    'Stickney' => 'Survival L2',
    'Ophelia' => 'Survival L3',
    'Mot' => 'Survival L4',
    'Malva' => 'DS Surv L1',
    'Wahiba' => 'DS Surv L2',
    'Assur' => 'DS Surv L3',
    'Zabala' => 'DS Surv L4',
    #'Tanaris' => 'Void Defence L1',
    #'Teshub' => 'Void Extermination L1',
    #'Hepit' => 'Void Capture L1',
    #'Stribog' => 'Void Sabotage L2',
    #'Tiwaz' => 'Void Mobile Defence L2',
    #'Ani' => 'Void Survival L2',
    #'Belenus' => 'Void Defence L3',
    #'Oxomoco' => 'Void Exterminate L3',
    #'Ukko' => 'Void Capture L3',
    #'Mithra' => 'Void Interception L4',
    #'Marduk' => 'Void Sabotage L4',
    #'Aten' => 'Void Mobile Defence L4',
);
my %Alitkeys;
my %Blitkeys;
my %Clitkeys;
my %Ameskeys;
my %Bmeskeys;
my %Cmeskeys;
my %Aneokeys;
my %Bneokeys;
my %Cneokeys;
my %Aaxikeys;
my %Baxikeys;
my %Caxikeys;

#mathematical mode function. Example use: mode(@array)
sub mode {
    my %count;
    map{$count{$_}++}@_;
    my @sorted = sort { $count{$a} <=> $count{$b} } keys %count;
    return $sorted[-1];
}

#rolled up key check
sub parsekeys {
    if($_[0] =~ /Lith (..) Relic/){
        $litkeys{$1} = '1';
    }
    if($_[0] =~ /Meso (..) Relic/){
        $meskeys{$1} = '1';
    }
    if($_[0] =~ /Neo (..) Relic/){
        $neokeys{$1} = '1';
    }
    if($_[0] =~ /Axi (..) Relic/){
        $axikeys{$1} = '1';
    }
}

#populate key hashes with currently active keys
my $celestials = %$json{'missionRewards'};
while ((my $celestial, my $node) = each (%$celestials)) {
    while ((my $node, my $mission) = each (%$node)) {
        if(ref($mission->{'rewards'}) eq "HASH" && !($mission->{'isEvent'})) {
            while ((my $rotation, my $rotationarray) = each (%{$mission->{'rewards'}})) {
                foreach my $reward (@$rotationarray){
                    parsekeys($reward->{'itemName'});
                }
            }
        }
    }
}

#populate mission hashes
while ((my $celestial, my $node) = each (%$celestials)) {
    while ((my $nodeKey, my $mission) = each (%$node)) {
        $Alitkeys{$_} = 0 for keys %litkeys;
        $Blitkeys{$_} = 0 for keys %litkeys;
        $Clitkeys{$_} = 0 for keys %litkeys;
        
        $Ameskeys{$_} = 0 for keys %meskeys;
        $Bmeskeys{$_} = 0 for keys %meskeys;
        $Cmeskeys{$_} = 0 for keys %meskeys;
        
        $Aneokeys{$_} = 0 for keys %neokeys;
        $Bneokeys{$_} = 0 for keys %neokeys;
        $Cneokeys{$_} = 0 for keys %neokeys;
        
        $Aaxikeys{$_} = 0 for keys %axikeys;
        $Baxikeys{$_} = 0 for keys %axikeys;
        $Caxikeys{$_} = 0 for keys %axikeys;
        if(ref($mission->{'rewards'}) eq "HASH" && !($mission->{'isEvent'}) && $missionnodes{$nodeKey} && $missiontypes{$mission->{'gameMode'}}){
            print($missionnodes{$nodeKey} . ',');
            foreach my $rotation (${$mission}{'rewards'}){
                foreach my $reward (@{$rotation->{'A'}}){
                    if($reward->{'itemName'} =~ /Lith (..) Relic/){
                        $Alitkeys{$1} += $reward->{'chance'};
                    }
                    if($reward->{'itemName'} =~ /Meso (..) Relic/){
                        $Ameskeys{$1} += $reward->{'chance'};
                    }
                    if($reward->{'itemName'} =~ /Neo (..) Relic/){
                        $Aneokeys{$1} += $reward->{'chance'};
                    }
                    if($reward->{'itemName'} =~ /Axi (..) Relic/){
                        $Aaxikeys{$1} += $reward->{'chance'};
                    }
                }
                foreach my $reward (@{$rotation->{'B'}}){
                    if($reward->{'itemName'} =~ /Lith (..) Relic/){
                        $Blitkeys{$1} += $reward->{'chance'};
                    }
                    if($reward->{'itemName'} =~ /Meso (..) Relic/){
                        $Bmeskeys{$1} += $reward->{'chance'};
                    }
                    if($reward->{'itemName'} =~ /Neo (..) Relic/){
                        $Bneokeys{$1} += $reward->{'chance'};
                    }
                    if($reward->{'itemName'} =~ /Axi (..) Relic/){
                        $Baxikeys{$1} += $reward->{'chance'};
                    }
                }
                foreach my $reward (@{$rotation->{'C'}}){
                    if($reward->{'itemName'} =~ /Lith (..) Relic/){
                        $Clitkeys{$1} += $reward->{'chance'};
                    }
                    if($reward->{'itemName'} =~ /Meso (..) Relic/){
                        $Cmeskeys{$1} += $reward->{'chance'};
                    }
                    if($reward->{'itemName'} =~ /Neo (..) Relic/){
                        $Cneokeys{$1} += $reward->{'chance'};
                    }
                    if($reward->{'itemName'} =~ /Axi (..) Relic/){
                        $Caxikeys{$1} += $reward->{'chance'};
                    }
                }
                #print output
                my $Alitsum = sum values %Alitkeys;
                my $Amessum = sum values %Ameskeys;
                my $Aneosum = sum values %Aneokeys;
                my $Aaxisum = sum values %Aaxikeys;
                
                my $Blitsum = sum values %Blitkeys;
                my $Bmessum = sum values %Bmeskeys;
                my $Bneosum = sum values %Bneokeys;
                my $Baxisum = sum values %Baxikeys;
                
                my $Clitsum = sum values %Clitkeys;
                my $Cmessum = sum values %Cmeskeys;
                my $Cneosum = sum values %Cneokeys;
                my $Caxisum = sum values %Caxikeys;
                
                my $Alitsum50 = $Alitsum/50;
                my $Amessum50 = $Amessum/50;
                my $Aneosum50 = $Aneosum/50;
                my $Aaxisum50 = $Aaxisum/50;
                
                my $AABClitsum = $Alitsum50 + $Blitsum/100 + $Clitsum/100;
                my $AABCmessum = $Amessum50 + $Bmessum/100 + $Cmessum/100;
                my $AABCneosum = $Aneosum50 + $Bneosum/100 + $Cneosum/100;
                my $AABCaxisum = $Aaxisum50 + $Baxisum/100 + $Caxisum/100;
                
                if ($Alitsum > 0) { print nearest(0.1, $Alitsum) . "% Lith"; }
                if ($Amessum > 0) { print nearest(0.1, $Amessum) . "% Meso"; }
                if ($Aneosum > 0) { print nearest(0.1, $Aneosum) . "% Neo"; }
                if ($Aaxisum > 0) { print nearest(0.1, $Aaxisum) . "% Axi"; }
                print ',';
                if ($Blitsum > 0) { print nearest(0.1, $Blitsum) . "% Lith"; }
                if ($Bmessum > 0) { print nearest(0.1, $Bmessum) . "% Meso"; }
                if ($Bneosum > 0) { print nearest(0.1, $Bneosum) . "% Neo"; }
                if ($Baxisum > 0) { print nearest(0.1, $Baxisum) . "% Axi"; }
                print ',';
                if ($Clitsum > 0) { print nearest(0.1, $Clitsum) . "% Lith"; }
                if ($Cmessum > 0) { print nearest(0.1, $Cmessum) . "% Meso"; }
                if ($Cneosum > 0) { print nearest(0.1, $Cneosum) . "% Neo"; }
                if ($Caxisum > 0) { print nearest(0.1, $Caxisum) . "% Axi"; }
                print ',';
                if ($Alitsum50 > 0) { print nearest(0.01, $Alitsum50); }
                print ',';
                if ($Amessum50 > 0) { print nearest(0.01, $Amessum50); }
                print ',';
                if ($Aneosum50 > 0) { print nearest(0.01, $Aneosum50); }
                print ',';
                if ($Aaxisum50 > 0) { print nearest(0.01, $Aaxisum50); }
                print ',';
                if ($AABClitsum > 0) { print nearest(0.01, $AABClitsum); }
                print ',';
                if ($AABCmessum > 0) { print nearest(0.01, $AABCmessum); }
                print ',';
                if ($AABCneosum > 0) { print nearest(0.01, $AABCneosum); }
                print ',';
                if ($AABCaxisum > 0) { print nearest(0.01, $AABCaxisum); }
                print ',';
                #PRINT KEY ROTATIONS
                print '+,';
                foreach my $relic (sort keys %Alitkeys){
                    if ($Alitkeys{$relic} > 0) {
                        print 'A';
                        my $mode = mode(values %Alitkeys);
                        if ($mode > 0 && abs($Alitkeys{$relic} - $mode) > 0.1) { print '(' . nearest(0.1, $Alitkeys{$relic}/$mode) . 'x)'; }
                    }
                    # added c check for printing '/'
                    if ($Alitkeys{$relic} > 0 && ($Blitkeys{$relic} > 0 || $Clitkeys{$relic} > 0)) { print '/'; }
                    if ($Blitkeys{$relic} > 0) {
                        print 'B';
                        my $mode = mode(values %Blitkeys);
                        if ($mode > 0 && abs($Blitkeys{$relic} - $mode) > 0.1) { print '(' . nearest(0.1, $Blitkeys{$relic}/$mode) . 'x)'; }
                    }
                    # added a check for printing '/'
                    if (($Alitkeys{$relic} > 0 || $Blitkeys{$relic} > 0) && $Clitkeys{$relic} > 0) { print '/'; }
                    if ($Clitkeys{$relic} > 0) {
                        print 'C';
                        my $mode = mode(values %Clitkeys);
                        if ($mode > 0 && abs($Clitkeys{$relic} - $mode) > 0.1) { print '(' . nearest(0.1, $Clitkeys{$relic}/$mode) . 'x)'; }
                    }
                    print ',';
                }
                print '+,';
                foreach my $relic (sort keys %Ameskeys){
                    if ($Ameskeys{$relic} > 0) {
                        print 'A';
                        my $mode = mode(values %Ameskeys);
                        if ($mode > 0 && abs($Ameskeys{$relic} - $mode) > 0.1) { print '(' . nearest(0.1, $Ameskeys{$relic}/$mode) . 'x)'; }
                    }
                    # added c check for printing '/'
                    if ($Ameskeys{$relic} > 0 && ($Bmeskeys{$relic} > 0 || $Cmeskeys{$relic} > 0)) { print '/'; }
                    if ($Bmeskeys{$relic} > 0) {
                        print 'B';
                        my $mode = mode(values %Bmeskeys);
                        if ($mode > 0 && abs($Bmeskeys{$relic} - $mode) > 0.1) { print '(' . nearest(0.1, $Bmeskeys{$relic}/$mode) . 'x)'; }
                    }
                    # added a check for printing '/'
                    if (($Ameskeys{$relic} > 0 || $Bmeskeys{$relic} > 0) && $Cmeskeys{$relic} > 0) { print '/'; }
                    if ($Cmeskeys{$relic} > 0) {
                        print 'C';
                        my $mode = mode(values %Cmeskeys);
                        if ($mode > 0 && abs($Cmeskeys{$relic} - $mode) > 0.1) { print '(' . nearest(0.1, $Cmeskeys{$relic}/$mode) . 'x)'; }
                    }
                    print ',';
                }
                print '+,';
                foreach my $relic (sort keys %Aneokeys){
                    if ($Aneokeys{$relic} > 0) {
                        print 'A';
                        my $mode = mode(values %Aneokeys);
                        if ($mode > 0 && abs($Aneokeys{$relic} - $mode) > 0.1) { print '(' . nearest(0.1, $Aneokeys{$relic}/$mode) . 'x)'; }
                    }
                    # added c check for printing '/'
                    if ($Aneokeys{$relic} > 0 && ($Bneokeys{$relic} > 0 || $Cneokeys{$relic} > 0)) { print '/'; }
                    if ($Bneokeys{$relic} > 0) {
                        print 'B';
                        my $mode = mode(values %Bneokeys);
                        if ($mode > 0 && abs($Bneokeys{$relic} - $mode) > 0.1) { print '(' . nearest(0.1, $Bneokeys{$relic}/$mode) . 'x)'; }
                    }
                    # added a check for printing '/'
                    if (($Aneokeys{$relic} > 0 || $Bneokeys{$relic} > 0) && $Cneokeys{$relic} > 0) { print '/'; }
                    if ($Cneokeys{$relic} > 0) {
                        print 'C';
                        my $mode = mode(values %Cneokeys);
                        if ($mode > 0 && abs($Cneokeys{$relic} - $mode) > 0.1) { print '(' . nearest(0.1, $Cneokeys{$relic}/$mode) . 'x)'; }
                    }
                    print ',';
                }
                print '+,';
                foreach my $relic (sort keys %Aaxikeys){
                    if ($Aaxikeys{$relic} > 0) {
                        print 'A';
                        my $mode = mode(values %Aaxikeys);
                        if ($mode > 0 && abs($Aaxikeys{$relic} - $mode) > 0.1) { print '(' . nearest(0.1, $Aaxikeys{$relic}/$mode) . 'x)'; }
                    }
                    # added c check for printing '/'
                    if ($Aaxikeys{$relic} > 0 && ($Baxikeys{$relic} > 0 || $Caxikeys{$relic} > 0)) { print '/'; }
                    if ($Baxikeys{$relic} > 0) {
                        print 'B';
                        my $mode = mode(values %Baxikeys);
                        if ($mode > 0 && abs($Baxikeys{$relic} - $mode) > 0.1) { print '(' . nearest(0.1, $Baxikeys{$relic}/$mode) . 'x)'; }
                    }
                    # added a check for printing '/'
                    if (($Aaxikeys{$relic} > 0 || $Baxikeys{$relic} > 0) && $Caxikeys{$relic} > 0) { print '/'; }
                    if ($Caxikeys{$relic} > 0) {
                        print 'C';
                        my $mode = mode(values %Caxikeys);
                        if ($mode > 0 && abs($Caxikeys{$relic} - $mode) > 0.1) { print '(' . nearest(0.1, $Caxikeys{$relic}/$mode) . 'x)'; }
                    }
                    print ',';
                }
                print "\n";
                last;
            }
        }
    }
}

#write legend
select OUTFILE;
print "Mission,A,B,C,AAL,AAM,AAN,AAA,CL,CM,CN,CA,0,";
foreach my $relic (sort keys %litkeys){
    print $relic . ",";
}
print "0,";
foreach my $relic (sort keys %meskeys){
    print $relic . ",";
}
print "0,";
foreach my $relic (sort keys %neokeys){
    print $relic . ",";
}
print "0,";
foreach my $relic (sort keys %axikeys){
    print $relic . ",";
}
print "\n";

#sort buffer and write to file
my @lines = split "\n", $buffer;
@lines = map { # Get original line back
    $_->[0]
} sort { # Compare first fields
    $a->[0] cmp $b->[0]
} map { # Turn each line into [original line, second field]
    [ $_, (split " ", $_)[1] ]
} @lines;
foreach my $line (@lines){
    print "$line \n";
}

close (OUTFILE);
exit;
