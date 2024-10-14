itemOnColor = "#114411";
itemOffColor = "#505050";
menuNext = "<img src=/ccrc/images/next.gif>";
newMenuXDepl = -2;
newMenuYDepl = 2;
menuBgColor="#00AA00";
menuFgColor="#00FF00";

// preload images

im1 = new Image();
im1.src = "/ccrc/images/nimic.gif";
im2 = new Image();
im2.src = "/ccrc/images/next.gif";

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

l3.addMenuItem('Blackwall Mountain', 'document.location=("/ccrc/Sport/Blackwall_Mountain/index.html")');
l3.addMenuItem('Palmdale', 'document.location=("/ccrc/Sport/Palmdale/index.html")');
l3.addMenuItem('Patonga', 'document.location=("/ccrc/Sport/Patonga/index.html")');
l3.addMenuItem('Phegans Bay', 'document.location=("/ccrc/Sport/Phegans_Bay/index.html")');
l3.addMenuItem('Point Clare', 'document.location=("/ccrc/Sport/Point_Clare/index.html")');
l3.addMenuItem('Reeves Street', 'document.location=("/ccrc/Sport/Reeves_Street/index.html")');
l3.addMenuItem('Wards Hill', 'document.location=("/ccrc/Sport/Wards_Hill/index.html")');
l3.addMenuItem('West Gosford', 'document.location=("/ccrc/Sport/West_Gosford/index.html")');
l3.addMenuItem('Bouddi National Park', 'document.location=("/ccrc/Traditional/Bouddi_National_Park/index.html")');
l3.addMenuItem('Hawkesbury River', 'document.location=("/ccrc/Hybrid/Hawkesbury_River/index.html")');
l3.addMenuItem('Jolls Bridge', 'document.location=("/ccrc/Hybrid/Jolls_Bridge/index.html")');
l4.addMenuItem('Blackwall Boulders', 'document.location=("/ccrc/Boulder/Blackwall_Boulders/index.html")');
l4.addMenuItem('Bouddi Bouldering', 'document.location=("/ccrc/Boulder/Bouddi_Bouldering/index.html")');
l4.addMenuItem('Palmdale bouldering', 'document.location=("/ccrc/Boulder/Palmdale_bouldering/index.html")');
l4.addMenuItem('Reeves Street Bouldering', 'document.location=("/ccrc/Boulder/Reeves_Street_Bouldering/index.html")');
l4.addMenuItem('Rumbalara', 'document.location=("/ccrc/Boulder/Rumbalara/index.html")');
l4.addMenuItem('Tuggerah', 'document.location=("/ccrc/Boulder/Tuggerah/index.html")');
l4.addMenuItem('Wamberal', 'document.location=("/ccrc/Boulder/Wamberal/index.html")');
l5.addMenuItem('Climb Fit', 'document.location=("/ccrc/Indoor/Climb_Fit/index.html")');
l5.addMenuItem('Kincumber - The Hangover', 'document.location=("/ccrc/Indoor/Kincumber_-_The_Hangover/index.html")');
l5.addMenuItem('Lakehaven', 'document.location=("/ccrc/Indoor/Lakehaven/index.html")');
l5.addMenuItem('X-Treme Edge', 'document.location=("/ccrc/Indoor/X-Treme_Edge/index.html")');
myStatus = 1;
status = 'Loaded';
}
