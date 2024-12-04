---
author: cjd
title: "Simplify Binary Management with `update_gitbin`"
date: 2024-12-04T10:42:27+11:00
tags:
  - scripts
url: /blog/2024/12/github_binary_update_script
---

I run a variety of systems including a couple which are running Debian stable.  This means that packages (although stable) are often not as current as I'd like.  To help get around this I started using prebuilt binaries directly from the upstream projects when they are hosted on GitHub. But this created a new problem - how to keep them up to date.  
This article introduces a shell script designed to automate the process of downloading and updating binary files from GitHub repositories.

## Introducing the `update_gitbin` Script

The `update_gitbin` script offers a solution to this problem by automating the retrieval and installation of binary updates from GitHub. The script operates as follows:

1. **Binary Definition:** An associative array named `gitbin` is defined within the script. This array stores the names of the binaries to be managed, along with the corresponding GitHub repositories where they are located.

2. **Update Process:** The script iterates through the `gitbin` array, performing the following actions for each binary:
    * **Retrieve Release Information:** The script fetches the latest release data from the GitHub API for the respective repository based on the value from the gitbin hash.  Compare this to the .\<binary\>.version file to see if this is a new release (so we don't keep re-downloading the same stuff).  Output to console what the version number is and the release date.
    * **Extract Download URL:** The download URL for the binary is extracted from the retrieved release information by checking for 'download_url' lines which metion linux/appimage but are not on my list of 'don't grab' (ie: rpm/deb/apk)
    * **Download the Binary:** The binary file is downloaded using the extracted URL.
    * **Installation:** If necessary, the script extracts the downloaded archive looking for the specific binary name given as the key for the hash.  It then moves the binary to the appropriate directory ~/Sync/bin/$ARCH which I've added to my `$PATH`
    * **Record the version:** Log the successful download into .\<binary\>.version for future reference
    * **Repeat for other archs:** I use both x86_64 and arm64 systems so the script tries to grab binaries for both.  As this progresses it lets you know which archs were downloaded and which were skippped (due to already being up to date)

## Utilizing the Script

To use the `update_gitbin` script:

1. **Grab the script:** [update_gitbin](https://github.com/cjd/bin/blob/main/update_gitbin)

2. **Customization:** Modify the `gitbin` array to include the desired binaries and their GitHub repository paths (you can see my selection as an example)

3. **Execution:** Run the script using `./update_gitbin`. To update a specific binary, provide its name as an argument, for example, `./update_gitbin <binary_name>`.

## Conclusion

The `update_gitbin` script provides an effective solution for automating binary updates from GitHub, streamlining a common task for developers and system administrators like me. This automation saves time, reduces manual effort, and helps ensure that systems are running the latest versions of essential command-line tools.
