set -e
./increment_version.sh
flutter build web
# This is where gihub pages will be deployed
mv build/web/* docs/
flutter build appbundle