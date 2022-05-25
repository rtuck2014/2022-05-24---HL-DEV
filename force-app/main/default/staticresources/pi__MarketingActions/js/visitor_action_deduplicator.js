function removeActionsHavingNonUniqueVisitors(marketingActions){
    var actions = [], action, unprocessedAction, hasBeenAdded;

    for(var i = 0; i < marketingActions.length; i++){
        hasBeenAdded = false;
        unprocessedAction = marketingActions[i];
        for(var j = 0; j < actions.length; j++){
            action = actions[j];
            if(visitorIsTheSame(unprocessedAction, action)){
                hasBeenAdded = true;
                break;
            }
        }
        if(!hasBeenAdded){
            actions.push(unprocessedAction);
        } else if(unprocessedActionIsNewer(unprocessedAction, action)){
            actions[j] = unprocessedAction;
        }
    }

    return actions;
}

function visitorIsTheSame(unprocessedAction, action){
    if(unprocessedAction.prospect && action.prospect){
        return unprocessedAction.prospect.id == action.prospect.id;
    } else {
        return unprocessedAction.visitor.id == action.visitor.id;
    }
}

function unprocessedActionIsNewer(unprocessedAction, action){
    return new Date(action.createdAt) < new Date(unprocessedAction.createdAt);
}

module.exports = {
    removeActionsHavingNonUniqueVisitors: removeActionsHavingNonUniqueVisitors
}
