#!/bin/bash

echo "This will remove EVERYTHING in docker."
read -p "Are you sure you want to proceed? [Y/n] " answer

answer=${answer:-n}

case $answer in
    [Yy]* )
        echo "Removing all Docker objects..."
        docker stop $(docker ps -aq)
        docker rm $(docker ps -aq)
        docker rmi $(docker images -q) --force
        docker system prune --volumes
        echo "All Docker object removed."
        ;;
    [Nn]* )
        echo "Operation cancelled."
        ;;
    * )
        echo "Invalid input. Please answer yes (Y) or no (n)."
        ;;
esac
