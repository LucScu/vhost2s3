#!/bin/bash
PATH=/bin:/usr/bin:/usr/local/bin


# get vars from config file
currentdir=$(dirname $0)
source $currentdir'/config'



##
## CHECK MODE: SINGLE OR VHOST
##

# if no one mode is setted
SINGLEDIR=`echo $singledir`
VHOSTDIR=`echo $vhostdir`
if [ "${SINGLEDIR}" == "" ] && [ "${VHOSTDIR}" == "" ]; then
echo 'please review your config file and choose single or vhost mode'
exit 1
fi

# if both mode are setted
if [ "${SINGLEDIR}" != "" ] && [ "${VHOSTDIR}" != "" ]; then
echo 'please review your config file and choose only one mode single or vhost'
exit 1
fi

# check which mode is setted
if [ -n "$singledir" ]; then
  mode='single'
fi

if [ -n "$vhostdir" ]; then
  mode='vhost'
fi



##
## other vars
##
now='_'$(date +"%Y%m%d")
MODE=`echo $mode`

# echo $MODE
# exit 0

# create tmp dir if not exists
mkdir -p $tmpdir



##
## single mode
##
if [ "${MODE}" == "single" ]; then
  
  # move to singledir
  cd $singledir  

  singledirname=${PWD##*/}
  sourcezip=$singledir
  destzip=$tmpdir$singledirname$now'.tar.gz'

  echo sourcezip: $sourcezip
  echo destzip: $destzip

  # create zip archive to upload
  tar -zcf $destzip $sourcezip

  sources3=$destzip
  dests3='s3://'$bucket'/'$s3dir'/'$singledirname$now'.tar.gz'

  echo sources3: $sources3
  echo dests3: $dests3

  # put to s3
  s3cmd put $sources3 $dests3

  # remove from /tmp/s3backup
  rm $destzip
fi



##
## vhost mode
##
if [ "${MODE}" == "vhost" ]; then

  # move to vhostdir
  cd $vhostdir


  # print $excludevhost content
  #for v in "${excludevhost[*]}"
  #do
  #  echo $v
  #done
  #exit 0


  #loop vhost dir
  #backup only dir that aren't in $excludevhost
  for D in `ls`
  do
    FOUND=`echo ${excludevhost[*]} | grep $D`
    if [ "${FOUND}" != "" ]; then
      echo not backup $D
    else
      echo backup $D
      sourcezip=$D
      destzip=$tmpdir$sourcezip$now'.tar.gz'

      echo sourcezip: $sourcezip
      echo destzip: $destzip
 
      # create zip archive
      tar -zcf $destzip $sourcezip

      sources3=$destzip
      dests3='s3://'$bucket'/'$s3dir'/'$sourcezip$now'.tar.gz'

      echo sources3: $sources3
      echo dests3: $dests3

      # put to s3
      s3cmd put $sources3 $dests3

      # remove from /tmp/s3backup
      rm $destzip
    fi
  done
fi


##
## delete old archive from bucket
##
date=""
now=`date --date="now" +%s`
deleteOlderThan=$deleteBeforeDay*86400
for E in `s3cmd ls s3://$bucket/$s3dir/`
do
  
  # find archive date
  DATE=`echo $E | grep "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}"`
  if [ "${DATE}" != "" ]; then
    date=$DATE
  fi

  # find archive filename
  FILE=`echo $E | grep "s3.*\.tar\.gz"`
  if [ "${FILE}" != "" ]; then
    entry_time=`date --date="$date" +%s`
    diff=$(($now - $deleteOlderThan))
    if [ $diff -gt $entry_time ]; then
      #echo $diff
      #echo $entry_time
      s3cmd del $FILE
    fi
  fi
done

# all done correctly, exit with success (0)
exit 0