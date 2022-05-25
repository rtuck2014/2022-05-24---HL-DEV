import React from 'react'
import Dispatcher from '../../dispatcher'
import ActionTypes from '../../action-types'
import ConfirmModal from './confirm-modal.jsx'

export default class PreviewErrorModal extends React.Component {
    onClose() {
        Dispatcher.dispatch({
            type: ActionTypes.CLOSE_PREVIEW_ERROR_MODAL
        });
    }

    render() {
        return (
            <ConfirmModal title='Preview Unavailable' singleButton={true} callback={this.onClose}>
                <p className="slds-p-around_medium">
                    You cannot preview this recipient because there was an error syncing.
                </p>
            </ConfirmModal>
        )
    }
}
