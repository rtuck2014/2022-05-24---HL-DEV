var Frame = function(originalFrame, origin, originValidator){
    this.originalFrame = originalFrame;
    this.origin = origin;
    this.messageHandlers = {};
    this.responseHandlers = [];
    this.validateOrigin = typeof(originValidator) === 'function' ? originValidator : defaultOriginValidator;
    listenForMessagesFromOriginalFrame.call(this);
}

Frame.prototype.please = function(messageName, message){
    return postMessage.call(this, messageName, message);
}

Frame.prototype.onRequest = function(handlerName, handler){
    this.messageHandlers[handlerName] = function(data){
        handler(data.request, function(response){
            data.response = response;
            this.originalFrame.postMessage(data, this.origin);
        }.bind(this))
    }.bind(this);
}

Frame.prototype.dispose = function() {
    if(this.messageEventHandler) {
        window.removeEventListener('message', this.messageEventHandler)
        delete this.messageEventHandler
    }
    if(this.responseHandlers.length) {
        this.responseHandlers.forEach(function(handler) {
            window.removeEventListener('message', handler)
        })
        this.responseHandlers = []
    }
}

function listenForMessagesFromOriginalFrame(){
    this.messageEventHandler = function(event) {
        var data = event.data;
        if(!this.validateOrigin(event.origin, this.origin) || !isValidRequest(data, this.messageHandlers)) {
            return;
        }

        this.origin = event.origin;

        this.messageHandlers[data.messageName](data);
    }.bind(this)

    window.addEventListener('message', this.messageEventHandler, false)
}

function defaultOriginValidator(eventOrigin, origin) {
    return eventOrigin === origin;
}

function postMessage(messageName, message){
    var data = {
        messageName: messageName,
        request: message,
        id: (messageName + '_' + new Date().getTime())
    }

    return new Promise(function(resolve, reject){
        var responseMessageHandler = createResponseMessageHandler.call(this, data, resolve, reject);
        this.responseHandlers.push(responseMessageHandler);
        window.addEventListener('message', responseMessageHandler, false);
        this.originalFrame.postMessage(data, this.origin);
    }.bind(this))
}

function createResponseMessageHandler(data, resolve, reject){
    var handler = function(event){
        if(!this.validateOrigin(event.origin, this.origin) || !isValidResponse(data, event)){
            return;
        }
        this.origin = event.origin;

        window.removeEventListener('message', handler);

        if(event.data.error){
            reject(event.data.error);
            return;
        }

        resolve(event.data.response);
    }.bind(this)

    return handler;
}

function isValidResponse(data, event) {
    return event.data && event.data.id === data.id && typeof event.data.response !== 'undefined';
}

function isValidRequest(data, messageHandlers){
    return typeof data === 'object' &&
        typeof data.request !== 'undefiend' &&
        typeof data.id !== 'undefiend' &&
        typeof data.messageName !== 'undefiend' &&
        typeof data.response === 'undefined' &&
        typeof messageHandlers[data.messageName] === 'function'

}

module.exports = Frame;
