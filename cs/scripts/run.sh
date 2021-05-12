#!/bin/bash

echo "Update service settings..."

ring cs --instance cs jdbc pools --name common set-params --url jdbc:postgresql://postgres:5432/${POSTGRES_DB}?currentSchema=public --username $POSTGRES_USER --password $POSTGRES_PASSWORD
ring cs --instance cs jdbc pools --name privileged set-params --url jdbc:postgresql://postgres:5432/${POSTGRES_DB}?currentSchema=public --username $POSTGRES_USER --password $POSTGRES_PASSWORD

echo "Restarting services..."

ring hazelcast --instance hazelcast service stop --init-system sysv
ring elasticsearch --instance elasticsearch service stop --init-system sysv
ring cs --instance cs service stop --init-system sysv

sleep 5

ring hazelcast --instance hazelcast service start --init-system sysv
ring elasticsearch --instance elasticsearch service start --init-system sysv
ring cs --instance cs service start --init-system sysv

sleep 30

curl -Sf -X POST -H "Content-Type: application/json" \
-d "{ \"url\" : \"jdbc:postgresql://postgres:5432/${POSTGRES_DB}\", \"username\" : \"$POSTGRES_USER\", \"password\" : \"$POSTGRES_PASSWORD\", \"enabled\" : true }" -u admin:admin http://localhost:8087/admin/bucket_server

echo "Services started..."

tail /var/opt/cs/cs/logs/* -f