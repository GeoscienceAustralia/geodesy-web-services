#!/usr/bin/env bash
# Start tomcat
service tomcat8 start

# Wait until Tomcat startup has finished
until curl -s http://localhost:8080; do
  echo Waiting for tomcat
  sleep 3
done

while [ "$(curl -w "%{http_code}" -s -o /dev/null http://localhost:8080/corsSites)" = 404 ]; do
  echo Waiting for GWS
  sleep 3
done
