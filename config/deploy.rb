# Ruby version, should match Gemfile
set :rvm_ruby_version, '3.3.5'

# config valid for current version and patch releases of Capistrano
# lock '~> 3.18.1'

set :application, 'wallet_status'
set :repo_url, 'git@github.com:jafuentest/wallet-status.git'

# Default branch is :master
branch_name = `git rev-parse --abbrev-ref HEAD`.chomp
branch_name == 'master' ? set(:branch, branch_name) : ask(:branch, branch_name)

# Default deploy_to directory is /var/www/wallet_status
set :deploy_to, '/home/ec2-user/wallet_status'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w[config/master.key config/credentials.yml.enc]

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'vendor', 'storage'

# Default value for default_env is {}
# set :default_env, { path: '/opt/ruby/bin:$PATH' }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :bundle_without, %w[development test]

set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w[~/.ssh/id_rsa.pub] }

set :puma_preload_app, true
set :puma_init_active_record, true # Change to false when not using ActiveRecord

# Name for the systemd service, default: "puma_#{fetch(:application)}_#{fetch(:stage)}"
set :puma_service_unit_name, 'puma_wallet_status.service'
set :puma_systemctl_user, :system

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end
end
