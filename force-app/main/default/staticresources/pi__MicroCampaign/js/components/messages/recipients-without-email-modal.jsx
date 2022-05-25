import React from 'react'
import PropTypes from 'prop-types'
import RecipientsErrorModal from './recipients-error-modal.jsx'

export default class RecipientsWithoutEmailModal extends React.Component {
    constructor(props) {
        super(props)
    }

    getTitle() {
        let {
            type,
            recipients
        } = this.props

        return `${type} Issues`
    }

    getTagline() {
        let recipientStr, have

        if (recipients > 1) {
            recipientStr = 'recipients'
            have = 'have'
        } else {
            recipientStr = 'recipient'
            have = 'has'
        }

        return `The ${recipientStr} you've selected ${have} no associated email address:`
    }

    render() {
        let {
            recipients,
            type
        } = this.props

        let useLargeModal = true;
        if (recipients.length <= 6) {
            useLargeModal = false;
        }

        return (
            <RecipientsErrorModal title={this.getTitle()} large={useLargeModal} recipients={recipients}
                type={type} tagline={this.getTagline()} onClose={this.props.onClose} />
        )
    }
}

RecipientsWithoutEmailModal.propTypes = {
    recipients: PropTypes.array.isRequired,
    type: PropTypes.string.isRequired,
    onClose: PropTypes.func
}
