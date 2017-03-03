breed [webs web]
breed [netizens netizen]

undirected-link-breed [weblinks weblink]
undirected-link-breed [netizenlinks netizenlink]

globals [
  world
  width
  Vi                                   ;;value of information

  clustering-coefficient               ;; the clustering coefficient of the network; this is the
                                       ;; average of clustering coefficients of all netizens
  average-path-length                  ;; average path length of the network
  clustering-coefficient-of-lattice    ;; the clustering coefficient of the initial lattice
  average-path-length-of-lattice       ;; average path length of the initial lattice
  infinity                             ;; a very large number.
                                       ;; used to denote distance between two netizens which
                                       ;; don't have a connected or unconnected path between them
  highlight-string                     ;; message that appears on the node properties monitor
  number-rewired                       ;; number of edges that have been rewired. used for plots.

]

webs-own [
  SiteId
  site_influence
  site_news_coefficient
  site_infoval
  num_login
  num_read
  num_comment
  infected_time
  site_status  ;; {'0':not published 1':published}
]

netizens-own [
  behavior_mode ;; {1,2,3,4}
  UserId
  user_type ;; {1:normal, 2:'active', 3:'professional'}
  Pri_mode ;; {1,2,3,4}
  entropy
  infected_threshold
  node-clustering-coefficient
  distance-from-other-netizens
  user_status ;; {'0':not know '1':know}
]

netizenlinks-own [
  rewired?
]


;;;;;;;;;;;;;;;;;;;;;;
;; init all
;;;;;;;;;;;;;;;;;;;;;
to setup
  ;;init the settings
  clear-all
  ask patches [set pcolor white]
  build_webs_network
  init_webs
  build_netizens_network
  init_netizens
  reset-ticks

end

to go

  ;; hide links between webs
  ask weblinks [
    ;;hide-link
  ]
  ;; hide or show the webs
  ask webs [
    if site_status = 0 [
      set color green
    ]
    if site_status = 1 [
      ;;show-turtle
      set color orange
    ]
  ]
  ask webs [
    let R sqrt(site_influence * world-width / pi)
    set size R * 5
  ]
  ask netizens [
    rt random 360
    fd 1
  ]
  ask webs [
    if site_status = 1 [
    let other_webs other webs

    ;; find the netizens who are in range of webinfluence
    let netizens_on netizens with [distance myself <= [size] of myself]
    ;; calculate teh timing-value of Information
    ;;let g 0
    set site_infoval exp( - site_news_coefficient * (ticks - infected_time)) * Vi
    ;; rule one
    ask netizens_on [

      ;; the probability that people login the web
      let P1 ([site_influence] of myself) * 10
      ;; the probability taht people care the information
      let P2 P1 * [site_infoval] of myself / 10
      ;; the probability that people choose the main spreading mode
      let alpha entropy
      let beta 1 - entropy

      set P1 1
      if random-float 1 <= P1 [
        ;; login the web
        ask myself [set num_login num_login + 1]
        let SIF (alpha * [num_read] of myself  + (beta * [num_comment] of myself)) / [num_login] of myself
        let P3 P2 * SIF * 10

        set P2 1
        if random-float 1 <= P2 [
          ;; care the information

          set P3 1
          if random-float 1 <= P3 [
            ;; spread the information
            ;; normal type people
            ifelse Pri_mode = 1 [
              print "Pri_mode:1"
              ask myself [ set num_read num_read + 1 ]
              set user_status 1
            ][
              ifelse Pri_mode = 2 [
                print "Pri_mode:2"
                ask myself [
                  set num_read num_read + 1
                  set num_comment num_comment + 1
                ]
                set user_status 1
              ][
                ifelse Pri_mode = 3 [
                  print "Pri_mode:3"
                  let old_web myself
                  ;; active type people
                  if user_type = 2 [
                    print "user_type:2"
                    ;; the probability that people choose a new web to spread
                    let P5 P2 * [num_read] of myself / [num_login] of myself * 10

                    set P5 0.5
                    if random-float 1 <= P5 [
                      ;; spread to a new web with maximum influence
                      let new_web max-one-of other_webs [site_influence]
                      ask new_web [
                        create-weblink-with old_web
                        [
                        set color green
                        set shape "dash"
                        ]
                        set site_status 1
                        set num_read num_read + 1
                        set infected_time ticks
                        set site_news_coefficient site_news_coefficient * exp(- random-float 1)
                      ]
                    ]

                    if random-float 1 <= 1 - P5 [
                      ;; choose another web as dpreading target
                      let any_web one-of other_webs
                      ask any_web [
                        create-weblink-with old_web [
                          set color green
                          set shape "dash"
                        ]
                        ;; update the attributes of any_web
                        set site_status 1
                        set num_read num_read + 1
                        set infected_time ticks
                        set site_news_coefficient site_news_coefficient * exp(- random-float 1)
                      ]
                    ]
                  ]

                  ;; professional type people
                  if user_type = 3 [
                    print "user_type: 3"
                    let n [site_news_coefficient] of old_web
                    ask myself [set site_news_coefficient n * exp(- num_comment / num_read)]
                    let P6 ([num_comment] of myself + [num_read] of myself) / (sum [num_comment] of webs + sum [num_read] of webs)
                    if random-float 1 < P6 [
                      ask myself [set site_influence site_influence * (1 / (1 + exp(- site_influence)))]
                    ]
                  ]
                ]
                [
                  ;; Pri_mode 4
                  let P4 P2 * count link-neighbors / count netizens * 10

                  set P4 1
                  if random-float 1 < P4 [
                    print "P4"
                    print P4
                    ask n-of (random (count link-neighbors)) netizens [
                      set user_status 1
                    ]
                  ]
                ]
              ]

            ]
        ]
      ]
    ]
  ]
  ]
  ]
  tick
end




to setup_adjust
  ;;adjust the settings
end

to layout_adjust
  ;;adjust the layout
end

to begin
  ;;start the simulation
end

to focus_display
  ;;display sth specially
end

to display_adjust
  ;; adjust the display
end

to draw
  ;;plot
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;init the Agent web's settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to init_webs
  set Vi info_value
  let init_prop initial_distribution / 100
  ask webs [
    set site_influence count link-neighbors / ((count weblinks) * 2)
  ]
  ask webs [
    set color green

    set site_status 0
    set site_infoval 0
    set infected_time 0
    set SiteId who
    set site_news_coefficient 0
    set num_login 0
    set num_read 0
    set num_comment 0
  ]
  ask n-of (Num_webs * init_prop) webs [
    set color orange

    set site_status 1
    set site_infoval Vi

    ;; init randomly, changeable
    set infected_time (- random 10)
    set num_login 20
    set num_read 20
    set num_comment 20
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; init the Agent netizen's setting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to init_netizens
  ask Netizens [
    set UserId who
    set user_type 0
    set user_status 0
    set entropy random-float 1
    set infected_threshold 0
  ]
  ;; User_type
  ask max-n-of (Num_netizens * active / 100) netizens [count link-neighbors] [
    set user_type 2
    set Pri_mode one-of [2 3 4]
    set color blue

  ]
  ask n-of (Num_netizens * professional / 100) netizens with [user_type = 0] [
    set user_type 3
    set Pri_mode one-of [3 4]
    set color red
  ]
  ask netizens with [user_type = 0] [
    set user_type 1
    set Pri_mode one-of [1 4]

  ]
end






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; build the Web topology gragh
;; use BA scale-free model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to build_webs_network
  ;;build a BA network

  ;;clear-all
  set-default-shape webs "wheel"
  make-web nobody
  make-web web 0
  while [count webs < Num_webs] [
    ask weblinks [set color gray]
    make-web find-partner

    layout
  ]
end

to make-web [old-node]
  create-webs 1
  [
    set color orange
    if old-node != nobody
    [
      create-weblink-with old-node [set color gray]
      move-to old-node
      fd 8
    ]
  ]
end

to-report find-partner
  report [one-of both-ends] of one-of weblinks
end

to layout
  repeat 3 [
    let factor sqrt count webs
    layout-spring webs weblinks (1 / factor) (7 / factor) (1 / factor)
    display
  ]
  let x-offset max [xcor] of webs + min [xcor] of webs
  let y-offset max [ycor] of webs + min [ycor] of webs
  set x-offset limit-magnitude x-offset 0.1
  set y-offset limit-magnitude y-offset 0.1
  ask webs [setxy (xcor - x-offset / 2) (ycor - y-offset / 2)]
end

to-report limit-magnitude [number limit]
  if number > limit [report limit]
  if number < (- limit) [report (- limit)]
  report number
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; build the netizens network
;; use the WS small world model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to build_netizens_network
  ;; build a WS small-world  network

  ;clear-all
  set infinity 9999  ;; just an arbitrary choice foe a large number
  set-default-shape netizens "person"
  make-netizens

  let success? false
  while [not success?] [
    wire-them
    set success? do-calculations
  ]

  set clustering-coefficient-of-lattice clustering-coefficient
  set average-path-length-of-lattice average-path-length
  set number-rewired 0

  rewire-all
  ask netizenlinks [
    hide-link
  ]

end

to make-netizens
  create-netizens Num_netizens [set color gray + 2]
  layout-circle (sort netizens) max-pxcor - 1
end

to rewire-all

  let success? false
  while [not success?] [
    ask netizenlinks [die]
    wire-them
    set number-rewired 0

    ask netizenlinks [
      if (random-float 1) < rewiring-probability / 100
      [
        let node1 end1
        if [ count link-neighbors ] of end1 < (count netizens - 1)
        [
          let node2 one-of netizens with [(self != node1) and (not link-neighbor? node1)]
          ask node1 [create-netizenlink-with node2 [set color cyan set rewired? true]]

          set number-rewired number-rewired + 1
          set rewired? true
        ]
      ]
      if (rewired?)
     [
      die
     ]
    ]

  set success? do-calculations
  ]
  update-plots
end

to-report do-calculations
  let connected? true
  find-path-lengths

  let num-connected-pairs sum [length remove infinity (remove 0 distance-from-other-netizens)] of netizens
  ifelse (num-connected-pairs != (count netizens * (count netizens - 1)))
  [
    set average-path-length infinity
    set connected? false
  ]
  [
    set average-path-length (sum [sum distance-from-other-netizens] of netizens) / (num-connected-pairs)
  ]
  find-clustering-coefficient
  report connected?
end

to-report in-neighborhood? [hood]
  report (member? end1 hood and member? end2 hood)
end

to find-clustering-coefficient
  ifelse all? netizens [count link-neighbors <= 1]
  [
    set clustering-coefficient 0
  ]
  [
    let total 0
    ask netizens with [count link-neighbors <= 1] [
      set node-clustering-coefficient "undefined" ]
    ask netizens with [count link-neighbors > 1]
    [
      let hood link-neighbors
      set node-clustering-coefficient (2 * count netizenlinks with [in-neighborhood? hood] / ((count hood) * (count hood - 1)) )
      set total total + node-clustering-coefficient
    ]
    set clustering-coefficient total / count netizens with [count link-neighbors > 1]
  ]
end

to find-path-lengths
  ask netizens
  [
    set distance-from-other-netizens []
  ]

  let i 0
  let j 0
  let k 0
  let node1 one-of netizens
  let node2 one-of netizens
  let node-count count netizens

  while [i < node-count]
  [
    set j 0
    while [j < node-count]
    [
      set node1 netizen (i + Num_webs)
      set node2 netizen (j + Num_webs)

      ifelse i = j
      [
        ask node1 [
          set distance-from-other-netizens lput 0 distance-from-other-netizens
        ]
      ]
      [
        ifelse [link-neighbor? node1] of node2
        [
          ask node1 [
            set distance-from-other-netizens lput 1 distance-from-other-netizens
          ]
        ]
        [
          ask node1 [
            set distance-from-other-netizens lput infinity distance-from-other-netizens
          ]
        ]
      ]
      set j j + 1
    ]
    set i i + 1
  ]
  set i 0
  set j 0
  let dummy 0
  while [k < node-count]
  [
    set i 0
    while [i < node-count]
    [
      set j 0
      while [j < node-count]
      [
        set dummy ((item k [distance-from-other-netizens] of netizen (i + Num_webs)) + (item j [distance-from-other-netizens] of netizen (k + Num_webs)))
        if dummy < (item j [distance-from-other-netizens] of netizen (i + Num_webs))
        [
          ask netizen (i + Num_webs) [
            set distance-from-other-netizens replace-item j distance-from-other-netizens dummy
          ]
        ]
        set j j + 1
      ]
      set i i + 1
    ]
    set k k + 1
  ]
end

to wire-them
  let n 0
  while [n < count netizens]
  [
    make-edge netizen (n + Num_webs) netizen (((n + 1) mod count netizens) + Num_webs)
    make-edge netizen (n + Num_webs) netizen (((n + 2) mod count netizens) + Num_webs)
    set n n + 1
  ]
end

to make-edge [node1 node2]
  ask node1 [create-netizenlink-with node2 [
    set rewired? false
  ]]
end


































@#$#@#$#@
GRAPHICS-WINDOW
796
19
1490
714
-1
-1
20.8
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
15
10
187
43
active
active
0
100
41.0
1
1
%
HORIZONTAL

SLIDER
196
11
368
44
info_value
info_value
0
10
9.0
1
1
NIL
HORIZONTAL

SLIDER
15
44
201
77
professional
professional
0
100
18.5
0.1
1
%
HORIZONTAL

SLIDER
207
45
466
78
initial_distribution
initial_distribution
0
100
20.0
1
1
%
HORIZONTAL

SLIDER
12
78
271
111
rewiring-probability
rewiring-probability
0
100
90.0
1
1
%
HORIZONTAL

SWITCH
280
78
483
111
detail_visible?
detail_visible?
1
1
-1000

BUTTON
518
16
619
49
初始化
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

BUTTON
519
49
620
82
重新调整
NIL
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
519
82
620
115
调整布局
NIL
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
17
141
218
186
display_mode
display_mode
"only_netizen_display"
0

CHOOSER
232
141
395
186
evolvement_mode
evolvement_mode
"easy"
0

CHOOSER
393
141
547
186
situation_mode
situation_mode
"normal"
0

BUTTON
41
192
142
225
仿真开始
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
166
191
267
224
重点显示
NIL
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
302
192
403
225
调整显示
NIL
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
432
191
498
224
绘图
NIL
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
261
255
570
405
传播概率及信息时效性价值
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

MONITOR
33
260
173
305
传播范围（单位：个）
list count webs with [site_status = 1] count netizens with [user_status = 1]
17
1
11

MONITOR
32
308
229
353
传播速度（单位：个/仿真周期）
count netizens with [user_status = 1] / ticks
17
1
11

MONITOR
34
353
174
398
网上与网下传播的比例
list sum [num_comment] of webs sum [num_read] of webs
17
1
11

PLOT
33
429
285
579
Web网度分析（log-log）
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

PLOT
289
430
585
579
网民类型与传播
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

PLOT
33
578
285
728
信息扩散律
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count netizens with [user_status = 1] / count netizens"

PLOT
289
578
585
728
2/8律
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

INPUTBOX
632
17
787
77
Num_netizens
300.0
1
0
Number

INPUTBOX
632
86
787
146
Num_webs
200.0
1
0
Number

OUTPUT
536
189
776
243
15

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

dash
0.0
-0.2 0 0.0 1.0
0.0 1 4.0 4.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
