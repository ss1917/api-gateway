FROM openresty/openresty:1.15.8.1-1-centos

MAINTAINER "shenshuo<191715030@qq.com>"

ENV LANG en_US.UTF-8
# 同步时间
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY . /usr/local/openresty/nginx/
VOLUME /var/log/
VOLUME /usr/local/openresty/nginx/logs/
EXPOSE 80
CMD ["/usr/bin/openresty", "-g", "daemon off;"]