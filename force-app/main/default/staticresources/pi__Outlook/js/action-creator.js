import Dispatcher from './dispatcher'
import ActionTypes from './action-types'

let OutlookActionCreators = {
    sendEmailWithoutWarning(){
        Dispatcher.dispatch({
            type: ActionTypes.SEND_TRACKED_EMAIL_AND_NOT_SHOW_WARNING_AGAIN
        });
    },
    continueSendingEmail(){
        Dispatcher.dispatch({
            type: ActionTypes.CONTINUE_SENDING_EMAIL
        });
    },
    cancelWarning(){
        Dispatcher.dispatch({
            type: ActionTypes.CLICK_WARNING_CANCEL
        });
    },
    selectFromMultipleRecords(people){
        Dispatcher.dispatch({
            type: ActionTypes.MULTIPLE_PEOPLE_FOUND_FOR_EMAIL,
            people: people
        });
    },
    clickCancel(target){
        Dispatcher.dispatch({
            type: ActionTypes.CLICK_CANCEL,
            target: target
        });
    }
};

export default OutlookActionCreators;
