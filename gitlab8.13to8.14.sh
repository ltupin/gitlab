# Upgrade Gitlab
cd /opt/bitnami
sudo ./ctlscript.sh stop
sudo /opt/bitnami/ctlscript.sh start postgresql
sudo /opt/bitnami/ctlscript.sh start redis

cd /opt/bitnami/apps/gitlab/htdocs

# Backup
sudo -u git -H bundle exec rake gitlab:backup:create RAILS_ENV=production

# Gitlab Code
# If errors happend just add and commit the files
# or stash them... sudo -u git -H git stash save --keep-index
sudo -u git -H git fetch --all
sudo -u git -H git checkout -- db/schema.rb
sudo -u git -H git checkout 8-14-stable

# Gitlab Shell
sudo chown git:git ../gitlab-shell/
cd /opt/bitnami/apps/gitlab/gitlab-shell
sudo -u git -H git fetch --all --tags
sudo -u git -H git checkout v4.1.1

# Gitlab Workhorse
cd /opt/bitnami/apps/gitlab-workhorse
sudo -u git -H git fetch --all
sudo -u git -H git checkout v1.0.1
sudo -u git -H make

# Ruby upgrade
sudo apt update && sudo apt upgrade -y
sudo apt install openssl -y
sudo apt install libqt4-dev libqtwebkit-dev libsqlite3-dev -y
sudo apt install libicu-dev cmake -y

sudo mv /opt/bitnami/ruby /opt/bitnami/ruby_bitnami

mkdir /tmp/ruby && cd /tmp/ruby
curl --remote-name --progress https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.3.tar.gz
tar xzf ruby-2.3.3.tar.gz
cd ruby-2.3.3
./configure --with-openssl-dir=/usr/bin --prefix=/opt/bitnami/ruby/ --disable-install-rdoc
make
sudo make install

sudo gem install bundler # Needed for gems migration

sudo gem install passenger -v '5.0.6' # Needed for apache2
sudo cp -r /opt/bitnami/ruby_bitnami/lib/ruby/gems/2.1.0/gems/passenger-5.0.6/buildout /opt/bitnami/ruby/lib/ruby/gems/2.3.0/gems/passenger-5.0.6/
sudo vi /opt/bitnami/apache2/conf/pagespeed_libraries.conf # comment lines with 2.3.08 and 2.3.05 contents

find /opt/bitnami/apache2/conf/ -name "*.conf" -type f -exec sed -i "s/2.1.0/2.3.0/g" {} \;
sed -ie 's/2.1.0/2.3.0/g' /opt/bitnami/scripts/setenv.sh

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

# Regression on button in project view

# OLD CODE
<i aria-label="Toggle switch project dropdown" data-target=".js-dropdown-menu-projects" data-toggle="dropdown" class="fa fa-chevron-down dropdown-toggle-caret js-projects-dropdown-toggle"></i>
# NEW CODE
<button name="button" type="button" class="dropdown-toggle-caret js-projects-dropdown-toggle" aria-label="Toggle switch project dropdown" data-target=".js-dropdown-menu-projects" data-toggle="dropdown"><i class="fa fa-chevron-down"></i></button>

# LINKS
https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/update/8.*-to-8.*.md
https://docs.bitnami.com/aws/apps/gitlab/#step-1-prepare-for-upgrade
https://docs.bitnami.com/aws/how-to/use-gitlab/
https://bitnami.com/stack/gitlab


