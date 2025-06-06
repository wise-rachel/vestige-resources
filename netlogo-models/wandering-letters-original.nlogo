globals
[
  text        ;; text to be written
  left-edge   ;; pxcor of leftmost column where letters can go
  right-edge  ;; ditto for rightmost
]

turtles-own
[
  word-length ;; the length of the word the turtle is in
  num-word    ;; the number the turtle's word is in the text
  leader      ;; the turtle with the character before this turtle's character
  new-line?   ;; whether we should start a new line or not
]

;; setup the variables and the View
to setup
  clear-all
  set text (word "These are the times that try men's souls. "
                ;; the next two sentences each contain all 26
                ;; letters of the alphabet!  (which makes them
                ;; good for testing typewriters)
                "The quick brown fox jumped over the lazy dog. "
                "Pack my box with five dozen liquor jugs.")
  draw-margins
  ;; make the turtles "disappear" using a shape that has nothing
  ;; in it.  we can't use hide-turtle since we want to be able to see the
  ;; turtle's label
  set-default-shape turtles "blank"
  ;; create enough turtles to have one for every character in text
  create-turtles (length text)
  [
    set word-length 0
    set leader nobody
    set new-line? false
    scatter
  ]
  setup-letters
  reset-ticks
end

to scatter  ;; turtle procedure
  setxy random-xcor random-ycor
end

to draw-margins
  ask patches
    [ ifelse (pxcor = left-margin + min-pxcor) or
             (pxcor = max-pxcor - right-margin)
        [ set pcolor red ]
        [ set pcolor black ] ]
end

;; assign the letters to the turtles, determine who leads them,
;; and set how long each word is
to setup-letters
  let remaining-text text
  let word-count 1
  let prev-letter nobody

  ask turtles
  [
    set label first remaining-text
    set leader prev-letter
    set num-word word-count
    if label = " "
    [
      set word-count word-count + 2
      set num-word num-word + 1
    ]
    set remaining-text but-first remaining-text
    set prev-letter self
  ]

  let index 1
  repeat word-count
  [
    let turtles-in-word turtles with [num-word = index]
    ask turtles-in-word
      [ set word-length count turtles-in-word ]
    set index index + 1
  ]
end

;; the main procedure called by the GO forever button
to go
  update-margins
  ask turtles
  [
    set new-line? false
    pick-heading  ;; choose the heading to the appropriate patch
    ;; if the turtle is not satisfied with where it is in
    ;; relation to its leader, go forward a bit
    ifelse happy?
      [ move-to patch-here ]  ;; move to center of patch
      [ fd 0.5 ]
  ]
  tick
end

;; updates the left-edge and right-edge variables to match the margin
;; sliders, and redraws the margins if necessary
to update-margins
  if left-edge != left-margin + min-pxcor + 1
    [ set left-edge left-margin + min-pxcor + 1
      draw-margins ]
  if right-edge != max-pxcor - right-margin - 1
    [ set right-edge max-pxcor - right-margin - 1
      draw-margins ]
end

;; set the heading of the turtle to the appropriate patch
to pick-heading
  ifelse leader = nobody
    ;; first letter goes to upper-leftmost patch
    [ face patch left-edge max-pycor ]
    ;; other patches head toward patch to the right of leader's patch
    [
      let p [patch-at 1 0] of leader
      if p != nobody
      [ face p ]
      ifelse right-edge - left-edge < word-length
      [
        ;; if our word is too long for the width of text,
        ;; check to see if the patch to the right of the leader is on or over
        ;; the right margin
        if [pxcor] of leader >= right-edge
        [
          ;; if it is change the heading to the beginning of the next line
          set new-line? true
          face patch left-edge new-line-pycor
        ]
      ]
      [
        ;; if our word is short enough to fit on a single line but there is not
        ;; enough room on this particular line, try to word wrap.  that is to say,
        ;; if the turtle is at the beginning of a word and the word is too long to
        ;; be completed on a single line given the starting point of the word,
        ;; have the leader of the word, move to the next line.
        if (num-word != [num-word] of leader) and
           ([pxcor] of leader + word-length >= right-edge)
        [
          ;; if it is change the heading to the beginning of the next line
          set new-line? true
          face patch left-edge new-line-pycor
        ]
      ]
  ]
end

;; reports pycor of the new line the turtle is supposed to go to
;; based on the location of its leader and the width of the text
to-report new-line-pycor  ;; turtle procedure
  ifelse abs ([pycor] of leader - line-spacing) > max-pycor
    [ report [pycor] of leader ]
    [ report [pycor] of leader - line-spacing ]
end

;; reports true if turtle is satisifed with its current position
to-report happy?  ;; turtle procedure
  if leader = nobody  ;; if the turtle is the first letter...
    ;; ...is it on the upper-left-most patch that it can be?
    [ report (pxcor = left-edge) and (pycor = max-pycor) ]
  ifelse new-line?  ;; do we want to start a new-line?
    ;; is the turtle at the beginning of the next line?
    [ report (pxcor = left-edge) and (pycor = new-line-pycor) ]
      ;; is the turtle on the patch to the right of its leader?
    [ report patch-at -1 0 = [patch-here] of leader ]
end


; Copyright 1997 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
193
10
578
396
-1
-1
13
1
10
1
1
1
0
0
0
1
-14
14
-14
14
1
1
1
ticks
30

SLIDER
5
118
177
151
line-spacing
line-spacing
1
3
2
1
1
NIL
HORIZONTAL

BUTTON
35
74
158
107
Scatter Letters
scatter
NIL
1
T
TURTLE
NIL
NIL
NIL
NIL
0

BUTTON
99
36
165
69
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
29
36
98
69
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
162
177
195
left-margin
left-margin
0
12
5
1
1
NIL
HORIZONTAL

SLIDER
5
196
177
229
right-margin
right-margin
0
12
5
1
1
NIL
HORIZONTAL
@#$#@#$#@
## WHAT IS IT?

This model illustrates how to build a word processor where each of the letters acts independently.  Each letter knows only which letter comes before it and how long its word is.  When the letters or margins are moved, the letters find their own ways back to their proper locations.

## HOW IT WORKS

Each letter looks both for changes in the margins and for being out of sync with its "leader", which is the letter before it in the text.  If it is not in its proper place relative to its leader, it takes a step in its leader's direction.

## HOW TO USE IT

SETUP initializes the margins and some sample sentences for the text.

GO starts and stops the simulation.

The LEFT-MARGIN and RIGHT-MARGIN sliders let you move the sliders.  You can move these sliders while GO is running and the letters will adjust on the fly.

SCATTER LETTERS scatters the letters randomly about the View.  You can press this even while GO is running.

LINE-SPACING controls how much space there is between lines.

## THINGS TO NOTICE

How do the letters find their way home?  In what ways is this different from the behavior of letters in a standard word processor?

## THINGS TO TRY

While GO is pressed try:

- Moving the margin sliders
- Changing the spacing
- Pushing the scatter button
- Combinations of all three

## EXTENDING THE MODEL

Can you extend the model so the user can type his/her own message?  You might want to use the user-input primitive for this.

Sometimes a space will end up at the beginning of a new line.  Try to fix it so that spaces are ignored at the ends of lines.

## NETLOGO FEATURES

Note the use of a blank shape to make a turtle that is invisible except for its label.

## CREDITS AND REFERENCES

This model is based on a Smalltalk program of the same name developed by Ted Kaehler of Disney Interactive.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1997).  NetLogo Wandering Letters model.  http://ccl.northwestern.edu/netlogo/models/WanderingLetters.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1997 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was developed at the MIT Media Lab using CM StarLogo.  See Wilensky, U. (1993). Thesis - Connected Mathematics: Building Concrete Relationships with Mathematical Knowledge. Adapted to StarLogoT, 1997, as part of the Connected Mathematics Project.  Adapted to NetLogo, 2001, as part of the Participatory Simulations Project.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.

<!-- 1997 2001 Wilensky -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

blank
false
0

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0
-0.2 0 0 1
0 1 1 0
0.2 0 0 1
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@

@#$#@#$#@
