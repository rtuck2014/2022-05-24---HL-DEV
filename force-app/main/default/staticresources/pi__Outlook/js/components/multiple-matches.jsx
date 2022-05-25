import React, {Component, PropTypes} from 'react'
import TrackedEmailStore from '../stores/tracked-email-store'
import Actions from '../action-creator'
import Dispatcher from '../dispatcher'
import DialogBox from './dialog-box.jsx'
import ActionTypes from '../action-types'
import InnerLink from './inner-link.jsx'
import { getOrigin } from '../util'

export default class MultipleMatches extends Component {

    constructor(props){
        super(props)
        this.state = TrackedEmailStore.get()
    }

    componentDidMount(){
        TrackedEmailStore.addListener(() => this.trackedEmailStoreUpdated())
    }

    componentWillUnmount(){
        TrackedEmailStore.removeListener(() => this.trackedEmailStoreUpdated())
    }

    trackedEmailStoreUpdated(){
        this.setState(TrackedEmailStore.get())
    }

    handleCancelClick(){
        Actions.clickCancel('info');
    }
    handleSendClick() {
        Dispatcher.dispatch({
            type: ActionTypes.CLICK_SELECT_RECORD,
            recordId: this.state.selectedRecordId
        })
    }

    setSelectedRecord(selectedRecordId) {
        this.setState({
            selectedRecordId
        }, ()=>{
            console.log(`The selected record is  ${this.state.selectedRecordId}`);
        })
    }

    getTitle() {
        return (
            <div>
                <img src={'https://pi.pardot.com/engage-for-outlook/images/plane_icon.png'} alt='' className='custom-icon'></img>
                &nbsp; Send Tracked Email Now
            </div>
        )
    }

    render(){
        if(this.state.people.length < 2 || !this.state.info){
            return null
        }

        let description = 'We found multiple records for that email. Please select one'
        let buttons = {
            cancel: {
                onClick: this.handleCancelClick,
                text: 'Cancel',
                disabled: false
            },
            confirm: {
                onClick: this.handleSendClick.bind(this),
                text: 'Send',
                disabled: !this.state.selectedRecordId
            }
        }

        return (
            <DialogBox theme='custom-theme' title={this.getTitle()} description={description} buttons={buttons} selectedRecord={this.state.selectedRecordId}>
                    <div className='slds-text-body--small slds-wrap contact-list'>
                        <RecordList people={this.state.people} onSelectRecord={this.setSelectedRecord.bind(this)}/>
                    </div>
            </DialogBox>
        );
    }
}

class RecordList extends Component{

    clickHandler(e) {
        if (typeof this.props.onSelectRecord === 'function') {
            this.props.onSelectRecord(e.target.value);
        }
    }

    getSingleNewRecordElement(record) {
        return (
            <div className='record inline'>
                <InnerLink href={getOrigin() + '/' + record.id} className='record-link'>
                    <span>{record.type}</span>
                    &nbsp;
                    <i className='outlook-icon new-window'></i>
                </InnerLink>
            </div>
        )
    }

    render(){

        return(
            <div>
                {
                    this.props.people
                        .map((record, index)=>
                            <div className="contact-item">
                                <label>
                                    <input key={record.id} type="radio" name="records" value={record.id} onClick={this.clickHandler.bind(this)}/>
                                    &nbsp;
                                    <span className='contact-name'> {record.name} </span>
                                </label>
                                {this.getSingleNewRecordElement(record)}
                            </div>)
                }
            </div>
        );
    }
}