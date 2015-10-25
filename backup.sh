#!/bin/bash
PATH=/bin:/usr/bin:/usr/local/bin


# Get config file
currentdir=$(dirname $0)
source $currentdir'/config'


# create tmp dir if not exists
mkdir -p $tmpdir


# move to vhost dir
cd $vhostdir
now=$(date +"%Y%m%d")


#print $excludevhost content
#for v in "${excludevhost[@]}"
#do
#  echo $v
#done


#loop vhost dir
#backup only dir that aren't in $excludevhost
for D in `ls`
do
  FOUND=`echo ${excludevhost[@]} | grep '$D'`
  if [ '${FOUND}' != '' ]; then
    echo not backup $D
  else
    echo backup $D
    sourcezip=$D
    destzip=$tmpdir$sourcezip$now'.tar.gz'

    echo sourcezip: $sourcezip
    echo destzip: $destzip
 
    tar -zcf $destzip $sourcezip

    sources3=$destzip
    dests3='s3://'$bucket'/'$s3dir'/'$sourcezip$now'.tar.gz'

    echo sources3: $sources3
    echo dests3: $dests3

    s3cmd put $sources3 $dests3
  fi
done

exit 0
