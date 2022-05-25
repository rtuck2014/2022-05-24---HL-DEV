import React from 'react'
import Dispatcher from '../dispatcher'
import ActionTypes from '../action-types'
import TrackedEmailStore from '../stores/tracked-email-store'
import DialogBox from './dialog-box.jsx'
import Actions from '../action-creator'

export default class ConfirmBeforeSending extends React.Component{
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

    handleCheckBoxChanged() {
        this.setState({
            doNotShowChecked: true
        })
    }

    handleCancelClick(){
        Actions.clickCancel('warning');
    }
    handleSendClick() {
        Dispatcher.dispatch({
            type: ActionTypes.CLICK_CONFIRM_SEND,
            rememberDoNotShowWarning: this.state.doNotShowChecked
        })
    }
    render(){
        if(!this.state.warning){
            return null
        }

        let title = 'Send Tracked Email Now'
        let description = 'This action will send your email immediately. Are you sure you want to send this message?'
        let buttons = {
            cancel: {
                onClick: this.handleCancelClick,
                text: 'Cancel'
            },
            confirm: {
                onClick: this.handleSendClick.bind(this),
                text: 'Send'
            }
        }

        return (
            <DialogBox theme='warning' title={title} description={description} buttons={buttons}>
                <label>
                    <input name='checkbox' type='checkbox' ref="doNotShow" onChange={this.handleCheckBoxChanged.bind(this)} />
                    &nbsp; Don't show me this again
                </label>
            </DialogBox>
        )
    }
}
