docker start ubuntu_page
docker exec  -it ubuntu_page bash
cd /data/git/blog.cndaqiang
nohup bundle exec jekyll s --host=0.0.0.0 &
#要多等一会
#报错就再执行一边就好了
exit
