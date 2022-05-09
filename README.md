# Roda Stack

Boilerplate for Roda + ArcadeDB projects.

This boilerplate includes the things I need most when starting a new project.

- dry-container based architecture
- bin/console (like `rails console`)
- RSpec setup
- I18n setup
- Continuous integration with Github Actions
- Params validation with `dry-validation`
- Documentation using `yard`.
- Environment is taken from »roda_env» 

A sample migration has been added to `migrate` folder.

# Running the app

You can start your application using `rackup` command.

# Running the console

```ruby
roda_env=production ./bin/console

```

The ruby [ArcadeDB](https://github.com/topofocus/arcadedb) Adapter is not released as Gem. 
Clone that project from GitHub and install it locally. 

The database handle is present via `Application[:db]` or `Arcade::Init.db`
