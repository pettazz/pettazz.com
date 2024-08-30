# build it
FROM ruby:3.1.3 AS builder

RUN apt-get update && apt-get install gettext -y

WORKDIR /build-zone

COPY . .

# interpolate secrets
RUN --mount=type=secret,id=ALL_SECRETS \
    eval "$(base64 -d /run/secrets/ALL_SECRETS)" && \
    export VARS="$(env | cut -d= -f1 | sed -e 's/^/$/')" && \
    echo $VARS && \
    envsubst "$VARS" < _config.yml > tmp.yml && mv tmp.yml _config.yml && \
    envsubst "$VARS" < nginx.conf > tmp.conf && mv tmp.conf nginx.conf

RUN gem install jekyll bundler
RUN bundle install 
RUN bundle exec jekyll build

# run it
FROM openresty/openresty:alpine AS runner

WORKDIR /app

COPY --from=builder /build-zone/_site/ ./
COPY --from=builder /build-zone/nginx.conf /etc/nginx/conf.d/site.conf

EXPOSE 8080