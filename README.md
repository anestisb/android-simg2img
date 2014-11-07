simg2img
=========

Tool to convert Android sparse images to raw images.

Code has been originally posted in Android AOSP, although has been removed from recent branches.


e.g.
```
$ simg2img system.img system.raw.img
$ file system.img
system.img: Android sparse image, version: 1.0, Total of 262144 4096-byte output blocks in 1620 input chunks.
$ file system.raw.img
system.raw.img: Linux rev 1.0 ext4 filesystem data, UUID=57f8f4bc-abf4-655f-bf67-946fc0f9f25b (extents) (large files)
```
