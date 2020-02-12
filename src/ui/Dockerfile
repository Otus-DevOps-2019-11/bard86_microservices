FROM alpine:3.11

LABEL maintainer="Denis Barsukov <job.dbarsukov@gmail.com>"

COPY gemrc /root/.gemrc

RUN apk update \
    && apk --no-cache add ruby \
                          ruby-etc \
                          ruby-bigdecimal \
    && apk --no-cache add --virtual .build-dependencies \
           build-base \
           ruby-dev \
    && gem install bundler -v 1.17.3 \
    && gem install json \
    && gem cleanup \
    && apk del .build-dependencies \
    && rm -rf /usr/lib/ruby/gems/*/cache/* \
          /var/cache/apk/* \
          /tmp/* \
          /var/tmp/*

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY Gemfile* $APP_HOME/

RUN apk add --no-cache --virtual .build-dependencies \
        build-base \
        ruby-dev \
    && bundle install \
    && apk del .build-dependencies \
    && rm -rf /usr/lib/ruby/gems/*/cache/* \
          /var/cache/apk/* \
          /tmp/* \
          /var/tmp/*

COPY . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000

ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
