# build a new docker image
docker image build \
--build-arg username=dockerman \
--build-arg uid=1000 \
--build-arg gid=100 \
--file ./docker/Dockerfile \
  ../