FROM ruby:2.6.5-alpine3.11

RUN \
  apk add --update --no-cache \
    bash \
    build-base \
    curl \
    postgresql-client \
    postgresql-dev \
  && curl -L https://get.rvm.io | rvm_tar_command=tar bash -s stable \
  && gem install bundler

WORKDIR /usr/local/gifmachine

COPY /Gemfile /Gemfile.lock /usr/local/gifmachine/
RUN bundle install

COPY / /usr/local/gifmachine

COPY build/api/resources/usr /usr
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
