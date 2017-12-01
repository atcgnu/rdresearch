#! /usr/bin/perl

my @vcfs = @ARGV;

my (%sites, %ss);
my $sample_id;

foreach my $vcf (@vcfs) {
#   open VCF, "$vcf" or die $!;
    &myopen('VCF', "$vcf", '<');

    while(<VCF>){
        chomp;
        next if /^##/;
        if(/^#/){
            $sample_id = (split /\t/)[-1];
            $ss{$sample_id} = 1;
#           push @ss, $sample_id;
        }
        next if /^#/;

        my ($chr, $pos, $id, $ref, $alt, $qua, $filter, $info, $format, $sample) = (split /\t/);
        $chr =~ s/chrM_NC_012920.1/chrM/g if $chr eq "chrM_NC_012920.1";

        my @k = (split /:/, $format);
        my @v = (split /:/, $sample);
        my (@alleles, %kv);

        map{
            $kv{$k[$_]} = $v[$_];
#           print "$k[$_] => $v[$_]\n";
        }(0..@k-1);

        push @alleles, $ref;
        $sites{"$chr\t$pos"}{ref} .= "$ref,";
        foreach (split /,/, $alt){
            push @alleles, $_;
            $sites{"$chr\t$pos"}{alt} .= "$_,";
        }

        my ($a1, $a2) = (split /[\/|\|]/, $kv{'GT'});
#       print "$a1 => $alleles[$a1]; $a2 => $alleles[$a2]\n";

        $sites{"$chr\t$pos"}{$sample_id} = "$alleles[$a1]/$alleles[$a2]:$kv{'AD'}:$kv{'GQ'}";
#       $sites{"$chr:$pos"}{$sample_id} = "$sample";
        $sites{"$chr\t$pos"}{allele} .= "#$ref:$alt#" if "#$ref:$alt#" ne $sites{"$chr\t$pos"}{allele};
        $sites{"$chr\t$pos"}{allele} = "#$ref:$alt#" if "#$ref:$alt#" eq $sites{"$chr\t$pos"}{allele};
#       print "$chr:$pos:$ref:$alt\t$format\t$sample\n";        
    }
}

my @sp = keys %ss;

my  $hsample = join "\t", @sp;

print "##fileformat=VCFv4.1\n";
print "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t$hsample\n";
foreach my $k (keys %sites){
    my ($gt_info, $gt_info2, %als);
    my @refs = (split /,/, $sites{$k}{ref});
    my @alts = (split /,/, $sites{$k}{alt});

    my $ref = shift @refs;
    map{
        $als{$_} = 1 if $_ ne $ref and $_ ne '.';
    }(@refs, @alts);

    my @alleles = keys %als;
    my $allele_list = join ",", @alleles;
    unshift @alleles, $ref;

    map{
        $hash{$alleles[$_]} = $_;
    }(0..@alleles-1);


    my @k = ('GT', 'AD', 'GQ');

    foreach my $sample (@sp){
        my %kv;
        my @v = (split /:/, $sites{$k}{$sample});
        map{
            $kv{$k[$_]} = $v[$_];
        }(0..@k-1);

        my ($a1, $a2) = (split /[\/|\|]/, $kv{'GT'});

        $gt_info .= "\t$hash{$a1}/$hash{$a2}:$kv{AD}:$kv{GQ}" if $sites{$k}{$sample};
        $gt_info2 .= "\t$sites{$k}{$sample}" if $sites{$k}{$sample};
        $gt_info .= "\t./." unless $sites{$k}{$sample};
    }
    print "$k\t.\t$ref\t$allele_list\t.\t.\t.\tGT:AD:GQ$gt_info\n";
#   print "$k\t$sites{$k}{allele}$gt_info2\n";
}

sub myopen{
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
