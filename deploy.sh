rm -rf ~/tmp/hugo/ && hugo --destination ~/tmp/hugo && hugo && diff -r ~/tmp/hugo ~/Sync/Website/adebenham/ 2>&1 |grep Only
pagefind --site ~/Sync/Website/adebenham
