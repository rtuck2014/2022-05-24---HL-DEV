import React from 'react'
import ConfirmModal from './confirm-modal.jsx'
import Dispatcher from '../../dispatcher'
import ActionTypes from '../../action-types'

export default class AllRecipientsRemovedModal extends React.Component {
    modalClosed() {
        Dispatcher.dispatch({
            type: ActionTypes.CONFIRM_ALL_RECIPIENTS_REMOVED
        })
    }

    render() {
        return (
            <ConfirmModal title='No more recipients' singleButton={true} callback={this.modalClosed} >
                <p>
                    You have deleted the available recipients, you will not be able to send an email.
                </p>
            </ConfirmModal>
        )
    }
}
