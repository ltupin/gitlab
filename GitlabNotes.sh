#####################################################################################################
# Test Gitlab status
cd /opt/bitnami/apps/gitlab/htdocs
sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production

#####################################################################################################
# Lets running Sidekiq
cd /opt/bitnami/apps/gitlab/htdocs
sudo -u git -H RAILS_ENV=production bin/background_jobs start

# Notes
cd $GITLAB_HOME && RAILS_ENV=production /opt/bitnami/ruby/bin/ruby bin/rake sidekiq:start
GITLAB_SIDEKIQ_SCRIPT=/opt/bitnami/apps/gitlab/scripts/sidekiq.sh

#####################################################################################################
# Manage services
cd /opt/bitnami/
./ctlscript.sh (start|stop|restart)
./ctlscript.sh (start|stop|restart) postgresql
./ctlscript.sh (start|stop|restart) redis
./ctlscript.sh (start|stop|restart) apache
./ctlscript.sh (start|stop|restart) sidekiq
     
https://bitnami.com/stack/gitlab/README.txt

#####################################################################################################
#Change hostname
sudo /opt/bitnami/apps/gitlab/bnconfig --machine_hostname gitlab.powermarket.uk

#####################################################################################################
#Gitlab Key for Sentry
zkjykqYLwstiaLkhybsN

#####################################################################################################
# Ruby commands

ruby -v

gem source
gem source -a https://rubygems.org/

ls /usr/local/lib/ruby/gems/2.3.0/gems
ls ruby2.1.9p490/lib/ruby/gems/2.1.0/gems/

#####################################################################################################
# Soucis de checkout ? (non pris en compte)
# La branche est en statut detached:

bitnami@ip-172-31-35-26:/opt/bitnami/apps/gitlab/gitlab-shell$ sudo -u git -H git status
HEAD detached at v3.6.1
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   CHANGELOG
        modified:   VERSION
        modified:   bin/gitlab-keys
        modified:   bin/gitlab-shell
        modified:   hooks/update

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        bin/bundler

no changes added to commit (use "git add" and/or "git commit -a")


bitnami@ip-172-31-35-26:/opt/bitnami/apps/gitlab/gitlab-shell$ sudo -u git -H git checkout master
error: Your local changes to the following files would be overwritten by checkout:
        CHANGELOG
        VERSION
        hooks/update
Please, commit your changes or stash them before you can switch branches.
Aborting

Before performing the checkout step in step 2, you must stash your changes with git stash, perform the 
checkout and pop the stashed content, solving any merging issue that arises. 
(I only had to execute git rm /opt/bitnami/apps/gitlab/htdocs/config/gitlab.yml.example to do that).

error: unable to unlink old 'CHANGELOG' (Permission denied)
error: unable to unlink old 'VERSION' (Permission denied)

sudo chown git:git ../gitlab-shell/
sudo -u git -H git rm -f VERSION
sudo -u git -H git rm -f CHANGELOG
sudo -u git -H git commit -m "Before 3.6.1"