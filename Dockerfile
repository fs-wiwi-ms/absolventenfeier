##
# Assets

FROM node:14 AS assets

RUN sed -i 's|deb.debian.org/debian|archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99disable-check-valid-until

RUN set -xe; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      inotify-tools \
      git \
      python3 make g++ \
    ; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app/assets

RUN mkdir -p /app/priv/static

COPY ./assets ./

ARG ENV=prod
ENV NODE_ENV $ENV

RUN yarn install

RUN if [ "$ENV" = "prod" ]; then yarn run deploy; fi

##
# App

FROM elixir:1.13-slim AS app

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  inotify-tools \
  git \
  make \
  gcc \
  libssl1.1 \
  ca-certificates \
  build-essential \
  && \
  rm -rf /var/lib/apt/lists/*

# Set environment variables for building the application
ARG ENV=prod
ENV MIX_ENV $ENV
ENV LANG=C.UTF-8

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Create the application build directory
RUN mkdir -p /app
WORKDIR /app

# Install and compile dependencies
COPY mix.* ./
RUN mix deps.get
RUN mix deps.compile

# Copy generated assets from asset container
RUN mkdir -p priv/static
COPY --from=assets /app/priv/static/ ./priv/static/

# workaround until docker or someone else gets his shit together
RUN true

# Fetch the application dependencies and build the application
COPY . ./
RUN mix compile --warning-as-errors
RUN if [ "$ENV" = "prod" ]; then mix do phx.digest, release absolventenfeier; fi

##
# Run
FROM debian:trixie-slim
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && \
  apt-get install -y --no-install-recommends \
  locales openssl && \
  rm -rf /var/lib/apt/lists/*

# Set LOCALE to UTF8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
  locale-gen en_US.UTF-8 && \
  dpkg-reconfigure locales && \
  /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8

# Copy over the build artifact from the previous step and create a non root user
WORKDIR /app
COPY --from=app /app/_build/prod/rel/absolventenfeier ./
COPY Procfile ./

ENTRYPOINT ["./bin/absolventenfeier"]
CMD ["start"]
