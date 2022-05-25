({
    afterRender: function (component, helper) {
        var showLookup = component.get("v.showLookupField");
        this.superAfterRender();
                if(showLookup){
        var targetEl = component.find("mainContainer").getElement();
        targetEl.addEventListener(
            "touchmove", 
            helper.scrollStopPropagation, 
            true // we use capture!
        );
    }
    }
})