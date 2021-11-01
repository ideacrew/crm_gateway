FROM public.ecr.aws/ideacrew/crm_gateway:base AS crm_gateway

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

RUN gem install --source "https://rubygems.org" bundler:2.2.14

# Configure app home directory
ENV HOME /crm_gateway
RUN mkdir -p $HOME
WORKDIR $HOME
COPY . $HOME

# Setting env up
ENV RAILS_ENV='production'
ENV NODE_ENV='production'

ARG CRM_GATEWAY_DB_HOST
ARG CRM_GATEWAY_DB_PORT
ARG CRM_GATEWAY_DB_NAME
ARG RABBITMQ_URL_EVENT_SOURCE
ARG RABBITMQ_HOST
ARG RABBITMQ_PORT
ARG RABBITMQ_VHOST
ENV CRM_GATEWAY_DB_HOST=$CRM_GATEWAY_DB_HOST
ENV CRM_GATEWAY_DB_PORT=$CRM_GATEWAY_DB_PORT
ENV CRM_GATEWAY_DB_NAME=$CRM_GATEWAY_DB_NAME
ENV RABBITMQ_URL_EVENT_SOURCE=$RABBITMQ_URL_EVENT_SOURCE
ENV RABBITMQ_HOST=$RABBITMQ_HOST
ENV RABBITMQ_PORT=$RABBITMQ_PORT
ENV RABBITMQ_VHOST=$RABBITMQ_VHOST

# RUN bundle config set deployment 'true' && \
RUN bundle install --jobs 20 --retry 5 --without development test
RUN yarn install
#RUN bundle exec rake assets:precompile
RUN bundle exec rails webpacker:compile
