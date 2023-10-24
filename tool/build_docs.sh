set -e
set -x

pushd example
flutter build web --web-renderer canvaskit --base-href "/flutter_arc_text/"
rm -rf $MELOS_ROOT_PATH/docs
mkdir $MELOS_ROOT_PATH/docs
cp -r build/web/ $MELOS_ROOT_PATH/docs
popd
