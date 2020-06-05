#!/bin/bash -xe
docker stop aws_bootstrap || true
docker rm aws_bootstrap || true