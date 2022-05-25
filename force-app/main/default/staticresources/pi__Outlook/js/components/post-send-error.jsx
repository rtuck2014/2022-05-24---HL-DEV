import React from 'react'
import Dispatcher from '../dispatcher'
import ActionTypes from '../action-types'
import TrackedEmailStore from '../stores/tracked-email-store'

export default class PostSendError extends React.Component{
    constructor(props){
        super(props)
        this.state = TrackedEmailStore.get()
    }
    componentWillMount(){
        TrackedEmailStore.addListener(() => this._storeWasUpdated())
    }
    componentWillUnmount(){
        TrackedEmailStore.removeListener(() => this._storeWasUpdated())
    }
    _storeWasUpdated(){
        this.setState(TrackedEmailStore.get())
    }
    handleClick(){
        Dispatcher.dispatch({
            type: ActionTypes.CLICK_EXIT
        })
    }
    render() {
        if(!this.state.postSendError){
            return null
        }

        let title = 'Unable to close window'
        let description = (
            <div>
                <div className='slds-m-bottom--large'>Your message has been sent.</div>
                We are having difficulties closing your compose window.  You will have to discard
                this message manually.
            </div>
        )
        let buttons = {
            confirm: {
                onClick: this.handleClick,
                text: 'Exit'
            }
        }

        return (
            <DialogBox theme='warning' title={title} description={description} buttons={buttons} />
        )
    }
}
