# download latest refGene data from http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/
# wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/refGene.txt.gz .
# get transcript gene pair
less refGene.hg19.txt.gz | awk -F'\t' '{print $2"\t"$13}'  | sort -u | less > NM2GENE.tsv
# based hgmd data and refGene get unmatched disease associated transcript, Subsequent, should be check manually
perl hgmd.t2g.pl disease_associated.transcript NM2GENE2.tsv | grep  '^\.' | less
# get based hgmd data and refGene get disease associated transcript
perl hgmd.t2g.pl disease_associated.transcript NM2GENE.tsv | grep -v '^\.' > g2t.list
# check unmatched disease associated transcript corresponding gene
# check gene corresponding available transcript: ClinVar support and exist in refGene > HGNC support and exist in refGene > ...
