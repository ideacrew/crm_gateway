FROM ruby:3.2.2 AS crm_gateway

LABEL author="IdeaCrew"

# Configure bundler and PATH
ENV LANG=C.UTF-8 \
    GEM_HOME=/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH \
    BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH /crm_gateway/bin:$BUNDLE_BIN:$PATH

ARG BUNDLER_VERSION_OVERRIDE
RUN echo $BUNDLER_VERSION_OVERRIDE
RUN apt-get update && \
    apt-get -yq dist-upgrade && \
    apt-get install -y curl tzdata build-essential vim libsodium-dev && \
    apt-get autoremove -y

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 12

# Install nvm with node and npm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.20.0/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && mkdir $NVM_DIR/versions \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

RUN mkdir -p /crm_gateway

ENV HOME /crm_gateway
WORKDIR $HOME

RUN gem install --source "https://rubygems.org" bundler:2.2.33

COPY Gemfile .
COPY Gemfile.lock .
COPY package.json .
COPY yarn.lock .

# Setting env up
ENV RAILS_ENV='development'
ENV NODE_ENV='development'

RUN . $NVM_DIR/nvm.sh && nvm use 12 && npm install -g yarn && yarn install

RUN cat /crm_gateway/Gemfile
RUN cd /crm_gateway && . $NVM_DIR/nvm.sh && nvm use 12 && bundle install
RUN cd /crm_gateway && . $NVM_DIR/nvm.sh && nvm use 12 && yarn install

COPY . /crm_gateway
