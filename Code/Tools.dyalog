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
      ⍝ Show (or hide - if "show"=0) control with given id
      :If 0=⎕NC'show'
      :OrIf show=1
          R←#.MiPage.Execute'$("#',id,'").removeClass("d-none");'
      :Else
          R←#.MiPage.Execute'$("#',id,'").addClass("d-none");'
      :EndIf
    ∇

    ∇ (h j)←getHTMLjs html;sc
      :Access  public shared
      ⍝ returns html and js of given object (or HTML-String)
      :If 326=⎕DR html ⋄ html←∊html.Render ⋄ :EndIf
      h←('<script>(.*)</script>'⎕R''⍠('DotAll' 1)('Mode' 'M')('Greedy' 0))html
     
      :If (⊂'')≢sc←⊆('<script>(.*)</script>'⎕S'\1'⍠('DotAll' 1)('Mode' 'M')('Greedy' 0))html
          j←∊sc
      :Else ⋄ j←''
      :EndIf
    ∇

    :endsection

    :Section Bootstrap-Tools
    ∇ R←tit MsgBox text_actions
⍝ title **MsgBox** text actions
⍝ actions: (BtnTitle NameOfCallback (or "close") [Style - vtv])
⍝ Style=primary  etc.    
      :Access Public
      (text actions)←2↑⊆text_actions
      R←'.modal'#.HtmlElement.New #._.div
      R.id←modId←R.GenId
      mc←('.modal-dialog .modal-dialog-centered role=document'R.Add #._.div).Add #._.div'' '.modal-content .bg-dark'
      mh←'.modal-header'mc.Add #._.div
      mh.Add #._.h3 tit'.modal-title'
⍝         <button type="button" class="close" data-dismiss="modal" aria-label="Close">
⍝           <span aria-hidden="true">&times;</span>
⍝         </button>
     
      mc.Add #._.div text'.modal-body'
⍝       <div class="modal-body">
⍝         ...
⍝       </div>
     
      mf←mc.Add #._.div'' '.modal-footer'
      :For b :In 1↑⊆actions
          (tit cb st)←3↑⊆b  ⍝ title, callback, style
          :If 0=≢tit ⋄ tit←GetText'OK' ⋄ :EndIf
          btn←mf.Add #._.Button tit
          :If 0=≢st  ⍝ if no style
          :AndIf 1=≢actions ⍝ and there is one button only
              st←'primary'   ⍝ that button nwill be the default one!
          :EndIf
          :If 0<≢cb
              :If cb≡'close'
                  btn.On'click' '' ''('$("#',modId,'").modal("close");$("#',modId,'").remove();')
              :Else
                  btn.On'click'cb
              :EndIf
          :ElseIf 1=≢⊆actions  ⍝ if there is one button only, it WILL close the dialog!
              btn.On'click' '' ''('$("#',modId,'").modal("close");$("#',modId,'").remove();')
          :EndIf
          s∆←'.btn'
          :For s :In ⊆st
              :If s∊⍥⊆'primary' 'secondary' 'danger' 'warning' 'success' 'info' 'light' 'dark' 'link'
                  s∆,←' .btn-',s
              :EndIf
          :EndFor
      :EndFor
     
      (h j)←getHTMLjs        R
      R←'body'#.MiPage.Append h
      R,←#.MiPage.Execute j
      R,←#.MiPage.Execute '$("#',modId,'").modal("show");'
⍝       <div class="modal-footer">
⍝         <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
⍝         <button type="button" class="btn btn-primary">Save changes</button>
⍝       </div>
⍝     </div>
⍝   </div>
⍝ </div>
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
