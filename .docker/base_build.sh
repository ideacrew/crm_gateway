docker build --build-arg BUNDLER_VERSION_OVERRIDE='2.2.33' \
             --build-arg NODE_MAJOR='12' \
             --build-arg YARN_VERSION='1.22.4' \
             -f .docker/base/Dockerfile --target crm_gateway -t $1:base .
docker push $1:base
