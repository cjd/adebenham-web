---
author: cjd
date: "2010-02-04T00:50:41+00:00"
title: MTPfs
url: /mtpfs/
summary: MTPfs is a FUSE filesystem that supports reading and writing from any MTP device (as supported by [libmtp](http://libmtp.sourceforge.net/))
thumbnail: /images/MTPfs.png

---
MTPfs is a FUSE filesystem that supports reading and writing from any MTP device (as supported by [libmtp](http://libmtp.sourceforge.net/))

See source at [https://github.com/cjd/mtpfs](https://github.com/cjd/mtpfs) **Current Version: _1.1_** **Download:** [mtpfs-1.1.tar.gz](/files/mtp/mtpfs-1.1.tar.gz)

### Currently implemented

- Support multiple storage areas
- Browsing Folders
- Reading files
- Writing files
- Browsing playlists
- Writing playlists
- Writing music tracks with metadata

### Details

When files are written their file extension is checked to determine the filetype. This means that images, videos and ics files (for instance) will be recognised by the player (rather than setting filetype to 'unknown').
There is also a virtual directory called "/Playlists" which contains your playlists as m3u files. If you write an m3u file to that directory a playlist will be created as well. m3u files are just a text file containing a list of all tracks you want in the playlist one per line)

You can disable libmad (used for mp3 metadata) by adding --disable-mad to the configure command

## MTPfs posts

\[xilipostinpost query="cat=35" showexcerpt=0 showcontent=1 beforetitle='

## ' aftertitle="

"\]
