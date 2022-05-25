import React from 'react'
import PropTypes from 'prop-types'
import Dispatcher from '../../dispatcher'
import ActionTypes from '../../action-types'
import ConfirmModal from './confirm-modal.jsx'
import { capitalize } from '../../util'
import { SendOnBehalfOfOptions } from '../../constants'
import Svg from '../../salesforce-lightning-design-system'

export default class UnsoboableSendWarningModal extends React.Component {
    render() {
        let {
            soboStatusByRecipientId,
            selected
        } = this.props

        const sendClicked = () => {
            Dispatcher.dispatch({
                type: ActionTypes.CLICK_UNSOBOABLE_WARNING_SEND
            })
        }

        const cancelClicked = () => {
            Dispatcher.dispatch({
                type: ActionTypes.CANCEL_UNSOBOABLE_WARNING
            })
        }

        const recipientsLinkClicked = (event) => {
            event.preventDefault()
            Dispatcher.dispatch({
                type: ActionTypes.SHOW_UNSOBOABLE_MODAL_CLICKED,
                fromWarningModal: true
            })
        }

        let modalProps = {
            title: 'Are you sure you want to send?',
            confirmText: 'Send',
            callback: sendClicked,
            cancelCallback: cancelClicked
        }

        let numUnsoboables = Object.values(soboStatusByRecipientId).reduce((total, recipient) => {
            return total + !recipient.canSobo
        }, 0)

        let s = numUnsoboables > 1 ? 's' : ''
        let the = numUnsoboables > 1 ? '' : 'the '

        return (
            <ConfirmModal {...modalProps}>
                <p>
                    <span>You don't have permission to send as {selected} to </span>
                    <a onClick={recipientsLinkClicked}>{numUnsoboables} recipient{s}</a>
                    <span>. </span>
                    <span>
                        Your email address (instead of the {selected}'s) will be used for sender. Remove {the}
                        recipient{s} if you don't want to be listed as the sender.
                    </span>
                </p>
            </ConfirmModal>
        )
    }
}

UnsoboableSendWarningModal.propTypes = {
    soboStatusByRecipientId: PropTypes.object.isRequired,
    selected: PropTypes.string.isRequired
}
