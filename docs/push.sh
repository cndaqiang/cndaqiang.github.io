dirname=$( dirname $(echo $0) )
cd $dirname
git add .
git commit -m "auto."$(date +'%Y.%m.%d_%H:%M')
git push origin master

