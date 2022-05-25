import React from 'react'
import PropTypes from 'prop-types'
import Dispatcher from '../../dispatcher'
import ActionTypes from '../../action-types'
import ConfirmModal from './confirm-modal.jsx'

export default class NoRecipientsHaveEmailModal extends React.Component {
    confirmClicked() {
        Dispatcher.dispatch({
            type: ActionTypes.CONFIRM_NO_RECIPIENTS_HAVE_EMAIL
        })
    }

    render() {
        let {
            recipientType
        } = this.props

        if (recipientType == 'Recipient') {
            recipientType = 'recipient';
        }

        return (
            <ConfirmModal title='No mailable recipients' singleButton={true} callback={this.confirmClicked}>
                <p>
                    You must select at least one {recipientType} with a valid email address.
                </p>
            </ConfirmModal>
        )
    }
}

NoRecipientsHaveEmailModal.propTypes = {
    recipientType: PropTypes.string.isRequired
}
