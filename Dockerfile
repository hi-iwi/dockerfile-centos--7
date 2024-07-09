FROM centos:7
# https://hub.docker.com/_/centos/

# docker 具备自启动功能，所以不再需要supervisor

# /var/log/dockervol   所有挂载容器内日志；/var/lib/dockervol  所有挂载数据
RUN groupadd -r aario && useradd -d /home/aario -m -g aario aario
RUN mkdir -p /var/lib/dockervol /var/log/dockervol /etc/aa/lock
RUN chown -R aario:aario /var/lib/dockervol /var/log/dockervol /etc/aa/lock
RUN ln -sf /dev/stdout /var/log/dockervol/stdout.log && ln -sf /dev/stderr /var/log/dockervol/stderr.log


RUN echo "multilib_policy=best" >> /etc/yum.conf
RUN echo "skip_missing_names_on_install=False" >> /etc/yum.conf
RUN sed -i '/^override_install_langs=/d' /etc/yum.conf
# centos7 已经停止yum源，必须要替换
RUN rm -f /etc/yum.repos.d/*
COPY ./yum.repos.d/* /etc/yum.repos.d/
RUN rm -f /var/lib/rpm/__db*
RUN rpm --rebuilddb
RUN yum clean all
RUN yum makecache

# 这里会生成新的 repo
RUN yum-config-manager --enable extras
RUN yum -y install centos-release-scl-rh

# mirrorlist 无法访问，使用 mirrors.centos.org
RUN for repo in /etc/yum.repos.d/* ;   do                       \
      sed -i 's/^\s*mirrorlist=/# mirrorlist=/' "$repo";        \
      sed -i 's/^#\s*baseurl=/baseurl=/' "$repo";               \
      sed -i 's/mirror.centos.org/mirrors.aliyun.com/' "$repo"; \
    done

RUN rm -f /var/lib/rpm/__db*
RUN rpm --rebuilddb
RUN yum clean all
RUN yum makecache

RUN yum -y update
RUN yum -y install yum-utils net-tools curl


# COPY 只能复制当前目录，不复制子目录内容
COPY ./etc/sysctl.conf /etc/
COPY --chown=aario:aario ./etc/aa/*  /etc/aa/


# 注意提交到docker 仓库
# ./docker build centos-7
# docker login
# docker tag aario/centos:7 aario/centos:7
# docker push aario/centos:7

