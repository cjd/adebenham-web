/******************************************************************************
*	(c) Ger Versluis 2000 version 5.41 24 December 2001                       *
*	For info write to menus@burmees.nl                                        *
*	You may remove all comments for faster loading                            *
*******************************************************************************/

	var NoOffFirstLineMenus=8;
	var LowBgColor='#505050';
	var LowSubBgColor='#505050';
	var HighBgColor='blue';
	var HighSubBgColor='blue';
	var FontLowColor='#00ff00';
	var FontSubLowColor='#00ff00';
	var FontHighColor='white';
	var FontSubHighColor='white';
	var BorderColor='#00ff00';
	var BorderSubColor='#00ff00';
	var BorderWidth=1;
	var BorderBtwnElmnts=1;
	var FontFamily='arial,comic sans ms,technical'	// Font family menu items
	var FontSize=12;
	var FontBold=1;
	var FontItalic=0;
	var MenuTextCentered='center';
	var MenuCentered='left';
	var MenuVerticalCentered='top';
	var ChildOverlap=.0;
	var ChildVerticalOverlap=.0;
	var StartTop=100;
	var StartLeft=1;
	var VerCorrect=0;
	var HorCorrect=0;
	var LeftPaddng=3;
	var TopPaddng=2;
	var FirstLineHorizontal=0;
	var MenuFramesVertical=1;
	var DissapearDelay=500;
	var TakeOverBgColor=1;
	var FirstLineFrame='navig';
	var SecLineFrame='space';
	var DocTargetFrame='space';
	var TargetLoc='';
	var HideTop=0;
	var MenuWrap=1;
	var RightToLeft=0;
	var UnfoldsOnClick=0;
	var WebMasterCheck=0;
	var ShowArrow=1;
	var KeepHilite=1;
	var Arrws=['/ccrc/images/tri.gif',5,10,'/ccrc/images/tridown.gif',10,5,'/ccrc/images/trileft.gif',5,10];

function BeforeStart(){return}
function AfterBuild(){return}
function BeforeFirstOpen(){return}
function AfterCloseAll(){return}

Menu1=new Array('Home','/ccrc/news.html','',0,20,180);

Menu2=new Array('Map','/ccrc/map.html','',0);

Menu6=new Array('Information','about:blank','',6);
	Menu6_1=new Array('Disclaimer','/ccrc/disclaimer.html','',0, 20, 160);
	Menu6_2=new Array('Grade Conversion','/ccrc/gradeconversion.html','',0);
	Menu6_3=new Array('Symbols','/ccrc/symbols.html','',0);
	Menu6_4=new Array('Code of Conduct','/ccrc/srccode.html','',0);
	Menu6_5=new Array('Safety Tips','/ccrc/safety.html','',0);
	Menu6_6=new Array('Beginner Tips','/ccrc/beginner.html','',0);


Menu7=new Array('Contact Us','/ccrc/contact.html','',4);
	Menu7_1=new Array('Contact Details','/ccrc/contact.html','',0,20,160);
	Menu7_2=new Array('Message Board','http://forum.cjb.net:81/cgi-bin/forum.cgi?forum=ccrc','',0);
	Menu7_3=new Array('Submit New Climb','/ccrc/newclimb.html','',0);
	Menu7_4=new Array('Credits','/ccrc/credits.html','',0);

Menu8=new Array('Other','about:blank','',4);
	Menu8_1=new Array('Credits','/ccrc/credits.html','',0,20,160);
	Menu8_2=new Array('Downloads','/ccrc/download.html','',0);
	Menu8_3=new Array('Links','/ccrc/links.html','',0);
	Menu8_4=new Array('Pictures','/ccrc/pics.html','',0);

