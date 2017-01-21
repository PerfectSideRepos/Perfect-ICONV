tar czvf /tmp/iconv.tgz Sources Tests Package.swift
scp /tmp/iconv.tgz 192.168.56.11:/tmp
ssh 192.168.56.11 "cd /tmp;rm -rf iconv;mkdir iconv;cd iconv;tar xzvf ../iconv.tgz;swift build;swift test"
