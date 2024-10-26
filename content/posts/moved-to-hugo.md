---
author: cjd
title: Moved to Hugo
date: "2024-10-21T19:06:46+11:00"
tags:
  - general
url: /blog/2020/10/moved-to-hugo
---

Recently I was thinking about how my websites are handled and realised that they are extremely static and so using WordPress as the CMS was overkill.  This led me down the path of trying to find a replacement.

After looking at some of the various static-site generator options I settled on [Hugo](https://gohugo.io) for a couple of reasons.


* The first reason was that I've spent a lot of time over the past few years working with YAML (thanks k8s) so I appreciate that I can do all the configuration in YAML
* The second was that the site contents are all written using Markdown (used for internal documentation where I work)
* The third was that it all runs from a single binary which I can grab pre-compiled from github (so no need to install any packages/recompile manually)
* The fourth I also like the what content can be laid out in a structured and navigable manner
* The fifth is that it is themeable in a reproducible way
* Finally I really appreciate that the way it works fits nicely into version control (so I can put it all in git)

The end result is a nicely organised and tracked website which can be found in [GitHub](https://github.com/cjd/adebenham-web). The entire site is tracked in there with change logging etc meaning I can quickly rebuild if needed.
I am using the theme [Mainroad](https://github.com/Vimux/Mainroad) and to enable searching it is using [Pagefind](https://pagefind.io). The only modification needed to the theme was to add 'data-pagefind-body' to [single.html](https://github.com/cjd/adebenham-web/blob/main/layouts/_default/single.html) so that only the standalone pages would be indexed (not the list pages).
