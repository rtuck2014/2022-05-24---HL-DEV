import React from 'react'
import TrackedEmailStore from '../stores/tracked-email-store'
import Dispatcher from '../dispatcher'
import ActionTypes from '../action-types'
import config from '../../../../js/config-built'

export default class SendTrackedEmailButton extends React.Component {
    constructor(props){
        super(props)
        this.state = TrackedEmailStore.get()
    }

    _storeWasUpdated(){
        this.setState(TrackedEmailStore.get())
    }

    componentWillMount(){
        TrackedEmailStore.addListener(() => this._storeWasUpdated())
    }

    componentWillUnmount(){
        TrackedEmailStore.removeListener(() => this._storeWasUpdated())
    }

    handleClick(){
        Dispatcher.dispatch({
            type: ActionTypes.CLICK_SEND_TRACKED_EMAIL
        })
    }

    render(){
        if(this.state.preSendError || this.state.postSendError || this.state.warning || this.state.recordCreate.needsRecordCreated || this.state.info){
            return null
        }

        return this.state.isSending ? this.renderSending() : this.renderNotSending()
    }

    renderSending(){
        let message = this.state.trackedEmailBody ? 'Sending Tracked Email' : 'Preparing Tracking'

        if(this.state.sendingComplete && config.api === 'dev') {
            message = 'Email Successfully Sent!'
        } else {
            message = message + '...'
        }

        return (
            <a className='sending slds-button slds-max-small-button--stretch slds-button--brand'>
                &nbsp; {message}
            </a>
        )
    }

    renderNotSending(){
        return (
            <a onClick={this.handleClick} className='slds-button slds-max-small-button--stretch slds-button--brand' >
                <img src={'https://pi.pardot.com/engage-for-outlook/images/plane_icon.png'} alt='' className='custom-icon'></img>
                &nbsp; Send Tracked Email Now
            </a>
        )
    }
}
