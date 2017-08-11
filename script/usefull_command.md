split fasta file

perl -e 'open C,">chrOrder";open I,"ucsc.hg19.fasta";$/=">";<I>;while(<I>){chomp;$chr=$1 if /^(chr\S+)\n/;open O,">$chr.fa";print O ">$_";close O;print C "$chr\n";print "$chr over ...\n";}close I;close C;'
