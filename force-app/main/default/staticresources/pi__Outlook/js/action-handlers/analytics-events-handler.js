import ActionTypes from '../action-types'
import Dispatcher from '../dispatcher'
import { getCompose } from '../outlook-wrapper'

const outlookWrapper = getCompose()

Dispatcher.register(action => {
    if(action.type === ActionTypes.CLICK_SEND_TRACKED_EMAIL){
        outlookWrapper.trackEvent('Click', 'Send tracked email')
    } else if(action.type === ActionTypes.SEND_TRACKED_EMAIL_VALIDATION_ERROR && action.analyticsMessage){
        outlookWrapper.trackEvent('Send tracked email validation error', action.analyticsMessage)
    }
})
