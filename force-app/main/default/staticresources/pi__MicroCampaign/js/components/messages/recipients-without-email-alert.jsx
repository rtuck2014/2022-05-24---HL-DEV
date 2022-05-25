import React from 'react'
import PropTypes from 'prop-types'
import Alert from './alert.jsx'
import RecipientsWithoutEmailModal from './recipients-without-email-modal.jsx'

export default class RecipientsWithoutEmailAlert extends React.Component {
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
            recipients
        } = this.props

        let numRecipients = recipients.length
        let recipientStr, numOfThe, dont

        if (numRecipients > 1) {
            numOfThe = `${numRecipients} of the`
            recipientStr = 'recipients'
            dont = 'don\'t'
        } else {
            numOfThe = 'The'
            recipientStr = 'recipient'
            dont = 'doesn\'t'
        }

        return (
            <Alert type={Alert.Types.Warning} closeCallback={this.close.bind(this)}>
                <span>
                    {`${numOfThe} ${recipientStr} you selected ${dont} have an email address listed, `}
                </span>
                <a onClick={this.alertClicked.bind(this)}>
                    find out why.
                </a>
                {this.renderModal()}
            </Alert>
        )
    }

    renderModal() {
        if (!this.state.showingModal) {
            return null
        }

        return <RecipientsWithoutEmailModal recipients={this.props.recipients} type={this.props.type} onClose={this.toggleModal.bind(this)} />
    }
}

RecipientsWithoutEmailAlert.propTypes = {
    recipients: PropTypes.array.isRequired,
    type: PropTypes.string.isRequired
}
