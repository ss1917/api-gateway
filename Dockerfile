FROM openresty/openresty:1.15.8.3-2-centos
ENV LANG=en_US.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN yum install epel-release -y && yum install -y supervisor && yum clean all -y

COPY . /usr/local/openresty/nginx/
RUN  mv  /usr/local/openresty/nginx/supervisor_ops.conf  /etc/supervisord.conf

EXPOSE 80 443

CMD ["/usr/bin/supervisord"]
#CMD ["/usr/bin/openresty", "-g", "daemon off;"]