import Dispatcher from './dispatcher'
import ActionTypes from './action-types'

export const debugLog = (...args) => setTimeout(() => {
    console.log.apply(console, args)
    Dispatcher.dispatch({
        type: ActionTypes.DEBUG_LOG,
        args
    })
})

export const clearLogs = () => Dispatcher.dispatch({
    type: ActionTypes.CLEAR_LOGS
})
