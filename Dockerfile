# Copyright (c) 2009-2024 Yegor Bugayenko
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met: 1) Redistributions of source code must retain the above
# copyright notice, this list of conditions and the following
# disclaimer. 2) Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided
# with the distribution. 3) Neither the name of the rultor.com nor
# the names of its contributors may be used to endorse or promote
# products derived from this software without specific prior written
# permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT
# NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
# THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.

# The software packages configured here (PHP, Node, Ruby, Java etc.) are for
# the convenience of the users going to use this default container.
# If you are going to use your own container, you may remove them.
# Rultor has no dependency on these packages.

FROM ubuntu:22.04
LABEL Description="This is the java image for Rultor.com" Version="0.0.0"
WORKDIR /tmp

ENV DEBIAN_FRONTEND=noninteractive

# To disable IPv6
RUN mkdir ~/.gnupg \
  && printf "disable-ipv6" >> ~/.gnupg/dirmngr.conf

# UTF-8 locale
RUN apt-get clean \
  && apt-get update -y --fix-missing \
  && apt-get -y install locales \
  && locale-gen en_US.UTF-8 \
  && dpkg-reconfigure locales \
  && echo "LC_ALL=en_US.UTF-8\nLANG=en_US.UTF-8\nLANGUAGE=en_US.UTF-8" > /etc/default/locale \
  && echo 'export LC_ALL=en_US.UTF-8' >> /root/.profile \
  && echo 'export LANG=en_US.UTF-8' >> /root/.profile \
  && echo 'export LANGUAGE=en_US.UTF-8' >> /root/.profile

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Basic Linux tools
RUN apt-get -y install wget \
  curl \
  sudo \
  software-properties-common

# Docker cli
RUN mkdir -p /tmp/download \
  && curl -s -L "https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz" | tar -xz -C /tmp/download \
  && mv /tmp/download/docker/docker /usr/bin/ \
  && rm -rf /tmp/download

# Git 2.0
RUN add-apt-repository ppa:git-core/ppa \
  && apt-get update -y --fix-missing \
  && apt-get -y --no-install-recommends install git \
  && bash -c 'git --version'

# SSH Daemon
RUN apt-get -y install ssh \
  && mkdir /var/run/sshd \
  && chmod 0755 /var/run/sshd

# Ruby
RUN apt-get -y install ruby-dev libmagic-dev zlib1g-dev openssl \
  && gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
  && curl -L https://get.rvm.io | sudo bash -s stable \
  && echo "source /usr/local/rvm/scripts/rvm && rvm use 3.2.2 && rvm default 3.2.2" >> /root/.profile \
  && bash -l -c ". /etc/profile.d/rvm.sh && rvm pkg install openssl" \
  && bash -l -c ". /etc/profile.d/rvm.sh && rvm install ruby-2.7.6 --with-openssl-dir=/usr/local/rvm/usr" \
  && bash -l -c ". /etc/profile.d/rvm.sh && rvm install ruby-3.2.2 --with-openssl-lib=/usr/lib --with-openssl-include=/usr/include" \
  && echo 'gem: --no-document' >> ~/.gemrc \
  && echo 'rvm_silence_path_mismatch_check_flag=1' >> ~/.rvmrc \
  && bash -l -c ". /etc/profile.d/rvm.sh \
    && rvm use 3.2.2 \
    && gem install bundler -v 2.3.26 \
    && gem install xcop -v 0.7.1 \
    && gem install pdd -v 0.23.1 \
    && gem install openssl -v 3.1.0"

# Java
ENV MAVEN_OPTS "-Xmx1g"
ENV JAVA_OPTS "-Xmx1g"
ENV JAVA_HOME "/usr/lib/jvm/java-17"
RUN apt-get -y install ca-certificates openjdk-11-jdk openjdk-17-jdk \
  && update-java-alternatives --set $(ls /usr/lib/jvm | grep java-1.11) \
  && ln -s "/usr/lib/jvm/$(ls /usr/lib/jvm | grep java-1.11)" /usr/lib/jvm/java-11 \
  && ln -s "/usr/lib/jvm/$(ls /usr/lib/jvm | grep java-1.17)" /usr/lib/jvm/java-17 \
  && echo 'export JAVA_HOME=/usr/lib/jvm/java-11' >> /root/.profile \
  && bash -c '[[ "$(javac  --version)" =~ "11.0" ]]'

# Maven
ENV MAVEN_VERSION 3.9.6
ENV M2_HOME "/usr/local/apache-maven/apache-maven-${MAVEN_VERSION}"
RUN echo 'export M2_HOME=/usr/local/apache-maven/apache-maven-${MAVEN_VERSION}' >> /root/.profile \
  && wget --quiet "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
  && mkdir -p /usr/local/apache-maven \
  && mv "apache-maven-${MAVEN_VERSION}-bin.tar.gz" /usr/local/apache-maven \
  && tar xzvf "/usr/local/apache-maven/apache-maven-${MAVEN_VERSION}-bin.tar.gz" -C /usr/local/apache-maven/ \
  && update-alternatives --install /usr/bin/mvn mvn "${M2_HOME}/bin/mvn" 1 \
  && update-alternatives --config mvn \
  && mvn -version \
  && bash -c '[[ "$(mvn --version)" =~ "${MAVEN_VERSION}" ]]'
COPY settings.xml /root/.m2/settings.xml

# Clean up
RUN rm -rf /tmp/* \
  /root/.ssh \
  /root/.cache \
  /root/.wget-hsts \
  /root/.gnupg

ENTRYPOINT ["/bin/bash", "--login", "-c"]
