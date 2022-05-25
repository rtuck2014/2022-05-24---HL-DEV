import React from 'react'
import PropTypes from 'prop-types'
import RecipientsErrorModal from './recipients-error-modal.jsx'

export default class UnmailableRecipientsModal extends React.Component {
    constructor(props) {
        super(props)
    }

    getTitle() {
        let {
            type,
            duplicateRecipients
        } = this.props

        let typeString = type
        if (duplicateRecipients.length > 1) {
            typeString += 's'
        }

        return `Duplicate Email ${typeString}`
    }

    getTagline() {
        let records
        let they
        let contain

        if (this.props.duplicateRecipients.length > 1) {
            records = 'records'
            they = 'they'
            contain = 'contain'
        } else {
            records = 'record'
            they = 'it'
            contain = 'contains'
        }

        return `The following ${records} cannot be sent in the Engage campaign because ${they} ${contain}
        the same email address as another record in the same Engage campaign.`
    }

    render() {
        let {
            duplicateRecipients,
            type
        } = this.props

        let useLargeModal = true;
        if (duplicateRecipients.length <= 6) {
            useLargeModal = false;
        }

        return (
            <RecipientsErrorModal title={this.getTitle()} large={useLargeModal} recipients={duplicateRecipients}
                type={type} tagline={this.getTagline()} onClose={this.props.onClose} />
        )
    }
}

UnmailableRecipientsModal.propTypes = {
    duplicateRecipients: PropTypes.array.isRequired,
    type: PropTypes.string.isRequired,
    onClose: PropTypes.func
}
