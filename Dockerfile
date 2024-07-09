FROM centos:7
# https://hub.docker.com/_/centos/

# docker 具备自启动功能，所以不再需要supervisor

# /var/log/dockervol   所有挂载容器内日志；/var/lib/dockervol  所有挂载数据
RUN groupadd -r aario && useradd -d /home/aario -m -g aario aario
RUN mkdir -p /var/lib/dockervol /var/log/dockervol /etc/aa/lock
RUN chown -R aario:aario /var/lib/dockervol /var/log/dockervol /etc/aa/lock
RUN ln -sf /dev/stdout /var/log/dockervol/stdout.log && ln -sf /dev/stderr /var/log/dockervol/stderr.log

# 阿里云yum源非常不稳定

#RUN rm -f /etc/yum.repos.d/*
#RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#RUN yum clean all
#RUN yum makecache
RUN echo "multilib_policy=best" >> /etc/yum.conf
RUN echo "skip_missing_names_on_install=False" >> /etc/yum.conf
RUN sed -i '/^override_install_langs=/d' /etc/yum.conf
RUN yum -y update
RUN yum -y install yum-utils curl
RUN yum-config-manager --enable extras
RUN yum -y install centos-release-scl-rh
RUN rpm --rebuilddb

# COPY 只能复制当前目录，不复制子目录内容
COPY ./etc/sysctl.conf /etc/
COPY --chown=aario:aario ./etc/aa/*  /etc/aa/


# 注意提交到docker 仓库
# ./docker build centos-7
# docker login
# docker tag aario/centos:7 aario/centos:7
# docker push aario/centos:7

