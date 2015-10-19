# docker built -t nx-server .
FROM centos:6.6
MAINTAINER stoleas <stoleas@users.noreply.github.com>

ENV PASSWORD_FIELD password

# SETUP A USER
RUN adduser equail
RUN rm -rf /home/equail/.ba*
RUN sed -i s/"equail:x:1000:"/"equail:x:500:"/g /etc/group
RUN sed -i s,"equail:x:1000:1000::/home/equail:/bin/bash","equail:x:500:500::/home/equail:/bin/bash",g /etc/passwd
RUN printf "%s\n" "${PASSWORD_FIELD}" "${PASSWORD_FIELD}" | passwd equail
RUN ln -s /home/equail /home/edquail

# Install base software
RUN yum -y -q update
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
    rpm -Uvh http://li.nux.ro/download/nux/dextop/el6/x86_64/nux-dextop-release-0-2.el6.nux.noarch.rpm
RUN yum -y install freenx-server nxagent terminator sessreg wget supervisor git net-toolts python-setuptools yum-util xorg-x11-xauth
RUN printf "%s\n" "y" | nxsetup --install ; exit 0
RUN /usr/libexec/nx/nxserver --restart
RUN /etc/init.d/sshd start && chkconfig sshd on
RUN cat /etc/nxserver/client.id_dsa.key

RUN echo -e "\n\nequail  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# SETUP SUPERVISOR
RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor
ADD supervisor/supervisord.conf /etc/supervisord.conf

EXPOSE 7777

# docker run \
#        --expose 7777 \
#        -p 7777:22 \
#        -v /home:/home \
#        -it \
#             nx-server /bin/bash

# docker run \
#        --expose 7777 \
#        -p 7777:22 \
#        -v /home:/home \
#             nx-server /bin/bash -c 'supervisord -c /etc/supervisord.conf'