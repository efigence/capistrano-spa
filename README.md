# Capistrano::SPA

Want to deploy a single-page-application (which uses your rails api) along with your rails backend?

#### Requirements

* using capistrano v3
* keeping front-end app in separate repository
* not keeping `public` directory inside your rails app repository

#### Installation

1. Add to Gemfile: `gem "capistrano-spa"`
2. Require in Capfile: `require 'capistrano/spa'`

#### Usage

Preferred way is to use it with [capistrano rsync](https://github.com/Bladrak/capistrano-rsync) extension.

Task `spa:all` consists of 4 tasks:

1. `spa:create_cache` - clones your SPA app into `YOUR_RAILS_APP/tmp` (or other dir of your choice)
2. `spa:update_cache` - updates spa cache dir, if already been cloned
3. `spa:build`: builds the SPA app with command you've passed (defaults to `yarn install && yarn build`)
4. `spa:copy_to_rsync_dir`: copies the built package (that usually means `dist`) into the `public` folder of rsync cache directory of your Rails application

You need to call the Capistrano task provided by this gem by yourself (this way you can call it anytime you need - depending on your deploy strategy). If you're using `capistrano-rsync`, then proper way to do it is after rails rsync cache dir has been prepared - it's going to append content of SPA app into `public` dir just before it's rsync'ed to server.

`after 'rsync:stage_done', 'spa:all'`

If you need asset pipeline's assets on production, then it's advised to precompile then locally just after running `spa:all`. This way rails assets will get appended to public folder before rsync'ing data to server. As an alternative to `capistrano/rails/migrations`, you can do it like:

    # Precompile webpack assets locally
    namespace :assets do
      task :compile do
        run_locally do
          with rails_env: fetch(:stage) do
            Dir.chdir fetch(:rsync_stage) do
              execute 'cp config/database.dev.yml config/database.yml'
              execute :bundle, 'exec bin/rails assets:precompile'
            end
          end
        end
      end
    end

    after 'spa:all', 'assets:compile'

#### Configuration

* `:spa_repo_url` - required
* `:spa_cache_dir`, defaults to: `tmp/spa`
* `:spa_branch`, , defaults to: `master`
* `:spa_build_dir`, defaults to: `dist`
* `:spa_git_remote`, defaults to: `origin`
* `:rsync_cache_dir`, default to `tmp/deploy`
* `:spa_build_cmds`, default to: `[[:yarn, "install"], [:yarn, "build"]]`

#### Notes

If you don't want to use rsync strategy for your rails app, you can skip the last task (`spa:copy_to_rsync_dir`) and move the SPA build to the server by yourself in anyway you like it.
