import React from 'react';
import ConfirmModal from './confirm-modal.jsx';
import Dispatcher from '../../dispatcher'
import ActionTypes from '../../action-types'

const infoUrl = 'http://help.pardot.com/customer/portal/articles/2125968-why-is-my-email-sending-disabled-';

export default class EmailBlockedModal extends React.Component {
    confirmClicked() {
        Dispatcher.dispatch({
            type: ActionTypes.CONFIRM_EMAIL_BLOCKED
        })
    }

    render() {
        return (
            <ConfirmModal title='Send Engage Email'
                          confirmText='Ok'
                          singleButton={true}
                          callback={this.confirmClicked}>

                <p>
                    Due to the recent <a href={infoUrl} target='_blank'>email sending suspension</a> on your Pardot account,
                    Engage emails cannot be sent at this time. Please contact your Pardot Administrator for more information.
                    Once sending capabilities are restored, please attempt sending emails again
                </p>
            </ConfirmModal>
        );
    }
}
