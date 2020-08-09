:namespace Overrides
⍝ this namespace has the overrides which are treated differently by MiServer and HRServer
⍝ these fns are called directly by HRServer, whereas the MiServer-methods are stores in the Server-class
⍝ and overridden by fns that call these fns as.

    ∇ onServerStart;⎕using
     
⍝ collect info about the environment
      '#.Env'⎕NS''
      :If ⎕NEXISTS file←#.Boot.AppRoot,'version.json'
          #.Env.(tsVersion tsDate tsId)←(⎕JSON 1⊃⎕NGET file).(tag id created_at)
      :Else
          #.Env.(tsVersion tsDate tsId)←⊂'N/A'
      :EndIf
      :If ⎕NEXISTS file←({6::⍵.WC2Root ⋄ ⍵.MSRoot}#.Boot),'version.json'  ⍝ use #.Boot.MSRoot or WC2Root
          #.Env.(msVersion msDate msId)←(⎕JSON 1⊃⎕NGET file).(tag id created_at)
      :Else
          #.Env.(msVersion msDate msId)←⊂'N/A'
      :EndIf
      ⎕using←'System'
      #.Env.dotnetVersion ←4⊃#.Tools.GetDOTNETVersion
      #.Env.serial←2 ⎕NQ'.' 'GetEnvironment' 'DYALOG_SERIAL'
      #.Env.os←3↑1⊃'.'⎕WG'APLVersion'  ⍝ reports current operating systems (abbreviated to 3 letters):    Win | Mac | Lin | AIX | Sol
      #.Env.dyaVersion←2⊃'.'⎕WG'APLVersion'
      #.Env.lic←0 ⍝ 0=unreg, 1=personal, 2=commercial
      :If 6=+/#.Env.serial∊⎕D
          #.Env.lic←1+500000>#.Strings.tonum #.Env.serial
      :Else
          #.Env.serial←'(unregistred)'
      :EndIf
      #.Env.tsMode←{6::2 ⋄ 'HRServer'≡⍎⍵}'#.Boot.ms.Framework'         ⍝ 1=running locally, 2=remote
      #.Env.temp←{⍵,(~¯1↑⍵∊'\/')/'/'}739⌶0   ⍝ temporary (local) directory with a trailing backslash
      #.Env.maxws←2 ⎕NQ'.' 'GetEnvironment' 'maxws'
    ∇



    ∇ onSessionStart req
    ∇


    ∇ onHandleMSP req
  ⍝    i←req.Session.Pages._PageName⍳⊂req.Page
  ⍝    inst←i⊃req.Session.Pages
  
    ∇

    ∇ Cleanup
      :If {6::2 ⋄ 'HRServer'≡⍎⍵}'#.Boot.ms.Framework'
      :AndIf {6::⍵ ⋄ #.Prefs.closeAPLonExit}0
          ⎕OFF
      :EndIf
    ∇



:endnamespace
