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

## Concepts  

The app uses vocabulary that is provided in a `.JSON`-format as illustrated in the norwegian vocabulary
in `Data/norw.json` We're planning to offer a method for an easy import/input and maintenance of this data,  
atm this is a little bit of a "rough edge" we aplogize for.

To learn a language, you need to define a "learning project" - again, this is done using `.JSON`-Format,
and the relevant sample is `Data/norw-fw.json`. (The *fw* indicated *forward learning*, meaning that you learn **from**
native **to** foreign language.) The technical specification of this "learning direction" is done through the `direction`-field in that file which has value `1`. (Learning `backward` = **from** foreign **to** native would be  
specified using value `2`.)
The `progress`-field in that file is a counter that is incremented with every day (of exercise). According to this parameter you'll be presented with different sections of the index-box for learning.

## Using it  

* requires [Dyalog APL](https://www.dyalog.com/) - free for personal, non-commercial use. V17 onwards...

* first, to load the app. do:  
  `]load /git/FRAPL-Voka/*.aplc`  
  which brings the neccessary classes into the workspace.

* to run it, you need to open a "learning project":
  `myP←⎕NEW #.project '/git/FRAPL-Voka/Data/norw-hin.json'  

* for status-info, of that project:  
  `myP.info`

* to run the daily lesson:
  `myP.Lesson`
