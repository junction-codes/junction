# Junction

_(Where's your dysfunction?)_

[![codecov][codecov-badge]][codecov-report]

Junction is an internal developer portal inspired by [Backstage]. Built using
[Ruby on Rails][rails], it aims to implement many of the same concepts while
focusing on developer experience and ease of use.

## Why Rails?

We're Rubyists, and we believe that Rails (and Ruby in general) is uniquely
suited for rapid development of scalable, extensible web applications. We're
not experts in Typescript and learning an entirely new ecosystem just to build
and maintain a developer portal wasn't practical. Instead, we built upon the
concepts created by the Backstage team using the tools we know and work with
every day.

## Getting started

> [!WARNING]
> Junction is still in early development and should not be considered stable.
> APIs are likely to change and there is no guarantee of compatibility between
> commits.
>
> Contributors and testers are welcome, but please use with caution and care.

### Quick Start

The fastest way to try Junction is to create a new Rails app and add Junction as
a gem.

1. Create a new Rails app (if you don't have one)

   ```bash
   rails new my-portal
   cd my-portal
   ```

1. Add Junction to your Gemfile

   ```bash
   bundle add "junction-codes" --git https://github.com/junction-codes/junction.git
   bundle insall
   ```

1. [Configure your database][database-config]
1. Run the install generator

   > [!NOTE]
   > This will:
   >
   > - Mount the Juntion engine
   > - Create the database
   > - Install and run all migrations
   > - Create a default admin user (`admin@example.com` / `passWord1!`)

   ```bash
   ./bin/rails g junction:install
   ```

1. Compile assets and start the application in development

   ```bash
   ./bin/rails assets:precompile
   ./bin/dev
   ```

You should now be able to access the application at http://localhost:3000. Log
in using the default username and password `admin@example.com` and `passWord1`.

> [!CAUTION]
> Remember to change the default password before making the application
> available outside your local system.

[backstage]: https://backstage.io/
[codecov-badge]: https://codecov.io/github/junction-codes/junction/graph/badge.svg?token=RXGOZ8UNEM
[codecov-report]: https://codecov.io/github/junction-codes/junction
[database-config]: https://guides.rubyonrails.org/configuring.html#configuring-a-database
[rails]: https://rubyonrails.org/
