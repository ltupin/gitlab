# Upgrade Gitlab
cd /opt/bitnami
sudo ./ctlscript.sh stop
sudo /opt/bitnami/ctlscript.sh start postgresql
sudo /opt/bitnami/ctlscript.sh start redis

cd /opt/bitnami/apps/gitlab/htdocs
# Backup
# sudo -u git -H bundle exec rake gitlab:backup:create RAILS_ENV=production

# Gitlab Code
# If errors happend just add and commit the files
sudo -u git -H git fetch --all
sudo -u git -H git checkout -- db/schema.rb
sudo -u git -H git checkout 8-12-stable

# Gitlab Shell
sudo chown git:git ../gitlab-shell/
cd /opt/bitnami/apps/gitlab/gitlab-shell
sudo -u git -H git fetch --all --tags
sudo -u git -H git checkout v3.6.1

# Gitlab Workhorse
cd /opt/bitnami/apps/gitlab-workhorse
sudo -u git -H git fetch --all
sudo -u git -H git checkout v0.8.2
sudo -u git -H make

# Libs Gems migration
cd /opt/bitnami/apps/gitlab/htdocs
sudo -u git -H bundle install --without mysql development test --deployment
sudo -u git -H bundle clean
sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production
sudo chmod 755 /opt/bitnami/apps/gitlab/htdocs/public/uploads

# Restart
cd /opt/bitnami
sudo ./ctlscript.sh start

# Launch sidekiq
cd /opt/bitnami/apps/gitlab/htdocs
sudo -u git -H RAILS_ENV=production bin/background_jobs start

# Check
sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production
sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production