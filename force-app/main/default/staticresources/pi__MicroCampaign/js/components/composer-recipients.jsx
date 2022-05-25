import React from 'react'
import PropTypes from 'prop-types'
import ReactDOM from 'react-dom'
import {
    Svg,
    Modal
} from '../salesforce-lightning-design-system'
import Dispatcher from '../dispatcher'
import ActionTypes from '../action-types'

export default class ComposerRecipients extends React.Component {
    constructor(props) {
        super(props)

        this.state = {
            showModal: false,
            removedRecipientIds: []
        }
    }

    render() {
        let { recipients } = this.props
        let total = recipients.length

        return (
            <div className='composer-recipients'>
                <div className='form-control slds-clearfix slds-m-top--x-small'>
                    <label className='label slds-float--left slds-text-align--right slds-p-right--small slds-text-color--weak'>
                        To
                    </label>
                    <div className='control slds-float--right'>
                        <a onClick={this.recipientsLinkClicked.bind(this)}>
                            {total} recipient{total > 1 ? 's' : ''}
                        </a>
                    </div>
                </div>
                {this.renderModal(recipients)}
            </div>
        )
    }

    closeModal(save) {
        let ids = this.state.removedRecipientIds

        this.setState({
            showModal: false,
            removedRecipientIds: []
        }, () => {
            if (save) {
                Dispatcher.dispatch({
                    type: ActionTypes.SUBMIT_REMOVED_RECIPIENTS,
                    ids
                })
            }
        })
    }

    renderModal(recipients) {
        if (!this.state.showModal) {
            return null
        }

        // if we have fewer recipients, show smaller modal
        let useLargeModal = true;

        if (recipients.length <= 6) {
            useLargeModal = false;
        }

        let modalProps = {
            title: 'Engage Campaign Recipients',
            large: useLargeModal,
            confirmButton: {
                text: 'Save',
                callback: this.closeModal.bind(this, true)
            },
            cancelButton: {
                text: 'Cancel',
                callback: this.closeModal.bind(this, false)
            }
        }

        recipients = recipients.filter((recipient) => {
            return !this.state.removedRecipientIds.includes(recipient.id)
        })

        let these, recipientsStr

        if (recipients.length > 1) {
            these = 'these'
            recipientsStr = 'recipients'
        } else {
            these = 'this'
            recipientsStr = 'recipient'
        }

        return (
            <Modal {...modalProps}>
                <div className='slds-text-heading--small slds-text-align--center slds-m-bottom--medium'>
                    <span>
                        We are sending this email to {these} {recipientsStr} <b>individually</b>:
                    </span>
                </div>
                <div className='slds-grid slds-wrap recipients-modal-list slds-p-horizontal--xx-large'>
                    {recipients.map(this.renderRecipient.bind(this))}
                </div>
            </Modal>
        )
    }

    renderRecipient(recipient) {
        return (
            <div className='slds-size--1-of-2' key={recipient.id}>
                <div className='slds-media slds-m-bottom--x-small'>
                    <div className='slds-media__figure'>
                        <button className='slds-button slds-button--icon' onClick={this.removeRecipientClicked.bind(this, recipient.id)} title='Remove Recipient'>
                            <Svg className='slds-button__icon slds-button__icon--small' props={{'aria-hidden': true}} type={Svg.Types.Action} symbol='close' />
                            <span className='slds-assistive-text'>Remove Recipient</span>
                        </button>
                    </div>
                    <div className='slds-media__body'>
                        <div title={recipient.name} className='slds-truncate'>
                            {recipient.name}
                        </div>
                        <div title={recipient.email} className='slds-text-body--small slds-truncate'>
                            {recipient.email}
                        </div>
                    </div>
                </div>
            </div>
        )
    }

    recipientsLinkClicked(event) {
        event.preventDefault()
        this.setState({
            showModal: true,
            removedRecipientIds: []
        })
    }

    removeRecipientClicked(id, event) {
        this.setState({
            removedRecipientIds: [...this.state.removedRecipientIds, id]
        })
    }
}

ComposerRecipients.propTypes = {
    recipients: PropTypes.array.isRequired
}
