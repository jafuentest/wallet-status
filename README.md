# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
  * MRI 3.0.0

* System dependencies
  * PostgreSQL 13.3 or higher
  * Before attempting Capistrano deploy:
    * Install rvm + Ruby version
    * Install Postgres developer package
    * Install NodeJS + Yarn

<!-- * Configuration -->

* Database creation
  ```
  CREATE DATABASE wallet_status_production;
  CREATE USER wallet_status WITH ENCRYPTED PASSWORD '<secure-password>';
  GRANT ALL PRIVILEGES ON DATABASE wallet_status_production TO wallet_status;
  ```

<!-- * Database initialization -->

<!-- * How to run the test suite -->

* Services <!-- (job queues, cache servers, search engines, etc.) -->
  * Uses Delayed Job for background tasks

* Deployment instructions
  * Make sure you have installed base dependencies in your server

  * Store the appropiate ssh key on your own PC
  ```
  ~/.ssh/wallet-status.pem
  ```

  * Run capistrano deploy. If if fails just continue with the steps and try
  again at the end
  ```
  cap production deploy
  ```

  * Now go to your server and:
  ```
  # Assuming you installed the app on your /home/your-user/wallet_status
  cd ~/wallet_status/current

  # Sets up the puma service
  cp ./ops/puma_wallet_status.service /etc/systemd/system

  # Sets up Nginx
  cp ./ops/wallet_status.conf /etc/nginx/conf.d
  # Create the certificate
  service nginx restart
  ```

  * Run seeds (after a successful deployment)
  ```
  cd ~/wallet_status/current
  RAILS_ENV="production" bundle exec rails db:seed
  ```
