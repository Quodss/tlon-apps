/-  h=hooks
/+  wasm=wasm-lia
/*  bin  %wasm  /quick-js-emcc/wasm
::
=*  cw            coin-wasm:wasm-sur:wasm
=*  script-form   script-raw-form:lia-sur:wasm
=*  stub  !!
::
=<  builder
|%
+$  hook-gate  $-(args:h outcome:h)
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
  ==
::
++  arr  (arrows:wasm acc-mold)
++  builder
  |=  code=cord
  ^-  hook-gate
  |=  [=event:h bowl:h]
  ^-  outcome:h
  =/  state-json  !<(json state.hook)
  =/  event-json=json  (event-to-json event)
  ::
  ::  %&: head of return and new state
  ::  %|: QuickJS error and our label
  =;  res=(each (pair json json) (pair cord cord))
    ?:  ?=(%| -.res)
      [%| p.p.res q.p.res ~]
    =/  out=(pair event-result:h (list effect:h))
      (return-of-json p.p.res)
    [%& out !>(q.p.res)]
  ::
  =/  yil-mold  (each (pair json json) (pair cord cord))
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
  ;<  ~          try:m  (set-acc run-u ctx-u fil-u ~ state-json)
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
  (return:m &+[out state.acc])
::
::  XX check memory conventions, add free calls
::
++  event-to-json
  |=  =event:h
  ^-  json
  stub
::
++  return-of-json
  |=  jon=json
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