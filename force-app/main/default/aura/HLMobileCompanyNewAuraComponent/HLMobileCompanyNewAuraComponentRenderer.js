({
    afterRender: function (component, helper) {
        this.superAfterRender();
        var targetEl = component.find("mainContainer").getElement();
        targetEl.addEventListener(
            "touchmove", 
            helper.scrollStopPropagation, 
            true // we use capture!
        );
    }
})