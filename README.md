# Absolventenfeier

[![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=fs-wiwi-ms/absolventenfeier)](https://dependabot.com)
[![Actions-Status](https://github.com/fs-wiwi-ms/absolventenfeier/workflows/publish-image/badge.svg)](https://github.com/fs-wiwi-ms/absolventenfeier/actions)

## Architecture

We have one Dockerfile which consists of three
[stages](https://docs.docker.com/develop/develop-images/multistage-build/):

1. A Elixir app which compiles, fetches dependencies, ...
2. A node.js app which compiles the assets. It uses libraries from the Elixir app.
3. A production stage which copies the results from (1) and (2) and runs them.

In development we split the Dockerfile up into two separate containers (using
the `target` directive) to continously re-compile the app and its assets.

Both containers share a volume with docker-sync to perfomantly access changed
files as well as for the Elixir app to deliver the compiled assets.

Developers can mount more Containers into the stack with a custom `docker-compose.user.yml` file.
It can look like this:

```yaml
  version: "3.4"

  services:
      adminer:
          image: adminer
          ports:
            - 8080:8080
          environment:
            ADMINER_DEFAULT_SERVER: db
            ADMINER_DESIGN: pepa-linha
```

## Setup

### Prerequisites

Install:

* Docker
* Docker-Compose

### Development

* Run `bin/dev`, it will run the three containers specified below. You can access the website by visiting `http://localhost:4000`.
* Run `bin/seed` to seed the database.

After the initial start things might be wonky. Just restart the app and you should be fine. There are two cases where you need to interact with Docker directly:

* In some cases the containers won't stop after <kbd>ctrl</kbd> + <kbd>c</kbd> and keep running in the background (`docker ps`). If so you need to run `docker-compose down` manually. The same goes for the tests.

### Testing

#### Unittesting

If you like you can run `bin/test up`, which will start a separate stack which continuously runs tests agains a test database.

## Update

### Elixir

* Check for outdated deps with `bin/compose run app mix hex.outdated` and maybe change version constraints in `mix.ex`.
* Run `bin/compose run app mix deps.update --all`
* Check app for errors before commiting

### Yarn

* Check for outdated deps with `bin/compose run assets yarn outdated` and maybe change version constraints in `assets/package.json`.
* Run `bin/compose run assets yarn upgrade`
* Check app for errors before commiting

## Hosting and Deployment

* Production URL: [absolventenfeier.de](https://absolventenfeier.de/)
* GitHub builds containers for each commit. Master commits will be pushed to Docker Packages.
* Server listens with watchtower for changes and restarts app container.

## Learn more about Phoenix

* [Official website](http://www.phoenixframework.org/)
* [Guides](https://hexdocs.pm/phoenix/overview.html)
* [Docs](https://hexdocs.pm/phoenix)
* [Mailing list](http://groups.google.com/group/phoenix-talk)
* [Source](https://github.com/phoenixframework/phoenix)

## License

Absolventenfeier

Copyright (C) 2020  Tobias Hoge

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
