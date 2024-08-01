set -e
./increment_version.sh
flutter build web --release
# This is where github pages will be deployed
rm -Rf docs/*
mv build/web/* docs/
git commit -am "Deploy to GitHub pages"
git push
flutter build appbundle