include Process

server  = IO.popen('/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf')
waitpid(server.pid)
puts "Finished startup:#{server.read}"
log = IO.popen('tail -f /usr/local/nginx/logs/error.log')

while 1
  puts log.read
  sleep 10
end