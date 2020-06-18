FROM ubuntu:20.04



ARG CHANNEL=stable
ARG CHEF_VERSION=20.6.62
ARG TERRAFORM_VERSION=0.12.26

ENV DEBIAN_FRONTEND=noninteractive \
  PATH=/opt/chefdk/bin:/opt/chefdk/embedded/bin:/root/.chefdk/gem/ruby/2.5.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENV CHEF_LICENSE=""

RUN apt-get update && \
  apt-get install -y apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common \
  wget \
  openssh-client \
  make \
  libxss1 \
  build-essential \
  virtualbox \
  vagrant

# install docker
RUN curl -fsSL "https://download.docker.com/linux/$(lsb_release -is | awk '{print tolower($0)}')/gpg" | apt-key add - && \
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | awk '{print tolower($0)}') $(lsb_release -cs) stable" && \
  apt-get update && \
  apt-get install -y docker-ce


RUN wget --quiet --content-disposition "https://packages.chef.io/files/${CHANNEL}/chef-workstation/${CHEF_VERSION}/$(lsb_release -is | awk '{print tolower($0)}')/$(lsb_release -rs )/chef-workstation_${CHEF_VERSION}-1_amd64.deb" -O /tmp/chefdk.deb && \
  dpkg -i /tmp/chefdk.deb && \
  CHEF_LICENSE="accept-no-persist" chef gem install kitchen-docker && \
  CHEF_LICENSE="accept-no-persist" chef gem install kitchen-openstack && \
  CHEF_LICENSE="accept-no-persist" chef gem install kitchen-terraform && \
  CHEF_LICENSE="accept-no-persist" chef gem install knife-openstack && \
  apt-get remove -y build-essential && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -L -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip /tmp/terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm /tmp/terraform.zip

VOLUME /var/run/docker.sock


