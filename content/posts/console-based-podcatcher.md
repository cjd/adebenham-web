---
author: cjd
date: "2009-03-19T07:12:25+00:00"
tags:
  - bashpodder
  - scripts
title: Console-based podcatcher
url: /blog/2009/03/19/console-based-podcatcher/

---
A few days ago I installed a new disk in my laptop to replace the existing small one. Being the careful person I am I backed up the important data and then migrated the contents from the old disk to the new one via rsync.   Everything worked well and I was able to boot into the new disk right away without issue.   That is until I went to update the podcasts I listen to.

I had forgotten that I keep my podcasts (and the script I used to grab them) on a ZFS partition that I accessed via zfs-fuse (since I access it from linux)   Being the careful person I am I had forgotten to backup that partition :-(

As such I was faced with re-constructing the script from memory or rewriting from scratch - I chose option 2.

I remember a while back finding a simple bash-based podcatcher called [BashPodder](http://lincgeek.org/bashpodder) that I figured would be a good base. But the problem was that BashPodder is designed for running from a cronjob on a daily basis and offers no real display of status, no parallelism etc but it did know how to parse a rss feed and that is what I most wanted.

I took that script and then re-designed it for usage as a console application.   It now will fork a sub-process for each feed and download all the feeds in parallel while providing a status screen showing how much is download, the percent finished, the download rate, the estimated download time remaining and the filename for each feed.

Here is a sample output:

```
    Down|Perc| Rate| Remain|Filename
-----------------------------------------------------------------
195600K| 70%| 110K| 23m12s|tekzilla--0080--itunes--large.xvid.avi
154550K| 33%| 254K|  1h48m|diggnation--0194--SXSW2009--large.xvid.avi
188050K| 34%| 165K|  1h41m|trs--0104--2years--large.xvid.avi
163100K| 77%| 167K| 15m32s|scamschool--0053--strapped--large.xvid.avi
150700K| 66%| 113K|  27m6s|systm--0095--benchmark--large.xvid.avi

```

Since I don't run this from a cronjob and I can't guarantee all the downloads will finish before I have to go offline it also allows you to press 'q' to quit - at which time it tells each sub-process (via a control file) to stop downloading.   When you next run the script it will continue the download from wherever they were up to.   As such I no longer download the podcasts into a different directory each day - rather they all end up in a common directory to allow continuing downloads the next day.

Thanks to another control-file - which contains a count of the number of active downloads - the script doesn't exit until all the sub-processes are done or have exited.   This control file sits in ~/.bashpodder\_logs (which also contains the wget logs for active downloads and the list of files already downloaded)

The script reads from a file called '.bashpodder' in your home directory containing the URL of each feed (comments are allowed) and logs which files have been downloaded to a seperate logfile for each feed (based on a md5 hash of the feedurl - saves having to parse the url to make it filename safe) so as to not re-download them later

Since I lost all my previous data there was no existing list of downloaded files and so the script would proceed to try and download everything in the feeds.   To stop this I added a 'catchup' mode which can be accessed using the '-c' option.   In this mode the script wouldn't actually download anything but would act as if it did (and so log that the files were already downloaded). After running the script in catchup mode once I edited each of the logfiles and removed the last one or two entries.   Then when I finally ran the script normally it started downloading those episodes.

And now I am finally returning to normal!

The script can be see at [bashpodder.sh](/files/bashpodder/bashpodder.sh)

Here is a sample [.bashpodder](/files/bashpodder/.bashpodder)
