import React from 'react';
import ConfirmModal from './confirm-modal.jsx';
import Dispatcher from '../../dispatcher'
import ActionTypes from '../../action-types'

export default class SalesforceTagsErrorModal extends React.Component {
    confirmClicked() {
        Dispatcher.dispatch({
            type: ActionTypes.CONFIRM_SALESFORCE_TAGS
        })
    }

    render() {
        return (
            <ConfirmModal title='Error Sending Email'
                callback={this.confirmClicked} singleButton={true}>

                <p>
                    It looks like you are using Salesforce merge fields in your email,
                    however the email is being sent using Pardot's marketing template format.
                    Please use Pardot variable tags instead. For more information about Pardot
                    variable tags check out:

                    <a href='http://www.pardot.com/faqs/emails/variable-tags/' target='_blank'>
                        http://www.pardot.com/faqs/emails/variable-tags/
                    </a>
                </p>
            </ConfirmModal>
        )
    }
}
