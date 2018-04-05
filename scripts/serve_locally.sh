#!/usr/bin/env bash
docker run -it --rm --name jekyll -p 4000:4000 -v /Users/wonderfly/src/github.com/wonderfly/wonderfly.github.io/vendor/bundle/:/usr/local/bundle:rw -v /Users/wonderfly/src/github.com/wonderfly/wonderfly.github.io/:/srv/jekyll:rw jekyll/jekyll jekyll serve
