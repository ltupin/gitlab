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

sudo gem install bundler --no-ri --no-rdoc # Needed for gems migration

sudo gem install passenger -v '5.0.6' # Needed for apache2
sudo cp -r /opt/bitnami/ruby_bitnami/lib/ruby/gems/2.1.0/gems/passenger-5.0.6/buildout /opt/bitnami/ruby/lib/ruby/gems/2.3.0/gems/passenger-5.0.6/
sudo vi /opt/bitnami/apache2/conf/pagespeed_libraries.conf # comment lines with 2.3.08 and 2.3.05 contents

find /opt/bitnami/apache2/conf/ -name "*.conf" -type f -exec sed -i "s/2.1.0/2.3.0/g" {} \;
sed -ie 's/2.1.0/2.3.0/g' /opt/bitnami/scripts/setenv.sh


for i in $(ls ruby2.1.9p490/lib/ruby/gems/2.1.0/gems/ | sed -e 's/\([^.]*\).*/\1/' -e 's/\(.*\)-.*/\1/'); do sudo gem install $i; done
