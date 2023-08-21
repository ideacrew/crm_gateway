#!/bin/sh

/opt/jboss/keycloak/bin/standalone.sh > /tmp/server-log.txt &
SERVER_PID=$!
sleep 1
while ! grep -m1 'Admin console listening on' < /tmp/server-log.txt; do
    sleep 1
done

# /opt/jboss/keycloak/bin/kcadm.sh create realms -s realm=Anthem -s enabled=true -s sslRequired=NONE --server=http://localhost:8080/auth --realm master --user $1 --password $2
/opt/jboss/keycloak/bin/kcadm.sh create partialImport -r master -f /tmp/realm-export.json -s ifResourceExists=SKIP --server=http://localhost:8080/auth --realm master --user $1 --password $2
/opt/jboss/keycloak/bin/kcadm.sh create partialImport -r master -f /tmp/realm-export.json -s ifResourceExists=SKIP --server=http://localhost:8080/auth --realm master --user $1 --password $2

kill $SERVER_PID