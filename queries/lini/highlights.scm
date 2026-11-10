; Port of lini's editors/zed/languages/lini/highlights.scm (generated from src/grammar/vocab.rs).
; Neovim lets the last matching pattern win, so each generic capture precedes its keyword overrides.

(comment) @comment
(string) @string
(escape) @string.escape
(number) @number
(hex_color) @constant

(type_bars "|" @punctuation.bracket)
(id) @tag
(define_op) @operator

(type) @type
((type) @type.builtin
  (#any-of? @type.builtin "BT" "BZ" "C" "D" "F" "FB" "I" "J" "L" "LED" "M" "Q" "R" "SW" "TP" "V" "Y" "alt" "appliance" "area" "axis" "badge" "balloon" "band" "bars" "bath" "bed" "block" "box" "breakline" "bubble" "caption" "cell" "centerline" "chart" "column" "component" "control" "cyl" "datum" "diamond" "dining" "door" "door-leaf" "door-swing" "dots" "drawing" "else" "entity" "feature-control" "field" "floorplan" "footer" "footnote" "frame" "gnd" "grid" "group" "halo" "header" "hex" "hidden" "hole" "icon" "image" "junction" "label" "line" "loop" "magnifier" "mark" "mindmap" "nc" "note" "opamp" "opt" "oval" "page" "partition" "path" "pie" "pin" "pitch-circle" "plane" "poly" "projection" "rect" "row" "schematic" "sequence" "sheet-caption" "shoulder" "sign" "sketch" "slant" "slice" "sofa" "space" "stack" "stair-arrow" "stair-tread" "stairs" "surface-finish" "table" "threadline" "tick" "title-block" "topic" "wall" "window" "window-sill" "zone"))

(property) @variable.member
((property) @property
  (#any-of? @property "activation" "align" "along" "approved" "at" "author" "axis" "bars" "baseline" "break" "categories" "cell" "characteristic" "clearance" "color" "columns" "corner-radius" "curve" "data" "date" "datums" "density" "department" "direction" "document-type" "draw" "drawing-number" "facing" "fill" "fit" "fn" "font-family" "font-size" "font-style" "font-weight" "format" "gap" "gap-fill" "gridlines" "height" "hinge" "hint" "hole" "href" "justify" "labels" "layer" "layout" "legend" "letter-spacing" "line-spacing" "marker" "marker-end" "marker-start" "material" "max-width" "mirror" "modifiers" "multiple" "number" "of" "on" "opacity" "padding" "path" "pattern" "pin" "pins" "place" "points" "prefix" "project" "radius" "range" "reference" "revision" "revolve" "rotate" "routing" "rows" "samples" "scale" "shadow" "shape" "sheet" "sheet-number" "side" "skew" "span" "src" "status" "step" "steps" "stroke" "stroke-style" "stroke-width" "swing" "symbol" "text-decoration" "text-shadow" "text-transform" "text-wrap" "thickness" "thread" "ticks" "title" "tol" "tooltip" "translate" "unit" "value" "width" "zone"))

(css_var) @variable

(call_name) @function
((call_name) @function.builtin
  (#any-of? @function.builtin "gradient" "hatch" "hsl" "hsla" "linear-gradient" "oklch" "radial-gradient" "repeat" "rgb" "rgba"))

((value_ident) @constant.builtin
  (#any-of? @constant.builtin "flow" "row" "column" "radial" "bilateral" "start" "center" "end" "stretch" "evenly" "origin" "rows" "columns" "none" "auto" "solid" "dashed" "dotted" "wavy" "phantom" "log" "linear" "hover" "always" "orthogonal" "natural" "straight" "contain" "cover" "x-axis" "y-axis" "px" "mm" "cm" "m" "in" "over" "arrow" "dot" "circle" "diamond" "datum" "crow" "many" "one" "exactly-one" "zero-or-one" "one-or-many" "zero-or-many" "bottom" "left" "right" "top" "chart" "drawing" "floorplan" "grid" "pie" "schematic" "sequence" "stack" "tree"))

((value_ident) @constant.builtin
  (#any-of? @constant.builtin "white" "black" "red" "green" "blue" "gray" "grey" "crimson" "orange" "yellow" "gold" "silver" "navy" "teal" "purple" "pink" "brown" "cyan" "magenta" "lime" "maroon" "olive" "cornflowerblue" "currentColor" "transparent"))

(class) @attribute
(side) @constant.builtin
(link_op) @operator
(assign_op) @operator
(fanout) @operator
["{" "}" "[" "]" "(" ")"] @punctuation.bracket
[";" ","] @punctuation.delimiter
