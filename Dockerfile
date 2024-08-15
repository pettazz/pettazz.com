# build it
FROM ruby:3.1.3 AS builder

WORKDIR /build-zone

COPY . .

envsubst < _config.yml > tmp.yml && mv tmp.txt _config.yml

RUN gem install jekyll bundler
RUN bundle install 
RUN bundle exec jekyll build

# run it
FROM nginx:alpine AS runner

WORKDIR /app

COPY --from=builder /build-zone/_site/ ./
COPY ./nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080