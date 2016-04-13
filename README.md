# Vhost2s3 tool for automatic backup
- author: Luca Sculco, [sculco.luca@gmail.com](mailto:sculco.luca@gmail.com)


### What is Vhost2s3
Vhost2s3 (`vhost2s3`) is a free bash script that secures your vhosts data.
It puts all content of your vhosts directories to your Amazon S3 bucket with automatic backups.

If you own a shared server you have to backup all your customers data automatically and chronically.
Vhost2s3 make it simple with just few settings in `config-demo` file.


### Requirements
- Amazon S3 bucket
- Vhost2s3 interacts with Amazon S3 thanks the useful [S3cmd](https://github.com/s3tools/s3cmd) tool, so before to start to use Vhost2s3 you have to install S3cmd and verify that it works properly.


### How to use
1. Create `vhost2s3` dir into your home directory
2. Clone the repo into `vhost2s3` dir
3. Customize required settings in `config-demo`
4. Rename `config-demo` to `config`
5. Backup your vhosts
 * for **manual backup** go into `vhost2s3` folder and run `bash backup.sh`
 * for **automatic backup** set an entry in crontab, i.e. `0 4 * * * bash ~/vhost2s3/backup.sh` to run Vhost2s3 every day at 4am
