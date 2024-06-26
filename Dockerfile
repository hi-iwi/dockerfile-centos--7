FROM centos:7
# https://hub.docker.com/_/centos/

# docker 具备自启动功能，所以不再需要supervisor

# /var/log/dockervol   所有挂载容器内日志；/var/lib/dockervol  所有挂载数据
RUN groupadd -r iwi && useradd -d /home/iwi -m -g iwi iwi
RUN mkdir -p /var/lib/dockervol /var/log/dockervol /etc/aa/lock
RUN chown -R iwi:iwi /var/lib/dockervol /var/log/dockervol /etc/aa/lock
RUN ln -sf /dev/stdout /var/log/dockervol/stdout.log && ln -sf /dev/stderr /var/log/dockervol/stderr.log

RUN echo "multilib_policy=best" >> /etc/yum.conf
RUN echo "skip_missing_names_on_install=False" >> /etc/yum.conf
RUN sed -i '/^override_install_langs=/d' /etc/yum.conf
RUN yum -y update
RUN yum -y install yum-utils curl
RUN yum-config-manager --enable extras
RUN yum -y install centos-release-scl-rh
RUN rpm --rebuilddb
RUN yum clean all

# COPY 只能复制当前目录，不复制子目录内容
COPY ./etc/sysctl.conf /etc/
COPY --chown=iwi:iwi ./etc/aa/*  /etc/aa/
