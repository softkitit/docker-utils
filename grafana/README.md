go to localhost:8086

login admin
password admin
set new password softkit_whatever

# add influx datasource

host http://influxdb:8086

````
db telegraf
user softkit
password softkitIsGreat
method GET 
````
press save and test 


import telegraf dashboard from the templates folder to the grafana manually 



# cassandra setup 
https://andreastech.wordpress.com/2018/03/19/cassandra-performance-monitoring-by-using-jolokia-agent-telegraf-influxdb-and-grafana/

add to cass env

JVM_OPTS="$JVM_OPTS -javaagent:/opt/grafana/plugins/jolokia-1.6.1/agents/jolokia-jvm.jar=host=0.0.0.0"

sudo service cassandra restart


change client base configs (hostname) and start it 

sudo docker-compose -f docker-compose-client.yml up -d 

