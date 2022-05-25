import React from 'react'
import Dispatcher from '../dispatcher'
import ActionTypes from '../action-types'
import TrackedEmailStore from '../stores/tracked-email-store'
import DialogBox from './dialog-box.jsx'

export default class PreSendError extends React.Component{
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
            type: ActionTypes.CLICK_ERROR_CLEAR
        })
    }
    render() {
        if(!this.state.preSendError){
            return null
        }

        let title = 'Oops, your message was not sent'
        let description = this.state.preSendError
        let buttons = {
            confirm: {
                onClick: this.handleClick,
                text: 'Okay'
            }
        }

        return (
            <DialogBox theme='warning' title={title} description={description} buttons={buttons} />
        )
    }
}
