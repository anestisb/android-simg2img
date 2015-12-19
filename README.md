simg2img
=========

Tool to convert Android sparse images to raw images.

Since image tools are not part of Android SDK, this standalone port of AOSP libsparse aims to avoid complex building chains.

```
$ make
$ simg2img /path/to/Android/images/system.img /output/path/system.raw.img
$ file /path/to/Android/images/system.img
system.img: Android sparse image, version: 1.0, Total of 262144 4096-byte output blocks in 1620 input chunks.
$ file /output/path/system.raw.img
system.raw.img: Linux rev 1.0 ext4 filesystem data, UUID=57f8f4bc-abf4-655f-bf67-946fc0f9f25b (extents) (large files)
```
