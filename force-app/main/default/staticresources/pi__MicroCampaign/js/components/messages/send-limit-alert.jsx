import React from 'react'
import PropTypes from 'prop-types'
import Alert from './alert.jsx'
import {
    MaximumEngageEmailRecipients,
} from '../../constants';

export default class SendLimitAlert extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            hidden: false
        }
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
            remaining,
            total,
            resetMessage,
            numberOfRecipients
        } = this.props

        let amountOver = (remaining - numberOfRecipients) * -1

        let type, statusText

		let maxRecipients = remaining ? remaining : MaximumEngageEmailRecipients;

        if (numberOfRecipients > maxRecipients) {
            statusText = `Can't send email to more than ${maxRecipients} recipients. Remove some recipients.`
            type = Alert.Types.Error
        } else if (remaining < 1) {
            statusText = `You have reached your daily email send limit of ${total}. Your limit will reset ${resetMessage}`
            type = Alert.Types.Error
        } else if (amountOver > 0) {
            let s = amountOver == 1 ? '' : 's'
            statusText = `You have selected ${amountOver} more email${s} than you are allowed to send today. Please delete ${amountOver} recipient${s} to send your campaign.`
            type = Alert.Types.Error
        } else {
            statusText = `You can send ${remaining} more emails today.`

            if (remaining < 0.33 * total) {
                type = Alert.Types.Error
            } else if (remaining >= 0.33 * total && remaining < 0.66 * total) {
                type = Alert.Types.Warning
            } else {
                type = Alert.Types.Success
            }
        }

        return (
            <Alert type={type} closeCallback={this.close.bind(this)}>
                {statusText}
            </Alert>
        )
    }
}

SendLimitAlert.propTypes = {
    remaining: PropTypes.number,
    total: PropTypes.number,
    resetMessage: PropTypes.string,
    numberOfRecipients: PropTypes.number
}
