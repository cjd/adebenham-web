---
author: cjd
tags:
  - xlights
date: "2017-10-15T23:04:48+00:00"
guid: https://www.adebenham.com/?p=262
title: Automatic testing of xLights builds via Travis-CI/Docker/Github
url: /blog/2017/10/16/automatic-testing-of-xlights-builds-via-travis-cidockergithub/

---
[xLights](http://xlights.org/) is a free and open source program that enables you to design, create and play amazing lighting displays through the use of DMX controllers, E1.31 Ethernet controllers and more.

With it you can layout your display visually then assign effects to the various items throughout your sequence. This can be in time to music (with beat-tracking built into xLights) or just however you like.
Currently xLights runs on [Windows](https://xlights.org/faq/how-to-install-xlights-on-windows/), [OSX](https://xlights.org/faq/how-to-install-xlights-on-osx/) and [Linux](https://xlights.org/faq/how-to-install-xlights-on-linux/)

I look after the Linux build and since most of the other core developers are running Windows or OSX build/compile issues occasionally come up.

To help know when/how such breakage occurs I have setup automatic builds via [travis-ci](https://travis-ci.org/smeighan/xLights) which are triggered after every commit.  This way when a commit breaks the linux build I get an email so I can quickly go and check/fix as needed.  Thanks to the integration with GitHub

Setting this up was a bit more complicated than just turning on builds in travis-ci.

By default the build environment on travis-ci is Ubuntu trusty (which is the Ubuntu I want to use as it is the oldest LTS still supported and so useful for AppImage builds) - but sadly that doesn't have new enough libraries (in particular the ffmpeg libraries) and also the build toolchain is too old (need C++14 support which is only in the newer gcc).  Adding these dynamically every build was not practical.  As such I had to build a custom docker image which was pre-configured with the necessary libraries/tools etc.  Doing it this way also meant that I could provide a pre-compiled wxwidgets as part of the image rather than having to rebuild it every time (this saves substantial time).

To build the Docker image I had to create a suitable ' [Dockerfile](/wp-content/uploads/xlights/build/Dockerfile)' which describes the build of the image.  This dockerfile was as follows:

```
FROM ubuntu:14.04

ADD cbp2make /usr/bin/cbp2make
ADD Recipe.deps /Recipe.deps
ADD Recipe /Recipe
ADD Recipe.appimage /Recipe.appimage

RUN bash -ex Recipe.dep
```

This dockerfile is different to most others I have seen.

It starts by saying the base image (Ubuntu 14.04) and then adds a couple of files.  Rather than having the dockerfile cause the complete build of xLights it just sets up for future builds.

It adds four files, the first being a quick pre-built cbp2make (since that is not available in ubuntu 14.04 - this was the simplest way to add)

The next three are Recipe files.

- [Recipe.deps](/wp-content/uploads/xlights/build/Recipe.deps) just sets up the image by installing dependencies and pre-building wxWidgets.
- [Recipe](/wp-content/uploads/xlights/build/Recipe) clones the source of xLights from GitHub and then builds it.
- Recipe.appimage takes the built xLights and packages it up as an [AppImage](https://appimage.org/) binary.

Then it only runs the Recipe.deps - this way the docker image is ready to build and we don't waste time rebuilding things that don't change.

Once this was setup with all those files in a single directory the next step was to build the docker image and upload to docker hub.

```
$ ls
cbp2make Dockerfile out Recipe Recipe.appimage Recipe.deps
$ docker build -t xlights_image .
$ docker create --name xlights_container xlights_image
$ docker tag xlights_image debenham/xlights:latest
$ docker push debenham/xlights:latest
```

This simply build the docker image and called it 'xlights\_image'.  This runs the Dockerfile script which adds the required files and then runs Recipe.deps to preconfigure the image.

It then created a container from this image, tagged it with my dockerhub username and finally uploaded to dockerhub so that Travis-CI can use it.

At this point I could test the build (from almost anywhere) by simply pulling the image and running the 'Recipe' script.

```
$ docker pull debenham/xlights
$ docker run --name buildvm debenham/xlights /bin/bash Recipe
```

If I want to build the AppImage binary I do the same thing - but run the Recipe.appimage script instead.

```
$ docker pull debenham/xlights
$ docker run --name buildvm debenham/xlights /bin/bash Recipe.appimage
```

Now all that was left was to integrate this with GitHub/Travis-CI.  This is done by creating a ' [.travis.yml](https://github.com/smeighan/xLights/blob/master/.travis.yml)' file in the root of the git repository.

Thanks to the docker image this file is simple

```
dist: trusty
sudo: required
services:
    - docker
git:
    depth: 3
script:
    - docker pull debenham/xlights
    - docker run --name buildvm debenham/xlights /bin/bash Recipe
notifications:
    email:
      recipients:
        - chris@adebenham.com
        - keithsw1111@hotmail.com
     on_success: never
     on_failure: always
```

This travis file starts by saying what the build needs (ubuntu trusty, docker, sudo etc).  Then describes how to build/test xLights (by pulling the image and then running the Recipe).  Once this is done it says what sort of notifications are needed.  In this case it will notify via email to myself and one other developer.  It also says that want to be notified when the build fails (rather than on every build)

All that remained was going to Travis-CI and turning on the automatic build.

In a coming post I will describe how I build both AppImage binaries and Ubuntu packages for each release.
