:class User
⍝
⍝ User-Management
⍝
⍝ Data-Folder contains file "users.dcf" (initialized if not found)
⍝
⍝ Its only content is the table often to as "users"  (if we have thousand of simulatenous users, a DB might be better - but this makes for an easy start)
⍝
⍝  every row is a user-record. The row-index is the UserID. Data of that table:
⍝  [;1]: email-address
⍝  [;2]: salt (for pwsd)
⍝  [;3]: hash of salt,pswd
⍝  [;4]: Status: 1=new user, no pwd set ("START" as default-pwd should be changed after login)
⍝                2=regular user
⍝                3=forgot pwd
⍝        Status 1 or 3 must be reminded to change their password!!!
⍝  [;5]: Time-number of registration
⍝  [;6]: Time-number of last login
⍝  [;7]: Time-number of last logout
⍝  [;8]: Time-number of "forgot pwd"
⍝  [;9]: hash of salt+temporary pswd (if status=3)
⍝  [;10]: tvt with details of req (related to 8)

    :field public id←¯1  ⍝ not logged in, ¯2: error signing in
    :field public Status←0
    :field public Prefs
    :field public MyDataDir←''

    ∇ LoginWithUID uid;t;users
      :Access public
      :Implements constructor
      t←TieUsers 1 ⋄ users←⎕FREAD t,1
      users[uid;6]←1 ⎕DT⊂⎕TS ⋄ users ⎕FREPLACE t,1 ⋄ ⎕FUNTIE t
      id←uid
      Status←users[uid;4]
      GetPrefs
    ∇

    ∇ Login(email pwd)
      :Access public
      :Implements constructor
      t←TieUsers 0 ⋄ users←⎕FREAD t,1 ⋄ ⎕FUNTIE t
      →((≢users)<i←users[;1]⍳⍥⎕C⊂email)/0
     
      hash←#.Strings.stringToHex hash(2⊃users[i;]),pwd
      :If hash≡3⊃users[i;]
          id←i
          t←TieUsers 1 ⋄ users←⎕FREAD t,1 ⋄ users[id;6]←1 ⎕DT⊂⎕TS ⋄ users ⎕FREPLACE t,1 ⋄ ⎕FUNTIE t
      :ElseIf users[i;4]=3
      :AndIf hash≡9⊃users[i;]
          id←i
      :Else
          id←¯2 ⋄ →0
      :EndIf
      Status←users[id;4]
      GetPrefs
    ∇

    ∇ Logout;t;users
      :Implements destructor
      t←TieUsers 1 ⋄ users←⎕FREAD t,1
      :If id>0
          users[id;7]←1 ⎕DT⊂⎕TS
          users ⎕FREPLACE t,1
          id←0
      :EndIf
      ⎕FUNTIE t
    ∇


    ∇ R←{details}Register email;t;file;users;i;salt;hash
      :Access public shared
⍝ R is a one or two-element vector
⍝ R[1]: ¯1: Error (see 2⊃R for msgs)
⍝ R[1]≥0: [1] is the id of the new user
      :If 0=⎕NC'details' ⋄ details←'' ⋄ :EndIf
      t←TieUsers 1
      users←⎕FREAD t,1
      :If (≢users)≥i←users[;1]⍳⍥⎕C⊂email
          R←0(GetText'UserExists')
      :Else
          salt←salt 32  ⍝ create new salt (ok, this relies on the #.Tools-ns being present...)
          hash←#.Strings.stringToHex hash salt,'START'
          users⍪←(email)salt hash 1(1 ⎕DT⊂⎕TS)0 0 0 ''details
          users ⎕FREPLACE t,1
          R←≢users
      :EndIf
      ⎕FUNTIE t
    ∇


    ∇ t←TieUsers exclusive;file
      ⍝ tie the user-DB, optionally attempt to ⎕FHOLD it
      :If ~⎕NEXISTS(file←#.Env.Root,'Data\users'),'.dcf'
          t←file ⎕FCREATE 0
          (0 10⍴0)⎕FAPPEND t
      :Else ⋄ t←file ⎕FSTIE 0
      :EndIf
      →exclusive↓0
      ⎕FHOLD t
    ∇


    ∇ R←ListProjects
      :Access public
⍝ return list of filenames of boxes in user's datadir
      R←{∊1↓⎕NPARTS ⍵}¨⊃0(⎕NINFO⍠1)#.Env.Root,'Data/Users/u',(⍕id),'/*.lbox.json'
    ∇



    ∇ GetPrefs
⍝ read preferences for user <id> (if there are any)
⍝ and make sure we have a datadir for him
      :Access public
      :If ~⎕NEXISTS MyDataDir←#.Env.Root,'Data/Users/u',⍕id
          3 ⎕MKDIR MyDataDir
      :EndIf
      :If ⎕NEXISTS file←MyDataDir,'/settings.json'
          Prefs←⎕JSON 1⊃⎕NGET file
      :Else  ⍝ initialize preferences
          Prefs←⎕NS''
          Prefs.lang←'EN'
          (⊂⎕JSON Prefs)⎕NPUT file 1
      :EndIf
      LoadTexts Prefs.lang
      #.Boot.ms.Config.Lang←¯1 ⎕C Prefs.lang  ⍝ pretend we're sending data in the selected language ;)

      ⍝ *************************************************
      ⍝ *  Defaults for language-dependen accelerators  *
      ⍝ *************************************************
      Default←{0=⎕NC ⍺:⍎⍺,'←⍵'}
      :If 0=Prefs.⎕NC'accel' ⋄ Prefs.accel←⎕NS'' ⋄ :EndIf
      'Prefs.accel.OK'Default(GetText'DefaultAccelOK')
      'Prefs.accel.Reveal'Default(GetText'DefaultAccelReveal')
      'Prefs.accel.Nope'Default(GetText'DefaultAccelNope')
     
    ∇


    ∇ show;t;hdr
      :Access public shared
    ⍝ quick & dirty tool for testing - remove later!
      t←TieUsers 0
      hdr←'#' 'mail' 'salt' 'hash' 'stat' 'TSreg' 'TSlogin' 'TSlogout' 'TSforgot' 'HASHforgot' 'details'
      ⎕SE.Dyalog.Utils.display hdr⍪{(⍳≢⍵),⍵}⎕FREAD t,1
      ⎕FUNTIE t
    ∇
:endclass
