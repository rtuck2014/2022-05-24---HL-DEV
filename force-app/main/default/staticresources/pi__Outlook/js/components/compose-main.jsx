import React from 'react'
import SendTrackedEmailButton from './send-tracked-email-button.jsx'
import PreSendError from './pre-send-error.jsx'
import PostSendError from './post-send-error.jsx'
import LoggedInUser from './logged-in-user.jsx'
import MultipleMatches from './multiple-matches.jsx'
import ConfirmBeforeSending from './confirm-before-sending.jsx'
import InnerLink from './inner-link.jsx'
import CreateRecord from './create-record.jsx'

export default class ComposeMain extends React.Component {
    render() {
        return (
            <div className='slds'>
                <ConfirmBeforeSending />
                <PreSendError />
                <PostSendError />
                <MultipleMatches />
                <CreateRecord />
                <SendTrackedEmailButton packageNamespace={this.props.packageNamespace} />
                <div className='slds-text-body--small spaced'>
                    <p>
                        Track clicks and opens to individual recipients using the "Send Tracked Email" button.
                    </p>
                </div>
                <InnerLink href="http://www.pardot.com/products/salesforce-engage/">
                    <div className='slds-text-body--small'>
                        Salesforce Engage for Outlook Add-In.
                    </div>
                </InnerLink>
                <LoggedInUser />
            </div>
        )
    }
}
