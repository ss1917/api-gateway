FROM openresty/openresty:1.15.8.3-2-centos
ENV LANG en_US.UTF-8
# 同步时间
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY . /usr/local/openresty/nginx/

EXPOSE 80
#CMD ["/usr/bin/openresty", "-g", "daemon off;"]
ENTRYPOINT ["/usr/bin/openresty", "-g", "daemon off;"]
