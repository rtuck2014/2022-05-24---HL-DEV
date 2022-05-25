var ActionFactory = require('./action_factory.js');
var actionsRendered;

function render(actions, containerElement, onClickCallback){
    actionsRendered = 0;

    for(var i = 0; i < actions.length; i++){
        renderAction(actions[i], containerElement, onClickCallback);
    }
}

function renderAction(_action, parentElement, onClickCallback){
    var action, ActionClass;

    try {
        ActionClass = ActionFactory.getActionClass(_action);
        action = new ActionClass(_action, parentElement);
        action.render();
        action.setOnClickCallback(onClickCallback);
        actionsRendered++;
    } catch(e){
        console.log(e);
    }
}

function getNumberOfActionsRendered(){
    return actionsRendered;
}

module.exports = {
    render: render,
    getNumberOfActionsRendered: getNumberOfActionsRendered
}
