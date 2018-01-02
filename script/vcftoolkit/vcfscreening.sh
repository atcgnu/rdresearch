#! /bin/bash
vcf=$1 # vcf file
config=$2 # screen.config
sampledb=$3 # sample.db
individual=$4 # if not sure, anything is OK
outfile=$5 #absolute path

export PERL5LIB=/ifswh1/BC_PUB/biosoft/pipeline/DNA/rdresearch/v2.0.1/software/perl-5.24.0/lib:/ifswh1/BC_PUB/biosoft/pipeline/DNA/rdresearch/v2.0.1/software/vcftools_0.1.12b/lib/perl5/site_perl
export PATH=/ifswh1/BC_PUB/biosoft/pipeline/DNA/rdresearch/v2.0.1/bin:${PATH}

perl="/ifswh1/BC_PUB/biosoft/pipeline/DNA/rdresearch/v2.0.1/software/perl-5.24.0/bin/perl"
vcf2simple="/ifswh1/BC_PUB/biosoft/pipeline/DNA/rdresearch/v2.0.0/bin/vcf2simple.pl"
vep="/ifswh1/BC_PUB/biosoft/pipeline/DNA/rdresearch/v2.0.1/software/ensembl-tools-release-77/scripts/variant_effect_predictor/variant_effect_predictor.pl"
vep_cache="/ifswh1/BC_PUB/biosoft/pipeline/DNA/rdresearch/data/ensembl/cache"
screening="/ifswh1/BC_PUB/biosoft/pipeline/DNA/rdresearch/v2.0.0/bin/screen.v2017.r1.0913"

# Get result directory
resultdir=`dirname $out`
# Get MD5 of vcf
md5vcf=`md5sum $vcf | /bin/awk '{print $1}'`
# Get origin filename without suffix
filename=`echo "$vcf" | awk -F'/' '{print $NF}'| sed -n 's/\.vcf//'p`
# split multi-allelic entry into bi-allelic entry
echo "transfer vcf to site.vcf"
$perl $vcf2simple $vcf $resultdir/$md5vcf.vcf
# Do annotation
echo "VEP annotated"
$perl $vep -i $resultdir/$md5vcf.vcf -o $resultdir/$md5vcf.VEP.vcf --offline --dir_cache $vep_cache --vcf --force_overwrite --quiet --fork 10 --hgvs --assembly GRCh37 --everything
# Do screening
echo "screening..."
$perl $screening $resultdir/$md5vcf.VEP.vcf $config $sampledb $outdir $out
# rename md5.VEP.vcf to orginal filename.VEP.vcf
mv $resultdir/$md5vcf.VEP.vcf $resultdir/$filename.VEP.vcf
echo "finished"
