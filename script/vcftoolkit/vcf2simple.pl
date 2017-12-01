#! /usr/bin/perl

my ($vcf, $output) = @ARGV;

open OT, "> $output" or die $!;

print OT "##fileformat=VCFv4.0\n";

#open VCF, "$vcf" or die $!;
&mkopen('VCF', $vcf, "<");
while(<VCF>){
    chomp;
    next if /^##/;
    print OT "$_\n" if /^#/;
    next if /^#/;
    my ($chr, $pos, $rs, $ref, $alt, $qua, $filter, $info, $format, @sample_infos) = (split /\t/);
    $chr =~ s/chr//;
    my $sample_info = (join "\t", @sample_infos);
    foreach my $allele (split /,/, $alt){
        print OT "chr$chr\t$pos\t$rs\t$ref\t$allele\t$qua\t$filter\tALT=$alt;$info\t$format\t$sample_info\n";
    }
}
close VCF;

sub mkopen {
    my ($fh,$file,$mode)=@_;
    if( $file =~ /\.gz$/ ){
        open $fh ,"gzip -dc $file |" or die "Cannot open input file $file" unless $mode =~ />/;
        open $fh ,"| gzip > $file" or die "Cannot open output file $file" if $mode eq '>';
        open $fh ,"| gzip >> $file" or die "Cannot open output file $file" if $mode eq '>>';
    }elsif( $file =~ /\.bz2$/ ){
        open $fh ,"bunzip2 -dc $file |" or die "Cannot open input file $file" unless $mode =~ />/;
        open $fh ,"| bzip2 > $file" or die "Cannot open output file $file" if mode eq '>';
        open $fh ,"| bzip2 >> $file" or die "Cannot open output file $file" if mode eq '>>';
    }else{
       open $fh, $file or die "Cannot open input file $file" unless $mode =~ />/;
        open $fh, "> $file" or die "Cannot open output file $file" if $mode eq '>';
        open $fh, ">> $file" or die "Cannot open output file $file" if $mode eq '>>';
    }
}
