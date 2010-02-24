#!/usr/bin/perl

# $slideml$

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

$version = 0.1;

$slideno = 0;
$listdepth = 0;
@liststack = ();
$inlistitem = 0;

$title = "SlideML";
$bgcolour = "#333333";
$fgcolour = "#e4e4e4";
$bgimage = "";

# Get path to script
@path = split '\/', $0;
pop @path;
$path = join '/', @path;

while (<>) {

	chomp;

	next if ($_ =~ /^#/);

	$style = "";

	if ($_ =~ /^@(.*)=(.*)/) {
		if ($slideno == 0) {
			$title = $2 if $1 eq 'title';
			$bgcolour = $2 if $1 eq 'background';
			$fgcolour = $2 if $1 eq 'foreground';
			$bgimage = $2 if $1 eq 'backimage';
		} else {
			$slide{bgcolour} = $2 if $1 eq 'background';
			$slide{fgcolour} = $2 if $1 eq 'foreground';
			$slide{bgimage} = $2 if $1 eq 'backimage';
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
			$style .= "background: url('$slide{bgimage}'); ";
		} elsif ($slide{bgcolour} ne '') {
			$style .= "background: $slide{bgcolour}; ";
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
		$w = $h = 0;
		$s = $a = '';
		foreach $nv (@nv) {
			($n, $v) = split /=/, $nv;
			$s = $v if $n eq 'src';
			$w = $v if $n eq 'width';
			$h = $v if $n eq 'height';
			$a = $v if $n eq 'align';
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
		print "  <div width=\"$w\" height=\"$h\"" .
		    ($style ne '' ? " style=\"$style\" " : '') . ">\n" .
		    "    <img src=\"$s\" width=\"$w\" height=\"$h\" />\n" .
		    "  </div>\n";
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

print "</li>\n" if $inlistitem;
while (scalar @liststack > 0) {
	print pop @liststack;
}
print "  </div>\n" if $cover;
print "</div>\n\n" if $slideno;

&footer();

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
  <meta http-equiv="Generator" content="SlideML" />
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

	open CSS, "$path/slidy.css";
	flock CSS, 1;
	@css = <CSS>;
	flock CSS, 8;
	close CSS;

	print @css;
}

sub slidy_js() {

	open JS, "$path/slidy.js";
	flock JS, 1;
	@js = <JS>;
	flock JS, 8;
	close JS;

	foreach $js (@js) {
		print $js if ($js !~ /<(\/)?script/) 
	}
}
