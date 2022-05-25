({
	afterRender : function(component){
        this.superAfterRender();
        var dateElement = component.find("recordDate").getElement();
        dateElement.children[0].setAttribute('placeholder', '(Select Date)');
    }
})