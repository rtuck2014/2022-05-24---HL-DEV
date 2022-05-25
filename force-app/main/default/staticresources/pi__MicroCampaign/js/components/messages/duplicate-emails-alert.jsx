import React from 'react'
import PropTypes from 'prop-types'
import Alert from './alert.jsx'
import DuplicateEmailsModal from './duplicate-emails-modal.jsx'

export default class DuplicateEmailsAlert extends React.Component {
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
            duplicateRecipients,
            type
        } = this.props

        let num = duplicateRecipients.length
        let recipients
        let are
        let have
        let contain

        if (num > 1) {
            recipients = 'recipients'
            are = 'are'
            have = 'have'
            contain = 'contain'
        } else {
            recipients = 'recipient'
            are = 'is'
            have = 'has'
            contain = 'contains'
        }

        return (
            <Alert type={Alert.Types.Warning} closeCallback={this.close.bind(this)}>
                {`${num} ${recipients} you selected ${contain} the same email address as another record and ${have} been removed from the list. `}
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

        let {
            type,
            duplicateRecipients
        } = this.props

        return <DuplicateEmailsModal type={type} onClose={this.toggleModal.bind(this)} duplicateRecipients={duplicateRecipients}/>
    }
}

DuplicateEmailsAlert.propTypes = {
    duplicateRecipients: PropTypes.array.isRequired,
    type: PropTypes.string.isRequired
}
