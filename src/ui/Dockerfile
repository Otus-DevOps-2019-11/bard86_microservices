FROM ruby:2.4.10-alpine3.10

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
ENV APP_HOME /app

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/

RUN apk add --no-cache --virtual .build-deps build-base \
    && gem install bundler -v "1.16.1" \
    && bundle install \
    && apk del .build-deps

COPY . $APP_HOME

CMD ["puma"]
