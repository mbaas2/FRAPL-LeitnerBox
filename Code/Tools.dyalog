:namespace Tools

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
                  R[4]←⊂'.NET Framework ',2⊃R  ⍝ JD: good enough?  Otherwise I may need to dig into the registry according to https://docs.microsoft.com/de-de/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed?view=netframework-4.8
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


    ∇ R←{show}Show id
⍝ Show (or hide - if "show"=0) control with given id
      :If 0=⎕NC'show'
      :OrIf show=1
          R←#.MiPage.Execute'$("#',id,'").removeClass("d-none");'
      :Else
          R←#.MiPage.Execute'$("#',id,'").addClass("d-none");'
      :EndIf
    ∇


:endnamespace
