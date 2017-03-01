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
sudo -u git -H git checkout 8-13-stable

# Gitlab Shell
sudo chown git:git ../gitlab-shell/
cd /opt/bitnami/apps/gitlab/gitlab-shell
sudo -u git -H git fetch --all --tags
sudo -u git -H git checkout v3.6.6

# Gitlab Workhorse
cd /opt/bitnami/apps/gitlab-workhorse
sudo -u git -H git fetch --all
sudo -u git -H git checkout v0.8.5
sudo -u git -H make

# Upgrade Ruby
sudo apt-get install openssl
sudo apt-get install libqt4-dev libqtwebkit-dev libsqlite3-dev

mkdir /tmp/ruby && cd /tmp/ruby
curl --remote-name --progress https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.3.tar.gz
tar xzf ruby-2.3.3.tar.gz
cd ruby-2.3.3
./configure --with-opt-dir=/usr/local --with-openssl
make
sudo make install

cd /opt/bitnami/
sudo mv ruby2.1.0 ruby.bak
sudo cp -r /usr/local/lib/ruby .
sudo cp -r /usr/local/bin/ruby /opt/bitnami/ruby/bin/
sudo mkdir ruby/bin
sudo cp /usr/local/bin/ruby ruby/bin/
for i in $(ls ruby.back/lib/ruby/gems/2.1.0/gems/ | sed -e 's/\([^.]*\).*/\1/' -e 's/\(.*\)-.*/\1/'); do sudo gem install $i; done
sudo -u git -H gem source -a http://rubygems.org/
sudo -u git -H gem source -r https://rubygems.org/

# Libs Gems migration
cd /opt/bitnami/apps/gitlab/htdocs 
sudo gem install raindrops -v '0.17.0'
sudo -u git -H bundle install --without mysql development test --deployment
sudo -u git -H bundle clean
sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production
#sudo chmod 755 /opt/bitnami/apps/gitlab/htdocs/public/uploads

# Diff in configuration oprtions
git diff origin/8-12-stable:config/gitlab.yml.example origin/8-13-stable:config/gitlab.yml.example

# Restart
cd /opt/bitnami
sudo ./ctlscript.sh start

# Launch sidekiq
cd /opt/bitnami/apps/gitlab/htdocs
sudo -u git -H RAILS_ENV=production bin/background_jobs start

# Change hostname
sudo /opt/bitnami/apps/gitlab/bnconfig --machine_hostname gitlab.powermarket.uk

# Check
cd /opt/bitnami/apps/gitlab/htdocs
sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production
sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production

https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/update/8.*-to-8.*.md
https://docs.bitnami.com/aws/apps/gitlab/#step-1-prepare-for-upgrade
https://docs.bitnami.com/aws/how-to/use-gitlab/
https://bitnami.com/stack/gitlab