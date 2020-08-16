function onEnterClick(event, rarg) {
    if (event.keyCode === 13) {
        $("#" + rarg).trigger("click");
        event.preventDefault();
    }
    event.stopImmediatePropagation(); // disable regular keyup-handler
    return false;
}