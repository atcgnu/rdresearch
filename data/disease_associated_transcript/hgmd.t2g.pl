#! /usr/bin/perl

my ($hgmdt, $nm) = @ARGV;

my (%hts, %gt2);

open GT, "$nm" or die $!;
while(<GT>){
    chomp;
    my ($t, $g) = (split /\t/);
    $gts{$t} = $g;
}
close GT;
open HT, "$hgmdt" or die $!;
while(<HT>){
    my ($transcript) = (split /\t/);
    print "$gts{$transcript}\t$transcript\n" if $gts{$transcript};
    print ".\t$transcript\n" unless $gts{$transcript};
}
close HT;
