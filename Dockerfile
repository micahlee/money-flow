FROM ruby:2.5.7

RUN apt-get update -y && \
    apt-get install -y curl software-properties-common

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get update -qq && \
    apt-get install -y nodejs postgresql-client

RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 4567

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
