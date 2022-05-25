import { Dispatcher } from 'flux'
import { isDev } from './util'

class AppDispatcher extends Dispatcher {
    dispatch(action={}){
        if (isDev()) {
            console.log(`Dispatched ${action.type}`, action);
        }
        super.dispatch(action);
    }
}

export default new AppDispatcher();
