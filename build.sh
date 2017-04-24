set -ex

source settings.sh

docker build -t $USERNAME/$IMAGE:latest .
