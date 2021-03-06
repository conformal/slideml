#!/usr/bin/perl
#
# Copyright (c) 2010 Joel Sing (joel@sing.id.au)
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

#
# Generate HTML Slidy slides from SlideML
#

use File::Basename;
use File::Fetch;

# See if Image::Size is available
eval {
	require Image::Size;
	$imagesize = 1;
};

$version = 0.1;

$slideno = 0;
$listdepth = 0;
@liststack = ();
$inlistitem = 0;
$inpre = 0;
$intable = 0;
@tstyle = ();

$title = "SlideML";
$bgcolour = "#333333";
$fgcolour = "#e4e4e4";
$bgimage = "";
$bgimagepos = "";
$bgimagerpt = "";
$tblborder = "solid";
$tblcolour = "#666666";

# Get path to script
$path = dirname(__FILENAME__);

while (<>) {

	next if ($_ =~ /^#/);

	$style = "";

	if ($_ =~ /^@(.*)=(.*)/) {
		if ($slideno == 0) {
			$title = $2 if $1 eq 'title';
			$bgcolour = $2 if $1 eq 'background';
			$fgcolour = $2 if $1 eq 'foreground';
			$bgimage = $2 if $1 eq 'backimage';
			$bgimagepos = $2 if $1 eq 'backimagepos';
			$bgimagerpt = $2 if $1 eq 'backimagerpt';
			$tblborder = $2 if $1 eq 'tableborder';
		} else {
			$slide{bgcolour} = $2 if $1 eq 'background';
			$slide{fgcolour} = $2 if $1 eq 'foreground';
			$slide{bgimage} = $2 if $1 eq 'backimage';
			$slide{bgimagepos} = $2 if $1 eq 'backimagepos';
			$slide{bgimagerpt} = $2 if $1 eq 'backimagerpt';
			$slide{tblborder} = $2 if $1 eq 'tableborder';
			$slide{type} = $2 if $1 eq 'type';
		}
		next;
	}

	next if $slideno == 0 && $_ !~ /^---$/;

	if ($slideno == 0) {
		&header();
	}

	if ($newslide == 1) {
		if ($slide{bgimage} ne '') {
			$style .= "background-image: url('$slide{bgimage}'); ";
		} 
		if ($slide{bgcolour} ne '') {
			$style .= "background-color: $slide{bgcolour}; ";
		}
		if ($slide{bgimagepos} ne '') {
			$style .= "background-position: $slide{bgimagepos}; ";
		}
		if ($slide{bgimagerpt} ne '') {
			if ($slide{bgimagerpt} eq 'no') {
				$slide{bgimagerpt} = "no-repeat";
			} elsif ($slide{bgimagerpt} eq 'yes') {
				$slide{bgimagerpt} = "repeat-x repeat-y";
			} elsif ($slide{bgimagerpt} eq 'x') {
				$slide{bgimagerpt} = "repeat-x";
			} elsif ($slide{bgimagerpt} eq '') {
				$slide{bgimagerpt} = "repeat-y";
			}
			$style .= "background-repeat: $slide{bgimagerpt}; ";
		}
		if ($slide{fgcolour} ne '') {
			$style .= "color: $slide{fgcolour}; ";
		}

		print "<div class=\"slide\" style=\"$style\">\n";
		if ($slide{type} eq 'title') {
			print "  <div class=\"cover\">\n";
		}

		$newslide = 0;
	}

	if ($inpre && $_ !~ /^==$/) {
		print html_escape($_);
		next;
	}

	if ($intable && $_ !~ /^\|.*\|$/) {
		print "  </table>\n";
		$intable = 0;
	}

	chomp;

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
		print "  </div>\n" if $slide{type} eq 'title';
		print "</div>\n\n" if $slideno;
		undef %slide;
		$slideno++;
		$newslide = 1;
	} elsif ($_ =~ /^<(.*)>$/) {
		# Header
		print "  <h1>$1</h1>\n";
	} elsif ($_ =~ /^>(.*)<$/) {
		# Centered Header
		print "  <h1 class=\"center\">$1</h1>\n";
	} elsif ($_ =~ /^!(.*)!$/) {
		# Footer
		print "  <div class=\"footer\">$1</div>\n";
	} elsif ($_ =~ /^\[img (.*)\]$/) {
		# Image
		@nv = split / +/, $1;
		$w = $h = $size = 0;
		$s = $a = '';
		foreach $nv (@nv) {
			($n, $v) = split /=/, $nv;
			$s = $v if $n eq 'src';
			$w = $v if $n eq 'width';
			$h = $v if $n eq 'height';
			$a = $v if $n eq 'align';
			if ($n eq 'size') {
				$size = $v;
				$size =~ s/%$//;
				$size /= 100;
			}
		}
		if ($size > 0) {
			if (!$imagesize) {
				print STDERR "Image size requires Image::Size ",
				    "module, which appears to be missing!\n";
				exit 1;
			}

			if ($s =~ /^http:\/\//) {
				$ff = File::Fetch->new(uri => $s);
				$filename = $ff->fetch(to => \$file);
			} else {
				$filename = $s;
			}

			($w, $h) = Image::Size::imgsize($filename);
			$w = int($w * $size);
			$h = int($h * $size);
		}
		if ($s eq '') {
			print STDERR "Image is missing source!\n";
			exit 1;
		}
		if ($w == 0 || $h == 0) {
			print STDERR "Image is missing width or height!\n";
			exit 1;
		}
		if ($a eq 'right') {
			$style = "float: right;";
		} elsif ($a eq 'left') {
			$style = "float: left;";
		} elsif ($a eq 'center' || $a eq 'centre') {
			$style = "margin-left: auto; margin-right: auto; ";
			$style .= "text-align: center";
		} elsif ($a eq 'bottom') {
			$style = "position: absolute; bottom: 32px;";
		}
		print "  <div" .
		    ($style ne '' ? " style=\"$style\"" : '') . ">\n" .
		    "    <img src=\"$s\" width=\"$w\" height=\"$h\" />\n" .
		    "  </div>\n";
	} elsif ($_ =~ /^==$/) {
		$inpre = !$inpre;
		print "<".($inpre ? '' : '/')."pre>\n";
	} elsif ($_ =~ /^\|.*\|$/) {
		# Table
		if (!$intable) {
			$intable = 1;
			@tstyle = ();
			$style = " border: 4px ".(($slide{tblborder} ne '') ?
                            $slide{tblborder} : $tblborder)." $tblcolour";
			print "  <table style=\"$style\">\n";
		}
		print "    <tr>\n";
		my $cellidx = 0;
		my @cells = split /^\||\s\|/;
		shift @cells;
		foreach $cell (@cells) {
			my $chr = substr($cell, 0, 1);
			my $align = '';
			my $colspan = '';
			my $rowspan = '';
			my $style = $tstyle[$cellidx];
			my $tag = 'td';

			until ($chr =~ /\s+/ || length($cell) < 1) {
				$chr = substr($cell, 0, 1);
				$cell = substr($cell, 1, length($cell) - 1);
				$tag = 'th' if $chr eq '|';
				$align = 'left' if $chr =~ /[Ll]/;
				$align = 'center' if $chr =~ /[Cc]/;
				$align = 'right' if $chr =~ /[Rr]/;
				if ($chr =~ /(\d)/ && $rowspan eq '') {
					$colspan = " colspan=\"$1\"";
				}
				if ($chr =~ /[Xx]/ && $cell =~ /^(\d+)/) {
					$rowspan = " rowspan=\"$1\"";
				}
			}

			$style = "text-align: $align;" if $align ne '';
			$tstyle[$cellidx] = $style if $tag eq 'th';
			$style .= " border: 2px ".(($slide{tblborder} ne '') ?
                            $slide{tblborder} : $tblborder)." $tblcolour";

			$cell =~ s/^\s+//;
			$cell =~ s/\\\|/\|/g;
			$cell = html_escape($cell);
			$cell = slideml_text($cell);

			print "      <$tag$colspan$rowspan " .
			    "style=\"$style\">$cell</$tag>\n";
			$cellidx++;
		}
		print "    </tr>\n";
	} else {

		$_ = html_escape($_);
		$_ = slideml_text($_);

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

print "</li>\n" if $inlistitem;
while (scalar @liststack > 0) {
	print pop @liststack;
}
print "  </div>\n" if $cover;
print "</div>\n\n" if $slideno;

&footer();

sub html_escape() {

	$_ = shift @_;

	# Prevent &, < and > from ending up in HTML
	$_ =~ s/&/\&amp;/g;
	$_ =~ s/</\&lt;/g;
	$_ =~ s/>/\&gt;/g;

	return $_;

}

sub slideml_text() {

	# Process text tags
	$_ =~ s-(^| )\*(.+)\*( |$)-$1<strong>$2</strong>$3-g;
	$_ =~ s-\\\*(.+)\\\*-<strong>$1</strong>-g;
	$_ =~ s-(^| )\/(.+)\/( |$)-$1<em>$2</em>$3-g;
	$_ =~ s-\\\/(.+)\\\/-<em>$1</em>-g;
	$_ =~ s-(^| )_(.+)_( |$)-$1<u>$2</u>$3-g;
	$_ =~ s-\\_(.+)\\_-<u>$1</u>-g;
	$_ =~ s-(^| )\^\^(.+)\^\^( |$)-$1<span class="b2">$2</span>$3-g;
	$_ =~ s-(^| )\^(.+)\^( |$)-$1<span class="b1">$2</span>$3-g;

	return $_;

}

sub header() {

	print <<EOF;
<?xml version="1.0" encoding="iso-8859-1"?>

<!DOCTYPE html
  PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>$title</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
  <meta http-equiv="Generator" content="SlideML - http://freshmeat.net/projects/slideml" />
EOF
	print "  <script type=\"text/javascript\">\n";
	print "  // <![CDATA[\n";
	&slidy_js();
	print "  // ]]>\n";
	print "  </script>\n";
	print "  <style>\n";
	&slidy_css();

print <<EOF;

h1.center {
	width: 100%;
	text-align: center;
}

div.slide {
	padding: 32px;
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

div.footer {
	position: absolute;
	bottom: 32px;
	font-size: 80%;
}

span.b1 {
	font-size: 125%;
}

span.b2 {
	font-size: 150%;
}

pre {
	font-size: 70%;
}

table {
	width: 80%;
	margin-left: auto;
	margin-right: auto;
	border-collapse: collapse;
}

td {
}

th {
}
EOF
	print "  </style>\n";
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

	open CSS, "$path/slidy.css" || die "Failed to open $path/slidy.css";
	flock CSS, 1;
	@css = <CSS>;
	flock CSS, 8;
	close CSS;

	print @css;
}

sub slidy_js() {

	open JS, "$path/slidy.js" || die "Failed to open $path/slidy.js";
	flock JS, 1;
	@js = <JS>;
	flock JS, 8;
	close JS;

	foreach $js (@js) {
		print $js if ($js !~ /<(\/)?script/) 
	}
}
