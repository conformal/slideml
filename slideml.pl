#!/usr/bin/perl

#
# Copyright (c) 2010 Joel Sing (joel@sing.id.au)
#
# Generate HTML Slidy slides from SlideML
#

$slideno = 0;
$listdepth = 0;
@liststack = ();
$inlistitem = 0;

$bgcolour = "#333333";
$fgcolour = "#e4e4e4";
$bgimage = "";

while (<>) {

	chomp;

	next if ($_ =~ /^#/);

	if ($slideno == 0 && $_ !~ /^---$/) {
		# Handle metadata
		if ($_ =~ /^background=(.*)$/) {
			$bgcolour = $1;
		} elsif ($_ =~ /^foreground=(.*)$/) {
			$fgcolour = $1;
		} elsif ($_ =~ /^backimage=(.*)$/) {
			$bgimage = $1;
		}

		next;
	}

	if ($slideno == 0) {
		&header();
	}

	# Determine indent depth
	$depth = 0;
	while ($_ =~ /^\t/) {
		$depth++;
		$_ =~ s/^\t//;
	}

	if ($_ =~ /^([\*\-\.0-9]) /) {

		$item = $1;
		$_ =~ s/^([\*\-\.0-9]) //;

		if ($listdepth == 0 || $listdepth <= $depth) {

			# New list
			if ($item =~ /^[0-9]+/) {
				$tag = 'ol';
				$style = 'numeric';
			} else {
				$tag = 'ul';
				$style = 'disc';
			}

			if ($item =~ /^\*/) {
				$style = "disc";
			} elsif ($item =~ /^\-/) {
				$style = "circle";
			}

			$style = "list-style-type: $style;";
			if ($listdepth == 0) {
				print "  <$tag style=\"$style\">\n";
				push @liststack, "  </$tag>\n";
			} else {
				print "\n" if $inlistitem;
				print "    " x $listdepth;
				print "  <$tag style=\"$style\">\n";
				push @liststack,
				    ("    " x $listdepth)."</li>\n";
				push @liststack,
				    ("    " x $listdepth)."  </$tag>\n";
				$inlistitem = 0;
			}
			$listdepth++;
		} elsif ($listdepth > $depth + 1) {
			print "</li>\n" if $inlistitem;
			while ($listdepth > $depth + 1) {
				print pop @liststack;
				print pop @liststack;
				$listdepth--;
			}
			$inlistitem = 0;
		}
	} else {
		print "</li>\n" if $inlistitem;
		while (scalar @liststack > 0) {
			print pop @liststack;
		}
		$listdepth = 0;
		$inlistitem = 0;
	}

	if ($_ =~ /^---$/) {
		# New slide
		print "  </div>\n" if $cover;
		print "</div>\n\n" if $slideno;
		print "<div class=\"slide\">\n";
		$cover = 0;
		$slideno++;
		if ($slideno == 1) {
			$cover = 1;
			print "  <div class=\"cover\">\n";
		}
	} elsif ($_ =~ /^<(.*)>$/) {
		# Header
		print "  <h1>$1</h1>\n";
	} elsif ($_ =~ /^<(.*)>$/) {
		# Header
		print "  <h1>$1</h1>\n";
	} elsif ($_ =~ /^!(.*)!$/) {
		# Footer
		print "  <div class=\"footer\">$1</div>\n";
	} else {

		$_ =~ s-\*(.+)\*-<strong>$1</strong>-g;
		$_ =~ s-\/(.+)\/-<em>$1</em>-g;
		$_ =~ s-_(.+)_-<u>$1</u>-g;

		print "</li>\n" if $inlistitem;
		$inlistitem = 0;

		if ($listdepth) {
			print "    " x $listdepth;
			print "<li>$_";
			$inlistitem = 1;
		} else {
			print "  <p>$_</p>\n";
		}

	}

}

&footer();

sub header() {

	print <<EOF;
<?xml version="1.0" encoding="iso-8859-1"?>

<!DOCTYPE html
     PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>SlideML</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
  <meta http-equiv="Author" content="Joel Sing" />
  <meta http-equiv="Generator" content="SlideML" />
  <!--<link rel="stylesheet" type="text/css" href="slidy.css"
    type="text/css" media="screen, projection, print"  />
  <script src="slidy.js" charset="utf-8" type="text/javascript"></script>-->
EOF
	print "<script type=\"text/javascript\">\n";
	&slidy_js();
	print "</script>\n";
	print "<style>\n";
	&slidy_css();
	print "</style>\n";
	print "</head>\n";

	if ($bgimage ne "") {
		$style = "background: url('$bgimage') $bgcolour;";
	} else {
		$style = "background: $bgcolour;";
	}

	$style .= " color: $fgcolour;";

	print "<body style=\"$style\">\n";
}

sub footer() {

	print <<EOF;
</body>
</html>
EOF

}

sub slidy_css() {

	print <<EOF;
/* slidy.css

   Copyright (c) 2005 W3C (MIT, ERCIM, Keio), All Rights Reserved.
   W3C liability, trademark, document use and software licensing
   rules apply, see:

   http://www.w3.org/Consortium/Legal/copyright-documents
   http://www.w3.org/Consortium/Legal/copyright-software
*/
body
{
  margin: 0 0 0 0;
  padding: 32 32 32 32;
  width: 100%;
  height: 100%;
  /*color: black;*/
  /*background-color: white;*/
  font-family: "Gill Sans MT", "Gill Sans", GillSans, sans-serif;
  font-size: 14pt;
}

.hidden { display: none; visibility: hidden }

div.toolbar {
  position: fixed; z-index: 200;
  top: auto; bottom: 0; left: 0; right: 0;
  height: 1.2em; text-align: right;
  padding-left: 1em;
  padding-right: 1em; 
  font-size: 60%;
  color: red; background: rgb(240,240,240);
}

div.background {
  display: none;
}

div.handout {
  margin-left: 20px;
  margin-right: 20px;
}

div.cover {
  padding-top: 80px;
  text-align: center;
}

div.slide div.cover h1 {
  margin: 0px;
  margin-top: 80px;
}

div.slide div.cover h2 {
  margin: 0px;
}

div.slide.titlepage {
  text-align: center;
}

div.slide.titlepage.h1 {
  padding-top: 40%;
  margin: 0px;
}

div.slide {
  z-index: 20;
  margin: 0 0 0 0;
  padding-top: 20px;
  padding-bottom: 20px;
  padding-left: 20px;
  padding-right: 20px;
  border-width: 0;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  line-height: 120%;
  background-color: transparent;
}

/* this rule is hidden from IE 6 and below which don't support + selector */
div.slide + div[class].slide { page-break-before: always;}

div.slide h1 {
  padding-left: 0;
  padding-right: 20pt;
  padding-top: 4pt;
  padding-bottom: 4pt;
  margin-top: 0;
  margin-left: 0;
  margin-right: 60pt;
  margin-bottom: 0.5em;
  display: block; 
  font-size: 160%;
  line-height: 1.2em;
  background: transparent;
}

div.toc {
  position: absolute;
  top: auto;
  bottom: 4em;
  left: 4em;
  right: auto;
  width: 60%;
  max-width: 30em;
  height: 30em;
  border: solid thin black;
  padding: 1em;
  background: rgb(240,240,240);
  color: black;
  z-index: 300;
  overflow: auto;
  display: block;
  visibility: visible;
}

div.toc-heading {
  width: 100%;
  border-bottom: solid 1px rgb(180,180,180);
  margin-bottom: 1em;
  text-align: center;
}

pre {
 font-size: 80%;
 font-weight: bold;
 line-height: 120%;
 padding-top: 0.2em;
 padding-bottom: 0.2em;
 padding-left: 1em;
 padding-right: 1em;
 border-style: solid;
 border-left-width: 1em;
 border-top-width: thin;
 border-right-width: thin;
 border-bottom-width: thin;
 border-color: #95ABD0;
 color: #00428C;
 background-color: #E4E5E7;
}

li pre { margin-left: 0; }

@media print {
  div.slide {
     display: block;
     visibility: visible;
     position: relative;
     border-top-style: solid;
     border-top-width: thin;
     border-top-color: black;
  }
  div.slide pre { font-size: 60%; padding-left: 0.5em; }
  div.handout { display: block; visibility: visible; }
}

blockquote { font-style: italic }

/*img { background-color: transparent }*/

p.copyright { font-size: smaller }

.center { text-align: center }
.footnote { font-size: smaller; margin-left: 2em; }

a img { border-width: 0; border-style: none }

/*
a:visited { color: navy }
a:link { color: navy }
a:hover { color: red; text-decoration: underline }
a:active { color: red; text-decoration: underline }
*/

a {text-decoration: none}
.navbar a:link {color: white}
.navbar a:visited {color: yellow}
.navbar a:active {color: red}
.navbar a:hover {color: red}

ul { list-style-type: square; }
ul ul { list-style-type: disc; }
ul ul ul { list-style-type: circle; }
ul ul ul ul { list-style-type: disc; }
li { margin-left: 0.5em; margin-top: 0.5em; }
li li { font-size: 85%; font-style: italic }
li li li { font-size: 85%; font-style: normal }

div dt
{
  margin-left: 0;
  margin-top: 1em;
  margin-bottom: 0.5em;
  font-weight: bold;
}
div dd
{
  margin-left: 2em;
  margin-bottom: 0.5em;
}

/*
p,pre,ul,ol,blockquote,h2,h3,h4,h5,h6,dl,table {
  margin-left: 1em;
  margin-right: 1em;
}
*/

p.subhead { font-weight: bold; margin-top: 2em; }

.smaller { font-size: smaller }
.bigger { font-size: 130% }

td,th { padding: 0.2em }

ul {
/*  margin: 0.5em 1.5em 0.5em 1.5em; */
  margin-left: 48px;
  padding: 0;
}

ol {
/*  margin: 0.5em 1.5em 0.5em 1.5em; */
  margin-left: 64px;
  margin-right: 64px;
  padding: 0;
}

ul { list-style-type: square; }
ul ul { list-style-type: disc; }
ul ul ul { list-style-type: circle; }
ul ul ul ul { list-style-type: disc; }

ul li { 
  list-style: square;
/*  margin: 0.1em 0em 0.6em 0;
  padding: 0 0 0 0; */
  line-height: 140%;
}

ol li { 
/*  margin: 0.1em 0em 0.6em 1.5em;
  padding: 0 0 0 0px; */
  line-height: 140%;
  list-style-type: decimal;
}

li ul li { 
  font-size: 85%; 
  font-style: italic;
  list-style-type: disc;
  background: transparent;
  padding: 0 0 0 0;
}
li li ul li { 
  font-size: 85%; 
  font-style: normal;
  list-style-type: circle;
  background: transparent;
  padding: 0 0 0 0;
}
li li li ul li {
  list-style-type: disc;
  background: transparent;
  padding: 0 0 0 0;
}

li ol li {
  list-style-type: decimal;
}


li li ol li {
  list-style-type: decimal;
}

/*
 setting class="outline on ol or ul makes it behave as an
 ouline list where blocklevel content in li elements is
 hidden by default and can be expanded or collapsed with
 mouse click. Set class="expand" on li to override default
*/

ol.outline li:hover { cursor: pointer }
ol.outline li.nofold:hover { cursor: default }

ul.outline li:hover { cursor: pointer }
ul.outline li.nofold:hover { cursor: default }

ol.outline { list-style:decimal; }
ol.outline ol { list-style-type:lower-alpha }

ol.outline li.nofold {
  padding: 0 0 0 20px;
  background: transparent url(nofold-dim.gif) no-repeat 0px 0.5em;
}
ol.outline li.unfolded {
  padding: 0 0 0 20px;
  background: transparent url(fold-dim.gif) no-repeat 0px 0.5em;
}
ol.outline li.folded {
  padding: 0 0 0 20px;
  background: transparent url(unfold-dim.gif) no-repeat 0px 0.5em;
}
ol.outline li.unfolded:hover {
  padding: 0 0 0 20px;
  background: transparent url(fold.gif) no-repeat 0px 0.5em;
}
ol.outline li.folded:hover {
  padding: 0 0 0 20px;
  background: transparent url(unfold.gif) no-repeat 0px 0.5em;
}

ul.outline li.nofold {
  padding: 0 0 0 20px;
  background: transparent url(nofold-dim.gif) no-repeat 0px 0.5em;
}
ul.outline li.unfolded {
  padding: 0 0 0 20px;
  background: transparent url(fold-dim.gif) no-repeat 0px 0.5em;
}
ul.outline li.folded {
  padding: 0 0 0 20px;
  background: transparent url(unfold-dim.gif) no-repeat 0px 0.5em;
}
ul.outline li.unfolded:hover {
  padding: 0 0 0 20px;
  background: transparent url(fold.gif) no-repeat 0px 0.5em;
}
ul.outline li.folded:hover {
  padding: 0 0 0 20px;
  background: transparent url(unfold.gif) no-repeat 0px 0.5em;
}

/* for slides with class "title" in table of contents */
a.titleslide { font-weight: bold; font-style: italic }

div.footer {
	position: absolute;
	bottom: 32px;
}
EOF
}

sub slidy_js() {

	print <<EOF;
var ns_pos=(typeof window.pageYOffset!='undefined');var khtml=((navigator.userAgent).indexOf("KHTML")>=0?true:false);var opera=((navigator.userAgent).indexOf("Opera")>=0?true:false);var ie7=(!ns_pos&&navigator.userAgent.indexOf("MSIE 7")!=-1);window.onload=startup;window.onbeforeprint=beforePrint;window.onafterprint=afterPrint;setTimeout(hideAll,50);function hideAll()
{if(document.body)
document.body.style.visibility="hidden";else
setTimeout(hideAll,50);}
var slidenum=0;var slides;var slideNumElement;var notes;var backgrounds;var toolbar;var title;var lastShown=null;var eos=null;var toc=null;var outline=null;var selectedTextLen;var viewAll=0;var wantToolbar=1;var mouseClickEnabled=true;var scrollhack=0;var helpAnchor;var helpPage="http://www.w3.org/Talks/Tools/Slidy/help.html";var helpText="Navigate with mouse click, space bar, Cursor Left/Right, "+"or Pg Up and Pg Dn. Use S and B to change font size.";var sizeIndex=0;var sizeAdjustment=0;var sizes=new Array("10pt","12pt","14pt","16pt","18pt","20pt","22pt","24pt","26pt","28pt","30pt","32pt");var okayForIncremental=incrementalElementList();var lastWidth=0;var lastHeight=0;var objects;var lang="en";var strings_es={"slide":"pág.","help?":"Ayuda","contents?":"Índice","table of contents":"tabla de contenidos","Table of Contents":"Tabla de Contenidos","restart presentation":"Reiniciar presentación","restart?":"Inicio"};strings_es[helpText]="Utilice el ratón, barra espaciadora, teclas Izda/Dcha, "+"o Re pág y Av pág. Use S y B para cambiar el tamaño de fuente.";var strings_ca={"slide":"pàg..","help?":"Ajuda","contents?":"Índex","table of contents":"taula de continguts","Table of Contents":"Taula de Continguts","restart presentation":"Reiniciar presentació","restart?":"Inici"};strings_ca[helpText]="Utilitzi el ratolí, barra espaiadora, tecles Esq./Dta. "+"o Re pàg y Av pàg. Usi S i B per canviar grandària de font.";var strings_nl={"slide":"pagina","help?":"Help?","contents?":"Inhoud?","table of contents":"inhoudsopgave","Table of Contents":"Inhoudsopgave","restart presentation":"herstart presentatie","restart?":"Herstart?"};strings_nl[helpText]="Navigeer d.m.v. het muis, spatiebar, Links/Rechts toetsen, "+"of PgUp en PgDn. Gebruik S en B om de karaktergrootte te veranderen.";var strings_de={"slide":"Seite","help?":"Hilfe","contents?":"Übersicht","table of contents":"Inhaltsverzeichnis","Table of Contents":"Inhaltsverzeichnis","restart presentation":"Präsentation neu starten","restart?":"Neustart"};strings_de[helpText]="Benutzen Sie die Maus, Leerschlag, die Cursortasten links/rechts oder "+"Page up/Page Down zum Wechseln der Seiten und S und B für die Schriftgrösse.";var strings_pl={"slide":"slajd","help?":"pomoc?","contents?":"spis treści?","table of contents":"spis treści","Table of Contents":"Spis Treści","restart presentation":"Restartuj prezentację","restart?":"restart?"};strings_pl[helpText]="Zmieniaj slajdy klikając myszą, naciskając spację, strzałki lewo/prawo"+"lub PgUp / PgDn. Użyj klawiszy S i B, aby zmienić rozmiar czczionki.";var strings_fr={"slide":"page","help?":"Aide","contents?":"Index","table of contents":"table des matières","Table of Contents":"Table des matières","restart presentation":"Recommencer l'exposé","restart?":"Début"};strings_fr[helpText]="Naviguez avec la souris, la barre d'espace, les flèches "+"gauche/droite ou les touches Pg Up, Pg Dn. Utilisez "+"les touches S et B pour modifier la taille de la police.";var strings_hu={"slide":"oldal","help?":"segítség","contents?":"tartalom","table of contents":"tartalomjegyzék","Table of Contents":"Tartalomjegyzék","restart presentation":"bemutató újraindítása","restart?":"újraindítás"};strings_hu[helpText]="Az oldalak közti lépkedéshez kattintson az egérrel, vagy "+"használja a szóköz, a bal, vagy a jobb nyíl, illetve a Page Down, "+"Page Up billentyűket. Az S és a B billentyűkkel változtathatja "+"a szöveg méretét.";var strings_it={"slide":"pag.","help?":"Aiuto","contents?":"Indice","table of contents":"indice","Table of Contents":"Indice","restart presentation":"Ricominciare la presentazione","restart?":"Inizio"};strings_it[helpText]="Navigare con mouse, barra spazio, frecce sinistra/destra o "+"PgUp e PgDn. Usare S e B per cambiare la dimensione dei caratteri.";var strings_el={"slide":"σελίδα","help?":"βοήθεια;","contents?":"περιεχόμενα;","table of contents":"πίνακας περιεχομένων","Table of Contents":"Πίνακας Περιεχομένων","restart presentation":"επανεκκίνηση παρουσίασης","restart?":"επανεκκίνηση;"};strings_el[helpText]="Πλοηγηθείτε με το κλίκ του ποντικιού, το space, τα βέλη αριστερά/δεξιά, "+"ή Page Up και Page Down. Χρησιμοποιήστε τα πλήκτρα S και B για να αλλάξετε "+"το μέγεθος της γραμματοσειράς.";var strings_ja={"slide":"スライド","help?":"ヘルプ","contents?":"目次","table of contents":"目次を表示","Table of Contents":"目次","restart presentation":"最初から再生","restart?":"最初から"};strings_ja[helpText]="マウス左クリック ・ スペース ・ 左右キー "+"または Page Up ・ Page Downで操作， S ・ Bでフォントサイズ変更";var localize={"es":strings_es,"ca":strings_ca,"nl":strings_nl,"de":strings_de,"pl":strings_pl,"fr":strings_fr,"hu":strings_hu,"it":strings_it,"el":strings_el,"jp":strings_ja};function startup()
{lang=document.body.parentNode.getAttribute("lang");if(!lang)
lang=document.body.parentNode.getAttribute("xml:lang");if(!lang)
lang="en";document.body.style.visibility="visible";title=document.title;toolbar=addToolbar();wrapImplicitSlides();slides=collectSlides();notes=collectNotes();objects=document.body.getElementsByTagName("object");backgrounds=collectBackgrounds();patchAnchors();slidenum=findSlideNumber(location.href);window.offscreenbuffering=true;sizeAdjustment=findSizeAdjust();hideImageToolbar();initOutliner();if(slides.length>0)
{var slide=slides[slidenum];slide.style.position="absolute";if(slidenum>0)
{setVisibilityAllIncremental("visible");lastShown=previousIncrementalItem(null);setEosStatus(true);}
else
{lastShown=null;setVisibilityAllIncremental("hidden");setEosStatus(!nextIncrementalItem(lastShown));}
setLocation();}
toc=tableOfContents();hideTableOfContents();document.onclick=mouseButtonClick;document.onmouseup=mouseButtonUp;document.onkeydown=keyDown;window.onresize=resized;window.onscroll=scrolled;singleSlideView();setLocation();resized();if(ie7)
setTimeout("ieHack()",100);showToolbar();}
String.prototype.localize=function()
{if(this=="")
return this;var s,lookup=localize[lang];if(lookup)
{s=lookup[this];if(s)
return s;}
var lg=lang.split("-");if(lg.length>1)
{lookup=localize[lg[0]];if(lookup)
{s=lookup[this];if(s)
return s;}}
return this;}
function hideImageToolbar()
{if(!ns_pos)
{var images=document.getElementsByTagName("IMG");for(var i=0;i<images.length;++i)
images[i].setAttribute("galleryimg","no");}}
function ieHack()
{window.resizeBy(0,-1);window.resizeBy(0,1);}
function reload(e)
{if(!e)
var e=window.event;hideBackgrounds();setTimeout("document.reload();",100);stopPropagation(e);e.cancel=true;e.returnValue=false;return false;}
function isKHTML()
{var agent=navigator.userAgent;return(agent.indexOf("KHTML")>=0?true:false);}
function resized()
{var width=0;if(typeof(window.innerWidth)=='number')
width=window.innerWidth;else if(document.documentElement&&document.documentElement.clientWidth)
width=document.documentElement.clientWidth;else if(document.body&&document.body.clientWidth)
width=document.body.clientWidth;var height=0;if(typeof(window.innerHeight)=='number')
height=window.innerHeight;else if(document.documentElement&&document.documentElement.clientHeight)
height=document.documentElement.clientHeight;else if(document.body&&document.body.clientHeight)
height=document.body.clientHeight;if(height&&(width/height>1.05*1024/768))
{width=height*1024.0/768;}
if(width!=lastWidth||height!=lastHeight)
{if(width>=1100)
sizeIndex=5;else if(width>=1000)
sizeIndex=4;else if(width>=800)
sizeIndex=3;else if(width>=600)
sizeIndex=2;else if(width)
sizeIndex=0;if(0<=sizeIndex+sizeAdjustment&&sizeIndex+sizeAdjustment<sizes.length)
sizeIndex=sizeIndex+sizeAdjustment;adjustObjectDimensions(width,height);document.body.style.fontSize=sizes[sizeIndex];lastWidth=width;lastHeight=height;{var slide=slides[slidenum];hideSlide(slide);showSlide(slide);}
refreshToolbar(200);}}
function scrolled()
{if(toolbar&&!ns_pos&&!ie7)
{hackoffset=scrollXOffset();toolbar.style.display="none";if(scrollhack==0&&!viewAll)
{setTimeout(showToolbar,1000);scrollhack=1;}}}
function refreshToolbar(interval)
{if(!ns_pos&&!ie7)
{hideToolbar();setTimeout(showToolbar,interval);}}
function showToolbar()
{if(wantToolbar)
{if(!ns_pos)
{var xoffset=scrollXOffset();toolbar.style.left=xoffset;toolbar.style.right=xoffset;toolbar.style.bottom=0;}
toolbar.style.display="block";toolbar.style.visibility="visible";}
scrollhack=0;try
{if(!opera)
helpAnchor.focus();}
catch(e)
{}}
function test()
{var s="docH: "+documentHeight()+" winH: "+lastHeight+" yoffset: "+scrollYOffset()+" toolbot: "+(documentHeight()-lastHeight-scrollYOffset());var slide=slides[slidenum];var name=ns_pos?"class":"className";var style=(slide.currentStyle?slide.currentStyle["backgroundColor"]:document.defaultView.getComputedStyle(slide,'').getPropertyValue("background-color"));alert("class='"+slide.getAttribute(name)+"' backgroundColor: "+style);}
function hideToolbar()
{toolbar.style.display="none";toolbar.style.visibility="hidden";window.focus();}
function toggleToolbar()
{if(!viewAll)
{if(toolbar.style.display=="none")
{toolbar.style.display="block";toolbar.style.visibility="visible";wantToolbar=1;}
else
{toolbar.style.display="none";toolbar.style.visibility="hidden";wantToolbar=0;}}}
function scrollXOffset()
{if(window.pageXOffset)
return self.pageXOffset;if(document.documentElement&&document.documentElement.scrollLeft)
return document.documentElement.scrollLeft;if(document.body)
return document.body.scrollLeft;return 0;}
function scrollYOffset()
{if(window.pageYOffset)
return self.pageYOffset;if(document.documentElement&&document.documentElement.scrollTop)
return document.documentElement.scrollTop;if(document.body)
return document.body.scrollTop;return 0;}
function optimizeFontSize()
{var slide=slides[slidenum];var dh=slide.scrollHeight;var wh=getWindowHeight();var u=100*dh/wh;alert("window utilization = "+u+"% (doc "
+dh+" win "+wh+")");}
function getDocHeight(doc)
{if(!doc)
doc=document;if(doc&&doc.body&&doc.body.offsetHeight)
return doc.body.offsetHeight;if(doc&&doc.body&&doc.body.scrollHeight)
return doc.body.scrollHeight;alert("couldn't determine document height");}
function getWindowHeight()
{if(typeof(window.innerHeight)=='number')
return window.innerHeight;if(document.documentElement&&document.documentElement.clientHeight)
return document.documentElement.clientHeight;if(document.body&&document.body.clientHeight)
return document.body.clientHeight;}
function documentHeight()
{var sh,oh;sh=document.body.scrollHeight;oh=document.body.offsetHeight;if(sh&&oh)
{return(sh>oh?sh:oh);}
return 0;}
function smaller()
{if(sizeIndex>0)
{--sizeIndex;}
toolbar.style.display="none";document.body.style.fontSize=sizes[sizeIndex];var slide=slides[slidenum];hideSlide(slide);showSlide(slide);setTimeout(showToolbar,300);}
function bigger()
{if(sizeIndex<sizes.length-1)
{++sizeIndex;}
toolbar.style.display="none";document.body.style.fontSize=sizes[sizeIndex];var slide=slides[slidenum];hideSlide(slide);showSlide(slide);setTimeout(showToolbar,300);}
function adjustObjectDimensions(width,height)
{for(var i=0;i<objects.length;i++)
{var obj=objects[i];var mimeType=obj.getAttribute("type");if(mimeType=="image/svg+xml"||mimeType=="application/x-shockwave-flash")
{if(!obj.initialWidth)
obj.initialWidth=obj.getAttribute("width");if(!obj.initialHeight)
obj.initialHeight=obj.getAttribute("height");if(obj.initialWidth&&obj.initialWidth.charAt(obj.initialWidth.length-1)=="%")
{var w=parseInt(obj.initialWidth.slice(0,obj.initialWidth.length-1));var newW=width*(w/100.0);obj.setAttribute("width",newW);}
if(obj.initialHeight&&obj.initialHeight.charAt(obj.initialHeight.length-1)=="%")
{var h=parseInt(obj.initialHeight.slice(0,obj.initialHeight.length-1));var newH=height*(h/100.0);obj.setAttribute("height",newH);}}}}
function cancel(event)
{if(event)
{event.cancel=true;event.returnValue=false;if(event.preventDefault)
event.preventDefault();}
return false;}
function keyDown(event)
{var key;if(!event)
var event=window.event;if(window.event)
key=window.event.keyCode;else if(event.which)
key=event.which;else
return true;if(!key)
return true;if(event.ctrlKey||event.altKey||event.metaKey)
return true;if(isShownToc()&&key!=9&&key!=16&&key!=38&&key!=40)
{hideTableOfContents();if(key==27||key==84||key==67)
return cancel(event);}
if(key==34)
{nextSlide(false);return cancel(event);}
else if(key==33)
{previousSlide(false);return cancel(event);}
else if(key==32)
{nextSlide(true);return cancel(event);}
else if(key==37)
{previousSlide(!event.shiftKey);return cancel(event);}
else if(key==36)
{firstSlide();return cancel(event);}
else if(key==35)
{lastSlide();return cancel(event);}
else if(key==39)
{nextSlide(!event.shiftKey);return cancel(event);}
else if(key==13)
{if(outline)
{if(outline.visible)
fold(outline);else
unfold(outline);return cancel(event);}}
else if(key==188)
{smaller();return cancel(event);}
else if(key==190)
{bigger();return cancel(event);}
else if(key==189||key==109)
{smaller();return cancel(event);}
else if(key==187||key==191||key==107)
{bigger();return cancel(event);}
else if(key==83)
{smaller();return cancel(event);}
else if(key==66)
{bigger();return cancel(event);}
else if(key==90)
{lastSlide();return cancel(event);}
else if(key==70)
{toggleToolbar();return cancel(event);}
else if(key==65)
{toggleView();return cancel(event);}
else if(key==75)
{mouseClickEnabled=!mouseClickEnabled;alert((mouseClickEnabled?"enabled":"disabled")+" mouse click advance");return cancel(event);}
else if(key==84||key==67)
{if(toc)
showTableOfContents();return cancel(event);}
else if(key==72)
{window.location=helpPage;return cancel(event);}
return true;}
function mouseButtonUp(e)
{selectedTextLen=getSelectedText().length;}
function mouseButtonClick(e)
{var rightclick=false;var leftclick=false;var middleclick=false;var target;if(!e)
var e=window.event;if(e.target)
target=e.target;else if(e.srcElement)
target=e.srcElement;if(target.nodeType==3)
target=target.parentNode;if(e.which)
{leftclick=(e.which==1);middleclick=(e.which==2);rightclick=(e.which==3);}
else if(e.button)
{if(e.button==4)
middleclick=true;rightclick=(e.button==2);}
else leftclick=true;hideTableOfContents();if(selectedTextLen>0)
{stopPropagation(e);e.cancel=true;e.returnValue=false;return false;}
if(mouseClickEnabled&&leftclick&&target.nodeName!="EMBED"&&target.nodeName!="OBJECT"&&target.nodeName!="INPUT"&&target.nodeName!="TEXTAREA"&&target.nodeName!="SELECT"&&target.nodeName!="OPTION")
{nextSlide(true);stopPropagation(e);e.cancel=true;e.returnValue=false;}}
function previousSlide(incremental)
{if(!viewAll)
{var slide;if((incremental||slidenum==0)&&lastShown!=null)
{lastShown=hidePreviousItem(lastShown);setEosStatus(false);}
else if(slidenum>0)
{slide=slides[slidenum];hideSlide(slide);slidenum=slidenum-1;slide=slides[slidenum];setVisibilityAllIncremental("visible");lastShown=previousIncrementalItem(null);setEosStatus(true);showSlide(slide);}
setLocation();if(!ns_pos)
refreshToolbar(200);}}
function nextSlide(incremental)
{if(!viewAll)
{var slide,last=lastShown;if(incremental||slidenum==slides.length-1)
lastShown=revealNextItem(lastShown);if((!incremental||lastShown==null)&&slidenum<slides.length-1)
{slide=slides[slidenum];hideSlide(slide);slidenum=slidenum+1;slide=slides[slidenum];lastShown=null;setVisibilityAllIncremental("hidden");showSlide(slide);}
else if(!lastShown)
{if(last&&incremental)
lastShown=last;}
setLocation();setEosStatus(!nextIncrementalItem(lastShown));if(!ns_pos)
refreshToolbar(200);}}
function firstSlide()
{if(!viewAll)
{var slide;if(slidenum!=0)
{slide=slides[slidenum];hideSlide(slide);slidenum=0;slide=slides[slidenum];lastShown=null;setVisibilityAllIncremental("hidden");showSlide(slide);}
setEosStatus(!nextIncrementalItem(lastShown));setLocation();}}
function lastSlide()
{if(!viewAll)
{var slide;lastShown=null;if(lastShown==null&&slidenum<slides.length-1)
{slide=slides[slidenum];hideSlide(slide);slidenum=slides.length-1;slide=slides[slidenum];setVisibilityAllIncremental("visible");lastShown=previousIncrementalItem(null);showSlide(slide);}
else
{setVisibilityAllIncremental("visible");lastShown=previousIncrementalItem(null);}
setEosStatus(true);setLocation();}}
function setEosStatus(state)
{if(eos)
eos.style.color=(state?"rgb(240,240,240)":"red");}
function showSlide(slide)
{syncBackground(slide);window.scrollTo(0,0);slide.style.visibility="visible";slide.style.display="block";}
function hideSlide(slide)
{slide.style.visibility="hidden";slide.style.display="none";}
function beforePrint()
{showAllSlides();hideToolbar();}
function afterPrint()
{if(!viewAll)
{singleSlideView();showToolbar();}}
function printSlides()
{beforePrint();window.print();afterPrint();}
function toggleView()
{if(viewAll)
{singleSlideView();showToolbar();viewAll=0;}
else
{showAllSlides();hideToolbar();viewAll=1;}}
function showAllSlides()
{var slide;for(var i=0;i<slides.length;++i)
{slide=slides[i];slide.style.position="relative";slide.style.borderTopStyle="solid";slide.style.borderTopWidth="thin";slide.style.borderTopColor="black";try{if(i==0)
slide.style.pageBreakBefore="avoid";else
slide.style.pageBreakBefore="always";}
catch(e)
{}
setVisibilityAllIncremental("visible");showSlide(slide);}
var note;for(var i=0;i<notes.length;++i)
{showSlide(notes[i]);}
hideBackgrounds();}
function singleSlideView()
{var slide;for(var i=0;i<slides.length;++i)
{slide=slides[i];slide.style.position="absolute";if(i==slidenum)
{slide.style.borderStyle="none";showSlide(slide);}
else
{slide.style.borderStyle="none";hideSlide(slide);}}
setVisibilityAllIncremental("visible");lastShown=previousIncrementalItem(null);var note;for(var i=0;i<notes.length;++i)
{hideSlide(notes[i]);}}
function hasToken(str,token)
{if(str)
{var pattern=/\w+/g;var result=str.match(pattern);for(var i=0;i<result.length;i++)
{if(result[i]==token)
return true;}}
return false;}
function getClassList(element)
{if(typeof window.pageYOffset=='undefined')
return element.getAttribute("className");return element.getAttribute("class");}
function hasClass(element,name)
{var regexp=new RegExp("(^| )"+name+"\W*");if(regexp.test(getClassList(element)))
return true;return false;}
function removeClass(element,name)
{var clsname=ns_pos?"class":"className";var clsval=element.getAttribute(clsname);var regexp=new RegExp("(^| )"+name+"\W*");if(clsval)
{clsval=clsval.replace(regexp,"");element.setAttribute(clsname,clsval);}}
function addClass(element,name)
{if(!hasClass(element,name))
{var clsname=ns_pos?"class":"className";var clsval=element.getAttribute(clsname);element.setAttribute(clsname,(clsval?clsval+" "+name:name));}}
function wrapImplicitSlides()
{var i,heading,node,next,div;var headings=document.getElementsByTagName("h1");if(!headings)
return;for(i=0;i<headings.length;++i)
{heading=headings[i];if(heading.parentNode!=document.body)
continue;node=heading.nextSibling;div=document.createElement("div");div.setAttribute((ns_pos?"class":"className"),"slide");document.body.replaceChild(div,heading);div.appendChild(heading);while(node)
{if(node.nodeType==1&&(node.nodeName=="H1"||node.nodeName=="h1"||node.nodeName=="DIV"||node.nodeName=="div"))
break;next=node.nextSibling;node=document.body.removeChild(node);div.appendChild(node);node=next;}}}
function collectSlides()
{var slides=new Array();var divs=document.body.getElementsByTagName("div");for(var i=0;i<divs.length;++i)
{div=divs.item(i);if(hasClass(div,"slide"))
{slides[slides.length]=div;div.style.display="none";div.style.visibility="hidden";var node1=document.createElement("br");div.appendChild(node1);var node2=document.createElement("br");div.appendChild(node2);}
else if(hasClass(div,"background"))
{div.style.display="block";}}
return slides;}
function collectNotes()
{var notes=new Array();var divs=document.body.getElementsByTagName("div");for(var i=0;i<divs.length;++i)
{div=divs.item(i);if(hasClass(div,"handout"))
{notes[notes.length]=div;div.style.display="none";div.style.visibility="hidden";}}
return notes;}
function collectBackgrounds()
{var backgrounds=new Array();var divs=document.body.getElementsByTagName("div");for(var i=0;i<divs.length;++i)
{div=divs.item(i);if(hasClass(div,"background"))
{backgrounds[backgrounds.length]=div;if(getClassList(div)!="background")
{div.style.display="none";div.style.visibility="hidden";}}}
return backgrounds;}
function syncBackground(slide)
{var background;var bgColor;if(slide.currentStyle)
bgColor=slide.currentStyle["backgroundColor"];else if(document.defaultView)
{var styles=document.defaultView.getComputedStyle(slide,null);if(styles)
bgColor=styles.getPropertyValue("background-color");else
{bgColor="transparent";}}
else
bgColor=="transparent";if(bgColor=="transparent")
{var slideClass=getClassList(slide);for(var i=0;i<backgrounds.length;i++)
{background=backgrounds[i];var bgClass=getClassList(background);if(matchingBackground(slideClass,bgClass))
{background.style.display="block";background.style.visibility="visible";}
else
{background.style.display="none";background.style.visibility="hidden";}}}
else
hideBackgrounds();}
function hideBackgrounds()
{for(var i=0;i<backgrounds.length;i++)
{background=backgrounds[i];background.style.display="none";background.style.visibility="hidden";}}
function matchingBackground(slideClass,bgClass)
{if(bgClass=="background")
return true;var pattern=/\w+/g;var result=slideClass.match(pattern);for(var i=0;i<result.length;i++)
{if(hasToken(bgClass,result[i]))
return true;}
return false;}
function nextNode(root,node)
{if(node==null)
return root.firstChild;if(node.firstChild)
return node.firstChild;if(node.nextSibling)
return node.nextSibling;for(;;)
{node=node.parentNode;if(!node||node==root)
break;if(node&&node.nextSibling)
return node.nextSibling;}
return null;}
function previousNode(root,node)
{if(node==null)
{node=root.lastChild;if(node)
{while(node.lastChild)
node=node.lastChild;}
return node;}
if(node.previousSibling)
{node=node.previousSibling;while(node.lastChild)
node=node.lastChild;return node;}
if(node.parentNode!=root)
return node.parentNode;return null;}
function incrementalElementList()
{var inclist=new Array();inclist["P"]=true;inclist["PRE"]=true;inclist["LI"]=true;inclist["BLOCKQUOTE"]=true;inclist["DT"]=true;inclist["DD"]=true;inclist["H2"]=true;inclist["H3"]=true;inclist["H4"]=true;inclist["H5"]=true;inclist["H6"]=true;inclist["SPAN"]=true;inclist["ADDRESS"]=true;inclist["TABLE"]=true;inclist["TR"]=true;inclist["TH"]=true;inclist["TD"]=true;inclist["IMG"]=true;inclist["OBJECT"]=true;return inclist;}
function nextIncrementalItem(node)
{var slide=slides[slidenum];for(;;)
{node=nextNode(slide,node);if(node==null||node.parentNode==null)
break;if(node.nodeType==1)
{if(node.nodeName=="BR")
continue;if(hasClass(node,"incremental")&&okayForIncremental[node.nodeName])
return node;if(hasClass(node.parentNode,"incremental")&&!hasClass(node,"non-incremental"))
return node;}}
return node;}
function previousIncrementalItem(node)
{var slide=slides[slidenum];for(;;)
{node=previousNode(slide,node);if(node==null||node.parentNode==null)
break;if(node.nodeType==1)
{if(node.nodeName=="BR")
continue;if(hasClass(node,"incremental")&&okayForIncremental[node.nodeName])
return node;if(hasClass(node.parentNode,"incremental")&&!hasClass(node,"non-incremental"))
return node;}}
return node;}
function setVisibilityAllIncremental(value)
{var node=nextIncrementalItem(null);while(node)
{node.style.visibility=value;node=nextIncrementalItem(node);}}
function revealNextItem(node)
{node=nextIncrementalItem(node);if(node&&node.nodeType==1)
node.style.visibility="visible";return node;}
function hidePreviousItem(node)
{if(node&&node.nodeType==1)
node.style.visibility="hidden";return previousIncrementalItem(node);}
function patchAnchors()
{var anchors=document.body.getElementsByTagName("a");for(var i=0;i<anchors.length;++i)
{anchors[i].onclick=clickedAnchor;}}
function clickedAnchor(e)
{if(!e)
var e=window.event;if(pageAddress(this.href)==pageAddress(location.href))
{var newslidenum=findSlideNumber(this.href);if(newslidenum!=slidenum)
{slide=slides[slidenum];hideSlide(slide);slidenum=newslidenum;slide=slides[slidenum];showSlide(slide);setLocation();}}
else if(this.target==null)
location.href=this.href;this.blur();stopPropagation(e);}
function pageAddress(uri)
{var i=uri.indexOf("#");if(i<0)
return uri;return uri.substr(0,i);}
function showSlideNumber()
{slideNumElement.innerHTML="slide".localize()+" "+
(slidenum+1)+"/"+slides.length;}
function setLocation()
{var uri=pageAddress(location.href);uri=uri+"#("+(slidenum+1)+")";if(uri!=location.href&&!khtml)
location.href=uri;document.title=title+" ("+(slidenum+1)+")";showSlideNumber();}
function findSlideNumber(uri)
{var i=uri.indexOf("#");if(i<0)
return 0;var anchor=unescape(uri.substr(i+1));var target=document.getElementById(anchor);if(!target)
{var re=/\((\d)+\)/;if(anchor.match(re))
{var num=parseInt(anchor.substring(1,anchor.length-1));if(num>slides.length)
num=1;if(--num<0)
num=0;return num;}
re=/\[(\d)+\]/;if(anchor.match(re))
{var num=parseInt(anchor.substring(1,anchor.length-1));if(num>slides.length)
num=1;if(--num<0)
num=0;return num;}
return 0;}
while(true)
{if(target.nodeName.toLowerCase()=="div"&&hasClass(target,"slide"))
{break;}
target=target.parentNode;if(!target)
{return 0;}};for(i=0;i<slides.length;++i)
{if(slides[i]==target)
return i;}
return 0;}
function slideName(index)
{var name=null;var slide=slides[index];var heading=findHeading(slide);if(heading)
name=extractText(heading);if(!name)
name=title+"("+(index+1)+")";name.replace(/\&/g,"&amp;");name.replace(/\</g,"&lt;");name.replace(/\>/g,"&gt;");return name;}
function findHeading(node)
{if(!node||node.nodeType!=1)
return null;if(node.nodeName=="H1"||node.nodeName=="h1")
return node;var child=node.firstChild;while(child)
{node=findHeading(child);if(node)
return node;child=child.nextSibling;}
return null;}
function extractText(node)
{if(!node)
return"";if(node.nodeType==3)
return node.nodeValue;if(node.nodeType==1)
{node=node.firstChild;var text="";while(node)
{text=text+extractText(node);node=node.nextSibling;}
return text;}
return"";}
function findCopyright()
{var name,content;var meta=document.getElementsByTagName("meta");for(var i=0;i<meta.length;++i)
{name=meta[i].getAttribute("name");content=meta[i].getAttribute("content");if(name=="copyright")
return content;}
return null;}
function findSizeAdjust()
{var name,content,offset;var meta=document.getElementsByTagName("meta");for(var i=0;i<meta.length;++i)
{name=meta[i].getAttribute("name");content=meta[i].getAttribute("content");if(name=="font-size-adjustment")
return 1*content;}
return 0;}
function addToolbar()
{var slideCounter,page;var toolbar=createElement("div");toolbar.setAttribute("class","toolbar");if(ns_pos)
{var right=document.createElement("div");right.setAttribute("style","float: right; text-align: right");slideCounter=document.createElement("div")
slideCounter.innerHTML="slide".localize()+" n/m";right.appendChild(slideCounter);toolbar.appendChild(right);var left=document.createElement("div");left.setAttribute("style","text-align: left");eos=document.createElement("span");eos.innerHTML="* ";left.appendChild(eos);var help=document.createElement("a");help.setAttribute("href",helpPage);help.setAttribute("title",helpText.localize());help.innerHTML="help?".localize();left.appendChild(help);helpAnchor=help;var gap1=document.createTextNode(" ");left.appendChild(gap1);var contents=document.createElement("a");contents.setAttribute("href","javascript:toggleTableOfContents()");contents.setAttribute("title","table of contents".localize());contents.innerHTML="contents?".localize();left.appendChild(contents);var gap2=document.createTextNode(" ");left.appendChild(gap2);var i=location.href.indexOf("#");if(i>0)
page=location.href.substr(0,i);else
page=location.href;var start=document.createElement("a");start.setAttribute("href",page);start.setAttribute("title","restart presentation".localize());start.innerHTML="restart?".localize();left.appendChild(start);var copyright=findCopyright();if(copyright)
{var span=document.createElement("span");span.innerHTML=copyright;span.style.color="black";span.style.marginLeft="4em";left.appendChild(span);}
toolbar.appendChild(left);}
else
{toolbar.style.position=(ie7?"fixed":"absolute");toolbar.style.zIndex="200";toolbar.style.width="99.9%";toolbar.style.height="1.2em";toolbar.style.top="auto";toolbar.style.bottom="0";toolbar.style.left="0";toolbar.style.right="0";toolbar.style.textAlign="left";toolbar.style.fontSize="60%";toolbar.style.color="red";toolbar.borderWidth=0;toolbar.style.background="rgb(240,240,240)";var sp=document.createElement("span");sp.innerHTML="&nbsp;&nbsp;*&nbsp;";toolbar.appendChild(sp);eos=sp;var help=document.createElement("a");help.setAttribute("href",helpPage);help.setAttribute("title",helpText.localize());help.innerHTML="help?".localize();toolbar.appendChild(help);helpAnchor=help;var gap1=document.createTextNode(" ");toolbar.appendChild(gap1);var contents=document.createElement("a");contents.setAttribute("href","javascript:toggleTableOfContents()");contents.setAttribute("title","table of contents".localize());contents.innerHTML="contents?".localize();toolbar.appendChild(contents);var gap2=document.createTextNode(" ");toolbar.appendChild(gap2);var i=location.href.indexOf("#");if(i>0)
page=location.href.substr(0,i);else
page=location.href;var start=document.createElement("a");start.setAttribute("href",page);start.setAttribute("title","restart presentation".localize());start.innerHTML="restart?".localize();toolbar.appendChild(start);var copyright=findCopyright();if(copyright)
{var span=document.createElement("span");span.innerHTML=copyright;span.style.color="black";span.style.marginLeft="2em";toolbar.appendChild(span);}
slideCounter=document.createElement("div")
slideCounter.style.position="absolute";slideCounter.style.width="auto";slideCounter.style.height="1.2em";slideCounter.style.top="auto";slideCounter.style.bottom=0;slideCounter.style.right="0";slideCounter.style.textAlign="right";slideCounter.style.color="red";slideCounter.style.background="rgb(240,240,240)";slideCounter.innerHTML="slide".localize()+" n/m";toolbar.appendChild(slideCounter);}
toolbar.onclick=stopPropagation;document.body.appendChild(toolbar);slideNumElement=slideCounter;setEosStatus(false);return toolbar;}
function isShownToc()
{if(toc&&toc.style.visible=="visible")
return true;return false;}
function showTableOfContents()
{if(toc)
{if(toc.style.visibility!="visible")
{toc.style.visibility="visible";toc.style.display="block";toc.focus();if(ie7&&slidenum==0)
setTimeout("ieHack()",100);}
else
hideTableOfContents();}}
function hideTableOfContents()
{if(toc&&toc.style.visibility!="hidden")
{toc.style.visibility="hidden";toc.style.display="none";try
{if(!opera)
helpAnchor.focus();}
catch(e)
{}}}
function toggleTableOfContents()
{if(toc)
{if(toc.style.visible!="visible")
showTableOfContents();else
hideTableOfContents();}}
function gotoEntry(e)
{var target;if(!e)
var e=window.event;if(e.target)
target=e.target;else if(e.srcElement)
target=e.srcElement;if(target.nodeType==3)
target=target.parentNode;if(target&&target.nodeType==1)
{var uri=target.getAttribute("href");if(uri)
{var slide=slides[slidenum];hideSlide(slide);slidenum=findSlideNumber(uri);slide=slides[slidenum];lastShown=null;setLocation();setVisibilityAllIncremental("hidden");setEosStatus(!nextIncrementalItem(lastShown));showSlide(slide);try
{if(!opera)
helpAnchor.focus();}
catch(e)
{}}}
hideTableOfContents(e);if(ie7)ieHack();stopPropagation(e);return cancel(e);}
function gotoTocEntry(event)
{var key;if(!event)
var event=window.event;if(window.event)
key=window.event.keyCode;else if(event.which)
key=event.which;else
return true;if(!key)
return true;if(event.ctrlKey||event.altKey)
return true;if(key==13)
{var uri=this.getAttribute("href");if(uri)
{var slide=slides[slidenum];hideSlide(slide);slidenum=findSlideNumber(uri);slide=slides[slidenum];lastShown=null;setLocation();setVisibilityAllIncremental("hidden");setEosStatus(!nextIncrementalItem(lastShown));showSlide(slide);try
{if(!opera)
helpAnchor.focus();}
catch(e)
{}}
hideTableOfContents();if(ie7)ieHack();return cancel(event);}
if(key==40&&this.next)
{this.next.focus();return cancel(event);}
if(key==38&&this.previous)
{this.previous.focus();return cancel(event);}
return true;}
function isTitleSlide(slide)
{return hasClass(slide,"title");}
function tableOfContents()
{var toc=document.createElement("div");addClass(toc,"toc");var heading=document.createElement("div");addClass(heading,"toc-heading");heading.innerHTML="Table of Contents".localize();heading.style.textAlign="center";heading.style.width="100%";heading.style.margin="0";heading.style.marginBottom="1em";heading.style.borderBottomStyle="solid";heading.style.borderBottomColor="rgb(180,180,180)";heading.style.borderBottomWidth="1px";toc.appendChild(heading);var previous=null;for(var i=0;i<slides.length;++i)
{var title=hasClass(slides[i],"title");var num=document.createTextNode((i+1)+". ");toc.appendChild(num);var a=document.createElement("a");a.setAttribute("href","#("+(i+1)+")");if(title)
addClass(a,"titleslide");var name=document.createTextNode(slideName(i));a.appendChild(name);a.onclick=gotoEntry;a.onkeydown=gotoTocEntry;a.previous=previous;if(previous)
previous.next=a;toc.appendChild(a);if(i==0)
toc.first=a;if(i<slides.length-1)
{var br=document.createElement("br");toc.appendChild(br);}
previous=a;}
toc.focus=function(){if(this.first)
this.first.focus();}
toc.onclick=function(e){e||(e=window.event);hideTableOfContents();stopPropagation(e);if(e.cancel!=undefined)
e.cancel=true;if(e.returnValue!=undefined)
e.returnValue=false;return false;};toc.style.position="absolute";toc.style.zIndex="300";toc.style.width="60%";toc.style.maxWidth="30em";toc.style.height="30em";toc.style.overflow="auto";toc.style.top="auto";toc.style.right="auto";toc.style.left="4em";toc.style.bottom="4em";toc.style.padding="1em";toc.style.background="rgb(240,240,240)";toc.style.borderStyle="solid";toc.style.borderWidth="2px";toc.style.fontSize="60%";document.body.insertBefore(toc,document.body.firstChild);return toc;}
function replaceByNonBreakingSpace(str)
{for(var i=0;i<str.length;++i)
str[i]=160;}
function initOutliner()
{var items=document.getElementsByTagName("LI");for(var i=0;i<items.length;++i)
{var target=items[i];if(!hasClass(target.parentNode,"outline"))
continue;target.onclick=outlineClick;if(!ns_pos)
{target.onmouseover=hoverOutline;target.onmouseout=unhoverOutline;}
if(foldable(target))
{target.foldable=true;target.onfocus=function(){outline=this;};target.onblur=function(){outline=null;};if(!target.getAttribute("tabindex"))
target.setAttribute("tabindex","0");if(hasClass(target,"expand"))
unfold(target);else
fold(target);}
else
{addClass(target,"nofold");target.visible=true;target.foldable=false;}}}
function foldable(item)
{if(!item||item.nodeType!=1)
return false;var node=item.firstChild;while(node)
{if(node.nodeType==1&&isBlock(node))
return true;node=node.nextSibling;}
return false;}
function fold(item)
{if(item)
{removeClass(item,"unfolded");addClass(item,"folded");}
var node=item?item.firstChild:null;while(node)
{if(node.nodeType==1&&isBlock(node))
{node.display=getElementStyle(node,"display","display");node.style.display="none";node.style.visibility="hidden";}
node=node.nextSibling;}
item.visible=false;}
function unfold(item)
{if(item)
{addClass(item,"unfolded");removeClass(item,"folded");}
var node=item?item.firstChild:null;while(node)
{if(node.nodeType==1&&isBlock(node))
{node.style.display=(node.display?node.display:"block");node.style.visibility="visible";}
node=node.nextSibling;}
item.visible=true;}
function outlineClick(e)
{var rightclick=false;var target;if(!e)
var e=window.event;if(e.target)
target=e.target;else if(e.srcElement)
target=e.srcElement;if(target.nodeType==3)
target=target.parentNode;while(target&&target.visible==undefined)
target=target.parentNode;if(!target)
return true;if(e.which)
rightclick=(e.which==3);else if(e.button)
rightclick=(e.button==2);if(!rightclick&&target.visible!=undefined)
{if(target.foldable)
{if(target.visible)
fold(target);else
unfold(target);}
stopPropagation(e);e.cancel=true;e.returnValue=false;}
return false;}
function hoverOutline(e)
{var target;if(!e)
var e=window.event;if(e.target)
target=e.target;else if(e.srcElement)
target=e.srcElement;if(target.nodeType==3)
target=target.parentNode;while(target&&target.visible==undefined)
target=target.parentNode;if(target&&target.foldable)
target.style.cursor="pointer";return true;}
function unhoverOutline(e)
{var target;if(!e)
var e=window.event;if(e.target)
target=e.target;else if(e.srcElement)
target=e.srcElement;if(target.nodeType==3)
target=target.parentNode;while(target&&target.visible==undefined)
target=target.parentNode;if(target)
target.style.cursor="default";return true;}
function stopPropagation(e)
{if(window.event)
{window.event.cancelBubble=true;}
else if(e)
{e.cancelBubble=true;e.stopPropagation();}}
function isBlock(elem)
{var tag=elem.nodeName;return tag=="OL"||tag=="UL"||tag=="P"||tag=="LI"||tag=="TABLE"||tag=="PRE"||tag=="H1"||tag=="H2"||tag=="H3"||tag=="H4"||tag=="H5"||tag=="H6"||tag=="BLOCKQUOTE"||tag=="ADDRESS";}
function getElementStyle(elem,IEStyleProp,CSSStyleProp)
{if(elem.currentStyle)
{return elem.currentStyle[IEStyleProp];}
else if(window.getComputedStyle)
{var compStyle=window.getComputedStyle(elem,"");return compStyle.getPropertyValue(CSSStyleProp);}
return"";}
function createElement(element)
{if(typeof document.createElementNS!='undefined')
{return document.createElementNS('http://www.w3.org/1999/xhtml',element);}
if(typeof document.createElement!='undefined')
{return document.createElement(element);}
return false;}
function getElementsByTagName(name)
{if(typeof document.getElementsByTagNameNS!='undefined')
{return document.getElementsByTagNameNS('http://www.w3.org/1999/xhtml',name);}
if(typeof document.getElementsByTagName!='undefined')
{return document.getElementsByTagName(name);}
return null;}
function getSelectedText()
{try
{if(window.getSelection)
return window.getSelection().toString();if(document.getSelection)
return document.getSelection().toString();if(document.selection)
return document.selection.createRange().text;}
catch(e)
{return"";}
return"";}
EOF
}
