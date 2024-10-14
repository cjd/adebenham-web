itemOnColor = "#114411";
itemOffColor = "#505050";
menuNext = "<img src=images/next.gif>";
newMenuXDepl = -2;
newMenuYDepl = 2;
menuBgColor="#00AA00";
menuFgColor="#00FF00";

// preload images

im1 = new Image();
im1.src = "images/nimic.gif";
im2 = new Image();
im2.src = "images/next.gif";

function loaded(){

status = "Loading menus...";
myStatus = 0;

l1=addMenu(0,'<B>Home','document.location=("/ccrc/news.html")',200,150,20,70);
l2=addMenu(0,'<B>Map','document.location=("/ccrc/map.html")',200,150);
l3=addMenu(0,'<B>Climbs','document.location=("/ccrc//climbs.html")','200','150');
l4=addMenu(0,'<B>Boulders','document.location=("/ccrc//Boulder/")','200','150');
l5=addMenu(0,'<B>Indoor / Commercial','document.location=("/ccrc//Indoor/")','200','150');
l6=addMenu(0,'<B>Information','',200,150);
l7=addMenu(0,'<B>Contact Us','document.location=("/ccrc/contact.html")',200,150);
l8=addMenu(0,'<B>Other','',200,150);

l6.addMenuItem('Disclaimer','document.location=("/ccrc/disclaimer.html")');
l6.addMenuItem('Grade Conversion','document.location=("/ccrc/gradeconversion.html")');
l6.addMenuItem('Symbols','document.location=("/ccrc/symbols.html")');
l6.addMenuItem('Code of Conduct','document.location=("/ccrc/srccode.html")');
l6.addMenuItem('Safety Tips','document.location=("/ccrc/safety.html")');
l6.addMenuItem('Beginner Tips','document.location=("/ccrc/beginner.html")');


l7.addMenuItem('Contact Details','document.location=("/ccrc/contact.html")');
l7.addMenuItem('Message Board','document.location=("http://forum.cjb.net:81/cgi-bin/forum.cgi?forum=ccrc")');
l7.addMenuItem('Submit New Climb','document.location=("/ccrc/newclimb.html")');
l7.addMenuItem('Credits','document.location=("/ccrc/credits.html")');

l8.addMenuItem('Credits','document.location=("/ccrc/credits.html")');
l8.addMenuItem('Downloads','document.location=("/ccrc/download.html")');
l8.addMenuItem('Links','document.location=("/ccrc/links.html")');
l8.addMenuItem('Pictures','document.location=("/ccrc/pics.html")');

