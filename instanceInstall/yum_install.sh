#!/usr/bin
user=$1
cd /home/$user/dba/rpm
sudo rpm -Uvh libev-4.15-3.el7.x86_64.rpm
sudo rpm -Uvh percona-xtrabackup-24-2.4.4-1.el7.x86_64.rpm

tar zxvf percona-toolkit-2.2.19.tar.gz
cd percona-toolkit-2.2.19.tar.gz
perl Makefile.PL
make && sudo make install

tar zxvf TermReadKey-2.14.tar.gz
cd TermReadKey-2.14.tar.gz
perl Makefile.PL
make && sudo make install


sudo yum -y install screen sysbench  libev  perl-CPAN perl-Digest-MD5 numactl.x86_64 expect.x86_64 perl-DBD-MySQL-4.023-5.e17.x86_64
