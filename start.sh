#!/bin/env bash

sudo /usr/sbin/nginx -c /tmp/nginx-0.conf 2>&1 > /tmp/nginx-0.log
sudo /usr/sbin/nginx -c /tmp/nginx-1.conf 2>&1 > /tmp/nginx-1.log

sudo /usr/local/sbin/haproxy -D -f /tmp/haproxy.conf -p /tmp/haproxy.pid 2>&1 > /tmp/haproxy.log

ab -c 1 -n 5000000 http://localhost:8080/ 2>&1 > /tmp/ab.out &

c=0
while true
do
  if [ $(( $c % 2 )) -eq 0 ]
  then
    sed -i -e 's/\( server web-0\)/#\1/g' -e 's/# \(server web-1\)/ \1/g' /tmp/haproxy.conf
  else
    sed -i -e 's/\( server web-1\)/#\1/g' -e 's/# \(server web-0\)/ \1/g' /tmp/haproxy.conf
  fi

  sudo /usr/local/sbin/haproxy -D -f /tmp/haproxy.conf -p /tmp/haproxy.pid -sf $(cat /tmp/haproxy.pid) 2>&1 > /tmp/haproxy.log

  c=$(( $c + 1 ))
  sleep 0.5
done

while true
do
  sudo /usr/local/sbin/haproxy -D -f /tmp/haproxy.conf -p /tmp/haproxy.pid -sf $(cat /tmp/haproxy.pid) 2>&1 > /tmp/haproxy.log
  sleep 0.5
done
