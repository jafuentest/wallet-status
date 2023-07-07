# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
  * MRI 3.0.0

* System dependencies
  * PostgreSQL 13.3 or higher

* Services <!-- (job queues, cache servers, search engines, etc.) -->
  * Uses Delayed Job for background tasks

## Capistrano deployment

1. Install basic dependencies
  * Postgres server
  * rvm + Ruby version
  * NodeJS + Yarn
  * Postgres devel package

2. Ensure ssh key exists and is available
    ```
    ~/.ssh/wallet-status.pem
    ```

3. Login to the psql shell with root privileges
    ```
    CREATE DATABASE wallet_status_production;
    CREATE USER wallet_status WITH ENCRYPTED PASSWORD '<secure-password>';
    GRANT ALL PRIVILEGES ON DATABASE wallet_status_production TO wallet_status;
    ```

4. Copy system configuration files. Assuming that:
  * The cap deploy_to dir is `~/wallet_status`
  * The domain is `wallet_status.wikifuentes.com`
    ```
    mkdir -p ~/wallet_status/shared/config

    # Copies the master key to decrypt rails secrets
    scp -i ~/.ssh/wikifuentes.pem config/master.key ec2-user@wallet-status.wikifuentes.com:~/wallet_status/shared/config

    # Sets up the puma service
    scp -i ~/.ssh/wikifuentes.pem ops/wallet_status.conf ec2-user@wallet-status.wikifuentes.com:/etc/nginx/conf.d

    # Sets up Nginx
    scp -i ~/.ssh/wikifuentes.pem ops/puma_wallet_status.service ec2-user@wallet-status.wikifuentes.com:/etc/systemd/system
    ```

5. Deploy!
    ```
    cap production deploy
    ```

6. Now ssh to the server `ssh -i ~/.ssh/wikifuentes.pem ec2-user@wallet-status.wikifuentes.com` and
  * Create and setup the SSL certificate https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/SSL-on-amazon-linux-2.html#letsencrypt

  * Patch app files permissions (This is lazy way, for a safer way the app should be outside home, like `/var/www/`)
    ```
    chmod +x ~
    chmod +x ~/wallet_status -R
    ```

  * Restart Nginx
    ```
    sudo service nginx restart
    ```

7. Initialize the database
    ```
    cd ~/wallet_status/current
    RAILS_ENV="production" bundle exec rails db:seed
    ```
