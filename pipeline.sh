#!/bin/sh

#***************************************************************************************************
# FileName: rdresearch
# Creator: Chen Y.L. <shenyulan@genomics.cn>
# Create Time: Wed Nov  9 09:36:09 CST 2016

# Description:
# CopyRight:
# vision: 0.1
# ModifyList:
#   Revision:
#   Modifier:
#   ModifyTime:
#   ModifyReason:
#***************************************************************************************************
function usage {
    echo "    USAGE:sh $0 -o path2outdir -p monitor_project -q queue -P bgi_project -r"
    echo -e "    Example:sh $0 -o /ifs5/BC_MD/DEV/pipeline/v1.0.0/t -p test -q st.q -P st_md -r\n"
    echo -e "    option:"
    echo -e "       -o path to output directory"
    echo -e "       -p project name for monitor"
    echo -e "       -q SGE queue"
    echo -e "       -P BGI project"
    echo -e "       -f force remove project directory if existed"
    echo -e "       -r automatic start analysis, otherwise the analysis should be start on demand\n"
}

if [ $# -lt 2 ]
then
    usage
    exit
fi

while getopts :o:q:P:p:f:r opt
do
    case "$opt" in
    o)outDir=$OPTARG;;
    q)queue=$OPTARG;;
    P)bgi_project=$OPTARG;;
    p)monitor_project=$OPTARG;;
    f)is_force_rm=$OPTARG;;
    r)is_run='run';;
    *)echo "Unknown option: $opt";;
    esac
done
#------ Shenzhen SGE cluster ------
perl="/ifs4/BC_PUB/biosoft/pipeline/DNA/rdresearch/software/perl-5.18.1/bin/perl"
monitor="/ifs5/BC_MD/DEV/pipeline/rdresearch/bin/monitor"
ppl="/ifs5/BC_MD/DEV/pipeline/rdresearch/panel.BGISEQ500.v1.0.0628/version.curent"


rm -rf $outDir/$monitor_project.config.txt

if [ "$is_force_rm"x == "YES"x ]
then
    rm -r $outDir/$monitor_project
fi

#for i in  `grep -v '^[#@]' $outDir/sample.db | awk '{print \$1}' | xargs`
line_marker=`grep -v '^[#@]' $outDir/sample.db | wc -l`
for i in `seq 1 $line_marker`
do
    $perl $ppl $i $outDir/$monitor_project  $outDir/screen.config $outDir/sample.db >> $outDir/$monitor_project.config.txt
done

if [ "$is_run"x == "run"x ]
then
    $monitor taskmonitor -p $monitor_project -i $outDir/$monitor_project.config.txt -q $queue -P $bgi_project -f 1
else
    echo "pipeline dirctories and scripts have been created, user can start analysis by command 'sh manual_run.sh'"
echo "$monitor taskmonitor -p $monitor_project -i $outDir/$monitor_project.config.txt -q $queue -P $bgi_project -f 1" > $outDir/manual_run.sh
fi
