﻿:class lBox  ⍝ was "project"

    :field public data
    :field public file
    :field public stock
    :field private method← 1 1 2 1 1 2 1 1 2 3 1 1 2 1 1 2 1 1 2 3 4
    :field private lumpSize←20   ⍝ how many new words to add to 1?
    :field public Wort
    :field public Lesson

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
      Lesson←⎕NEW cLesson(data todaysLesson stock)
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

    ∇ saveData
      :Access public
      ((⎕JSON⍠'Compact' 0)data)⎕NPUT file 1
    ∇

    :class cLesson
        :field public _words←⍬
        :field private idx←1
        :field public data
        :field private stock

        ∇ make arg
          :Implements constructor
          :Access public
          ⍝ Constructor: data lesson
          (data _words stock)←arg
        ∇


        ∇ R←GetWord
          :Access public
          word←stock.cards[stock.cards.id⍳_words[idx]]
          R←word.(h f)[data.direction,(⍳2)~data.direction]
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
              :if 1=1⊃##.SectionInfo   ⍝ if we're in box 1 
              _words,←s  ⍝ repeat failed words till they are mastered!
              :endif
          :EndIf
          idx+←1
        ∇

        ∇ R←Done
          :Access public
⍝ are we done yet?
          R←idx>≢_words
        ∇

    :endclass
:endclass
