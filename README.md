# FRAPL-LeitnerBox

## Purpose

This little project has been developed by the [FRAPL-Meetup](https://www.meetup.com/de-DE/Frankfurt-APLers/) - a group of APL-Enthusiasts in and around Frankfurt.
Our goal is to learn how to use APL by building useful software. This little (totally untypical) APL-Application  
intends to help students (or other "learners") in their study of vocabulary or other material they need to memorize. It uses the [Flashcard](https://wikipedia.org/wiki/Flashcard)-ideas from [Sebastian Leitner](https://de.wikipedia.org/wiki/Sebastian_Leitner).

The current name is probably temporary - one fine day (when it gets really useable) we may drop the FRAPL-Prefix! ;)

### DUI-UI 
In Feb2020 we started implementing an HTML-UI which can be used cross-platform. This uses DUI (Dyalog User Interface) which renders HTML/JS-based UIs.
Available from its repository https://github.com/Dyalog/DUI (doco of controls & how to build pages etc. currently to be found @ https://miserver.dyalog.com/)

To execute it, start Dyalog and then:
`)load /git/dui/dui ⍝ adjust path as appropriate`

To run the app using HTMLRenderer as a container:
`DUI.Run'/git/frapl-voka'`

Run it serving pages to your browser:
`DUI.Run'/git/frapl-voka' 8080`  ⍝ click URL that is shown in output`

** Warning: ** sorry, it's still very early days for this UI...
