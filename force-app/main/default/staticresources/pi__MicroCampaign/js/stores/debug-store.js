import { Store } from 'flux/utils'
import Dispatcher from '../dispatcher'
import ActionTypes from '../action-types'

let data = {
    logs: []
}

class DebugStore extends Store {
    get() {
        return data
    }

    __onDispatch(action) {
        const a = ActionTypes

        switch (action.type) {
            case a.DEBUG_LOG:
                data.logs.push(action.args)
                break
            case a.CLEAR_LOGS:
                data.logs = []
                break
            default:
                let args = [
                    'Dispatched',
                    action
                ]
                data.logs.push(args)
                break
        }

        this.__emitChange()
    }
}

export default new DebugStore(Dispatcher)
