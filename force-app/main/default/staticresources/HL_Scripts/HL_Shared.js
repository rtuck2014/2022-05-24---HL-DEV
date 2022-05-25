function maskKeys(event) {
    var c = event.keyCode
    var ctrlDown = event.ctrlKey || event.metaKey // Mac support
    //window.status = event.keyCode + ctrlDown;

    if (
    // Allow <DEL>, <BACKSPACE>, <TAB>, <ESC>, <ENTER>, etc...
			(event.keyCode >= 8 && event.keyCode <= 46)

    // Allow <.>, <->, <->, <.> (both keyboard and numpad)
			|| event.keyCode === 190 
			|| event.keyCode === 109 || event.keyCode === 110

    // Allow CTRL+ A, C, X, V
			|| (event.keyCode === 65 && event.ctrlKey === true)
			|| (event.keyCode === 67 && event.ctrlKey === true)
			|| (event.keyCode === 86 && event.ctrlKey === true)
			|| (event.keyCode === 88 && event.ctrlKey === true)
		) {
        return;
    }
    else {
        // Ensure that it is a number and stop the keypress
        if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105)) {
            event.preventDefault();
        }
    }
}