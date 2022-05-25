import React from 'react'
import PropTypes from 'prop-types'
import ConfirmModal from './confirm-modal.jsx'
import Dispatcher from '../../dispatcher'
import ActionTypes from '../../action-types'

export default class AllRecipientsOptedOutModal extends React.Component {
    modalClosed() {
        Dispatcher.dispatch({
            type: ActionTypes.CONFIRM_ALL_RECIPIENTS_OPTED_OUT
        })
    }

    render() {
        let { recipientType } = this.props

        return (
            <ConfirmModal title={`No mailable ${recipientType}s`} singleButton={true} callback={this.modalClosed} >
                <p>
                    All of the {recipientType}s you've selected have opted out of emails or have corresponding prospect records in Pardot that are archived.
                </p>
            </ConfirmModal>
        )
    }
}

AllRecipientsOptedOutModal.propTypes = {
    recipientType: PropTypes.string.isRequired
}
