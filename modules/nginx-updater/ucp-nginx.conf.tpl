user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

stream {
    upstream ucp_443 {
        server ${ucp_ip0}:443 max_fails=2 fail_timeout=30s;
        server ${ucp_ip1}:443 max_fails=2 fail_timeout=30s;
        server ${ucp_ip2}:443 max_fails=2 fail_timeout=30s;
    }
        upstream kubectl_6443 {
        server ${ucp_ip0}:6443 max_fails=2 fail_timeout=30s;
        server ${ucp_ip1}:6443 max_fails=2 fail_timeout=30s;
        server ${ucp_ip2}:6443 max_fails=2 fail_timeout=30s;
    }
    server {
        listen 443;
        proxy_pass ucp_443;
    }
        server {
        listen 6443;
        proxy_pass kubectl_6443;
     }
}
