---
author: cjd
date: "2010-02-21T21:43:29+00:00"
tags:
  - bashpodder
  - scripts
title: Console-based podcaster - updated
url: /blog/2010/02/22/console-based-podcaster-updated/

---
It has been a while since I first posted my version of bashpodder (a console-based podcaster in a single bash script)

Since then a bunch of small fixes have been added to the script to better handle 'odd' rss feeds and also to clean up the output.

The configuration of the script now sits in the file ~/.bashpodder   Inside this file you can specify where the logs go to and where the files download to (makes it easier to run the script automatically)

Thanks to Mobilediesel it now also doesn't create the temporary xslt file and there is the option to use '-a feedurl \[items\]' to add a feed to the config file.   The \[items\] parameter is optional and when used will cause bashpodder to mark all items in the feed as already downloaded **except** the last _\[items\]_ items.   This is useful when added a new feed so that it doesn't try to download every item in the feed since day one :-)

The updated script can be downloaded as [bashpodder.sh](/files/bashpodder/bashpodder.sh) and an example config file as [.bashpodder](/files/bashpodder/.bashpodder)

For more details on the script see the original post \[intlink id="8" type="post"\]here\[/intlink\]
