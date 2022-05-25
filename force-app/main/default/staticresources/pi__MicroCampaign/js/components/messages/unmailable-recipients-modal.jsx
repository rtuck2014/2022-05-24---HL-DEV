import React from 'react'
import PropTypes from 'prop-types'
import RecipientsErrorModal from './recipients-error-modal.jsx'

export default class UnmailableRecipientsModal extends React.Component {
    constructor(props) {
        super(props)
    }

    getTitle() {
        let {type, unmailableRecipients} = this.props
        return `Unmailable ${type}${unmailableRecipients.length > 1 ? 's' : ''}`
    }

    getMessage() {
        let {type, unmailableRecipients} = this.props

        let singulars = [
            'This',
            type,
            'is',
            'It',
            'has'
        ]

        let plurals = [
            'These',
            `${type}s`,
            'are',
            'They',
            'have'
        ]

        let l = unmailableRecipients.length > 1 ? plurals : singulars

        return `${l[0]} ${l[1]} ${l[2]} unmailable. ${l[3]} ${l[4]}
        been removed from the list for one or more of the following reasons:`
    }

    getReasons() {
        let singulars = [
            'Has',
            'Was',
        ]

        let plurals = [
            'Have',
            'Were'
        ]

        let l = this.props.unmailableRecipients.length > 1 ? plurals : singulars

        return (
            <ul className='slds-list'>
                <li>{l[0]} been opted out of email communication in Pardot</li>
                <li>{l[1]} imported and globally opted out</li>
                <li>{l[1]} manually marked as "Do Not Mail"</li>
                <li>Had a hard bounce (or 5 soft bounces) when emailed through Pardot</li>
                <li>Corresponding prospect record in Pardot is archived</li>
            </ul>
        )
    }

    getTagline() {
        return (
            <div>
                <div className='slds-text-heading--small'>
                    {this.getMessage()}
                </div>
                <div className='slds-m-top--medium'>
                    {this.getReasons()}
                </div>
            </div>
        )
    }

    render() {
        let {
            unmailableRecipients,
            type
        } = this.props

        let useLargeModal = true;
        if (unmailableRecipients.length <= 6) {
            useLargeModal = false;
        }

        return (
            <RecipientsErrorModal title={this.getTitle()} large={useLargeModal} recipients={unmailableRecipients}
                type={type} tagline={this.getTagline()} onClose={this.props.onClose} />
        )
    }
}

UnmailableRecipientsModal.propTypes = {
    unmailableRecipients: PropTypes.array.isRequired,
    type: PropTypes.string.isRequired,
    onClose: PropTypes.func
}
