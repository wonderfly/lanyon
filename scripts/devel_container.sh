#!/usr/bin/env bash
docker run --rm --name blog -it -v /Users/wonderfly/src/github.com/wonderfly/wonderfly.github.io/:/github/:rw -u wonderfly wonderfly/devel
