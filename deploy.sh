set -e
./increment_version.sh
flutter build web
flutter build appbundle