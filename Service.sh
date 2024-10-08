sudo rm /etc/systemd/system/jekyll_blog.service
sudo nano /etc/systemd/system/jekyll_blog.service
[Unit]
Description=Jekyll Blog Service
After=network.target

[Service]
Type=simple
User=cndaqiang
WorkingDirectory=/home/cndaqiang/git/blog.cndaqiang
ExecStart=/bin/bash -c "source $HOME/.rvm/scripts/rvm && jekyll s --host=0.0.0.0"
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload
sudo systemctl start jekyll_blog.service
sudo systemctl status jekyll_blog.service


