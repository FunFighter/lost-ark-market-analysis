docker container run \
  --rm \
  --tty \
  --volume ${pwd}/data:/home/dockerman/app/data \
  --volume ${pwd}/notebooks:/home/dockerman/app/notebooks \
  --publish 8888:8888 \
  test:1.0