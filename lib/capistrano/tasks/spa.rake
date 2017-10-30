namespace :load do
  task :defaults do
    set :spa_cache_dir, "tmp/spa"
    set :spa_branch, "master"
    set :spa_build_dir, "dist"
    set :spa_git_remote, "origin"
    set :rsync_cache_dir, fetch(:rsync_stage, "tmp/deploy")
    set :spa_build_cmds, [
      [:yarn, "install"],
      [:yarn, "build"],
    ]
    set :spa_repo_url, -> { raise Capistrano::ValidationError, "spa_repo_url param is required!" }
  end
end

namespace :spa do
  desc 'Clone SPA repository to cache dir, unless exists already'
  task :create_cache do
    next if File.directory?(fetch(:spa_cache_dir))

    run_locally do
       execute :git,
        :clone,
        fetch(:spa_repo_url),
        fetch(:spa_cache_dir),
        '--quiet --depth=1 --no-single-branch'
    end
  end

  desc 'Pull latest changes into SPA cache dir'
  task :update_cache do
    target = "#{fetch(:spa_git_remote)}/#{fetch(:spa_branch)}"
    run_locally do
      within fetch(:spa_cache_dir) do
        execute :git, :fetch, '--quiet --all --prune --depth=1'
        execute :git, :checkout, fetch(:spa_branch), '--quiet'
        execute :git, :reset, target, '--hard'
      end
    end
  end

  desc 'Build SPA application'
  task :build do
    run_locally do
      within fetch(:spa_cache_dir) do
        fetch(:spa_build_cmds).each do |cmd|
          execute *cmd
        end
      end
    end
  end

  desc 'Copy files to local rsync cache dir'
  task :copy_to_rsync_dir do
    destination_dir = "#{fetch(:rsync_cache_dir)}/public"
    build_dir = "#{fetch(:spa_cache_dir)}/#{fetch(:spa_build_dir)}"

    run_locally do
      execute :rm, '-rf', destination_dir
      execute :cp, '-r', build_dir, destination_dir
    end
  end

  task :all => [:create_cache, :update_cache, :build, :copy_to_rsync_dir]
end
