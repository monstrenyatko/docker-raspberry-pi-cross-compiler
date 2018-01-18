Raspberry Pi Compiler in a Docker Container
===========================================

[![Build Status](https://travis-ci.org/monstrenyatko/docker-rpi-cross-compiler.svg?branch=no_rpxc)](https://travis-ci.org/monstrenyatko/docker-rpi-cross-compiler)


About
=====

An easy-to-use all-in-one compiler for the Raspberry Pi.
See [Docker](https://www.docker.com).

Upstream Links
--------------
* Docker Registry @[monstrenyatko/rpi-cross-compiler](https://hub.docker.com/r/monstrenyatko/rpi-cross-compiler/)
* GitHub @[monstrenyatko/docker-rpi-cross-compiler](https://github.com/monstrenyatko/docker-rpi-cross-compiler/tree/no_rpxc/)

Features
--------
* Image based on [raspbian/jessie](https://hub.docker.com/r/raspbian/jessie/)
* Built-in `qemu-arm-static` allows running the image on `x86` platform (**Note:** performance might be not good).
* [CMake](https://cmake.org/)
* [Boost](http://www.boost.org) 1.55 C++ libraries
* `libssl-dev`. See [OpenSSL](https://www.openssl.org/)
* `libjansson-dev`. See [Jansson](https://github.com/akheron/jansson)

Usage
=====

1. Prepare the `run.sh` script to be executed into the container, this script performs the actual build:

    ```sh
        #!/bin/bash

        exiterr() { echo "Error: ${1}" >&2; exit 1; }

        set -e
        set -x

        if [ ! -f /.dockerenv ]; then
          exiterr "This script ONLY runs in a Docker container."
        fi

        # Your compilation commands
        # Ex:
        # cmake -D CMAKE_BUILD_TYPE=Release \
        #    /source
        # make
    ```
2. Prepare the  `build.sh` script for easy execution:

    ```sh
        #!/bin/bash

        set -e
        set -x

        exiterr() { echo "Error: ${1}" >&2; exit 1; }

        function abs_path {
            if [[ -d "$1" ]]
            then
                pushd "$1" >/dev/null
                pwd
                popd >/dev/null
            elif [[ -e $1 ]]
            then
                pushd "$(dirname "$1")" >/dev/null
                echo "$(pwd)/$(basename "$1")"
                popd >/dev/null
            else
                echo "$1" does not exist! >&2
                return 1
            fi
        }

        SRC_PATH=$(abs_path $1)
        if [ -z "$SRC_PATH" ]; then
            exiterr "$1 does not exist!"
        fi

        # Select the Docker image
        export DOCKER_IMAGE=monstrenyatko/rpi-cross-compiler:no_rpxc

        # If we are not running via boot2docker provide the current user UID and GID
        if [ -z $DOCKER_HOST ]; then
            BUILD_USER_IDS_ENV="-e BUILD_USER_UID=$( id -u ) -e BUILD_USER_GID=$( id -g )"
        fi

        # Execute build
        docker run --rm -it \
            $BUILD_USER_IDS_ENV \
            -v $PWD:/build \
            -v $SRC_PATH:/source \
            -w="/build" \
            $DOCKER_IMAGE /source/run.sh
    ```
3. Place both scripts to the `project sources root directory`
4. Start the out-of-source build:

    * create `build` directory and navigate to this directory:

    ```sh
        mkdir build && cd build
    ```

    * execute `build.sh` script:
    ```sh
        <path to project sources root directory>/build.sh <path to project sources root directory>
    ```


Build own image
===============

Own image based on available Main image
---------------------------------------

```Dockerfile
    FROM monstrenyatko/rpi-cross-compiler:no_rpxc

    # your modifications
```

Main image
----------

```sh
    ./build.sh monstrenyatko/rpi-cross-compiler:no_rpxc
```

Stage One image
---------------

The `Main image` based on this image to speed-up image recreation.

*Better to avoid rebuilding of this image and perform all required modifications into the `Main image`
or make own image based on available `Main image`.*

**Note:** Build takes plenty of time and sometimes fails/hangs on `x86` platform because of `QEMU` problems.
In case of problems, try to build directly on `ARM` platform to avoid `QEMU` emulation.

```sh
    ./stage_1/build.sh monstrenyatko/rpi-cross-compiler:no_rpxc_stage_1
```
