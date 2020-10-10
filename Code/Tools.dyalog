:namespace Tools
    Texts←⍬   ⍝ see "GetText



    ∇ ReadSessionPrefs req;sess
      :Access public
     
      sess←req.Session
      sess.Prefs←⎕JSON #.Files.ReadText #.Boot.AppRoot,'preferences.json'  ⍝ make sess.Prefs independend (do not link it to #.Prefs - might cause trouble if we ever do multi-user...)
      sess.(⍙⍙trap⍙⍙←Prefs.Session.TrapErrors≡⊂'true')
      sess.Prefs.Session.decimals←10 sess.Prefs.{0::⍺ ⋄ ⍎⍵}'Session.decimals'
      :If 0=sess.⎕NC'_tsLog'
      :OrIf 0=≢sess._tsLog
          sess._tsLog←req.Session._tsLog←,#.tsSiteTools.mns('type' 5)('in' 'Welcome to TamStat')('_id' 1)
      :EndIf
     
     
    ∇

⍝ from dfns: (slightly modified to allow type=2 as default (if omitted))
      mns←{                                         ⍝ Make NS from association list ⍵.
          ⍺←⎕NS''                                   ⍝ default new space.
          0=≢⍵:⍺                                    ⍝ list exhausted: finished.
          w←{2=|≡⍵:,⊂⍵ ⋄ ,⍵}⍵                       ⍝ ensure proper format
          name class value←{(1↑⍵),¯2↑2,1↓⍵}⎕IO⊃w    ⍝ first triple.
          class=2:⍺ ∇ 1↓w⊣name ⍺.{⍎⍺,'←⍵'}value     ⍝ var: assign.
          class∊3 4:⍺ ∇ 1↓⍵⊣⍺.⎕FX value             ⍝ fn or op: fix.
          class=9:⍺ ∇ 1↓w⊣name ∇ ⍺.{                ⍝ space: recursively process,
              (⍎⍺,'←⎕NS ⍬')⍺⍺ ⍵                     ⍝   in new sub-space,
          }value                                    ⍝   the sub-list.
          'Eh?'⎕SIGNAL 11                           ⍝ unrecognised class: abort.
      }


    ∇ DETRAP
      {}600⌶1
    ∇

    ∇ RETRAP
      {}600⌶2
    ∇

    ∇ txt∆←{opts}sprintf R;txt;fmt;val;align;pad;width;precision;prc;i;RhoRho;prc∆
 ⍝ replaces format specifiers in txt with values
 ⍝ format specifiers are introduced with '%'
 ⍝ txt might be vector or matrix
 ⍝ Format:
 ⍝ %[index of argument in'[]'][-][0][width][.precision]type
 ⍝ type = s -> String
 ⍝        b -> String with removal of extraneous blanks
 ⍝        i -> Integer
 ⍝        d -> Number with decimals
 ⍝ very oooooold code if found in a shed (originally developed for Dyalog 10.1) - can probably be improved! ;)
 ⍝ Ideas for extensions:
 ⍝ - ⎕FmtString⎕ for d or i
     
     
      :If 1=≡R ⋄ txt∆←R ⋄ →0 ⋄ :EndIf  ⍝ not nested → no replacements needed...
      txt←1⊃R ⋄ R←1↓R
      RhoRho←⍴⍴txt
     
      txt←¯1↓,txt,⎕TC[2]  ⍝ Newline
      txt∆←''
      prc←0
     
      :While '%'∊txt
          i←txt⍳'%'
          txt∆←txt∆,(i-1)↑txt
          :If txt[i+1]≡'%' ⋄ txt∆←,'%' ⋄ txt←(i+1)↓txt
          :Else ⋄ align←0 ⋄ pad←' ' ⋄ width←¯1 ⋄ precision←1 ⋄ txt←i↓txt ⋄ prc+←1
              prc∆←prc
              :If txt[1]≡'[' ⋄ prc←2⊃⎕VFI 1↓(¯1+txt⍳']')↑txt ⋄ txt←(txt⍳']')↓txt ⋄ :EndIf
              :If txt[1]≡'-' ⋄ align←1 ⋄ txt←1↓txt ⋄ :EndIf  ⍝ Align numbers left and text right
              :If txt[1]≡'0' ⋄ pad←'0' ⋄ txt←1↓txt ⋄ :EndIf  ⍝ Pad numbers with zeroes instead of blanks
              :If txt[1]∊⎕D
                  i←+/∧\txt∊⎕D ⋄ width←2⊃⎕VFI i↑txt ⋄ txt←i↓txt
              :EndIf
              :If txt[1]≡'.'
                  txt←1↓txt ⋄ i←+/∧\txt∊⎕D ⋄ precision←2⊃⎕VFI i↑txt ⋄ txt←i↓txt
              :EndIf
              val←''
              :Select txt[1]
              :Case 'b' ⋄ val←#.Strings.deb,⍕prc∆⊃R ⋄ :If width>0 ⋄ val←width↑val ⋄ :EndIf  ⍝ String with blank-removal
              :Case 's' ⋄ val←,⍕prc∆⊃R ⋄ :If width>0 ⋄ val←width↑val ⋄ :EndIf  ⍝ String
              :Case 'd' ⋄ val←prc∆⊃R         ⍝ Number, optionally with decimals
                  :If 0≠1↑0↑val ⋄ val←2⊃⎕VFI⍕val ⋄ :EndIf  ⍝ why???
                  width←width⌈⍴,⍕⌊val
                  fmt←('M<->','IF'[1+precision>0],(⍕width+precision+(precision>0)+val<0),(precision>0)/'.',(⍕precision))
                  val←,fmt ⎕FMT val
              :Case 'i' ⋄ val←prc∆⊃R        ⍝ Integer, rounded if necessary, ignoring decimals
                  :If 0≠1↑0↑val ⋄ val←2⊃⎕VFI'0',⍕val ⋄ :EndIf
                  val←⍬⍴,val ⋄ width←width⌈⍴⍕⌊val+0.5
                  fmt←'M<->I',⍕width+val<0
                  val←,fmt ⎕FMT⌊val+0.5
              :EndSelect
              :If 0<width ⋄ :AndIf (align>0)∨pad≠' '
                  :If align=1
                      :If txt[1]='s' ⋄ val←⌽LJ⌽val ⋄ :Else ⋄ val←LJ val ⋄ :EndIf
                  :EndIf
                  :If pad='0'
                      :Select align,txt[1]='s'
                      :Case 1 0 ⍝ numeric, lft-aligned
                      :Case 1 1 ⋄ val[⍸∧\val=' ']←'0' ⍝ Text, rechtsbündig, links wird gefüllt!
                      :Case 0 0 ⋄ val[⍸∧\val=' ']←'0' ⍝ numerisch, rechtsbündig, links füllen
                      :Case 0 1 ⋄ val[⍸⌽∧\⌽val=' ']←'0' ⍝ Text, linksbündig, am Ende '0' anhängen
                      :EndSelect
                  :EndIf
              :EndIf
              txt←1↓txt ⋄ txt∆←txt∆,val
          :EndIf
      :EndWhile
      txt∆←txt∆,txt
      :If 2=RhoRho
          txt←↑⎕TC[2]#.Strings.split txt∆
      :EndIf
    ∇

    :section dotNet


    ∇ R←GetDOTNETVersion;vers;⎕IO;⎕USING
⍝ R[1] = 0/1/2: 0=nothing, 1=.net Framework, 2=NET CORE
⍝ R[2] = Version (text-vector)
⍝ R[3] = Version (identifiable x.y within [2] in numerical form)
⍝ R[4] = Textual description of the framework
      ⎕IO←1
      R←0 '' 0 ''
      :Trap 0
          ⎕USING←'System' ''
          vers←System.Environment.Version
          R[2]←⊂⍕vers
          R[3]←vers.(Major+0.1×Minor)
          :If 4=⌊R[3]   ⍝ a 4 indicates .net Framework!
              R[1]←1
              :If (⍕vers)≡'4.0.30319.42000'   ⍝ .NET 4.6 and higher!
                  R[4]←⊂Runtime.InteropServices.RuntimeInformation.FrameworkDescription
              :ElseIf (10↑⍕vers)≡'4.0.30319.' ⍝ .NET 4, 4.5, 4.5.1, 4.5.2
                  R[4]←⊂'.NET Framework ',2⊃R
              :EndIf
          :ElseIf 3.1=R[3]  ⍝ .NET CORE
          :OrIf 4<R[3]
              R[1]←2
              ⎕USING←'System,System.Runtime.InteropServices.RuntimeInformation'
              R[4]←⊂Runtime.InteropServices.RuntimeInformation.FrameworkDescription
          :EndIf
      :Else
      ⍝ bad luck, go with the defaults
      :EndTrap
    ∇
    :endsection

    :section HTML/DUI-Tools
    ∇ R←{show}Display id
      ⍝ Show (or hide - if "show"=0) control with given id (optionally id[1] can be '#' or '.')
      :If ~(⊃id)∊'.#' ⋄ id←'#',id ⋄ :EndIf
      :If 0=⎕NC'show'
      :OrIf show=1
          R←#.MiPage.Execute'$("',id,'").removeClass("d-none");'
          R,←#.MiPage.Execute'$("',id,'").trigger("becameVisible");'
      :Else
          R←#.MiPage.Execute'$("',id,'").addClass("d-none");'
      :EndIf
    ∇

    ∇ (h j)←getHTMLjs html;sc
      :Access  public shared
      ⍝ returns html and js of given object (or HTML-String)
     
      :If 326=⎕DR html ⋄ html←html.Render ⋄ :EndIf
      h←('<script>(.*)</script>'⎕R''⍠('DotAll' 1)('Mode' 'M')('Greedy' 0))html
     
      :If 1∊'<script>'⍷html
          :If 0<≢j←⊆('<script>\$\(function\(\)\{(.*)}\);</script>'⎕S'\1'⍠('DotAll' 1)('Mode' 'M')('Greedy' 0))html
              html←('<script>\$\(function\(\)\{(.*)}\);</script>'⎕R''⍠('DotAll' 1)('Mode' 'M')('Greedy' 0))html
          :EndIf
          j,←⊆('<script>(.*)</script>'⎕S'\1'⍠('DotAll' 1)('Mode' 'M')('Greedy' 0))html
     
      :Else ⋄ j←''
      :EndIf
    ∇

    :endsection

    :Section Bootstrap-Tools

    ∇ R←tit_opts MsgBox text_actions;opts;text;actions;tit;opts;mc;h;mf;js;btn;c∆;b;st;cb;keep;modId;s
⍝ title **MsgBox** text actions
⍝ actions: (BtnTitle NameOfCallback (or "close") [Style - vtv])
⍝ Style=primary  etc.
⍝ also: if style is "default", that button will be triggered when enter is pressed. and it will be a primary-btn!
⍝ opts: 1           - return object (otherwise: return result of a typical callback-function)
⍝       2           - bg-dark (if not set, we won't set)
     
      :Access Public
      (text actions)←2↑⊆text_actions
      :If 1≠≡tit_opts ⋄ (tit opts)←tit_opts ⋄ :Else ⋄ tit←tit_opts ⋄ opts←0 ⋄ :EndIf
      opts←⌽2 2⊤opts
      R←'.modal data-backdrop=static data-keyboard=false'#.HtmlElement.New #._.div
      R.id←modId←R.GenId
      mc←('.modal-dialog .modal-dialog-centered role=document'R.Add #._.div).Add #._.div''('.modal-content',opts[2]/'.bg-dark')
      mh←'.modal-header'mc.Add #._.div
      mh.Add #._.h3 tit'.modal-title'
      ('type=button class=close data-dismiss=modal'mh.Add #._.button).Add #._.span'&times;' 'aria-hidden=true'
      js←''
     
      mc.Add #._.div text'.modal-body'
     
      mf←mc.Add #._.div'' '.modal-footer'
      :For b :In ,⊆actions
          (tit cb st keep)←4↑⊆b  ⍝ title, callback, style, keepDialog
          c∆←'btn'
          :If ~∨/keep∊0 1 ⋄ :OrIf 1≠≢keep ⋄ keep←0 ⋄ :EndIf
          :If 0=≢tit ⋄ tit←GetText'OK' ⋄ c∆,←' btn-primary' ⋄ :EndIf
          btn←mf.Add #._.Button tit
          :If 0=≢st  ⍝ if no style
          :AndIf 1=≢actions ⍝ and there is one button only
          :AndIf ~∨/'btn-primary'⍷c∆
              st←'primary'   ⍝ that button nwill be the default one!
          :EndIf
          btn.(id←GenId)
          h←mf.Add #._.Handler('#',btn.id)'click'
          :If 0<≢cb
              :If cb≡'close'
                  h.Callback←0
              :Else
                  h.Callback←cb
                  h.ClientData←'mid' 'string'modId
              :EndIf
          :EndIf
          :If ~keep
              h.JavaScript,←'$("#',modId,'").modal("hide");$("#',modId,'").remove();'
          :EndIf
          :For s :In ⊆st
              :If s∊⍥⊆'primary' 'secondary' 'danger' 'warning' 'success' 'info' 'light' 'dark' 'link'
                  c∆,←' btn-',s
              :ElseIf 'default'≡⎕C s
                  c∆,←' btn-primary'
                  'onKeyUp'btn.Set'onEnterClick("#',btn.id,'");'
              :Else
                  ⎕←'Unknow style: ',s
                  ∘∘∘
              :EndIf
          :EndFor
          btn.class←c∆
      :EndFor
      :If opts[1]
          R.Add #._.script js,'$($("#',modId,'").modal("show"))'
          →0
      :EndIf
     
      (h j)←getHTMLjs R
      R←'body'#.MiPage.Append h
      R,←#.MiPage.Execute j,js
      R,←#.MiPage.Execute'$("#',modId,'").modal("show");'
    ∇

    ∇ {ctl}←ctl AddTooltipAndAccesskey code;accel;prefs;txt
      prefs←(1⊃⎕RSI).user.Prefs
      accel←prefs.accel⍎code
      txt←sprintf(GetText'Tooltip',code)accel
      ctl.Set'accesskey=',accel
      ctl AddTooltip txt
    ∇


    ∇ {ctl}←ctl AddTooltip txt
      ctl.Set'title="',txt,'"'
    ∇

    :EndSection Bootstrap-Tools


    :section Localization and regional stuff
    ∇ LoadTexts lang;file
      :If ~⎕NEXISTS file←#.Env.Root,'assets/texts-',(1 ⎕C lang),'.json'
          file←#.Env.Root,'assets/texts.json'
      :EndIf
      Texts←⎕JSON 1⊃⎕NGET file
    ∇

    ∇ R←{dflt}GetText code;z
      :If 0=⎕NC'dflt' ⋄ dflt←'' ⋄ :EndIf
      :If 0=≢Texts ⋄ LoadTexts'' ⋄ :EndIf
     
      :If '*'∊code
          z←((¯1+≢code)↑¨Texts.Code)≡¨⊂¯1↓code
          R←↑{⍵.Code ⍵.HTML}¨z/Texts
      :ElseIf Texts.Code∊⍨⊂code
          R←((Texts.Code⍳⊂code)⊃Texts).HTML ⍝ just return empty vector for unrecognized codes...
      :ElseIf 0<≢dflt
          R←dflt
      :Else
          R←'"',code,'"'
      :EndIf
    ∇

    ∇ str←{opts}fmtDate ts;days;months;idn
   ⍝ format a date in ⎕TS-Format as a string.
   ⍝ Format currently fixed as DDD, MMM dd yyyy hh:mm
   ⍝ opts not used - might be extended later...
      days←'Mon' 'Tue' 'Wed' 'Thu' 'Fri' 'Sat' 'Sun'
      months←'Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec'
      idn←+2 ⎕NQ'.' 'IDNToDate'(2 ⎕NQ'.' 'DateToIDN'ts)
      str←(1+4⊃idn)⊃days
      str,←', ',(idn[2]⊃months),' ',(,'ZI2'⎕FMT 3⊃idn),' ',(⍕1⊃idn),(5≤≢ts)/' ',¯1↓,'ZI2,<:>'⎕FMT ¯2↑5↑ts
    ∇

    :endsection

    :section Cryptography
    hash←{#.Crypt.(HASH_SHA256 Hash ⍵)}
    salt←{#.Strings.stringToHex #.Crypt.Random ⍵}

    :endsection
:endnamespace
