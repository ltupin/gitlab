#####################################################################################################
# Upgrade GO
cd /tmp
wget https://storage.googleapis.com/golang/go1.7.3.linux-amd64.tar.gz
tar -xzvf go*.gz

cd /opt/bitnami
sudo mv go go.back
sudo mv /tmp/go /opt/bitnami
export PATH=$PATH:/opt/bitnami/go/bin
# Add this path to $HOME/.profile