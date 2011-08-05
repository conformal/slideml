# $slideml$
# example presentation

# comment
@title=My Fancy Presentation
@background=#aaaaaa
@foreground=#000044
#@backimage=moo.jpg
---
@type=title
<My Name Goes Here>
[img src=http://www.openbsd.org/art/sublow.jpg size=40% align=center]
A ^presentation^ on ^^thingy^^ stuff
---
@background=#284360
@backimage=http://www.openbsd.org/images/tshirt-23.gif
@backimagepos=center
@backimagerpt=no
---
@background=#000000
@foreground=#0000aa
<My presentation>
* Welcome to my bullet
	- yes it is this easy
* Lets *bold* it
* And /italic/
* Now lets _underscore_
	- this is so *awesome*
Include some text with_underscores_inline and *asterisks*inline!
Include some text with_formatted\_underscores\_inline and \*asterisks\*inline!
!copyright in the footer!
---
<Title on slide>
* is this cool or what?
* now for some picture action
[img src=http://www.openbsd.org/art/puffy/puf300X258.gif width=300 height=258 align=center]
* puffy is awesome
!my footer!
---
@background=#ffffff
@foreground=#333333
>One more slide<
1 number list
	1 indented number
2 yeah
3 three!
[img src=http://www.openbsd.org/art/puffy/puf300X258.gif size=20% align=right]
---
>A slide with two tables<
||L Heading A ||C Heading B ||R Heading C |
| 1 | 2 | 3 |
| _logical_ *OR* | \|\| | or |
|2R /foo/ |L _blah_ |

@tableborder=dotted
||4L Span some columns and rows |
| a |2x2C /foo/ |R _blah1_ |
| b |1x2 _blah2_ |
| 1 | 2 | 3 |
---
>Another example<
==
This is preformated
  text
    & should _not_ be
      <changed>
==
This text is <not> preformated & should be processed!
