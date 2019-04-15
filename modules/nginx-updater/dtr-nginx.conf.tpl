user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

stream {
    upstream dtr_80 {
        server ${dtr_ip0}:80  max_fails=2 fail_timeout=30s;
        server ${dtr_ip1}:80  max_fails=2 fail_timeout=30s;
        server ${dtr_ip2}:80  max_fails=2 fail_timeout=30s;
    }
    upstream dtr_443 {
        server ${dtr_ip0}:443 max_fails=2 fail_timeout=30s;
        server ${dtr_ip1}:443 max_fails=2 fail_timeout=30s;
        server ${dtr_ip2}:443 max_fails=2 fail_timeout=30s;
    }
    server {
        listen 443;
        proxy_pass dtr_443;
    }

    server {
        listen 80;
        proxy_pass dtr_80;
    }
}
