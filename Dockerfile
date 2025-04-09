FROM ruby:3.2.4
ARG ROOT="/lean_up"
ENV TZ=Asia/Tokyo

WORKDIR ${ROOT}

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs vim postgresql-client libvips

COPY Gemfile ${ROOT}
COPY Gemfile.lock ${ROOT}
RUN gem install bundler
RUN bundle install --jobs 4

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
