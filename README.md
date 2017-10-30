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

#### Configuration

* `:spa_repo_url` - required
* `:spa_cache_dir`, defaults to: `tmp/spa`
* `:spa_branch`, , defaults to: `master`
* `:spa_build_dir`, defaults to: `dist`
* `:spa_git_remote`, defaults to: `origin`
* `:rsync_cache_dir`, default to `tmp/deploy`
* `:spa_build_cmds`, default to: `[[:yarn, "install"], [:yarn, "build"]]`

#### Notes

To precompile rails assets properly, you can either:

* do it locally after SPA app is built, for example:

    `after 'spa:all', 'assets:my_custom_precompile_task'`
    
* or using `capistrano-rails`, but to make it work you need to clear one of it's tasks which is symlinking `public/assets` dir, which we don't want:

     `Rake::Task["deploy:set_linked_dirs"].clear`

If you don't want to use rsync strategy for your rails app, you can skip the last task (`spa:copy_to_rsync_dir`) and move the SPA build to the server by yourself in anyway you like it.

Also, depending on your `apache/nginx` server config, `index.html` should be served automatically, but if it's not on static files whitelist you can either add it to the list or serve `index.html` from controller, like:

    root "welcome#index"

    def index
      render file: 'public/index.html', layout: false
    end    
