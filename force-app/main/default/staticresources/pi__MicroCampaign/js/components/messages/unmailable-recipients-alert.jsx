import React from 'react'
import PropTypes from 'prop-types'
import Alert from './alert.jsx'
import UnmailableRecipientsModal from './unmailable-recipients-modal.jsx'

export default class UnmailableRecipientsAlert extends React.Component {
    constructor(props) {
        super(props)

        this.state = {
            showingModal: false,
            hidden: false
        }
    }

    alertClicked(event) {
        event.preventDefault()
        this.toggleModal()
    }

    toggleModal() {
        this.setState({
            showingModal: !this.state.showingModal
        })
    }

    close() {
        this.setState({
            hidden: true
        })
    }

    render() {
        if (this.state.hidden) {
            return null
        }

        let {
            unmailableRecipients
        } = this.props

        let numRecipients = unmailableRecipients.length
        let recipients, are, have

        if (numRecipients > 1) {
            recipients = 'recipients'
            are = 'are'
            have = 'have'
        } else {
            recipients = 'recipient'
            are = 'is'
            have = 'has'
        }

        return (
            <Alert type={Alert.Types.Warning} closeCallback={this.close.bind(this)}>
                <span>
                    {`${numRecipients} ${recipients} you selected ${are} unmailable and ${have} been removed from the list. `}
                </span>
                <a onClick={this.alertClicked.bind(this)}>
                    {`Show removed ${recipients}`}
                </a>
                {this.renderModal()}
            </Alert>
        )
    }

    renderModal() {
        if (!this.state.showingModal) {
            return null
        }

        return <UnmailableRecipientsModal unmailableRecipients={this.props.unmailableRecipients} type={this.props.type} onClose={this.toggleModal.bind(this)} />
    }
}

UnmailableRecipientsAlert.propTypes = {
    unmailableRecipients: PropTypes.array.isRequired,
    type: PropTypes.string.isRequired
}
