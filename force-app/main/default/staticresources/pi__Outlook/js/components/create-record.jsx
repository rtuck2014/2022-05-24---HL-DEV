import React from 'react'
import Dispatcher from '../dispatcher'
import ActionTypes from '../action-types'
import TrackedEmailStore from '../stores/tracked-email-store'
import InnerLink from './inner-link.jsx'
import DialogBox from './dialog-box.jsx'
import { getOrigin } from '../util'

export default class CreateRecord extends React.Component {
    constructor(props) {
        super(props)

        this.state = this.getDefaultState()
    }

    componentWillMount(){
        TrackedEmailStore.addListener(() => this.trackedEmailStoreUpdated())
    }

    componentWillUnmount(){
        TrackedEmailStore.removeListener(() => this.trackedEmailStoreUpdated())
    }

    trackedEmailStoreUpdated(){
        let state = Object.assign({}, this.state, TrackedEmailStore.get())
        console.log('recordType: ', state.recordType)
        this.setState(state)
    }

    getDefaultState() {
        return Object.assign({
            creatingRecord: false,
            recordType: null,
            selectedRecordId: null
        }, TrackedEmailStore.get())
    }

    cancelClicked() {
        this.setState(this.getDefaultState(), () => {
            Dispatcher.dispatch({
                type: ActionTypes.CLICK_CANCEL_RECORD_CREATE
            })
        })
    }

    newLeadClicked() {
        this.newRecordClicked('lead')
    }

    newContactClicked() {
        this.newRecordClicked('contact')
    }

    newRecordClicked(recordType) {
        this.setState({
            creatingRecord: true,
            recordType
        })
    }

    findNewRecordClicked() {
        Dispatcher.dispatch({
            type: ActionTypes.CLICK_SEARCH_FOR_NEW_RECORD,
            recordType: this.state.recordType
        })
    }

    setSelectedRecord(selectedRecordId) {
        this.setState({
            selectedRecordId
        })
    }

    confirmRecordClick() {
        Dispatcher.dispatch({
            type: ActionTypes.CLICK_CONFIRM_RECORD,
            recordId: this.state.selectedRecordId
        })
    }

    getTitle() {
        return (
            <div>
                <i className='fa fa-paper-plane'></i>
                &nbsp; Send Tracked Email Now
            </div>
        )
    }

    getSingleNewRecordElement(record) {
        return (
            <div className='record'>
                <span className='name'> {record.name} </span>
                <InnerLink href={getOrigin() + '/' + record.id}>
                    <span className='type'>{record.type}</span>
                    &nbsp;
                    <i className='outlook-icon new-window'></i>
                </InnerLink>
            </div>
        )
    }

    getMultipleNewRecordsElements() {
        let elements = this.state.recordCreate.newRecords
            .map((record) => {
                return (
                    <li key={record.id}>
                        <label>
                            <input type='radio' name='record' value={record.id} onClick={this.setSelectedRecord.bind(this, record.id)} />
                            {this.getSingleNewRecordElement(record)}
                        </label>
                    </li>
                )
            })
        return (
            <ul>
                {elements}
            </ul>
        )
    }

    render() {
        if(!this.state.recordCreate.needsRecordCreated) {
            return null
        } else if (this.state.recordCreate.newRecords.length > 0) {
            return this.renderConfirmNewRecord()
        } else if (this.state.recordCreate.searchingForNewRecordsComplete) {
            return this.renderNoNewRecordsFound()
        } else if(this.state.recordCreate.searchingForNewRecords) {
            return this.renderFindingNewRecord()
        } else if(this.state.creatingRecord) {
            return this.renderCreatingRecord()
        } else {
            return this.renderCreateRecordLinks()
        }
    }

    renderNoNewRecordsFound() {
        let description = "It looks like it's taking a while to find your newly created record:"

        let buttons = {
            cancel: {
                onClick: this.cancelClicked.bind(this),
                text: 'Cancel'
            },
            confirm: {
                onClick: this.findNewRecordClicked.bind(this),
                text: 'Search Again'
            }
        }

        return (
            <DialogBox theme='brand' title={this.getTitle()} description={description} buttons={buttons} />
        )
    }

    renderCreateRecordLinks() {
        let encodedEmail = window.encodeURIComponent(this.state.email)
        let description = (
            <div>
                <div>We did not find any records with that email.</div>
                <div>Would you like to create a:</div>
            </div>
        )

        return (
            <DialogBox theme='brand' title={this.getTitle()} description={description}>
                <div>
                    <InnerLink onClick={this.newLeadClicked.bind(this)} href={getOrigin() + '/00Q/e?lea11=' + encodedEmail}>
                        <span>Lead </span>
                        <i className='outlook-icon new-window'></i>
                    </InnerLink>
                </div>
                <div>
                    <InnerLink onClick={this.newContactClicked.bind(this)} href={getOrigin() + '/003/e?con15=' + encodedEmail}>
                        <span>Contact </span>
                        <i className='outlook-icon new-window'></i>
                    </InnerLink>
                </div>
            </DialogBox>
        )
    }

    renderConfirmNewRecord() {
        let newRecords = this.state.recordCreate.newRecords
        let description
        let newRecordElement

        if(newRecords.length === 1) {
            description = 'Please confirm that this is your newly created record:'
            let record = newRecords[0]
            newRecordElement = this.getSingleNewRecordElement(record)
            this.state.selectedRecordId = record.id
        } else {
            description = (
                <div>
                    <div>
                        We found multiple records with that email.
                    </div>
                    <div>
                        Please select one:
                    </div>
                </div>
            )
            newRecordElement = this.getMultipleNewRecordsElements()
        }

        let buttons = {
            cancel: {
                onClick: this.cancelClicked.bind(this),
                text: 'No'
            },
            confirm: {
                onClick: this.confirmRecordClick.bind(this),
                text: 'Yes'
            }
        }

        return (
            <DialogBox theme='brand' title={this.getTitle()} description={description} buttons={buttons}>
                {newRecordElement}
            </DialogBox>
        )
    }

    renderCreatingRecord() {
        let description = 'Search for your newly created record:'
        let buttons = {
            cancel: {
                onClick: this.cancelClicked.bind(this),
                text: 'Cancel'
            },
            confirm: {
                onClick: this.findNewRecordClicked.bind(this),
                text: 'Search'
            }
        }

        return (
            <DialogBox theme='brand' title={this.getTitle()} description={description} buttons={buttons} />
        )
    }

    renderFindingNewRecord() {
        let description = 'Searching for your newly created record...'

        return (
            <DialogBox theme='brand' title={this.getTitle()} description={description} />
        )
    }
}
