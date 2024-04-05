[![docker](https://github.com/volodya-lombrozo/rultor-image/actions/workflows/docker-build.yml/badge.svg)](https://github.com/volodya-lombrozo/rultor-image/actions/workflows/docker-build.yml)
[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/volodya-lombrozo/rultor-image)](https://hub.docker.com/r/volodya-lombrozo/rultor-image)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/volodya-lombrozo/total/rultor-image/master/LICENSE.txt)

This is a fork of the default Docker image
for [Rultor](https://github.com/yegor256/rultor-image). The primary distinction
is that this image is designed exclusively for Java projects. Unlike the main
image, which is quite large and slow to build, this one is significantly smaller
and faster

Docker Hub
as [`lombrozo/rultor-image-java`](https://hub.docker.com/r/lombrozo/rultor-image-java).

This image has Ubuntu 22.04 and the following packages, in their latest
versions:

* Git
* sshd
* Java
* Maven
* Ruby (left intentionally, to use `xcop` and `pdd` utilities)

Images uses Java 17.

Feel free to add yours by submitting a pull request.
