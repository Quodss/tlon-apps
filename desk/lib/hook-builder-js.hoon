/-  h=hooks, c=channels, cite, co=contacts, g=groups, ch=chat
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
+$  wild  (qual @ (list @) (map @ vase) (map vase @))
+$  acc-mold  ::  accumulator type for ++run-once
  $:  run-u=@                                         ::  runtime 
      ctx-u=@                                         ::  context
      fil-u=@                                         ::  file name
      $=  js-imports                                  ::  JS imports
      (map @ $-([@ @ @ @] (script-form @ acc-mold)))  ::  map @ -> ([ctx-u=@ this-u=@ argc-w=@ argv-u=@] => val-u=@)
  ::
      state=json
      =wild  :: next idx; free idxes; maps idx <-> unique vase
  ==
::
++  arr  (arrows:wasm acc-mold)
++  builder
  |=  code=cord
  ^-  hook-gate
  |=  [=event:h =bowl:h]
  ^-  outcome:h
  ~>  %bout
  ?~  state-json=(mole |.(!<(json state.hook.bowl)))
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
  =^  idx-bowl  wild.acc  (add-wild !>(bowl) wild.acc)
  ?>  =(0 idx-bowl)
  =^  event-json=json  wild.acc  (event-to-json event wild.acc)
  ;<  ~          try:m  (set-acc acc)
  ::
  ;<  err=(unit cord)  try:m  (make-function 'require' require)
  ?^  err  (return:m |+[u.err 'make require'])
  ;<  err=(unit cord)  try:m  (make-function '_get_state' get-state)  ::  XX TODO add properties normally through QTS_SetProperty or smth
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
  ;<  err=(unit cord)  try:m
    (make-function '_get_chat_messages_here' get-chat-messages-here)
  ::
  ?^  err  (return:m |+[u.err 'make _get_chat_messages_here'])
  ;<  err=(unit cord)  try:m
    (make-function '_get_members_here' get-members-here)
  ::
  ?^  err  (return:m |+[u.err 'make _get_members_here'])
  ;<  err=(unit cord)  try:m
    (make-function '_get_roles' get-roles)
  ::
  ?^  err  (return:m |+[u.err 'make _get_roles'])
  ;<  err=(unit cord)  try:m
    (make-function '_add_user' add-user)
  ::
  ?^  err  (return:m |+[u.err 'make _add_user'])
  ;<  err=(unit cord)  try:m
    (make-function '_kick_user' kick-user)
  ::
  ?^  err  (return:m |+[u.err 'make _kick_user'])
  ;<  err=(unit cord)  try:m
    (make-function '_give_role' give-role)
  ::
  ?^  err  (return:m |+[u.err 'make _give_role'])
  ;<  err=(unit cord)  try:m
    (make-function '_remove_role' remove-role)
  ::
  ?^  err  (return:m |+[u.err 'make _remove_role'])
  ;<  err=(unit cord)  try:m
    (make-function '_post_here' post-here)
  ::
  ?^  err  (return:m |+[u.err 'make _post_here'])
  ;<  err=(unit cord)  try:m
    (make-function '_send_dm' send-dm)
  ::
  ?^  err  (return:m |+[u.err 'make _send_dm'])
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
++  subj  ^~(!>(..subj))
++  wish-js
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script:lia-sur:wasm @ acc-mold)
  ^-  form:m
  =,  arr
  ?>  (gte argc-w 1)
  ;<  str=cord  try:m  (get-js-string argv-u)
  =/  gen=hoon  (ream str)
  =/  vax=vase  (slap subj gen)
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
++  get-chat-messages-here
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script @ acc-mold)
  ^-  form:m
  =,  arr
  ;<  acc=acc-mold  try:m  get-acc
  =+  !<(=bowl:h (need (get-wild 0 wild.acc)))
  ?~  channel.bowl  (call-1 'QTS_NewArray' ctx-u ~)
  =/  posts=v-posts:c  posts.u.channel.bowl
  =/  posts-list=(list v-post:c)
    (murn (tap:on-v-posts:c posts) tail)
  ::
  (store-json a+(turn posts-list v-post-c:enjs))
::
++  get-members-here
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script @ acc-mold)
  ^-  form:m
  =,  arr
  ;<  acc=acc-mold  try:m  get-acc
  =+  !<(=bowl:h (need (get-wild 0 wild.acc)))
  ?~  group.bowl  (call-1 'QTS_NewArray' ctx-u ~)
  =/  =fleet:g  fleet.u.group.bowl
  =/  ships=(list @p)  ~(tap in ~(key by fleet))
  (store-json a+(turn ships ship:enjs:format))
::
++  get-roles
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script @ acc-mold)
  ^-  form:m
  =,  arr
  ?>  (gte argc-w 1)
  ;<  acc=acc-mold  try:m  get-acc
  =+  !<(=bowl:h (need (get-wild 0 wild.acc)))
  ?~  group.bowl  (call-1 'QTS_NewArray' ctx-u ~)
  ;<  jon=json  try:m  (load-json argv-u)
  =/  ship=(unit @p)  (mole |.((ship-round:dejs jon)))
  ?~  ship  (call-1 'QTS_NewArray' ctx-u.acc ~)
  =/  =fleet:g  fleet.u.group.bowl
  =/  sev=(unit vessel:fleet:g)  (~(get by fleet) u.ship)
  ?~  sev  (call-1 'QTS_NewArray' ctx-u ~)
  (store-json a+(turn ~(tap in sects.u.sev) (lead %s)))
::
++  add-user
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script @ acc-mold)
  ^-  form:m
  =,  arr
  ?>  (gte argc-w 1)
  ;<  acc=acc-mold  try:m  get-acc
  =+  !<(=bowl:h (need (get-wild 0 wild.acc)))
  ?~  group.bowl  (call-1 'QTS_GetNull' ~)
  ;<  jon=json  try:m  (load-json argv-u)
  ?~  ship=(mole |.((ship-round:dejs jon)))
    (call-1 'QTS_GetNull' ~)
  =/  =diff:g  [%fleet [u.ship ~ ~] add+~]
  =/  =update:g  [now.bowl diff]
  ?~  channel.bowl  (call-1 'QTS_GetNull' ~)
  =/  =flag:g  group.perm.perm.u.channel.bowl
  =/  =action:g  [flag update]
  (store-json (frond:enjs:format groups+(action:enjs:gj action)))
::
++  kick-user
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script @ acc-mold)
  ^-  form:m
  =,  arr
  ?>  (gte argc-w 1)
  ;<  acc=acc-mold  try:m  get-acc
  =+  !<(=bowl:h (need (get-wild 0 wild.acc)))
  ?~  group.bowl  (call-1 'QTS_GetNull' ~)
  ;<  jon=json  try:m  (load-json argv-u)
  ?~  ship=(mole |.((ship-round:dejs jon)))
    (call-1 'QTS_GetNull' ~)
  =/  =diff:g  [%fleet [u.ship ~ ~] del+~]
  =/  =update:g  [now.bowl diff]
  ?~  channel.bowl  (call-1 'QTS_GetNull' ~)
  =/  =flag:g  group.perm.perm.u.channel.bowl
  =/  =action:g  [flag update]
  (store-json (frond:enjs:format groups+(action:enjs:gj action)))
::
++  give-role
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script @ acc-mold)
  ^-  form:m
  =,  arr
  ?>  (gte argc-w 2)
  ;<  acc=acc-mold  try:m  get-acc
  =+  !<(=bowl:h (need (get-wild 0 wild.acc)))
  ?~  group.bowl  (call-1 'QTS_GetNull' ~)
  ;<  jon=json  try:m  (load-json argv-u)
  ?~  ship=(mole |.((ship-round:dejs jon)))
    (call-1 'QTS_GetNull' ~)
  ;<  str=cord  try:m  (get-js-string (add argv-u 8))
  ?.  ((sane %tas) str)  (call-1 'QTS_GetNull' ~)
  =/  =diff:g  [%fleet [u.ship ~ ~] add-sects+[`@tas`str ~ ~]]
  =/  =update:g  [now.bowl diff]
  ?~  channel.bowl  (call-1 'QTS_GetNull' ~)
  =/  =flag:g  group.perm.perm.u.channel.bowl
  =/  =action:g  [flag update]
  (store-json (frond:enjs:format groups+(action:enjs:gj action)))
::
++  remove-role
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script @ acc-mold)
  ^-  form:m
  =,  arr
  ?>  (gte argc-w 2)
  ;<  acc=acc-mold  try:m  get-acc
  =+  !<(=bowl:h (need (get-wild 0 wild.acc)))
  ?~  group.bowl  (call-1 'QTS_GetNull' ~)
  ;<  jon=json  try:m  (load-json argv-u)
  ?~  ship=(mole |.((ship-round:dejs jon)))
    (call-1 'QTS_GetNull' ~)
  ;<  str=cord  try:m  (get-js-string (add argv-u 8))
  ?.  ((sane %tas) str)  (call-1 'QTS_GetNull' ~)
  =/  =diff:g  [%fleet [u.ship ~ ~] del-sects+[`@tas`str ~ ~]]
  =/  =update:g  [now.bowl diff]
  ?~  channel.bowl  (call-1 'QTS_GetNull' ~)
  =/  =flag:g  group.perm.perm.u.channel.bowl
  =/  =action:g  [flag update]
  (store-json (frond:enjs:format groups+(action:enjs:gj action)))
::
++  post-here
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script @ acc-mold)
  ^-  form:m
  =,  arr
  ?>  (gte argc-w 1)
  ;<  acc=acc-mold  try:m  get-acc
  =+  !<(=bowl:h (need (get-wild 0 wild.acc)))
  ;<  str=cord  try:m  (get-js-string argv-u)
  =/  =story:c  ~[inline+~[str]]
  =/  =memo:c  [story [our now]:bowl]
  =/  =essay:c  [memo chat+~]
  =/  =c-post:c  add+essay
  =/  =c-channel:c  post+c-post
  =/  =a-channel:c  c-channel
  ?~  channel.bowl  (call-1 'QTS_GetNull' ~)
  =/  =a-channels:c  [%channel nest.u.channel.bowl a-channel]
  (store-json (frond:enjs:format channels+(a-channels-c:enjs a-channels)))
::
++  send-dm
  |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
  =/  m  (script @ acc-mold)
  ^-  form:m
  =,  arr
  ?>  (gte argc-w 2)
  ;<  acc=acc-mold  try:m  get-acc
  =+  !<(=bowl:h (need (get-wild 0 wild.acc)))
  ;<  jon=json  try:m  (load-json argv-u)
  ?~  ship=(mole |.((ship-round:dejs jon)))
    (call-1 'QTS_GetNull' ~)
  ;<  str=cord  try:m  (get-js-string (add argv-u 8))
  =/  =story:c  ~[inline+~[str]]
  =/  =memo:c  [story [our now]:bowl]
  =/  =action:dm:ch  [u.ship u.ship^now.bowl %add memo ~ `now.bowl]
  (store-json (frond:enjs:format dm+(dm-action:enjs:chj action)))
::
++  get-wild
  |=  [idx=@ wil=wild]
  ^-  (unit vase)
  (~(get by r.wil) idx)
::
++  add-wild
  |=  [vax=vase wil=wild]
  ^-  [@ wild]
  ?^  idx=(~(get by s.wil) vax)
    [u.idx wil]
  ?~  q.wil
    =/  nu=@  p.wil
    [nu [+(nu) ~ (~(put by r.wil) nu vax) (~(put by s.wil) vax nu)]]
  :-  i.q.wil
  [p.wil t.q.wil (~(put by r.wil) i.q.wil vax) (~(put by s.wil) vax i.q.wil)]
::
++  del-wild
  |=  [idx=@ wil=wild]
  ^-  wild
  ?:  =(0 idx)  wil  ::  idx 0 is reserved for the bowl, keep it
  =/  q-wil=(list @)
    ?^  (find ~[idx] q.wil)  q.wil
    [idx q.wil]
  =/  vax=(unit vase)  (~(get by r.wil) idx)
  =?  s.wil  ?=(^ vax)  (~(del by s.wil) u.vax)
  [p.wil q-wil (~(del by r.wil) idx) s.wil]
::
++  event-to-json
  |=  [=event:h wil=wild]
  ^-  [json wild]
  =^  jon=json  wil
    ?-  -.event
      %cron      [~ wil]
      %on-post   [(on-post-h:enjs +.event) wil]
      %on-reply  [(on-reply-h:enjs +.event) wil]
      %wake      (waiting-hook-h:enjs +.event wil)
    ==
  =,  enjs:format
  [(frond -.event jon) wil]
::
++  enjs
  |%
  ++  on-post-h
    |=  a=on-post:h
    ^-  json
    =,  enjs:format
    %+  frond  -.a
    ?-    -.a
        %add
      (v-post-c post.a)
    ::
        %edit
      %-  pairs
      :~
        original+(v-post-c original.a)
        essay+(essay:enjs:cj essay.a)
      ==
    ::
        %del
      (v-post-c original.a)
    ::
        %react
      %-  pairs
      :~
        post+(v-post-c post.a)
        ship+(ship ship.a)
        react+?~(react.a ~ s+u.react.a)
      ==
    ::
    ==
  ::
  ++  v-post-c
    |=  =v-post:c
    ^-  json
    =,  enjs:format
    %-  pairs
    :~
      seal+(v-seal-c -.v-post)
      revision+s+(scot %ud rev.v-post)
      essay+(essay:enjs:cj +>.v-post)
    ==
  ::
  ++  v-seal-c
    |=  =v-seal:c
    ^-  json
    =,  enjs:format
    %-  pairs
    :~  id+(id:enjs:cj id.v-seal)
        replies+(v-replies-c replies.v-seal)
        reacts+(v-reacts-c reacts.v-seal)
    ==
  ::
  ++  v-replies-c
    |=  =v-replies:c
    ^-  json
    =,  enjs:format
    %-  pairs
    %+  turn  (tap:on-v-replies:c v-replies)
    |=  [t=@da v=(unit v-reply:c)]
    [(scot %ud t) ?~(v ~ (v-reply-c u.v))]
  ::
  ++  v-reply-c
    |=  =v-reply:c
    ^-  json
    =,  enjs:format
    %-  pairs
    :~
      id+(id:enjs:cj id.v-reply)
      reacts+(v-reacts-c reacts.v-reply)
      revision+s+(scot %ud rev.v-reply)
      content+(story:enjs:cj content.v-reply)
      author+(ship author.v-reply)
      sent+(time sent.v-reply)
    ==
  ::
  ++  v-reacts-c
    |=  =v-reacts:c
    ^-  json
    =,  enjs:format
    %-  pairs
    %+  turn  ~(tap by v-reacts)
    |=  [key=@p rev=@ rec=(unit react:c)]
    [(scot %p key) (pairs revision+s+(scot %ud rev) react+?~(rec ~ s+u.rec) ~)]
  ::
  ++  on-reply-h
    |=  =on-reply:h
    ^-  json
    =,  enjs:format
    %+  frond  -.on-reply
    ?-    -.on-reply
        %add
      %-  pairs
      :~
        parent+(v-post-c parent.on-reply)
        reply+(v-reply-c reply.on-reply)
      ==
    ::
        %edit
      %-  pairs
      :~
        parent+(v-post-c parent.on-reply)
        original+(v-reply-c original.on-reply)
        memo+(memo:enjs:cj memo.on-reply)
      ==
    ::
        %del
      %-  pairs
      :~
        parent+(v-post-c parent.on-reply)
        original+(v-reply-c original.on-reply)
      ==
    ::
        %react
      %-  pairs
      :~
        parent+(v-post-c parent.on-reply)
        reply+(v-reply-c reply.on-reply)
        ship+(ship ship.on-reply)
        react+?~(react.on-reply ~ s+u.react.on-reply)
      ==
    ==
  ::
  ++  waiting-hook-h
    |=  [=waiting-hook:h wid=wild]
    ^-  [json wild]
    =^  idx=@  wid  (add-wild data.waiting-hook wid)
    :_  wid
    =,  enjs:format
    %-  pairs
    :~
      id+(numb id.waiting-hook)
      hook+(numb hook.waiting-hook)
      data+(numb idx)
      fires-at+(time fires-at.waiting-hook)
    ==
  ::
  ++  a-channels-c
    |=  a=a-channels:c
    ^-  json
    =,  enjs:format
    %+  frond  -.a
    ?-    -.a
        %create
      (create-channel-c create-channel.a)
    ::
        %pin
      a+(turn pins.a nest:enjs:cj)
    ::
        %channel
      (pairs nest+(nest:enjs:cj nest.a) a-channel+(a-channel-c a-channel.a) ~)
    ::
      %toggle-post  (post-toggle:enjs:cj toggle.a)
    ==
  ::
  ++  create-channel-c
    |=  a=create-channel:c
    ^-  json
    =,  enjs:format
    %-  pairs
    :~
      kind+s+kind.a
      name+s+name.a
      group+(flag:enjs:cj group.a)
      title+s+title.a
      description+s+description.a
      readers+a+(turn ~(tap in readers.a) (lead %s))
      writers+a+(turn ~(tap in writers.a) (lead %s))
    ==
  ::
  ++  a-channel-c
    |=  a=a-channel:c
    ^-  json
    =,  enjs:format
    %+  frond  -.a
    ?-    -.a
        %join
      (flag:enjs:cj group.a)
    ::
        %leave
      ~
    ::
        %read
      ~
    ::
        %read-at
      s+(scot %ud time.a)
    ::
        %watch
      ~
    ::
        %unwatch
      ~
    ::
        %post
      (c-post-c c-post.a)
    ::
        %view
      s+view.a
    ::
        %sort
      s+sort.a
    ::
        %order
      ?~  order.a  ~
      a+(turn u.order.a (cork (cury scot %ud) (lead %s)))
    ::
        %add-writers
      a+(turn ~(tap in sects.a) (lead %s))
    ::
        %del-writers
      a+(turn ~(tap in sects.a) (lead %s))
    ::
    ==
  ::
  ++  c-post-c
    |=  a=c-post:c
    ^-  json
    =,  enjs:format
    %+  frond  -.a
    ?-    -.a
        %add
      (essay:enjs:cj essay.a)
    ::
        %edit
      (pairs id+s+(scot %ud id.a) essay+(essay:enjs:cj essay.a) ~)
    ::
        %del
      s+(scot %ud id.a)
    ::
        %reply
      (pairs id+s+(scot %ud id.a) essay+(c-reply-c c-reply.a) ~)
    ::
        %add-react
      (pairs id+s+(scot %ud id.a) ship+(ship p.a) react+s+q.a ~)
    ::
        %del-react
      (pairs id+s+(scot %ud id.a) ship+(ship p.a) ~)
    ::
    ==
  ::
  ++  c-reply-c
    |=  a=c-reply:c
    ^-  json
    =,  enjs:format
    %+  frond  -.a
    ?-    -.a
        %add
      (memo:enjs:cj memo.a)
    ::
        %del
      s+(scot %ud id.a)
    ::
        %edit
      (pairs id+s+(scot %ud id.a) memo+(memo:enjs:cj memo.a) ~)
    ::
        %add-react
      (pairs id+s+(scot %ud id.a) ship+(ship p.a) react+s+q.a ~)
    ::
        %del-react
      (pairs id+s+(scot %ud id.a) ship+(ship p.a) ~)
    ::
    ==
  --
::
++  dejs
  |%
  ++  ship-round  :: ensure roundtripping
    |=  jon=json
    ^-  @p
    ?~  jon  !!
    ?+  -.jon  !!
      %n  (rash p.jon (ifix [doq doq] ;~(pfix (punt sig) fed:ag)))
      %s  (rash p.jon ;~(pfix (punt sig) fed:ag))
    ==
  ::
  ++  event-h
    |=  wid=wild
    ^-  $-(json event:h)
    =,  dejs:format
    %-  of
    :~
      on-post+on-post-h
      on-reply+on-reply-h
      cron+ul
      wake+(waiting-hook-h wid)
    ==
  ::
  ++  v-post-c
    ^-  $-(json v-post:c)
    =,  dejs:format
    %-  ot
    :~
      seal+v-seal-c
      revision+(su dem:ag)
      essay+essay-c
    ==
  ++  v-seal-c
    ^-  $-(json v-seal:c)
    =,  dejs:format
    %-  ot
    :~
      id+(su dim:ag)
      replies+v-replies-c
      reacts+v-reacts-c
    ==
  ::
  ++  v-reacts-c
    ^-  $-(json v-reacts:c)
    =,  dejs:format
    %+  op  ;~(pfix sig fed:ag)
    %-  ot
    :~
      revision+(su dem:ag)
      react+(mu so)
    ==
  ::
  ++  v-replies-c
    ^-  $-(json v-replies:c)
    =,  dejs:format
    (op dem:ag (mu v-reply-c))
  ::
  ++  v-reply-c
    ^-  $-(json v-reply:c)
    =,  dejs:format
    %+  cu  |=  [id=id-reply:c reacts=v-reacts:c rev=@ud =memo:c]
            ^-  v-reply:c
            [[id reacts] rev memo]
    %-  ot
    :~
      id+(su dim:ag)
      reacts+v-reacts-c
      revision+(su dem:ag)
      content+story:dejs:cj
      author+ship-round
      sent+di
    ==
  ::
  ++  on-post-h
    ^-  $-(json on-post:h)
    =,  dejs:format
    %-  of
    :~
      add+v-post-c
      edit+(ot original+v-post-c essay+essay-c ~)
      del+v-post-c
      react+(ot post+v-post-c ship+ship-round react+(mu so) ~)
    ==
  ::
  ++  memo-c
    ^-  $-(json memo:c)
    =,  dejs:format
    %-  ot
    :~  content/story:dejs:cj
        author/ship-round
        sent/di
    ==
  ++  on-reply-h
    ^-  $-(json on-reply:h)
    =,  dejs:format
    %-  of
    :~
      add+(ot parent+v-post-c reply+v-reply-c ~)
      edit+(ot ~[parent+v-post-c original+v-reply-c memo+memo-c])
      del+(ot parent+v-post-c original+v-reply-c ~)
    ::
      :-  %react
      (ot parent+v-post-c reply+v-reply-c ship+ship-round react+(mu so) ~)
    ==
  ++  waiting-hook-h
    |=  wid=wild
    ^-  $-(json waiting-hook:h)
    =,  dejs:format
    %+  cu  |=  [p=@ q=@ r=@ s=time]
            ^-  waiting-hook:h
            [p q (need (get-wild r wid)) s]
    %-  ot
    :~
      id+ni
      hook+ni
      data+ni
      fires-at+di
    ==
  ::
  ++  contacts-action-co
    ^-  $-(json action:co)
    =,  dejs:format
    %-  of
    :~
      anon+ul
      self+contact-co
      page+(ot kip+kip-co contact+contact-co ~)
      edit+(ot kip+kip-co contact+contact-co ~)
      wipe+(ar kip-co)
      meet+(ar ship-round)
      drop+(ar ship-round)
      snub+(ar ship-round)
    ==
  ::
  ++  contact-co
    ^-  $-(json contact:co)
    =,  dejs:format
    (op sym value-co)
  ::
  ++  value-co
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
      ship+ship-round
      look+so
      flag+flag:dejs:gj
      set+(as value-co)
    ==
  ++  kip-co
    ^-  $-(json kip:co)
    =,  dejs:format
    %+  cu  |=  a=$%([%ship p=@p] [%id @])
            ?:  ?=(%ship -.a)  p.a
            a
    %-  of
    :~
      ship+ship-round
      id+ni
    ==
  ::
  ++  essay-c
    ^-  $-(json essay:c)
    =,  dejs:format
    %+  cu
      |=  [=story:c ship=@p time=@da =kind-data:c]
      `essay:c`[[story ship time] kind-data]
    %-  ot
    :~  content/story:dejs:cj
        author/ship-round
        sent/di
        kind-data/kind-data:dejs:cj
    ==
  --
::
++  return-of-json
  |=  [jon=json wid=wild]
  ^-  (pair event-result:h (list effect:h))
  ::
  =,  dejs:format
  %.  jon
  %-  ot
  :~
    :-  %event
    (of allowed+(event-h:^dejs wid) denied+(mu so) ~)
  ::
    :-  %effects
    %-  ar
    %-  of
    :~
      channels+a-channels:dejs:cj
      groups+action:dejs:gj
      activity+action:dejs:aj
      dm+dm-action:dejs:chj
      club+club-action:dejs:chj
      contacts+contacts-action-co:^dejs
      wait+(waiting-hook-h:^dejs wid)
    ==
  ==
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
  ;<  str=cord  try:m  (get-js-string argv-u)
  %:  ding
    'QTS_Throw'
    ctx-u
    (make-error (crip "Name {(trip str)} not recognized by `require`"))
    ~
  ==
::
++  tlon-hooks-code
  ^-  cord
  '''
  var _o = {
    get_state() {
      return _get_state();                // returns object from state.hook
    },

    set_state(obj) {
      return _set_state(obj);             // returns (), sets state.hook
    },

    wish(txt) {
      return _wish_js(txt) >>> 0;         // returns int: wild idx with the prodcuct of hoon expression
    },

    slam(idx1, idx2) {
      return _slam_js(idx1, idx2) >>> 0;  // returns int: wild idx with the product of gate slam
    },

    object_to_noun(obj) {
      return _to_json(obj) >>> 0;         // returns int: wild idx with the object as a noun
    },

    noun_to_object(idx) {
      return _of_json(idx);               // returns object: deserialization of of a noun at idx in wild
    },

    get_chat_messages_here() {
      return _get_chat_messages_here();   //  returns a list of chat messages from the current channel
    },

    get_members_here() {
      return _get_members_here();         //  returns a list of ships for the current channel
    },

    get_roles(ship) {
      return _get_roles(ship);            //  returns a list of role names for a given ship in the current channel
    },

    events {                              // event builders

      add_user(ship) {
        return _add_user(ship);               //  add ship to the current channel
      },

      kick_user(ship) {
        return _kick_user(ship);              //  remove ship from the current channel
      },

      give_role(ship, role) {
        return _give_role(ship, role);        // give a role to a given ship
      },

      remove_role(ship, role) {
        return _remove_role(ship, role);      // remove a role from a given ship
      },

      post_here(text) {
        return _post_here(text);              // post a message in the channel
      },

      send_dm(ship, text) {
        return _send_dm(ship, text);          // send a direct message to a ship
      },
    },
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
  ?>  (gte argc-w 1)
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