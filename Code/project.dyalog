:class project

    :field public data
    :field public file
    :field public stock
    :field private method← 1 1 2 1 1 2 1 1 2 3 1 1 2 1 1 2 1 1 2 3 4
    :field private lumpSize←20   ⍝ how many new words to add to 1?
    :field public Wort
    :field public Lektion

    nl←⎕ucs 13


    ∇ make arg
      :Implements constructor
      :Access public
      file←arg
      stock←⎕NS''
      :If ⎕NEXISTS file
          data←⎕JSON 1⊃⎕NGET file
          sf←data.stock
          :If ~∨/'\/'∊sf ⍝ is stock-file specified using a path?
              sf←(1⊃⎕NPARTS file),sf   ⍝ nope, then use same dir as project file
          :EndIf
          :If ⎕NEXISTS sf
              stock←⎕JSON 1⊃⎕NGET sf
          :EndIf
      :Else
          data←⎕NS''
          data.direction←1
          data.progress←1
          data.stats←,⎕NS''
          data.stats[1].(id sect)←1
          ((⎕JSON⍠'Compact' 0)data)⎕NPUT file 1
          ⎕←'Initialized data-file ',file,' please edit config!'
      :EndIf
      Lektion←⎕NEW cLesson(data todaysLesson stock)
    ∇

    ∇ R←info
      :Access public
      R←⊂'Project: ',file
      R,←⊂'trains: ',∊stock.desc.(foreign native )[data.direction+1],' ➔ ',stock.desc.(native foreign )[data.direction+1]
      R,←⊂'Progress: ',⍕data.progress
      :If 326≠⎕DR data.stats   ⍝ variable (namespace=9)
          R,←⊂'Cards per section (incl. S0/5): ',¯2↓∊(⍕¨(≢stock.cards.id),0 0 0 0 0),¨⊂' | '
      :Else
          R,←⊂'Cards per section (incl. S0/5): ',¯2↓∊(⍕¨(+/~stock.cards.id∊data.stats.id),+⌿data.stats.sect∘.=⍳5),¨⊂' | '
      :EndIf
      R,←⊂'Today''s section: ',⍕method[data.progress]
     
    ∇

    ∇ R←SectionInfo
      :Access public
⍝ R[1]: index of today's section
⍝ R[2]: vector with # of elements per section
      :If 326≠⎕DR data.stats   ⍝ variable (namespace=9)
          R←1
          R,←⊂6↑≢stock.cards.id
      :Else
          R←sect←method{w←(≢⍺)|⍵ ⋄ w←w+w=0 ⋄ w⊃⍺}data.progress
     
          R,←⊂(+/~stock.cards.id∊data.stats.id),+⌿data.stats.sect∘.=⍳5
      :EndIf
    ∇



    ∇ Lesson;z;loop;ok;lesson_ids;i;word;sink
      :Access public
      lesson_ids←todaysLesson
      ok←0×lesson_ids
      loop←1
      :While 0∊ok
          (⍕loop),'. pass, ',(⍕+/~ok),' words'
          loop+←1
          :For i :In ⍸~ok
              word←stock.cards[idx←stock.cards.id⍳lesson_ids[i]]
             ⍝ 40⍴⎕UCS 13     ⍝ CLS ;)
              ⎕←word.(h f)[data.direction]
              sink←⍞
              ⍞←word.(f f)[data.direction]
              ⍝ anzeigen
              ⍝ gewusst         oder   nicht
     ask:
              ⎕←'Correct...or failed? (1/y/j=Correct, 0/n=Failed, i=Info, q=Quit (w/o saving progress), e=Exit (save progress)'
              z←⍕⍞
              :If ∨/z∊'Qq' ⋄ ⎕←'Quit' ⋄ :GoTo 0 ⋄ :EndIf
              :If ∨/z∊'eE'
                  ⎕←'Exit' ⋄ :Leave
              :EndIf
              :If 'i'∊z
                  ⎕←1↑¯2↑info
                  →ask
              :EndIf
              z←∨/'jyJY1'∊z
              :If (≢data.stats.id)<s←data.stats.id⍳lesson_ids[i]
                  new←⎕NS'' ⋄ new.id←i ⋄ new.sect←data.progress ⋄ data.stats,←new
              :EndIf
              :If (,1)≡,z
                  data.stats[s].sect+←1
              :Else
                  data.stats[s].sect←1  ⍝ zurück nach1 !
              :EndIf
              ok[i]←z∨sect>1
          :EndFor
      :EndWhile
      data.progress+←1
      saveData
      ⎕←'lesson_ids ended. Status:'
      ⎕←↑info
    ∇

    ∇ R←todaysLesson;missing;new
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

    ∇ saveData
      :Access public
      ((⎕JSON⍠'Compact' 0)data)⎕NPUT file 1
    ∇

    :class cLesson
        :field public _words←⍬
        :field private idx←1
        :field public data
        :field public ok←⍬
        :field private stock

        ∇ make arg
          :Implements constructor
          :Access public
          ⍝ Constructor: data lesson
          (data _words stock)←arg
          ok←(≢_words)⍴0
        ∇


        ∇ R←GetWord
          :Access public
          word←stock.cards[stock.cards.id⍳_words[idx]]
          R←word.(h f)[data.direction,(⍳2)~data.direction]
        ∇


        ∇ Tested bool
          :Access public
⍝ actions after testing: word ok or failed - change status accordingly and increment internal counter
         
          :If (≢data.stats)<s←data.stats.id⍳_words[idx]
              new←⎕NS'' ⋄ new.id←_words[idx] ⋄ new.sect←data.progress ⋄ data.stats,←new
          :EndIf
         
          :If bool
              data.stats[s].sect+←1
          :Else
              data.stats[s].sect←1  ⍝ back to 1!
          :EndIf
          ok[idx]←bool∨data.stats[s].sect>1
          idx+←1
        ∇

        ∇ R←Done
          :Access public
⍝ are we done yet?
          R←idx>≢_words
        ∇

    :endclass
:endclass
