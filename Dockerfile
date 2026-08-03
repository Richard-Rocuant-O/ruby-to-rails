FROM ruby:3.3

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    default-libmysqlclient-dev \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile* ./
RUN if [ -f Gemfile ]; then bundle install; fi

COPY . .

EXPOSE 3000
