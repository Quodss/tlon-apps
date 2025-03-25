::  XX for testing purposes, to be removed
/-  h=hooks, c=channels
/+  builder=hook-builder-js
::
:-  %say  |=  *  :-  %noun
::
=>
  ::  enumerator core
  |%
  ++  flow
    |$  [item]
    $_  |?
    ^-  $@(~ [p=item q=(flow item)])
    ~
  ::
  ++  num
    ^-  (flow @)
    =+  s=0
    |.
    [s .(s (mul 2 +(s)))]
  ::
  ++  dat
    ^-  (flow @da)
    =|  s=@da
    |.
    [s .(s (add s ~d1))]
  ::
  ++  cod
    ^-  (flow cord)
    =+  s=''
    |.
    [s .(s (cat 3 'a' s))]
  ::
  ++  tem
    ^-  (flow cord)
    =+  s='a'
    |.
    [s .(s (cat 3 'a' s))]
  ::
  ++  rake
    |*  a=(flow)
    ?~  nex=(a)  !!
    p.nex
  ::
  ++  swim
    |*  [b=@ a=(flow)]
    ~+
    ^-  (unit _(rake a))
    =/  nex  (a)
    ?@  nex  ~
    ?:  =(0 b)  `p.nex
    $(a q.nex, b (dec b))
  ::
  ++  ross
    |=  [a=(flow *) b=(flow *)]
    ^-  (flow (pair * *))
    =/  diag=@  0
    =/  x=@     0
    |.
    ?:  (gth x diag)  $(x 0, diag +(diag))
    =/  y=@  (sub diag x)
    ?~  a-nex=(swim x a)  ~
    ?~  b-nex=(swim y b)  ~
    [[u.a-nex u.b-nex] ..$(x +(x))]
  ::
  ++  tag
    |=  flo=(list (pair cord (flow *)))
    ^-  (flow *)
    =/  sav  flo
    =/  dep=@  0
    |.
    ?~  flo  $(flo sav, dep +(dep))
    ?~  wim=(swim dep q.i.flo)  $(flo t.flo)
    [[p.i.flo u.wim] ..$(flo t.flo)]
  ::
  ++  take
    |*  [b=@ a=(flow)]
    |-  ^-  (list _(rake a))
    ?:  =(0 b)  ~
    ?~  nex=(a)  ~
    :-  p.nex
    :: ~&  b
    $(b (dec b), a q.nex)
  ::
  +$  test-type
    $%  [%foo @]
        [%bar @t]
    ==
  ::
  ++  alw
    |*  a=*
    ^-  (flow _a)
    |.(a^.)
  ::
  ++  qwen
    |=  a=_|?(`(flow *)`|?([~ .]))
    ^-  (flow (list *))
    =/  dep=@  0
    |.
    ?:  =(0 dep)  [~ ..$(dep 1)]
    :: ~&  dep+dep
    ?~  wim=(swim (dec dep) (a))  ~
    :: ~&  wim+wim
    [(reap dep u.wim) ..$(dep +(dep))]
  ::
  ++  uni
    |*  a=(flow)
    ^-  (flow (unit _(rake a)))
    |.
    :-  ~
    |.
    ?~  nex=(a)  ~
    [`p.nex ..$(a q.nex)]
  ::
  ++  cyc
    |=  a=(list *)
    ^-  (flow *)
    ?>  .?(a)
    =/  cpy  a
    |.
    ?~  a  $(a cpy)
    [i.a ..$(a t.a)]
  ::
  ++  kuk
    |*  [a=gate b=(flow *)]
    ^-  (flow *)
    |.
    ?~  nex=(b)  ~
    [(slum a p.nex) ..$(b q.nex)]
  ::
  ++  flow-stub
    ^-  (flow *)
    |.(!!)
  ::
  --
=>  |%
    ::
    ++  v-post  :(ross v-seal num essay)
    ++  essay  (ross memo kind-data)
    ++  memo  :(ross story num dat)
    ++  story  (qwen |.(verse))
    ++  verse  (tag block+block inline+(qwen |.(inline)) ~)
    ++  block
      %-  tag
      :~
        image+:(ross cod num num cod)
        cite+cite-c
        header+(ross (cyc %h1 %h2 %h3 %h4 %h5 %h6 ~) (qwen |.(inline)))
        listing+listing
        rule+(alw ~)
        code+(ross cod cod)
      ==
    ::
    ++  listing
      %-  tag
      :~
        list+:(ross (cyc %ordered %unordered %tasklist ~) (qwen |.(listing)) (qwen |.(inline)))
        item+(qwen |.(inline))
      ==
    ::
    ++  inline
      %-  tag
      :~
        break+(alw ~)
        italics+(qwen |.(inline))
        bold+(qwen |.(inline))
        strike+(qwen |.(inline))
        blockquote+(qwen |.(inline))
        inline-code+cod
        code+cod
        ship+num
        block+(ross num cod)
        tag+cod
        link+(ross cod cod)
        task+(ross (cyc & | ~) (qwen |.(inline)))
      ==
      ::
      ++  cite-c
        %-  tag
        :~
          chan+(ross nest-g path)
          group+flag-g
          desk+(ross flag-g path)
          bait+:(ross flag-g flag-g path)
        ==
      ::
      ++  path  (qwen |.(cod))
      ::
      ++  nest-g  (ross tem flag-g)
      ++  flag-g  (ross num tem)
      ++  v-seal  :(ross id-post v-replies v-reacts)
      ++  id-post  dat
      ++  id-reply  dat
      ++  v-replies
        %+  kuk  (cury gas:on-v-replies:c *v-replies:c)
        (qwen |.((ross id-reply (uni v-reply))))
      ::
      ++  v-reply  (ross (ross id-reply v-reacts) (ross num memo))
      ++  kind-data
        %-  tag
        :~
          diary+(ross cod cod)
          heap+(uni cod)
          chat+(cyc ~ notice+~ ~)
        ==
      ++  v-reacts
        %+  kuk  ~(gas by *(map * *))
        (qwen |.((ross num (ross num (uni cod)))))
    --
=/  event-of-json
  |=  [jon=json wid=wild:builder]
  ^-  event:h
  ((event-h:dejs:builder wid) jon)
::
=/  event-to-json  event-to-json:builder
=;  events=(list *)
  %+  skip  events
  |=  e=*
  ^-  ?
  =/  wid=*  *wild:builder
  =^  jon  wid  (slum event-to-json e wid)
  !:
  ~|  e
  =(e (slum event-of-json jon wid))
%+  take  10.000
%-  tag
:~
  :-  %on-post
  %-  tag
  :~
    add+v-post
    edit+(ross v-post essay)
    del+v-post
    react+:(ross v-post num (uni cod))
  ==
::
  :-  %on-reply
  %-  tag
  :~
    add+(ross v-post v-reply)
    edit+:(ross v-post v-reply memo)
    del+(ross v-post v-reply)
    react+:(ross v-post v-reply num (uni cod))
  ==
::
  :: cron+(alw ~)
::
  :: wake+:(ross num num (alw *vase) dat)
==