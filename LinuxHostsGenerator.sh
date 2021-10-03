#!/bin/bash
#################################################
# https://github.com/furkun/LinuxHostsGenerator #
#################################################

if ! [ $(id -u) = 0 ]; then
  echo "Please run as root!"
  exit 1
fi

rm -rf hosts-files
mkdir hosts-files
rm -f hosts.tmp
rm -f hosts

if [ -f "hosts-sources.txt" ]; then
  echo "-----Hosts files are downloading..."
  sleep 1s
  wget --no-check-certificate -i hosts-sources.txt -P hosts-files
else
  echo "hosts-sources.txt doesn't exist."
  exit
fi

echo "-----All hosts files have been downloaded."
sleep 1s
echo "-----Merging all hosts files..."
sleep 1s
for f in hosts-files/*; do (cat "${f}"; echo) >> hosts.tmp; done
rm -rf hosts-files
echo "-----All hosts files have been merged."
sleep 1s
echo "-----Compressing hosts file..."
sleep 1s
sed -i 's/#.*$//;/^$/d' hosts.tmp
awk '!seen[$0]++' hosts.tmp > hosts
rm -f hosts.tmp
sed -i 's/  / /' hosts
sed -i 's/   / /' hosts
sed -i 's/    / /' hosts
sed -i 's/     / /' hosts
sed -i 's/	/ /' hosts


echo "-----hosts file is compressed."
sleep 1s
sed -i '/127.0.0.1 localhost/d' hosts
sed -i '/::1 ip6-localhost ip6-loopback/d' hosts
sed -i '/fe00::0 ip6-localnet/d' hosts
sed -i '/ff00::0 ip6-mcastprefix/d' hosts
sed -i '/ff02::1 ip6-allnodes/d' hosts
sed -i '/ff02::2 ip6-allrouters/d' hosts
sed -i '/::1 localhost/d' hosts
sed -i 's/127.0.0.1/0.0.0.0/' hosts

echo "#This hosts file is created with LinuxHostsGenerator\n#https://github.com/furkun/LinuxHostsGenerator\n\n\n\n127.0.0.1	localhost\n127.0.1.1	$(hostname)\n::1     ip6-localhost ip6-loopback\nfe00::0 ip6-localnet\nff00::0 ip6-mcastprefix\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters\n\n$(cat hosts)" > hosts
echo "-----hosts file is generated. ✓"

read -p "Do you want to update your hosts file? (y/n)" CONT
if [ "$CONT" = "y" ]; then
  mv /etc/hosts.bak /etc/hosts.bak.bak
  mv /etc/hosts /etc/hosts.bak
  cp hosts /etc/hosts
  echo "-----hosts file is updated. ✓"
else
  exit
fi

read -p "Do you want to clear your dns cache? (y/n)" CONT
if [ "$CONT" = "y" ]; then
  /etc/init.d/nscd restart
  systemd-resolve --flush-caches
  echo "-----Your DNS cache is cleared. ✓"
else
  exit
fi
