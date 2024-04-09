#!/bin/bash

set -x

build() {
    echo "Building Docker containers"
    docker-compose build
}

run() {
    echo "Running Docker containers"
    docker-compose up -d
}

stop() {
    echo "Stopping Docker container(s)..."
    docker-compose down
}

# Print usage menu
menu() {
    echo "Usage:"
    echo "  build - Create docker container(s) for the application"
    echo "  run   - Run the application as container(s)"
    echo "  stop  - Stop the container(s)"
}

if [ $# -eq 0 ]; then
    menu
    exit 1
fi

case "$1" in
    build)
        build
        ;;
    run)
        run
        ;;
    stop)
        stop
        ;;
    *)
        echo "Invalid command: $1"
        menu
        exit 1
        ;;
esac

exit 0
