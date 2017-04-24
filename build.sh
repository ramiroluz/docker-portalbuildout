set -e

source settings.sh

docker build -t $USERNAME/$IMAGE:latest .
