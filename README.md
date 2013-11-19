
####About 

This docker image creates an nginx server with rtmp capabilities.  It also uses Ruby to authenticate 


####Build
```
$ sudo apt-get install -y squid-deb-proxy squid-deb-proxy-client
$ sudo docker build -t docker-nginx-rtmp .
```

#### Add media files
```
# in your shared vagrant folder (i.e. /docker)
$ mkdir /vagrant/mp4
```

#### Run
```
$ sudo docker run -v /vagrant/mp4:/var/mp4 -p :1935/udp -t docker-nginx-rtmp
```

#### Extra

As of this writing Docker is pretty new.  So you're probably thinking you would like to cache dependencies.  We use the method [here](https://vilimpoc.org/blog/2013/09/13/setting-up-docker-and-buildbot/).

```
# stop all containers
$ sudo docker stop $(docker ps -q)

# ip address of the first docker instance
$ sudo docker inspect $(docker ps -q) | grep "IPAddress"

# test rtmp on host
$ rtmpdump -r "rtmp://172.17.0.140/vod/sheephead_mountain.mp4
```
