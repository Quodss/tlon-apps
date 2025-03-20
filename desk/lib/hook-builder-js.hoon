/-  h=hooks, c=channels, cite
/+  wasm=wasm-lia
/*  bin  %wasm  /quick-js-emcc/wasm
::
=*  cw            coin-wasm:wasm-sur:wasm
=*  script-form   script-raw-form:lia-sur:wasm
=*  script        script:lia-sur:wasm
=*  stub  !!
::
=<  builder
|%
+$  hook-gate  $-(args:h outcome:h)
+$  wild  (pair (set @) (map @ vase))
++  acc-mold  ::  accumulator type for ++run-once
  |-
  =*  acc-mold  $
  $:  run-u=@                                         ::  runtime 
      ctx-u=@                                         ::  context
      fil-u=@                                         ::  file name
      $=  js-imports                                  ::  JS imports
      (map @ $-([@ @ @ @] (script-form @ acc-mold)))  ::  map @ -> ([ctx-u=@ this-u=@ argc-w=@ argv-u=@] => val-u=@)
  ::
      state=json
      =wild  :: free idxes; map idx -> vase
  ==
::
++  arr  (arrows:wasm acc-mold)
++  builder
  |=  code=cord
  ^-  hook-gate
  |=  [=event:h bowl:h]
  ^-  outcome:h
  =/  state-json  !<(json state.hook)
  ::
  ::  %&: head of return and new state
  ::  %|: QuickJS error and our label
  =;  res=(each return:h (pair cord cord))
    ?:  ?=(%| -.res)
      [%| p.p.res q.p.res ~]
    [%& p.res]
  ::
  =/  yil-mold  (each return:h (pair cord cord))
  %-  yield-need:wasm  =<  -
  %^  (run-once:wasm yil-mold acc-mold)  [bin imports]  %$
  =/  m  (script:lia-sur:wasm yil-mold acc-mold)
  ^-  form:m
  =,  arr
  ::
  ::  main script
  =/  filename=cord  'hook-eval.js'
  =/  filename-len  (met 3 filename)
  ;<  run-u=@    try:m  (call-1 'QTS_NewRuntime' ~)
  ;<  ctx-u=@    try:m  (call-1 'QTS_NewContext' run-u 0 ~)
  ;<  fil-u=@    try:m  (malloc-write +(filename-len) filename)
  =|  acc=acc-mold
  =.  acc  acc(run-u run-u, ctx-u ctx-u, fil-u fil-u, state state-json)
  =^  event-json=json  wild.acc  (event-to-json event wild.acc)
  ;<  ~          try:m  (set-acc acc)
  ::
  ;<  err=(unit cord)  try:m  (make-function 'require' require)
  ?^  err  (return:m |+[u.err 'make require'])
  ;<  err=(unit cord)  try:m  (make-function '_get_state' get-state)
  ?^  err  (return:m |+[u.err 'make _get_state'])
  ;<  err=(unit cord)  try:m  (make-function '_set_state' set-state)
  ?^  err  (return:m |+[u.err 'make _set_state'])
  ::
  ;<  *                try:m  (js-eval 'var module = {};')  ::  XX add actual CJS module system api?
  ;<  res-u=@          try:m  (js-eval code)  :: imports the interface library via require, exports a function to module.exports
  ;<  err=(unit cord)  try:m  (mayb-error res-u)
  ?^  err  (return:m |+[u.err 'failed to export the hook function'])
  ;<  *                try:m  (store-json-name '_eve' event-json)
  ;<  res-u=@          try:m  ::  XX sane function call instead of eval?
    %-  js-eval
    '''
    let _res = module.exports(_eve);
    _res
    '''
  ::
  ;<  err=(unit cord)  try:m  (mayb-error res-u)
  ?^  err  (return:m |+[u.err 'failed to call the exported function'])
  ;<  out=json         try:m  (load-json res-u)
  ;<  acc=acc-mold     try:m  get-acc
  =/  res=(pair event-result:h (list effect:h))  (return-of-json out wild.acc)
  (return:m &+[res !>(state.acc)])
::
::  XX check memory conventions, add free calls
::
++  add-wild
  |=  [vax=vase wild=(pair (set @) (map @ vase))]
  ^-  [@ _wild]
  ?~  p.wild
    =/  idx-new=@  +((~(rep in ~(key by q.wild)) max))
    [idx-new ~ (~(put by q.wild) idx-new vax)]
  :-  n.p.wild
  :-  (~(uni in l.p.wild) r.p.wild)
  (~(put by q.wild) n.p.wild vax)
::
++  del-wild
  |=  [idx=@ wild=(pair (set @) (map @ vase))]
  ^+  wild
  :-  (~(put in p.wild) idx)
  (~(del by q.wild) idx)
::
++  event-to-json
  |=  [=event:h wil=wild]
  |^  ^-  [json wild]
  =^  data=json  wil
    ?-  -.event
      %cron      [~ wil]
      %on-post   [(on-post +.event) wil]
      %on-reply  [(on-reply +.event) wil]
      %wake      (waiting-hook +.event wil)
    ==
  :: [o+(molt tag+`json`s+-.event -.event^data ~) wil]
  :_  wil
  ^-  json
  :-  %o
  %-  molt
  ^-  (list (pair @t json))
  :~
    [%tag [%s `@t`-.event]]
    [-.event data]
  ==
  ::
  ++  on-post
    |=  a=on-post:h
    ^-  json
    :-  %o
    %-  molt
    ^-  (list (pair @t json))
    :-  tag+s+-.a
    ?-    -.a
        %add
      ~[post+(v-post post.a)]
    ::
        %edit
      ~[original+(v-post original.a) essay+(essay essay.a)]
    ::
        %del
      ~[original+(v-post original.a)]
    ::
        %react
      :~  post+(v-post post.a)
          ship+(ship:enjs:format ship.a)
          react+(react react.a)
      ==
    ==
  ::
  ++  on-reply
    |=  a=on-reply:h
    ^-  json
    :-  %o
    %-  molt
    ^-  (list (pair @t json))
    :-  tag+s+-.a
    ?-    -.a
        %add
      ~[parent+(v-post parent.a) reply+(v-reply reply.a)]
    ::
        %edit
      :~  parent+(v-post parent.a)
          original+(v-reply original.a)
          content+(story content.memo.a)
          author+(ship:enjs:format author.memo.a)
          sent+(sect:enjs:format sent.memo.a)
      ==
    ::
        %del
      ~[parent+(v-post parent.a) original+(v-reply original.a)]
    ::
        %react
      :~  parent+(v-post parent.a)
          reply+(v-reply reply.a)
          ship+(ship:enjs:format ship.a)
          react+(react react.a)
      ==
    ::
    ==
  ::
  ++  waiting-hook
    |=  [a=waiting-hook:h wid=wild]
    ^-  [json wild]
    =^  idx=@  wid  (add-wild data.a wid)
    :_  wid
    =,  enjs:format
    %:  pairs
      [%id (numb id.a)]
      [%hook (numb hook.a)]
      [%data (numb idx)]
      [%fires-at (sect fires-at.a)]
      ~
    ==
  ::
  ++  v-post
    |=  =v-post:c
    ^-  json
    =,  enjs:format
    %:  pairs
      id+(sect id.v-post)
      replies+(v-replies replies.v-post)
      reacts+(v-reacts reacts.v-post)
      rev+(numb rev.v-post)
      content+(story content.v-post)
      author+(ship author.v-post)
      sent+(sect sent.v-post)
      kind+(kind kind-data.v-post)
      ~
    ==
  ::
  ++  kind
    |=  =kind-data:c
    ^-  json
    =,  enjs:format
    %-  pairs
    ^-  (list (pair @t json))
    :-  tag+s+-.kind-data
    ?-  -.kind-data
      %diary  ~[title+s+title image+s+image]:kind-data
      %heap   ~[title+?~(title ~ s+u.title)]:kind-data
      %chat   ~[title+?@(kind ~ s+'notice')]:kind-data
    ==
  ::
  ++  v-replies
    |=  =v-replies:c
    ^-  json
    =,  enjs:format
    :-  %a
    %+  turn  (tap:on-v-replies:c v-replies)
    |=  [key=id-reply:c val=(unit v-reply:c)]
    ^-  json
    %-  pairs
    :~
      id-reply+(sect key)
      v-reply+?~(val ~ (v-reply u.val))
    ==
  ::
  ++  v-reacts
    |=  =v-reacts:c
    ^-  json
    =,  enjs:format
    :-  %a
    %+  turn  ~(tap by v-reacts)
    |=  [key=@p val=(rev:c (unit react:c))]
    ^-  json
    %-  pairs
    :~
      ship+(ship key)
      rev+(numb rev.val)
      react+?~(+.val ~ s+u.+.val)
    ==
  ::
  ++  story
    |=  =story:c
    ^-  json
    =,  enjs:format
    :-  %a
    %+  turn  story
    |=  =verse:c
    ^-  json
    %-  pairs
    ^-  (list (pair @t json))
    :-  tag+s+-.verse
    ?-  -.verse
      %block  ~[block+(block p.verse)]
      %inline  ~[inline+a+(turn p.verse inline)]
    ==
  ::
  ++  block
    |=  =block:c
    ^-  json
    =,  enjs:format
    %-  pairs
    ^-  (list (pair @t json))
    :-  tag+s+-.block
    ?-    -.block
        %image
      :~  src+s+src.block
          height+(numb height.block)
          width+(numb width.block)
          alt+s+alt.block
      ==
    ::
        %cite
      ~[cite+(cite cite.block)]
    ::
        %header
      ~[p+s+p.block q+a+(turn q.block inline)]
    ::
        %listing
      ~[listing+(listing p.block)]
    ::
        %rule
      ~[rule+~]
    ::
        %code
      ~[code+s+code lang+s+lang]:block
    ::
    ==
  ::
  ++  cite
    |=  =cite:^cite
    ^-  json
    =,  enjs:format
    %-  pairs
    ^-  (list (pair @t json))
    :-  tag+s+-.cite
    ?-    -.cite
        %chan
      :~  app+s+p.nest.cite
          ship+(ship p.q.nest.cite)
          name+s+q.q.nest.cite
          path+(path wer.cite)
      ==
    ::
        %group
      ~[ship+(ship p.flag.cite) name+s+q.flag.cite]
    ::
        %desk
      ~[ship+(ship p.flag.cite) name+s+q.flag.cite path+(path wer.cite)]
    ::
        %bait
      :~  ship-grp+(ship p.grp.cite)
          name-grp+s+q.grp.cite
          ship-gra+(ship p.gra.cite)
          name-gra+s+q.gra.cite
          path+(path wer.cite)
      ==
    ::
    ==
  ::
  ++  listing
    |=  =listing:c
    ^-  json
    =,  enjs:format
    %-  pairs
    ^-  (list (pair @t json))
    :-  tag+s+-.listing
    ?-    -.listing
        %list
      :~  order+s+p.listing
          listings+a+(turn q.listing ^listing)
          text+a+(turn r.listing inline)
      ==
    ::
        %item
      ~[text+a+(turn p.listing inline)]
    ==
  ::
  ++  inline
    |=  =inline:c
    ^-  json
    ?@  inline  s+inline
    =,  enjs:format
    %-  pairs
    ^-  (list (pair @t json))
    :-  tag+s+-.inline
    ?-    -.inline
        %italics
      ~[text+a+(turn p.inline ^inline)]
    ::
        %bold
      ~[text+a+(turn p.inline ^inline)]
    ::
        %strike
      ~[text+a+(turn p.inline ^inline)]
    ::
        %blockquote
      ~[text+a+(turn p.inline ^inline)]
    ::
        %inline-code
      ~[text+s+p.inline]
    ::
        %code
      ~[text+s+p.inline]
    ::
        %ship
      ~[text+(ship p.inline)]
    ::
        %block
      ~[num+(numb p.inline) text+s+q.inline]
    ::
        %tag
      ~[text+s+p.inline]
    ::
        %link
      ~[p+s+p.inline q+s+q.inline]
    ::
        %task
      ~[flag+b+p.inline text+a+(turn q.inline ^inline)]
    ::
        %break
      ~[break+~]
    ::
    ==
  ::
  ++  essay
    |=  =essay:c
    ^-  json
    =,  enjs:format
    %-  pairs
    ^-  (list (pair @t json))
    :~
      content+(story content.essay)
      author+(ship author.essay)
      sent+(sect sent.essay)
      kind+(kind kind-data.essay)
    ==
  ::
  ++  react
    |=  a=(unit react:c)
    ^-  json
    ?~  a  ~
    s+u.a
  ::
  ++  v-reply
    |=  =v-reply:c
    ^-  json
    =,  enjs:format
    %-  pairs
    ^-  (list (pair @t json))
    :~
      id+(sect id.v-reply)
      reacts+(v-reacts reacts.v-reply)
      rev+(numb rev.v-reply)
      content+(story content.v-reply)
      author+(ship author.v-reply)
      sent+(sect sent.v-reply)
    ==
  ::
  --
::
++  return-of-json
  |=  [jon=json =wild]
  ^-  (pair event-result:h (list effect:h))
  stub
::
++  require
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script:lia-sur:wasm @ acc-mold)
  ^-  form:m
  =,  arr
  stub  :: XX add library code
::
++  get-state
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script:lia-sur:wasm @ acc-mold)
  ^-  form:m
  =,  arr
  ;<  acc=acc-mold  try:m  get-acc
  (store-json state.acc)
::
++  set-state
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script:lia-sur:wasm @ acc-mold)
  ^-  form:m
  =,  arr
  ;<  acc=acc-mold  try:m  get-acc
  ?>  =(1 argc-w)
  ;<  jon=json  try:m  (load-json argv-u)
  ;<  ~         try:m  (set-acc acc(state jon))
  (call-1 'QTS_NewFloat64' ctx-u 0 ~)
::
++  make-function
  |=  $:  name=cord
          gat=$-([@ @ @ @] (script-form @ acc-mold))
      ==
  =/  m  (script:lia-sur:wasm (unit cord) acc-mold)  ::  (unit error=cord)
  ^-  form:m
  =,  arr
  ;<  acc=acc-mold  try:m  get-acc
  =,  acc
  ::
  =/  mag-w=@
    ?:  =(~ js-imports)  0
    +((~(rep in ~(key by js-imports)) max))
  ;<  nam-u=@  try:m  (malloc-write +((met 3 name)) name)
  ;<  res-u=@  try:m  (call-1 'QTS_NewFunction' ctx-u mag-w nam-u ~)
  ::
  ;<  err=(unit cord)  try:m  (mayb-error res-u)
  ?^  err  (return:m err)
  ::
  ;<  global-this-u=@  try:m  (call-1 'QTS_GetGlobalObject' ctx-u ~)
  ;<  nam-val-u=@      try:m  (call-1 'QTS_NewString' ctx-u nam-u ~)  ::  free string value?
  ;<  undef-u=@        try:m  (call-1 'QTS_GetUndefined' ~)
  ;<  *                try:m
    %:  call  'QTS_DefineProp'
      ctx-u
      global-this-u
      nam-val-u
      res-u
      undef-u  ::  get
      undef-u  ::  set
      0        ::  configurable
      0        ::  enumerable
      1        ::  has_value
      ~
    ==
  ::
  ;<  ~  try:m
    (set-acc acc(js-imports (~(put by js-imports.acc) mag-w gat)))
  (return:m ~)
::
++  js-eval
  |=  code=cord
  =/  m  (script:lia-sur:wasm @ acc-mold)
  ^-  form:m
  =,  arr
  ;<  acc=acc-mold  try:m  get-acc
  =,  acc
  ::
  =/  code-len  (met 3 code)
  ;<  code-u=@  try:m  (malloc-write +(code-len) code)
  ;<  res-u=@   try:m  (call-1 'QTS_Eval' ctx-u code-u code-len fil-u 0 0 ~)
  ;<  *         try:m  (call 'free' code-u ~)
  (return:m res-u)
::
++  load-json
  |=  ptr-u=@
  =/  m  (script:lia-sur:wasm json acc-mold)
  ^-  form:m
  =,  arr
  ;<  acc=acc-mold  try:m  get-acc
  =,  acc
  ::
  ;<  type-u=@   try:m  (call-1 'QTS_Typeof' ctx-u ptr-u ~)
  ;<  type=cord  try:m  (get-c-string type-u)
  ?+    type  ~|(json-unsupported-type+type !!)
      ?(%'number' %'bigint')
    ;<  float=@rd  try:m  (call-1 'QTS_GetFloat64' ctx-u ptr-u ~)
    (return:m n+(rsh 3^2 (scot %rd float)))
  ::
      %'string'
    ;<  str=cord  try:m  (get-js-string ptr-u)
    (return:m s+str)
  ::
      %'boolean'
    ;<  float=@rd  try:m  (call-1 'QTS_GetFloat64' ctx-u ptr-u ~)
    (return:m b+!=(float 0))
  ::
      %'object'
    ::  %a, %o or ~
    ::  test for ~
    ::
    ;<  null-u=@  try:m  (call-1 'QTS_GetNull' ~)
    ;<  is-eq=@   try:m  (call-1 'QTS_IsEqual' ctx-u ptr-u null-u 0 ~)
    ?:  !=(0 is-eq)
      (return:m ~)
    ::  test for %a
    ::
    =/  name  'length'
    ;<  len-u=@  try:m
      %:  ding  'QTS_GetProp'
        ctx-u
        ptr-u
        (ding 'QTS_NewString' ctx-u (malloc-write +((met 3 name)) name) ~)
        ~
      ==
    ::
    ;<  err=(unit cord)  try:m  (mayb-error len-u)
    ;<  undef-u=@        try:m  (call-1 'QTS_GetUndefined' ~)
    ::
    ;<  is-undef=@  try:m  (call-1 'QTS_IsEqual' ctx-u len-u undef-u 0 ~)
    ?:  |(?=(^ err) !=(is-undef 0))  ::  obj.length either failed or undefined
      ::  object
      ::
      ;<  out-ptrs-u=@  try:m  (call-1 'malloc' 4 ~)
      ;<  out-len-u=@   try:m  (call-1 'malloc' 4 ~)
      ;<  err-u=@       try:m
        (call-1 'QTS_GetOwnPropertyNames' ctx-u out-ptrs-u out-len-u ptr-u 1 ~)  ::  JS_GPN_STRING_MASK
      ::
      ?:  !=(err-u 0)
        ;<  str=cord  try:m  (get-js-string err-u)
        ~|(str !!)
      ::
      ;<  len-octs=octs  try:m  (memread out-len-u 4)
      =/  len-w=@  q.len-octs
      ;<  arr-octs=octs  try:m  (memread out-ptrs-u 4)
      =/  arr-u=@  q.arr-octs
      =|  pairs=(list (pair @t json))
      |-  ^-  form:m
      ?:  =(len-w 0)  (return:m o+(molt pairs))
      =/  idx=@  (dec len-w)
      ;<  nam-val-octs=octs  try:m  (memread (add arr-u (mul 4 idx)) 4)
      =/  nam-val-u=@  q.nam-val-octs
      ;<  name=cord    try:m  (get-js-string nam-val-u)
      ;<  val-u=@      try:m
        %:  call-1  'QTS_GetProp'
          ctx-u
          ptr-u
          nam-val-u
          ~
        ==
      ::
      ;<  jon-child=json  try:m  (load-json val-u)
      $(len-w (dec len-w), pairs [[name jon-child] pairs])
    ::  array
    ::
    ;<  len-d=@rd  try:m  (call-1 'QTS_GetFloat64' ctx-u len-u ~)
    =/  len=@  (abs:si (need (toi:rd len-d)))
    =|  vals=(list json)
    |-  ^-  form:m
    ?:  =(len 0)  (return:m a+vals)
    =/  idx=@  (dec len)
    ;<  val-u=@  try:m
      %:  ding  'QTS_GetProp'
        ctx-u
        ptr-u
        (call-1 'QTS_NewFloat64' ctx-u (sun:rd idx) ~)
        ~
      ==
    ::
    ;<  jon-child=json  try:m  (load-json val-u)
    $(len (dec len), vals [jon-child vals])
  ==
::
++  store-json-name
  |=  [name=cord =json]
  =/  m  (script:lia-sur:wasm ,~ acc-mold)
  ^-  form:m
  =,  arr
  ;<  acc=acc-mold  try:m  get-acc
  =,  acc
  ::
  ;<  undef-u=@  try:m  (call-1 'QTS_GetUndefined' ~)
  ::
  ;<  *  try:m
    %:  ring  'QTS_DefineProp'
      ctx-u
      (call-1 'QTS_GetGlobalObject' ctx-u ~)
      (ding 'QTS_NewString' ctx-u (malloc-write +((met 3 name)) name) ~)
      (store-json json)
      undef-u  ::  get
      undef-u  ::  set
      1        ::  configurable
      1        ::  enumerable
      1        ::  has_value
      ~
    ==
  ::
  (return:m ~)
::
++  store-json
  |=  jon=json
  =/  m  (script:lia-sur:wasm @ acc-mold)
  ^-  form:m
  =,  arr
  ;<  acc=acc-mold  try:m  get-acc
  =,  acc
  ::
  =/  code=cord
    %-  crip
    """
    JSON.parse('{(trip (en:json:html jon))}')
    """
  ;<  res-u=@  try:m
    %:  ding  'QTS_Eval'
      ctx-u
      (malloc-write +((met 3 code)) code)
      (met 3 code)
      fil-u
      1
      0
      ~
    ==
  ::
  ;<  err=(unit cord)  try:m  (mayb-error res-u)
  ?^  err  ~|  u.err  !!
  (return:m res-u)
::
++  ring  ::  complex call
  |=  [func=cord args=(list $@(@ (script-form @ acc-mold)))]
  =/  m  (script:lia-sur:wasm (list @) acc-mold)
  ^-  form:m
  =,  arr
  =|  args-atoms=(list @)
  |-  ^-  form:m
  ?~  args  (call func (flop args-atoms))
  ?@  i.args  $(args t.args, args-atoms [i.args args-atoms])
  ;<  atom=@  try:m  i.args
  $(args t.args, args-atoms [atom args-atoms])
::
++  ding  ::  complex call-1
  |=  [func=cord args=(list $@(@ (script-form @ acc-mold)))]
  =/  m  (script:lia-sur:wasm @ acc-mold)
  ;<  out=(list @)  try:m  (ring func args)
  ?>  =(1 (lent out))
  (return:m -.out)
::
++  mayb-error
  |=  res-u=@
  =/  m  (script:lia-sur:wasm (unit cord) acc-mold)
  ^-  form:m
  =,  arr
  ;<  acc=acc-mold  try:m  get-acc
  =,  acc
  ::
  ;<  err-u=@   try:m  (call-1 'QTS_ResolveException' ctx-u res-u ~)
  ?:  =(0 err-u)  (return:m ~)
  ;<  str-u=@   try:m  (call-1 'QTS_GetString' ctx-u err-u ~)
  ;<  str=cord  try:m  (get-c-string str-u)
  (return:m `str)
::
++  malloc-write
  |=  data=octs
  =/  m  (script:lia-sur:wasm @ acc-mold)
  ^-  form:m
  =,  arr
  ;<  ptr-u=@  try:m  (call-1 'malloc' p.data ~)
  ;<  ~        try:m  (memwrite ptr-u data)
  (return:m ptr-u)
::
++  get-c-string
  |=  ptr=@
  =/  m  (script:lia-sur:wasm cord acc-mold)
  ^-  form:m
  =,  arr
  =/  len=@  0
  =/  cursor=@  ptr
  |-  ^-  form:m
  ;<  char=octs  try:m  (memread cursor 1)
  ?.  =(0 q.char)
    $(len +(len), cursor +(cursor))
  ;<  =octs  try:m  (memread ptr len)
  (return:m q.octs)
::
++  get-js-string
  |=  val-u=@
  =/  m  (script:lia-sur:wasm cord acc-mold)
  ^-  form:m
  =,  arr
  ;<  acc=acc-mold  try:m  get-acc
  =,  acc
  ::
  ;<  str-u=@  try:m  (call-1 'QTS_GetString' ctx-u val-u ~)
  (get-c-string str-u)
::
++  imports
  ^~  ^-  (import:lia-sur:wasm acc-mold)
  :-  *acc-mold
  =/  m  (script:lia-sur:wasm (list cw) acc-mold)
  %-  malt
  :~
    :-  'wasi_snapshot_preview1'^'clock_time_get'  ::  not a real time
    |=  args=(pole cw)
    ^-  form:m
    ?>  ?=([[%i32 @] [%i64 @] [%i32 time-u=@] ~] args)
    =,  arr  =,  args
    ;<  ~  try:m  (memwrite time-u 8 0)
    (return:m i32+0 ~)
  ::
    :-  'env'^'qts_host_call_function'
    |=  args=(pole cw)
    ^-  form:m
    ?>  ?=  $:  [%i32 ctx-u=@]
                [%i32 this-u=@]
                [%i32 argc-w=@]
                [%i32 argv-u=@]
                [%i32 magic-w=@]
                ~
            ==
        args
    ::
    =,  arr  =,  args
    ;<  acc=acc-mold  try:m  get-acc
    ;<  val-u=@       try:m
      ((~(got by js-imports.acc) magic-w) ctx-u this-u argc-w argv-u)
    (return:m i32+val-u ~)
  ::
    :-  'env'^'emscripten_notify_memory_growth'
    |=  args=(pole cw)
    (return:m ~)
  ==
--