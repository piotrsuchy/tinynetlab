#!/bin/bash

docker stop host1
docker rm host1
docker stop host2
docker rm host2
docker network rm bridge_1
