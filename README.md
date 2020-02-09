# FRAPL-Voka

## Purpose

This little project has been developed by the [FRAPL-Meetup](https://www.meetup.com/de-DE/Frankfurt-APLers/) - a group of APL-Enthusiasts in and around Frankfurt.
Our goal is to learn how to use APL by building useful software. This little (totally untypical) APL-Application  
intends to help students in their study of vocabulary of a foreign language.  

## The theory  

The program emulates an index box with cards (flashcards) containing the vocabulary. (One card per word.) When learning with such a box,  
we start with 20 (configureable, see "lumpSize") cards from the "stock" (an inventory of vocbulary that was entered beforehand (see below))
and "learn" them. As you learn words, the cards move into the higher numbered sections of the box (up to 4). Words in 1 must be known and will be repeated until you know them - words in higher numbered section will move ti their predecessor if you don't know them - or move on otherwise.
Words in 4 that you knew (while testing) are considered "mastered" and will not be repeated.

The methodology implemented here ensures that each you either repeat known words or you extend the vocabulary (20 words added each time you learn section 1.)

## Learning  

When you test your knowledge of vocabulary, the app shows the word in your native language and, after pressing the Enter-key,  
shows the translation. It then asks if your recollection of that translation was correct or not - and sorts the card into the appropriate stack.  

## Cheating  

Of course it's entirely up to you. You have the choice of saying "Yes, correct" when you did not know a translation..and become the unsung hero
of turbo-learning. But note that will you only harm yourself, because in the end you will not have mastered the lesson when taking the shortcut.

## UI  

The UI is a bit rough atm, the app currently operates using console input. We're planning to use this a test-case to explore
various approaches towards UI, so expect some movement in that direction.

### DUI-UI 
In Feb2020 we started implementing an HTML-UI which can be used cross-platform. This uses DUI (Dyalog User Interface) which renders HTML/JS-based UIs.
Available from its repository https://github.com/Dyalog/DUI (doco of controls & how to build pages etc. currently to be found @ https://miserver.dyalog.com/)

To execute it, start Dyalog and then:
`)load /git/dui/dui ⍝ adjust path as appropriate`

To run the app using HTMLRenderer as a container:
`DUI.Run'/git/frapl-voka'`

Run it serving pages to your browser:
`DUI.Run'/git/frapl-voka' 8080`  ⍝ click URL that is shown in output`

** Warning: ** sorry, it's still very early days for this UI, so currently there's not much it can do. We're planning to work on it! ;)


## Concepts  

The app uses vocabulary that is provided in a `.JSON`-format as illustrated in the norwegian vocabulary
in `Data/norw.json` We're planning to offer a method for an easy import/input and maintenance of this data,  
atm this is a little bit of a "rough edge" we aplogize for.

To learn a language, you need to define a "learning project" - again, this is done using `.JSON`-Format,
and the relevant sample is `Data/norw-fw.json`. (The *fw* indicated *forward learning*, meaning that you learn **from**
native **to** foreign language.) The technical specification of this "learning direction" is done through the `direction`-field in that file which has value `1`. (Learning `backward` = **from** foreign **to** native would be  
specified using value `2`.)
The `progress`-field in that file is a counter that is incremented with every day (of exercise). According to this parameter you'll be presented with different sections of the index-box for learning.

## Plans

* of course, we welcome contributions (PR) to this repository!
* top-priority: import of .CSV or .TXT-Files with vocabulary
* currently the app just pauses and displays the solution. It might be interesting to implement (optional) input
  of YOUR answer/translation and then try a comparison to the "solution" (although that will still need human verification and confirmation)
* we're looking for a "sexy" name fo the app. Contributions welcome! ;)