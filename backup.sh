# Get config file
source config-demo

# move to vhost directory
cd $vhostdir

# create tmp dir if not exists
mkdir -p $tmpdir

now=$(date +"%Y%m%d")
sourcezip=dir-to-backup
destzip=$tmpdir$sourcezip$now'.tar.gz'

echo sourcezip: $sourcezip
echo destzip: $destzip
 
tar -zcf $destzip $sourcezip

sources3=$destzip
dests3='s3://'$bucket'/'$s3dir'/'$sourcezip$now'.tar.gz'

echo sources3: $sources3
echo dests3: $dests3

s3cmd put $sources3 $dests3

exit 0
