# Upgrade Gitlab
cd /opt/bitnami
sudo ./ctlscript.sh stop
sudo /opt/bitnami/ctlscript.sh start postgresql
sudo /opt/bitnami/ctlscript.sh start redis

cd /opt/bitnami/apps/gitlab/htdocs

# Backup
sudo -u git -H bundle exec rake gitlab:backup:create RAILS_ENV=production

# Gitlab Code
sudo -u git -H git fetch --all
sudo -u git -H git checkout -- db/schema.rb
sudo -u git -H git checkout 8-17-stable

# Libs Gems migration
cd /opt/bitnami/apps/gitlab/htdocs
sudo -u git -H bundle install --without mysql development test --deployment
sudo -u git -H bundle clean
sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production
sudo -u git -H npm install --production
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
sudo apt install nodejs -y
sudo -u git -H bundle exec rake gitlab:assets:clean gitlab:assets:compile cache:clear RAILS_ENV=production 

# Gitlab Workhorse
cd /opt/bitnami/apps/gitlab/htdocs
sudo -u git -H bundle exec rake "gitlab:workhorse:install[/opt/bitnami/apps/gitlab-workhorse]" RAILS_ENV=production

# Git configuration
cd /opt/bitnami/apps/gitlab/htdocs
sudo -u git -H git config --global repack.writeBitmaps true

# Restart
cd /opt/bitnami
sudo ./ctlscript.sh start

# Launch sidekiq
cd /opt/bitnami/apps/gitlab/htdocs
sudo -u git -H RAILS_ENV=production bin/background_jobs start

# Check
cd /opt/bitnami/apps/gitlab/htdocs
sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production
sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production

# LINKS
https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/update/8.*-to-8.*.md
https://docs.bitnami.com/aws/apps/gitlab/#step-1-prepare-for-upgrade
https://docs.bitnami.com/aws/how-to/use-gitlab/
https://bitnami.com/stack/gitlab
