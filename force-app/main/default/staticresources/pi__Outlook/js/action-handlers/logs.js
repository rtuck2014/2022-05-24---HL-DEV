import ActionTypes from '../action-types'
import Dispatcher from '../dispatcher'
import ComposeWrapper from '../outlook-wrapper'

Dispatcher.register(action => {
    if(action.type === ActionTypes.TOGGLE_LOGS){
        ComposeWrapper.toggleLogs()
    } else if(action.type === ActionTypes.LOG){
        ComposeWrapper.log.apply(null, action.arguments)
    }
})
