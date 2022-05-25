var rules = {
    on: [],
    off: []
}

function addOnRule(rule){
    rules.on.push(rule);
}

function addOffRule(rule){
    rules.off.push(rule);
}

function shouldBeOn(){
    for(var i = 0; i < rules.on.length; i++){
        if(!rules.on[i]()){
            return false;
        }
    }
    for(var i = 0; i < rules.off.length; i++){
        if(rules.off[i]()){
            return false;
        }
    }

    return true;
}

module.exports = {
    addOnRule: addOnRule,
    addOffRule: addOffRule,
    shouldBeOn: shouldBeOn
};
