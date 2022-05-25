 $j.fn.waitUntilExists    = function (handler, shouldRunHandlerOnce, isChild) {
    var found       = 'found';
    var $this       = $j(this.selector);
    var $elements   = $this.not(function () { return $j(this).data(found); }).each(handler).data(found, true);

    if (!isChild)
    {
        (window.waitUntilExists_Intervals = window.waitUntilExists_Intervals || {})[this.selector] =
            window.setInterval(function () { $this.waitUntilExists(handler, shouldRunHandlerOnce, true); }, 500)
        ;
    }
    else if (shouldRunHandlerOnce && $elements.length)
    {
        window.clearInterval(window.waitUntilExists_Intervals[this.selector]);
    }

    return $this;
}