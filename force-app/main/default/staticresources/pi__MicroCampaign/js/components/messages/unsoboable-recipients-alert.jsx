import React from 'react'
import PropTypes from 'prop-types'
import Alert from './alert.jsx'
import UnsoboableModal from './unsoboable-modal.jsx'
import Dispatcher from '../../dispatcher'
import ActionTypes from '../../action-types'

export default class UnsoboableRecipientsAlert extends React.Component {
    constructor(props) {
        super(props)

        this.state = {
            hidden: false
        }
    }

    render() {
        if (this.state.hidden) {
            return null
        }

        let {
            recipients,
            selected,
            sendingUserPardotEmail,
            soboStatusByRecipientId
        } = this.props

        let numUnsoboables = Object.values(soboStatusByRecipientId).reduce((total, r) => (total + !r.canSobo), 0)

        if (!numUnsoboables || !sendingUserPardotEmail) {
            return null
        }

        let s = numUnsoboables > 1 ? 's' : ''

        const recipientsClicked = (event) => {
            event.preventDefault()
            openModal()
        }

        const close = () => {
            this.setState({
                hidden: true
            })
        }

        return (
            <Alert type={Alert.Types.Warning} closeCallback={close}>
                <span>
                    <span>You don't have permission to send as {selected} to </span>
                    <a onClick={recipientsClicked}> {numUnsoboables} recipient{s}</a>
                    <span>. Unless you remove them, {sendingUserPardotEmail} will be listed as the sender.</span>
                </span>
                 {this.renderModal()}
            </Alert>
        )
    }

    renderModal() {
        if (!this.props.unsoboableModal.showing) {
            return
        }

        let {
            recipients,
            soboStatusByRecipientId,
            selected,
            userFullName
        } = this.props

        let modalProps = {
            recipients,
            soboStatusByRecipientId,
            selected,
            userFullName,
            submitCallback: closeModal,
            cancelCallback: closeModal
        }

        return <UnsoboableModal {...modalProps} />
    }
}

const openModal = () => {
    Dispatcher.dispatch({
        type: ActionTypes.SHOW_UNSOBOABLE_MODAL_CLICKED
    })
}

const closeModal = () => {
    Dispatcher.dispatch({
        type: ActionTypes.CLOSE_UNSOBOABLES_MODAL
    })
}


UnsoboableRecipientsAlert.propTypes = {
    recipients: PropTypes.array.isRequired,
    selected: PropTypes.string.isRequired,
    userFullName: PropTypes.string.isRequired,
    soboStatusByRecipientId: PropTypes.object.isRequired,
    unsoboableModal: PropTypes.object.isRequired
}
