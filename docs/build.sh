cd docs
gitbook build --gitbook=3.2.2
cp -rf _book/* ../
cd ../
git add .
git commit -m 'regenerated docs'
git push origin master
