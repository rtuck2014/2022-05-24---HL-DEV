({
    doInit : function(component, event, helper) {
        helper.calculateState(component);
    },

    showHelpMessageIfInvalid : function(component, event, helper) {
        component.find('theInput').showHelpMessageIfInvalid();
    },

    setCustomValidity : function(component, event, helper) {
        var params = event.getParam('arguments');

        if (params) {
            component.find('theInput').setCustomValidity(params.message);
        }
    },

    calculateState: function (component, event, helper) {
        helper.calculateState(component);
    },

    setEnabled: function (component, event, helper) {
        helper.setEnabled(component);
    },

    setEditing: function (component, event, helper) {
        helper.setEditing(component);
    },

    checkChanged: function (component, event, helper) {
        var oldValue = component.get('v.previousValue');
        var newValue = component.get('v.value');

        if (oldValue != newValue) {
            component.set('v.previousValue', newValue);

            var changeEvent = component.getEvent('textChangeEvent');
            changeEvent.setParam('oldValue', oldValue);
            changeEvent.setParam('newValue', newValue);
            changeEvent.fire();
        }
    }
})