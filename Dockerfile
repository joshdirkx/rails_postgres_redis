FROM ruby:3.0.0-alpine
RUN apk add --update --no-cache bash build-base nodejs tzdata postgresql-dev yarn shared-mime-info npm bash
RUN gem install bundler

ARG DOPPLER_TOKEN

ENV DOPPLER_TOKEN=${DOPPLER_TOKEN}

# install the doppler cli
RUN wget -q -t3 'https://packages.doppler.com/public/cli/rsa.8004D9FF50437357.key' -O /etc/apk/keys/cli@doppler-8004D9FF50437357.rsa.pub && \
  echo 'https://packages.doppler.com/public/cli/alpine/any-version/main' | tee -a /etc/apk/repositories && \
  apk add doppler

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --check-files

COPY Gemfile Gemfile.lock ./
RUN bundle check || bundle install --verbose --jobs 20 --retry 5

COPY . ./

# Start the main process.
CMD ["./start.sh"]