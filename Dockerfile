ARG DEBIAN_VERSION=trixie-slim
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

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

FROM elixir:1.13 AS app

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  inotify-tools \
  git \
  make \
  gcc \
  libssl1.1 \
  ca-certificates \
  build-essential \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

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
# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}
RUN echo "=== entered final stage (runner) ==="
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Copy over the build artifact from the previous step and create a non root user
RUN mkdir -p /app
WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=app --chown=nobody:root /app/_build/${MIX_ENV}/rel/absolventenfeier ./
COPY Procfile ./

USER nobody

EXPOSE 4000

ENTRYPOINT ["./bin/absolventenfeier"]
CMD ["start"]