simg2img
=========

Tool to convert Android sparse images to raw images.

Since image tools are not part of Android SDK, this standalone port of AOSP libsparse aims to avoid complex building chains.

Usage
-----

```
$ make
$ simg2img /path/to/Android/images/system.img /output/path/system.raw.img
$ file /path/to/Android/images/system.img
system.img: Android sparse image, version: 1.0, Total of 262144 4096-byte output blocks in 1620 input chunks.
$ file /output/path/system.raw.img
system.raw.img: Linux rev 1.0 ext4 filesystem data, UUID=57f8f4bc-abf4-655f-bf67-946fc0f9f25b (extents) (large files)
```

Windows
-------

If you want to build simg2img on Windows you'll need to [install MinGW](http://www.mingw.org/wiki/howto_install_the_mingw_gcc_compiler_suite)
and also zlib and libasprintf (go to MinGW Libraries in the installer and check `mingw32-libz` and `mingw32-libasprintf`).
Once you've done that run the following command to build simg2img:

```
CFLAGS=-DUSE_MINGW LDFLAGS=-lasprintf mingw32-make
```

Linux
------

If zlib.h is missing then install it using

Ubuntu: ```sudo apt-get install libz-dev```

Fedora: ```sudo dnf install libz-devel```
