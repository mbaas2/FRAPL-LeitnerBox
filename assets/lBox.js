var myGridData;
var fieldTypes;
var nextID;
var flag_added = false;

function onEnterClick(event, rarg) {
  if (event.keyCode === 13) {
    $("#" + rarg).trigger("click");
    event.preventDefault();
  }
  event.stopImmediatePropagation(); // disable regular keyup-handler
  return false;
}


function ActionBegin(arg) {
  if (flag_added && arg.requestType == "save") {
    // testing - not complete...
    // see https://www.syncfusion.com/forums/131955/how-to-auto-increment-primary-key-of-grid-from-js
    arg.data.nr = nextID;
    nextID += 1;
  }
}

function ToolbarClick(arg) {
  flag_added = arg.itemName == "Add"  // only true when "+"-button clicked
}
