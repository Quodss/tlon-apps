/-  h=hooks, c=channels, cite, co=contacts
/+  wasm=wasm-lia
/+  cj=channel-json, gj=groups-json, aj=activity-json, chj=chat-json
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
+$  wild  (trel @ (list @) (map @ vase))
+$  acc-mold  ::  accumulator type for ++run-once
  $:  run-u=@                                         ::  runtime 
      ctx-u=@                                         ::  context
      fil-u=@                                         ::  file name
      $=  js-imports                                  ::  JS imports
      (map @ $-([@ @ @ @] (script-form @ acc-mold)))  ::  map @ -> ([ctx-u=@ this-u=@ argc-w=@ argv-u=@] => val-u=@)
  ::
      state=json
      =wild  :: next idx; free idxes; map idx -> vase
  ==
::
++  arr  (arrows:wasm acc-mold)
++  builder
  |=  code=cord
  ^-  hook-gate
  |=  [=event:h bowl:h]
  ^-  outcome:h
  ?~  state-json=(mole |.(!<(json state.hook)))
    [%| 'non json hook state' ~]
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
  =.  acc  acc(run-u run-u, ctx-u ctx-u, fil-u fil-u, state u.state-json)
  =^  event-json=json  wild.acc  (event-to-json event wild.acc)
  ;<  ~          try:m  (set-acc acc)
  ::
  ;<  err=(unit cord)  try:m  (make-function 'require' require)
  ?^  err  (return:m |+[u.err 'make require'])
  ;<  err=(unit cord)  try:m  (make-function '_get_state' get-state)
  ?^  err  (return:m |+[u.err 'make _get_state'])
  ;<  err=(unit cord)  try:m  (make-function '_set_state' set-state)
  ?^  err  (return:m |+[u.err 'make _set_state'])
  ;<  err=(unit cord)  try:m  (make-function '_wish_js' wish-js)
  ?^  err  (return:m |+[u.err 'make _wish_js'])
  ;<  err=(unit cord)  try:m  (make-function '_slam_js' slam-js)
  ?^  err  (return:m |+[u.err 'make _slam_js'])
  ;<  err=(unit cord)  try:m  (make-function '_to_json' to-json)
  ?^  err  (return:m |+[u.err 'make _to_json'])
  ;<  err=(unit cord)  try:m  (make-function '_of_json' of-json)
  ?^  err  (return:m |+[u.err 'make _of_json'])
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
++  suze  ^~(!>(..zuse))
++  wish-js
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script:lia-sur:wasm @ acc-mold)
  ^-  form:m
  =,  arr
  ?>  (gte argc-w 1)
  ;<  str=cord  try:m  (get-js-string argv-u)
  =/  gen=hoon  (ream str)
  =/  vax=vase  (slap suze gen)
  ;<  acc=acc-mold  try:m  get-acc
  =^  idx=@  wild.acc  (add-wild vax wild.acc)
  ;<  ~  try:m  (set-acc acc)
  (call-1 'QTS_NewFloat64' ctx-u (sun:rd idx) ~)
::
++  slam-js
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script:lia-sur:wasm @ acc-mold)
  ^-  form:m
  =,  arr
  ?>  (gte argc-w 2)
  ;<  idx1-float=@rd  try:m  (call-1 'QTS_GetFloat64' ctx-u argv-u ~)
  ;<  idx2-float=@rd  try:m  (call-1 'QTS_GetFloat64' ctx-u (add 8 argv-u) ~)  ::  sizeof JSValue == 8 in wasm
  ?~  idx1=(bind (toi:rd idx1-float) abs:si)
    (call-1 'QTS_NewFloat64' ctx-u .~nan ~)
  ::
  ?~  idx2=(bind (toi:rd idx2-float) abs:si)
    (call-1 'QTS_NewFloat64' ctx-u .~nan ~)
  ::
  ;<  acc=acc-mold  try:m  get-acc
  ?~  gat=(get-wild u.idx1 wild.acc)
    (call-1 'QTS_NewFloat64' ctx-u .~nan ~)
  ::
  ?~  sam=(get-wild u.idx2 wild.acc)
    (call-1 'QTS_NewFloat64' ctx-u .~nan ~)
  ::
  ?~  pro=(mole |.((slam u.gat u.sam)))
    (call-1 'QTS_NewFloat64' ctx-u .~nan ~)
  ::
  =^  idx=@  wild.acc  (add-wild u.pro wild.acc)
  ;<  ~  try:m  (set-acc acc)
  (call-1 'QTS_NewFloat64' ctx-u (sun:rd idx) ~)
::
++  of-json
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script:lia-sur:wasm @ acc-mold)
  ^-  form:m
  =,  arr
  ?>  (gte argc-w 1)
  ;<  idx-float=@rd  try:m  (call-1 'QTS_GetFloat64' ctx-u argv-u ~)
  ?~  idx=(bind (toi:rd idx-float) abs:si)  (call-1 'QTS_GetNull' ~)
  ;<  acc=acc-mold  try:m  get-acc
  ?~  vax=(get-wild u.idx wild.acc)         (call-1 'QTS_GetNull' ~)
  ?~  jon=(mole |.(!<(json u.vax)))         (call-1 'QTS_GetNull' ~)
  (store-json u.jon)
::
++  to-json
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script:lia-sur:wasm @ acc-mold)
  ^-  form:m
  =,  arr
  ?>  (gte argc-w 1)
  ;<  jon=json  try:m  (load-json argv-u)
  =/  vax=vase  !>(jon)
  ;<  acc=acc-mold  try:m  get-acc
  =^  idx=@  wild.acc  (add-wild vax wild.acc)
  ;<  ~             try:m  (set-acc acc)
  (call-1 'QTS_NewFloat64' ctx-u (sun:rd idx) ~)
::
++  get-wild
  |=  [idx=@ wil=wild]
  ^-  (unit vase)
  (~(get by r.wil) idx)
::
++  add-wild
  |=  [vax=vase wil=wild]
  ^-  [@ wild]
  ?~  q.wil
    =/  nu=@  p.wil
    [nu [+(nu) ~ (~(put by r.wil) nu vax)]]
  :-  i.q.wil
  [p.wil t.q.wil (~(put by r.wil) i.q.wil vax)]
::
++  del-wild
  |=  [idx=@ wil=wild]
  ^-  wild
  =/  q-wil=(list @)
    ?^  (find ~[idx] q.wil)  q.wil
    [idx q.wil]
  [p.wil q-wil (~(del by r.wil) idx)]
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
  [o+(molt ~[['tag' `json`[%s `@t`-.event]] [-.event data]]) wil]
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
++  event-of-json
  |=  [jon=json wid=wild]
  ^-  event:h
  stub
::
++  return-of-json
  |=  [jon=json wid=wild]
  ^-  (pair event-result:h (list effect:h))
  ?>  ?=([%o *] jon)
  =/  eve-res=json  (~(got by p.jon) 'event')
  =/  effects=json  (~(got by p.jon) 'effects')
  ?>  ?=([%o *] eve-res)
  =/  tag-eve-res=json  (~(got by p.eve-res) 'tag')
  =/  p-out=event-result:h
    ?+    tag-eve-res  !!
        [%s %'allowed']
      allowed+(event-of-json (~(got by p.eve-res) 'allowed') wid)
    ::
        [%s %'denied']
      :-  %denied
      ?~  msg=(~(got by p.eve-res) 'denied')
        ~
      ?.  ?=([%s *] msg)  !!
      `p.msg
    ==
  ::
  ?>  ?=([%a *] effects)
  =;  q-out=(list effect:h)
    [p-out q-out]
  %+  turn  p.effects
  |=  jon=json
  ^-  effect:h
  ?>  ?=([%o *] jon)
  =/  tag-effect=json  (~(got by p.jon) 'tag')
  ?+    tag-effect  !!
      [%s %'channels']
    =/  a-channels-jon  (~(got by p.jon) 'channels')
    channels+(a-channels:dejs:cj a-channels-jon)
  ::
      [%s %'groups']
    =/  action-jon  (~(got by p.jon) 'groups')
    groups+(action:dejs:gj action-jon)
  ::
      [%s %'activity']
    =/  action-jon  (~(got by p.jon) 'activity')
    activity+(action:dejs:aj action-jon)
  ::
      [%s %'dm']
    =/  action-jon  (~(got by p.jon) 'dm')
    dm+(dm-action:dejs:chj action-jon)
  ::
      [%s %'club']
    =/  action-jon  (~(got by p.jon) 'club')
    club+(club-action:dejs:chj action-jon)
  ::
      [%s %'contacts']
    =/  action-jon  (~(got by p.jon) 'contacts')
    contacts+(contacts-action-of-js action-jon)
  ::
      [%s %'wait']
    =/  wait  (~(got by p.jon) 'wait')
    wait+(waiting-hook-of-js wait wid)
  ::
  ==
::
++  contacts-action-of-js
  ^-  $-(json action:co)
  =,  dejs:format
  %-  of
  :~
    anon+ul
    self+contact-of-js
    page+(ot kip+kip-of-js contact+contact-of-js ~)
    edit+(ot kip+kip-of-js contact+contact-of-js ~)
    wipe+(ar kip-of-js)
    meet+(ar ni)
    drop+(ar ni)
    snub+(ar ni)
  ==
::
++  contact-of-js
  ^-  $-(json contact:co)
  =,  dejs:format
  (op sym value-of-js)
::
++  value-of-js
  |=  jon=json
  ^-  value:co
  ?~  jon  ~
  %.  jon
  =,  dejs:format
  %-  of
  :~
    text+so
    numb+ni
    date+di
    tint+ni
    ship+ni
    look+so
    flag+flag:dejs:gj
    set+(as value-of-js)
  ==
++  kip-of-js
  |=  jon=json
  ^-  kip:co
  ?~  jon  !!
  =,  dejs:format
  ?:  ?=(%n -.jon)  (ni jon)
  ((of id+ni ~) jon)
::
++  waiting-hook-of-js
  |=  [jon=json wid=wild]
  ^-  waiting-hook:h
  =,  dejs:format
  =/  hok=(qual @ @ @ time)
    ((ot id+ni hook+ni data+ni fires-at+di ~) jon)
  ::
  =/  data=vase  (need (get-wild r.hok wid))
  [p.hok q.hok data s.hok]
::
++  js-val-cord-compare
  |=  [val-u=@ =cord]
  =/  m  (script:lia-sur:wasm ? acc-mold)
  ^-  form:m
  =,  arr
  ;<  acc=acc-mold  try:m  get-acc
  =,  acc
  ::
  ;<  crd-u=@  try:m  (malloc-write +((met 3 cord)) cord)
  ;<  str-u=@  try:m  (call-1 'QTS_NewString' ctx-u crd-u ~)
  ;<  is-eq=@  try:m  (call-1 'QTS_IsEqual' ctx-u val-u str-u 0 ~)  :: QTS_EqualOp_SameValue
  ;<  *        try:m  (call 'QTS_FreeValuePointer' ctx-u str-u ~)
  ;<  *        try:m  (call 'free' crd-u ~)
  (return:m !=(is-eq 0))
::
++  make-error
  |=  txt=cord
  =/  m  (script:lia-sur:wasm @ acc-mold)
  ^-  form:m
  =,  arr
  ;<  acc=acc-mold  try:m  get-acc
  =,  acc
  ::
  ;<  err-u=@  try:m  (call-1 'QTS_NewError' ctx-u ~)
  =/  field=cord  'message'
  ;<  *        try:m
    %:  ring  'QTS_SetProp'
      ctx-u
      err-u
      (ding 'QTS_NewString' ctx-u (malloc-write +((met 3 field)) field) ~)
      (ding 'QTS_NewString' ctx-u (malloc-write +((met 3 txt)) txt) ~)
      ~
    ==
  ::
  (return:m err-u)
::
++  require
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script:lia-sur:wasm @ acc-mold)
  ^-  form:m
  =,  arr
  ?>  (gte argc-w 1)
  ;<  is-tlon-hooks=?  try:m  (js-val-cord-compare argv-u 'tlon-hooks')
  ?:  is-tlon-hooks  (js-eval tlon-hooks-code)  ::  TODO proper addition in agreement with `require` spec?
  ::  ;<  is-foo=?  try:m  (js-val-cord-compare argv-u 'foo')
  ::  ?:  is-foo  (js-eval foo-code)
  ::  ...
  ::
  (ding 'QTS_Throw' ctx-u (make-error 'Name not recognized by `require`') ~)
::
++  tlon-hooks-code
  ^-  cord
  '''
  var _o = {
    get_state() {
      return _get_state();  // returns object from state.hook
    },
  //
    set_state(obj) {
      return _set_state(obj);  // returns (), sets state.hook
    },
  //
    wish_js(txt) {
      return _wish_js(txt);  // returns float: wild idx with the prodcuct of hoon expression
    },
  //
    slam_js(idx1, idx2) {
      return _slam_js(idx1, idx2);  // returns float: wild idx with the product of gate slam
    },
  //
    to_json(obj) {
      return _to_json(obj);  // returns float: wild idx with the object as a noun
    },
  //
    of_json(idx) {
      return _of_json(idx); // returns object: deserialization of of a noun at idx in wild
    },
  //
  }
  _o
  '''
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