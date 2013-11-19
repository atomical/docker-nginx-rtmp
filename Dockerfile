FROM ubuntu:12.04
WORKDIR /home/nginx/
CMD ruby start.rb

RUN /sbin/ip route | awk '/default/ { print "Acquire::http::Proxy \"http://"$3":8000\";" }' > /etc/apt/apt.conf.d/30proxy

ADD sources.list /etc/apt/
RUN apt-get update

RUN apt-get install -y build-essential wget git bison libpcre3 libpcre3-dev zlib1g-dev libssl-dev ruby1.9.1 libhiredis-dev #ffmpeg
RUN gem install rake
RUN gem install bundler

RUN groupadd nginx
RUN useradd -m -g nginx nginx

# nginx
RUN cd /home/nginx/ && wget -q http://nginx.org/download/nginx-1.4.3.tar.gz
RUN cd /home/nginx/ && tar -xzvf nginx-1.4.3.tar.gz

# required scripts
ADD files/start.rb /home/nginx/

# rtmp server
RUN cd /home/nginx/nginx-1.4.3 && git clone git://github.com/arut/nginx-rtmp-module.git

#ruby scripting
RUN cd /home/nginx/nginx-1.4.3 && \
  git clone git://github.com/matsumoto-r/ngx_mruby.git && \
  cd ngx_mruby && \
  git submodule init && \
  git submodule update && \
  git clone git://github.com/matsumoto-r/mruby-httprequest.git && \
  cp -r mruby-httprequest mruby/mrbgems/ && \
  echo mruby-httprequest >> mruby/mrbgems/GEMS.active && \
  ./configure --with-ngx-src-root=/home/nginx/nginx-1.4.3 --with-ngx-config-opt="--prefix=/usr/local/nginx" && \
  make build_mruby && \
  make && \
  make install

# nginx
RUN cd /home/nginx/nginx-1.4.3; ./configure --prefix=/usr/local/nginx \
  --add-module=ngx_mruby \
  --add-module=ngx_mruby/dependence/ngx_devel_kit \
  --add-module=nginx-rtmp-module \
  --with-http_ssl_module && \
  make && \
  make install

# configuration
RUN rm /usr/local/nginx/conf/nginx.conf
ADD conf/nginx.conf /usr/local/nginx/conf/

# ruby api callbacks
RUN mkdir /usr/local/nginx/ruby
ADD files/ruby/ /usr/local/nginx/ruby


# finish up 
RUN chown -R nginx:nginx /usr/local/nginx/
RUN rm -rf /home/nginx/nginx-1.4.3
EXPOSE 8000 8000
EXPOSE 1935 1935
USER nginx
