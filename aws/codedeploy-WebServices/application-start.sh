#!/usr/bin/env bash
# Start tomcat
service tomcat8 start

# Wait until Tomcat startup has finished
until curl -s http://localhost:8080; do
  sleep 3
done
