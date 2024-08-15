# build it
FROM ruby:3.1.3 AS builder

RUN apt-get update && apt-get install gettext -y

WORKDIR /build-zone

COPY . .

RUN --mount=type=secret,id=WHY \
    echo "whyfile: $(cat /run/secrets/WHY)"


# interpolate secrets
RUN --mount=type=secret,id=ALL_SECRETS \
    echo "file: $(cat /run/secrets/ALL_SECRETS)" &&\
    echo "all: $(base64 -d /run/secrets/ALL_SECRETS)" &&\
    eval "$(base64 -d /run/secrets/ALL_SECRETS)" && \
    envsubst < _config.yml > tmp.yml && mv tmp.yml _config.yml

RUN gem install jekyll bundler
RUN bundle install 
RUN bundle exec jekyll build

# run it
FROM nginx:alpine AS runner

WORKDIR /app

COPY --from=builder /build-zone/_site/ ./
COPY ./nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080