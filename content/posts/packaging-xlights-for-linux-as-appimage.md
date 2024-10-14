---
author: cjd
tags:
  - xlights
date: "2017-10-19T22:56:11+00:00"
title: Packaging xLights for linux as AppImage
url: /blog/2017/10/20/packaging-xlights-for-linux-as-appimage/

---
Now that I have xLights being built fine within docker (see [Automatic testing of xLights builds via Travis-CI/Docker/Github](/blog/2017/10/16/automatic-testing-of-xlights-builds-via-travis-cidockergithub/)) the next step is to package up the application as an appimage binary so that it can easily be run on varied linux systems.

It is being built based on Ubuntu Trusty and has been tested to work on Ubuntu 16.04, 16.10, Fedora 25 and OpenSuse 42.2 (and should hopefully work pretty much anywhere else as well)

The creation of the AppImage is done by the [Recipe.appimage](/wp-content/uploads/xlights/build/Recipe.appimage) file that I included in the docker image.  This means that building of the appimage is simply:

```
$ docker pull debenham/xlights
$ docker run --name buildvm debenham/xlights /bin/bash Recipe.appimage
```

I'll break down the Recipe now to explain how it works:

First up we run the Recipe script to build xLights (as shown in previous post).

```
#!/bin/bash
./Recipe
```

Next up we setup the environment ready for later on.  The $VERSION number is generated using the version number in the xLights\_4\_64bit.iss (which is where the version number is explicitly set for the windows install and so is a good/safe place to grab from).   If I am generating a _release_ version (by passing 'release' as the command-line option) it will leave it at that.  If this is not a _release_ version (such as for testing/development) then it will also add the short hash of the last commit.  This is handy so I can easily tell which commit the package was built from.

```
export BASEDIR=/xLights
cd ${BASEDIR}/xlights-git
APP=xLights
COMMIT=`git log --pretty=format:'%h' -n 1`
VERS=`grep AppVersion xLights_4_64bit.iss |sed -e 's/^.*=//g'`
if [ "$1" = "release" ]
then VERSION=${VERS}
else VERSION=${VERS}-${COMMIT}
fi
```

Now we install xLights into the target AppDir directory

```
rm -rf ${BASEDIR}/$APP/
 mkdir ${BASEDIR}/$APP/
 make install DESTDIR=${BASEDIR}/$APP/$APP.AppDir PREFIX=/usr
```

Okay, we have xLights installed in ${BASEDIR}/$APP/$APP.AppDir so the next step is to setup this directory ready to be packaged up.  To do this we import the functions.sh script which contains a bunch of handy functions needed for building AppImages

```
cd ${BASEDIR}/$APP/

wget -q https://raw.githubusercontent.com/AppImage/AppImages/master/functions.sh -O ./functions.sh
 . ./functions.sh
```

Lets put the appicons/desktop launcher in place ready to go

```
cd ${BASEDIR}/$APP/$APP.AppDir

cp usr/share/icons/hicolor/256x256/apps/xlights.png .
cp usr/share/icons/hicolor/256x256/apps/xschedule.png .
cp ./usr/share/applications/xlights.desktop .
```

Next we need to grab the AppRun binary (which is basically a wrapper which takes care of setting up all the environment so the binary inside the AppImage uses the right libraries/paths etc).   Since xLights needs a newer libstdc++.so.6 than is included in Ubuntu Trusty we needed a specially patched AppRun which allows for the bundling of the newer library without breaking systems which already have a newer library.  See [https://github.com/darealshinji/AppImageKit-checkrt/](https://github.com/darealshinji/AppImageKit-checkrt/) for details of why this is needed.

```
wget -O AppRun https://github.com/darealshinji/AppImageKit-checkrt/releases/download/continuous/AppRun-patched-x86_64
 chmod +x AppRun
```

Now we need to find all the libraries needed by xLights and put them in place.  This is handled automatically by the copy\_deps function we imported previously from functions.sh.  I have to manually move the pulseaudio libraries to the common directory (so AppRun doesn't need to be modified further) and also remove libharfbuzz.\* as it causes xLights to be unable to run if it is included.  I also manually copy libstdc++.so.6 to the special path as needed by the modified AppRun.  We finish up by stripping the libraries to save space.

```
export LD_LIBRARY_PATH=./usr/lib/:$LD_LIBRARY_PATH

copy_deps ; copy_deps ; copy_deps # Three runs to ensure we catch indirect ones
 move_lib
 mv usr/lib/x86_64-linux-gnu/pulseaudio/* usr/lib/x86_64-linux-gnu
 rm usr/lib/x86_64-linux-gnu/libharfbuzz.*
 mkdir -p usr/optional/libstdc++
 cp /usr/lib/x86_64-linux-gnu/libstdc++.so.6 usr/optional/libstdc++/
 delete_blacklisted

strip usr/lib/* usr/lib/*/* || true
```

Almost done now. Just tell AppImageKit what the target launcher will be

```
get_desktopintegration xlights
```

Final steps now.  First we check if we are running within Docker. This is needed so that the generate function knows to not use FUSE to mount the image (since FUSE doesn't work properly within a standard docker container)

```
cd ..

########################################################################
 # AppDir complete
 # Now packaging it as an AppImage
 ########################################################################

if [[ ! $(cat /proc/1/sched | head -n 1 | grep init) ]]; then {
 echo in docker
 DOCKER_BUILD="yes"
 } fi
```

And the very last step is to call generate\_type2\_appimage to actually create the appimage file itself

```
generate_type2_appimage
```

After all this is done we are left with a xLights.xxxxxx.AppImage file sitting in ${BASEDIR}/out - ready for uploading to the web and people to use!

For me I then scp them to my web server and wordpress will show the new file automatically at /xlights-linux/
