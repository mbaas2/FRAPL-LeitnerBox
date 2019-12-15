This directory holds a custom build of the Bootstrap-framework which extends 
the "w-"-classes w25-w50-w75-w100 by adding w-5, w-10, w-15, w-35 as used in the Regression Wizard.
Don't fret! "Custom build" isn't a bad thing, Bootstrap is designed to allow that 
(using the SASS-Framework to create the .CSS). 
While this is ususually a painful process involving lots of strange tools 
(Gulp, Bower, Ruby, Node and any more) I found a web-app which does it all: https://bootstrap.build/

We need to modify "$sizes" there:
map-merge((5:5%, 10:10%, 15:15%, 20:20%, 25:25%, 30:30%, 35:35%, 50:50%, 75:75%, 100:100%), $sizes)

To create themed files, use the "Import"-Button on that page and select the desired
Bootswatch-Theme.

mbaas@dyalog.com / 20.8.2018