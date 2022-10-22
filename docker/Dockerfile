FROM openeuler/openeuler:22.09  AS base
# 由于海外访问国内服务不稳定修改更新服务地址
RUN  sed -i "s|http://repo.openeuler.org/|https://fr-repo.openeuler.org/|g" /etc/yum.repos.d/openEuler.repo
RUN yum update && yum install -y iftop make gcc mysql-devel

ARG KBE_ROOT=/opt/kbengine
ARG KBE_RES_PATH=$KBE_ROOT/kbe/res/:$KBE_ROOT/assets/:$KBE_ROOT/assets/scripts/:$KBE_ROOT/assets/res/
ARG KBE_BIN_PATH=$KBE_ROOT/kbe/bin/server/

ENV KBE_ROOT $KBE_ROOT
ENV KBE_RES_PATH $KBE_RES_PATH
ENV KBE_BIN_PATH $KBE_BIN_PATH

WORKDIR /opt

FROM base AS builder_py
RUN yum -y install wget tar make gcc gcc-c++ openssl-devel mysql-server mysql-devel \
    libffi-devel autoconf automake libtool libtirpc libtirpc-devel

# 编译 python
RUN yum remove -y python3-pip python-pip
COPY ./docker/Python-3.7.8rc1.tgz Python-3.7.8rc1.tgz
RUN tar -zxvf Python-3.7.8rc1.tgz && rm -f Python-3.7.8rc1.tgz && cd /opt/Python* && ./configure && make -j4 && make install

FROM builder_py AS builder
# 本地编译 kbengine
COPY ./kbengine/ /opt/kbengine/ 
RUN find  . -type f -print0 | xargs -0 sed -i "s/\r//g"
RUN cd $KBE_ROOT/kbe/src/ && make -j4 

COPY ./docker/Django-1.8.9.tar.gz $KBE_ROOT/kbe/tools/server/django_packages/Django-1.8.9.tar.gz
RUN cd $KBE_ROOT/kbe/tools/server/django_packages/ && rm -rf Django-1.6.11.tar.gz && tar -vxf Django-1.8.9.tar.gz
RUN cd $KBE_ROOT/kbe/tools/server/webconsole && chmod +x *.sh

FROM base AS runtime
COPY --from=builder /opt/kbengine /opt/kbengine
COPY --from=builder /usr/lib64/mysql /usr/lib64/mysql
COPY --from=builder /usr/local/bin /usr/local/bin 
COPY --from=builder /usr/local/include /usr/local/include
COPY --from=builder /usr/local/lib /usr/local/lib 
COPY --from=builder /etc/ld.so.conf.d/mysql-x86_64.conf /etc/ld.so.conf.d/mysql-x86_64.conf
COPY ./docker/kbengine_defaults.xml $KBE_ROOT/kbe/res/server/kbengine_defaults.xml.bak
COPY ./docker/settings.py $KBE_ROOT/kbe/tools/server/webconsole/KBESettings/settings.py.bak
RUN ldconfig

RUN ln -sf /usr/local/bin/python3.7 /usr/bin/python && ln -sf /usr/local/bin/pip3 /usr/bin/pip
RUN yum install -y mysql-devel
RUN pip install asgiref==3.5.2 sqlparse==0.4.3 pytz==2022.4 mysqlclient==1.3.14
COPY ./docker/main.sh /opt/main.sh
RUN chmod +x /opt/main.sh
COPY ./docker/kbengine_stresstest/mmorpg/server_assets /opt/kbengine/assets
RUN cd /opt/kbengine/assets && find  . -type f -print0 | xargs -0 sed -i "s/\r//g"
RUN cp /opt/kbengine/assets/res/server/kbengine.xml /opt/kbengine/assets/res/server/kbengine.xml.bak

RUN yum clean all

EXPOSE 20099 20013 21103 40000 20015-20115 20099 50000 30040 20086-20088 8000
ENTRYPOINT [ "/opt/main.sh"]
CMD ["/bin/bash"]