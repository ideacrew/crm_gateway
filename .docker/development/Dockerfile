FROM ruby:3.2.2 AS crm_gateway

LABEL author="IdeaCrew"

ENV HOME /crm_gateway

RUN mkdir -p $HOME

WORKDIR $HOME

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

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
    apt-get install -y tzdata build-essential nodejs vim libsodium-dev && \
    apt-get autoremove -y && \
    npm install --global yarn

RUN gem install --source "https://rubygems.org" bundler:2.2.33


COPY Gemfile .
COPY Gemfile.lock .
COPY package.json .
COPY yarn.lock .

# Setting env up
ENV RAILS_ENV='development'
ENV NODE_ENV='development'

# RUN bundle config set deployment 'true' && \
RUN cat $HOME/Gemfile
RUN cd $HOME && bundle install
RUN cd $HOME && yarn install

COPY . $HOME
