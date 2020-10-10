:class lBox  ⍝ was "project"

    :field public data
    :field public file  ⍝ the .lbox (user-dir)
    :field public CardFile
    :field public stock
    :field public Wort
    :field public Lesson
    :field private sf←'' ⍝ stockfile

    nl←⎕ucs 13


    ∇ make arg;f
      :Implements constructor
      :Access public
      file←arg
      stock←⎕NS''
      :If ⎕NEXISTS file
          data←⎕JSON 1⊃⎕NGET file
          sf←data.stock
          :If ~∨/'\/'∊sf ⍝ is stock-file specified using a path?
              sf←(1⊃⎕NPARTS file),sf   ⍝ nope, then use same dir as project file
          :OrIf '.'=1⊃file ⍝ if it's a relative path
              sf←(1⊃⎕NPARTS file),sf   ⍝ nope, then use same dir as project file
          :EndIf
          :If 0=data.⎕NC'stats'
              data.stats←⍳0
          :EndIf
          :If ⎕NEXISTS sf
              stock←⎕JSON 1⊃⎕NGET CardFile←sf
            ⍝ make sure optional fields have a value everywhere
              :For f :In ({6::'' ⋄ (#.HtmlElement._true≡⍵.optional)/⍵.code}¨stock.meta.fields)~⊂''
                  {}(⊂f){6::⍎'⍵.',⍺,'←⎕NULL' ⋄ ⍵⍎⍺}¨stock.cards
              :EndFor
          :Else ⋄ ∘∘∘
          :EndIf
      :Else  ⍝ todo: take this out and explicitely add something to make a new lBox based on seleced card-file
          data←⎕NS''
          ⍝ TODO: Init mode with first mode!
          data.progress←1
          data.stats←⍳0
          ((⎕JSON⍠'Compact' 0)data)⎕NPUT file 1
          ⎕←'Initialized data-file ',file,' please edit config!'
      :EndIf
      Lesson←⎕NEW cLesson(data stock)
    ∇


    ∇ R←NameOfBox
      :Access public
      R←2⊃⎕NPARTS file
    ∇

    ∇ saveData
      :Access public
      ((⎕JSON⍠'Compact' 0)data)⎕NPUT file 1
    ∇

    :class cLesson
        :field public _words←⍬
        :field private idx←1
        :field private lumpSize←20   ⍝ how many new words to add to 1?
        :field public data
        :field private stock
        :field private method← 1 1 2 1 1 2 1 1 2 3 1 1 2 1 1 2 1 1 2 3 4
        :field public f1  ⍝ code
        :field public f2
        :field public Filter← ⍬

        ∇ make arg
          :Implements constructor
          :Access public
          ⍝ Constructor: data lesson
          (data stock)←arg
          :If (⊂data.mode)∊stock.meta.modes.id
              stock.meta.fields.(type←{6::'text' ⋄ type}0)
              z←stock.meta.modes.id⍳⊂data.mode
              (f1∆ f2∆)←(z⊃stock.meta.modes).(f1 f2)
              f1←stock.meta.fields[stock.meta.fields.code⍳⊆f1∆]
              f2←stock.meta.fields[stock.meta.fields.code⍳⊆f2∆]
            ⍝   f1.label←(stock.meta.fields.code⍳⊆f1.id)⊃stock.meta.fields.label
            ⍝   f2.label←(stock.meta.fields.code⍳⊆f2.id)⊃stock.meta.fields.label
            ⍝   (f1 f2).type←⊂'text'
            ⍝   :If 2=(stock.meta.fields.code⍳⊆f1.id)⊃stock.meta.fields.⎕NC⊂'type'
            ⍝       f1.type←(stock.meta.fields.code⍳⊂f1.id)⊃stock.meta.fields.type
            ⍝   :EndIf
            ⍝   :If 2^.=∊(⊂stock.meta.fields.code⍳⊆f2.id)⌷stock.meta.fields.⎕NC⊂'type'
            ⍝       f2.type←(stock.meta.fields.code⍳⊆f2.id)⌷stock.meta.fields.type
            ⍝   :EndIf
         
          :Else
               ⍝ TODO: Error handling if configured mode not found in box!
          :EndIf
          _words←todaysLesson
        ∇

        ∇ R←ReadOnly
          :Access public
        ⍝ is the card-stock readonly?
          R←stock.meta{6::0 ⋄ #.HtmlElement._true≡⊂⍺⍎⍵}'readonly'
        ∇

        ∇ R←ApplyFilter sel
          :Access public
          :If 0<≢sel
              R←Filter←EvalFilter sel
          :Else
              Filter←⍬
          :EndIf
        ∇

        ∇ R←EvalFilter sel
          :Access public
          R←⍎'stock.cards.',sel
        ∇



        :property cards2mat
        :access public
            ∇ R←get
              :Access public
              nm←∪⊃,/stock.cards.⎕NL-2
              R←↑stock.cards{
                  6::''
                  ⍺⍎¨⍵
              }¨⊂nm
              R←nm⍪R
            ∇

            ∇ set R
              :Access public
              nm←R.NewValue[1;]
              R←1↓[1]R.NewValue
              stock.cards←⎕NS¨(≢R)⍴⊂''
              ⍎'stock.cards.(',(∊nm,¨' '),')←↓R'
            ∇


        :endproperty


        :property stock_meta
        :access public

            ∇ R←get
              :Access public
              R←stock.meta
            ∇

            ∇ set R
              :Access public
              stock.meta←R
            ∇

        :endproperty

        ∇ IncProgress
          :Access public
          data.progress+←1
          _words←todaysLesson
        ∇
        ∇ R←GetCSS
          :Access public
          R←''
          :If 2=stock_meta.⎕NC'css'
              R←1⊃⎕NGET(1⊃⎕NPARTS ##.CardFile),stock_meta.css
              ((10=⎕UCS R)/R)←' '                               ⍝ remove linefeeds!
          :EndIf
         
        ∇

        ∇ R←GetWord;dat;i;t;F;j
          :Access public
          DETRAP
          R←⍬
          :If idx≤≢_words
              :If Filter≡⍬
                  i←stock.cards.id⍳_words[idx]
              :Else
                  :If 0<≢z←⍸(idx-1)↓Filter[stock.cards.id⍳_words]
                      idx←z[1]+idx-1
                      i←stock.cards.id⍳_words[idx]
                  :Else
                      i←1+≢stock.cards
                  :EndIf
              :EndIf
              :If i≤≢stock.cards
                  word←stock.cards[i]
                  R←⊂word⍎¨⊆f1.code
                  R,←⊂word⍎¨⊆f2.code
                  :For i :In ⍳2
                      F←,i⊃f1 f2
                      :For j :In ⍳≢F
                          :If 2=F[j].⎕NC'type'
                          :AndIf F[j].type≡'media'
                              :Select ⎕C 3⊃⎕NPARTS j⊃,i⊃R
                              :Case '.png'
                                  t←((1⊃⎕NPARTS ##.CardFile),j⊃,i⊃R)⎕NTIE 0
                                  dat←⎕NREAD t,(⎕DR' '),,⎕NSIZE t ⋄ ⎕NUNTIE t
                                  dat←#.Base64.Encode dat
                                  (j⊃,i⊃R)←'data:image/png;base64,',dat
                              :Case '.svg'
                                  dat←⊃⎕NGET(1⊃⎕NPARTS ##.CardFile),j⊃i⊃R
                                  (j⊃i⊃R)←'data:image/svg;',dat
                              :Case '.mp3'
                                  t←((1⊃⎕NPARTS ##.CardFile),j⊃i⊃R)⎕NTIE 0
                                  dat←⎕NREAD t,(⎕DR' '),,⎕NSIZE t ⋄ ⎕NUNTIE t
                                  dat←#.Base64.Encode dat
                                  (i⊃i⊃R)←'data:audio/mpeg;base64,',dat
                              :EndSelect
                          :EndIf
                      :EndFor
                  :EndFor
                  R,←_words[idx]   ⍝ 3d elemnt is the id of that word!
              :EndIf
          :EndIf
          RETRAP
        ∇

        ∇ R←todaysLesson;missing;new;sect
          :Access public
    ⍝ get ids of words to be learned today
          R←⍬
          ⎕RL←⍬ 2  ⍝ ensure "real random" (for ?)
          :If 326≠⎕DR data.stats
              missing←stock.cards.id
          :Else
              missing←(~stock.cards.id∊data.stats.id)/stock.cards.id
          :EndIf
          sect←1⊃SectionInfo
          new←(sect=1)/missing[(lumpSize⌊≢missing)?≢missing]
          :If 326=⎕DR data.stats
              R←(sect=data.stats.sect)/data.stats.id
              R←R[?⍨≢R]
          :EndIf
          R←R,new
          :If 0<≢new
              data.stats⍪←{n←⎕NS'' ⋄ n.id←⍵ ⋄ n.sect←1 ⋄ n}¨new
          :EndIf
        ∇
        ∇ Tested bool
          :Access public
⍝ actions after testing: word ok or failed - change status accordingly and increment internal counter
         
          :If (≢data.stats)<s←data.stats.id⍳_words[idx]  ⍝ do we have stats for that word already?
              new←⎕NS'' ⋄ new.id←_words[idx] ⋄ new.sect←data.progress ⋄ data.stats,←new  ⍝ nope - new entry!
          :EndIf
         
          :If bool
              data.stats[s].sect+←1
          :Else
              data.stats[s].sect←1  ⍝ back to 1!
              :If 1=1⊃SectionInfo   ⍝ if we're in box 1
                  _words,←_words[idx]  ⍝ repeat failed words till they are mastered!
              :EndIf
          :EndIf
          idx+←1
        ∇

        ∇ R←SectionInfo;sects;unassigned
          :Access public
⍝ R[1]: index of today's section
⍝ R[2]: vector with # of elements per section
⍝ R[3]: ids per section
          :If 0=data.⎕NC'stats'
          :OrIf 326≠⎕DR data.stats   ⍝ variable (namespace=9)
              R←1
              R,←⊂6↑≢stock.cards.id
          :Else
              R←sect←method{w←(≢⍺)|⍵ ⋄ w=0:(≢⍺)⊃⍺ ⋄ w⊃⍺}data.progress
              ⍝(~stock.cards.id∊data.stats.id)/stock.cards.id
              :if Filter≡⍬
              sects←data.stats.sect{⍺ ⍵}⌸data.stats.id
              :else
              z←data.stats.id ∊Filter/stock.cards.id
              sects←(z/data.stats.sect){⍺ ⍵}⌸z/data.stats.id
              :endif
              sects←(sects[;2],⊂⍬)[sects[;1]⍳⍳5]
              :if Filter≡⍬
              unassigned←(~stock.cards.id∊data.stats.id)/stock.cards.id
              :else 
              unassigned←(Filter^~stock.cards.id∊data.stats.id)/stock.cards.id
              :endif
              R,←⊂(≢unassigned),≢¨sects
              R,←⊂(⊂unassigned),sects
          :EndIf
        ∇

        ∇ R←Done
          :Access public
         ⍝ are we done yet?
          R←idx>≢_words
        ∇

    :endclass
:endclass