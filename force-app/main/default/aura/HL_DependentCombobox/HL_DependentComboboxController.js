({
    updateOptions : function(component, event, helper) {
        let placeholder = component.get("v.placeholder");
        let noOptionsPlaceholder = component.get("v.noOptionsPlaceholder");

        let parentOptions = component.get("v.parentOptions");

        if ((!parentOptions) || (parentOptions.length == 0)) {
            component.set("v.options", null);
            component.set("v.value", null);
            component.set("v.displayPlaceholder", noOptionsPlaceholder);

            return;
        }

        let parentValue = component.get("v.parentValue");

        let dependentOptionsKey = component.get("v.dependentOptionsKey");

        let options = [];

        for (var i = 0; i < parentOptions.length; i++) {  // linear search, ok for short and medium length lists
            if (parentOptions[i].value == parentValue) {
                options = parentOptions[i][dependentOptionsKey];

                break;
            }
        }

        component.set("v.options", options);

        if ((!options) || (options.length == 0)) {
            component.set("v.value", null);
            component.set("v.displayPlaceholder", noOptionsPlaceholder);

            return;
        }

        component.set("v.displayPlaceholder", placeholder);

        let currentValue = component.get("v.value");

        for (var i = 0; i < options.length; i++) {
            if (options[i].value == currentValue) {
                return;
            }
        }

        component.set("v.value", null);  // clear out current value because it's not in the list of options
    },

    checkValidity : function(component, event, helper) {
        component.find("theCombobox").checkValidity();
    },

    reportValidity : function(component, event, helper) {
        component.find("theCombobox").reportValidity();
    },

    setCustomValidity : function(component, event, helper) {
        var params = event.getParam("arguments");
        
        if (params) {
            component.find("theCombobox").setCustomValidity(params.message);
        }
    },

    showHelpMessageIfInvalid : function(component, event, helper) {
        component.find("theCombobox").showHelpMessageIfInvalid();
    }
})