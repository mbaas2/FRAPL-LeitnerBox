:namespace Overrides
⍝ this namespace has the overrides which are treated differently by MiServer and HRServer
⍝ these fns are called directly by HRServer, whereas the MiServer-methods are stored in the Server-class
⍝ and overridden by fns that call these fns as.

    ∇ onServerStart;⎕USING;t;uid;file;u
      ⎕PATH←'#.Tools'  ⍝ make our tools accessible
⍝ collect info about the environment
      DETRAP
      '#.Env'⎕NS''
      :If ⎕NEXISTS file←#.Boot.AppRoot,'version.json'
          #.Env.(tsVersion tsDate tsId)←(⎕JSON 1⊃⎕NGET file).(tag id created_at)
      :Else
          #.Env.(tsVersion tsDate tsId)←⊂'N/A'
      :EndIf
      #.Env.Root←#.Boot.AppRoot  ⍝ pointer to our HOME-Folder
      ⎕USING←'System'
      #.Env.dotnetVersion←4⊃GetDOTNETVersion
      #.Env.serial←2 ⎕NQ'.' 'GetEnvironment' 'DYALOG_SERIAL'
      #.Env.os←3↑1⊃'.'⎕WG'APLVersion'  ⍝ reports current operating systems (abbreviated to 3 letters):    Win | Mac | Lin | AIX | Sol
      #.Env.dyaVersion←2⊃'.'⎕WG'APLVersion'
      #.Env.lic←0 ⍝ 0=unreg, 1=personal, 2=commercial
      :If 6=+/#.Env.serial∊⎕D
          #.Env.lic←1+500000>#.Strings.tonum #.Env.serial
      :Else
          #.Env.serial←'(unregistred)'
      :EndIf
      RETRAP
      :If ⎕NEXISTS file←({6::⍵.WC2Root ⋄ ⍵.MSRoot}#.Boot),'version.json'  ⍝ use #.Boot.MSRoot or WC2Root
          #.Env.(msVersion msDate msId)←(⎕JSON 1⊃⎕NGET file).(tag id created_at)
      :Else
          #.Env.(msVersion msDate msId)←⊂'N/A'
      :EndIf
      #.Env.tsMode←{6::2 ⋄ 'HRServer'≡⍎⍵}'#.Boot.ms.Framework'         ⍝ 1=running locally, 2=remote
      :If #.Env.isHR←{6::0 ⋄ 'HRServer'≡⍎⍵}'#.Boot.ms.Framework'   ⍝ Are we running with HTMLRenderer
          DETRAP
          #.Env.temp←{⍵,(~¯1↑⍵∊'\/')/'/'}739⌶0   ⍝ temporary (local) directory with a trailing backslash
          #.Env.maxws←2 ⎕NQ'.' 'GetEnvironment' 'maxws'
          #.Env.DevToolsVisible←0
          #.Env.DevToolsVisible←1=2⊃⎕VFI #.Boot.ms.Config.HRServer.Debug
      :EndIf
      RETRAP
      :If ⎕NEXISTS(file←#.Env.Root,'Data/last'),'.dcf'
          t←file ⎕FSTIE 0
          uid←⎕FREAD t,1 ⋄ ⎕FUNTIE 1
          #.Boot.ms.SessionHandler.Sessions.user←u←⎕NEW #.User uid  ⍝ log him in by passing user id (security???)
          ⎕FUNTIE t
          :If 0<≢f←u{6::'' ⋄ ⍺⍎⍵}'Prefs.autoOpen'
          :AndIf ⎕NEXISTS f←#.Env.Root,'Data/Users/u',(⍕uid),'/',f
              prj←⎕NEW #.lBox f
              #.Boot.ms.SessionHandler.Sessions.user←u
              #.Boot.ms.SessionHandler.Sessions.prj←prj
          :EndIf
      :EndIf
    ∇



    ∇ onSessionStart req;t;file
    ∇


    ∇ onHandleMSP req
  ⍝    i←req.Session.Pages._PageName⍳⊂req.Page
  ⍝    inst←i⊃req.Session.Pages
     
    ∇

    ∇ Cleanup
      :If {0::0 ⋄ 'HRServer'≡⍎⍵}'#.Boot.ms.Framework'
      :AndIf {0::0 ⋄ ⍵.Prefs.closeAPLonExit}user
          ⎕OFF
      :EndIf
    ∇



:endnamespace
