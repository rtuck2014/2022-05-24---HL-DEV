({
    isInStringList: function(value, strings) {
        if (!strings) {
            return false;
        }

        var found = false;

        var values = strings.split(',');

        var arrayLength = values.length;
        for (var i = 0; i < arrayLength; i++) {
            if (value == values[i].trim()) {
                found = true;

                break;
            }
        }

        return found;
    },

    evaluateStateList: function(state, stateList) {
        if ((!state) || (!stateList)) {
            return false;
        }

        if (stateList.substring(0, 1) != '!') {
            return this.isInStringList(state, stateList);
        }

        // negate

        return !this.isInStringList(state, stateList.substring(1));
    },

    calculateVisibleState: function (component) {
        var state = component.get('v.state');

        var isVisible = component.get('v.defaultIsVisible');

        var visibleStates = component.get('v.visibleStates');
        var hiddenStates = component.get('v.hiddenStates');

        if (this.evaluateStateList(state, visibleStates)) {
            isVisible = true;
        }

        if (this.evaluateStateList(state, hiddenStates)) {
            isVisible = false;
        }

        var forceVisible = component.get('v.forceVisible');
        var forceHidden = component.get('v.forceHidden');

        if (forceVisible) {
            isVisible = true;

        } else if (forceHidden) {
            isVisible = false;
        }

        if (isVisible != component.get('v.isVisible')) {
            component.set('v.isVisible', isVisible);
        }
    },

    calculateEnabledState: function (component) {
        var state = component.get('v.state');

        var isEnabled = component.get('v.defaultIsEnabled');

        var enabledStates = component.get('v.enabledStates');
        var disabledStates = component.get('v.disabledStates');

        if (this.evaluateStateList(state, enabledStates)) {
            isEnabled = true;
        }

        if (this.evaluateStateList(state, disabledStates)) {
            isEnabled = false;
        }

        var forceEnabled = component.get('v.forceEnabled');
        var forceDisabled = component.get('v.forceDisabled');

        if (forceEnabled) {
            isEnabled = true;
            
        } else if (forceDisabled) {
            isEnabled = false;
        }

        if (isEnabled != component.get('v.isEnabled')) {
            component.set('v.isEnabled', isEnabled);
        }
    },

    calculateEditingState: function (component) {
        var state = component.get('v.state');

        var isEditing = component.get('v.defaultIsEditing');

        var editingStates = component.get('v.editingStates');
        var readOnlyStates = component.get('v.readOnlyStates');

        if (this.evaluateStateList(state, editingStates)) {
            isEditing = true;
        }

        if (this.evaluateStateList(state, readOnlyStates)) {
            isEditing = false;
        }

        var forceEditing = component.get('v.forceEditing');
        var forceReadOnly = component.get('v.forceReadOnly');

        if (forceEditing) {
            isEditing = true;
            
        } else if (forceReadOnly) {
            isEditing = false;
        }

        if (isEditing != component.get('v.isEditing')) {
            component.set('v.isEditing', isEditing);
        }
    },

    calculateState: function (component) {
        this.calculateVisibleState(component);
        this.calculateEnabledState(component);
        this.calculateEditingState(component);
    },

    setEnabled: function (component) {
        var isEnabled = component.get('v.isEnabled');

        var body = component.get('v.body');

        if (!body) {
            return;
        }

        var arrayLength = body.length;
        for (var i = 0; i < arrayLength; i++) {
            body[i].set('v.disabled', !isEnabled);
        }
    },

    setEditing: function (component) {
        var isEditing = component.get('v.isEditing');

        var body = component.get('v.body');

        if (!body) {
            return;
        }

        var arrayLength = body.length;
        for (var i = 0; i < arrayLength; i++) {
            body[i].set('v.isEditing', isEditing);
        }
    }
})