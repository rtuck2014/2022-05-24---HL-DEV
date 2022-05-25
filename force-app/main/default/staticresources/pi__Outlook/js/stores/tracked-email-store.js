import { Store } from 'flux/utils'
import ActionTypes from '../action-types'
import Dispatcher from '../dispatcher'
import Api from '../api'
import ComposeWrapper from '../outlook-wrapper'
import { cancellableSequence } from '../store-helper'
import { setTimeoutPromise } from '../util'

const SEQUENCE = {
    GET_EMAIL_FIELDS: 'GET_EMAIL_FIELDS',
    SEARCH_FOR_RECORDS: 'SEARCH_FOR_RECORDS',
    CHECK_IF_SEND_WARNING_CONFIRMED: 'CHECK_IF_SEND_WARNING_CONFIRMED',
    GET_TRACKED_EMAIL_BODY: 'GET_TRACKED_EMAIL_BODY',
    SEND_EMAIL: 'SEND_EMAIL'
}

const ERROR_CODES = {
    PRE_SEND_ERROR: 0,
    POST_SEND_ERROR: 1
}

let _data = {
    isSending: false,
    sendingComplete: false,
    trackedEmailBody: null,
    recordCreate: {
        needsRecordCreated: false,
        searchingForNewRecords: false,
        searchingForNewRecordsComplete: false,
        newRecords: []
    },
    people: [],
    email: null,
    emailFields: {
        subject: null,
        body: null,
        recipients: [],
        messageType: null,
        crmfid: null,
        crmRecordType: null
    },
    postSendError: null,
    preSendError: null,
    hostInfo: {
        hostName: null,
        hostVersion: null
    },
    warning: false,
    info: false,
    selectedRecordId: ''
}

class TrackedEmailStore extends Store {
    get() {
        return _data
    }

    __onDispatch(action) {
        const a = ActionTypes

        switch (action.type) {
            case a.CLICK_EXIT:
              this._exitClicked()
              break;
            case a.CLICK_SEND_TRACKED_EMAIL:
                this._sendTrackedEmailClicked()
                break
            case a.CLICK_ERROR_CLEAR:
                _data.preSendError = null
                _data.postSendError = null
                this.__emitChange()
                break
            case a.CLICK_CANCEL:
                switch (action.target){
                    case 'warning':
                        _data.warning = false;
                        break;
                    case 'info':
                        _data.info = false;
                }
                _data.isSending = false;
                this.__emitChange()
                break
            case a.CLICK_CONFIRM_SEND:
                this._confirmSendClicked(action.startTime, action.rememberDoNotShowWarning)
                break
            case a.CLICK_SEARCH_FOR_NEW_RECORD:
                this._searchForNewRecords(action.recordType)
                break
            case a.CLICK_CONFIRM_RECORD:
                this._confirmRecordClick(action.recordId)
                break
            case a.CLICK_SELECT_RECORD:
                this._selectRecordClick(action.recordId)
                break
            case a.CLICK_CANCEL_RECORD_CREATE:
                this._cancelRecordCreateClicked()
                break
            case a.TRACKED_EMAIL_ASYNC_DATA_RECEIVED:
                this._asyncDataReceived(action.data)
                break
        }
    }

    _exitClicked() {
        ComposeWrapper.exit()
    }

    _sendTrackedEmailClicked() {
        _data.isSending = true
        this.__emitChange()

        this._startSendTrackedEmailSequence()
    }

    _confirmSendClicked(startTime, rememberDoNotShowWarning) {
        _data.isSending = true
        _data.warning = false
        this.__emitChange()

        this._startSendTrackedEmailSequence(SEQUENCE.GET_TRACKED_EMAIL_BODY)

        if(rememberDoNotShowWarning) {
            rememberDoNotShowSendWarning()
        }
    }

    _confirmRecordClick(recordId) {
        let newRecord = _data.recordCreate.newRecords
            .filter(record => record.id === recordId)[0]

        _data.people = [newRecord]
        _data.recordCreate.needsRecordCreated = false
        _data.recordCreate.newRecords = []
        this.__emitChange()

        this._startSendTrackedEmailSequence(SEQUENCE.CHECK_IF_SEND_WARNING_CONFIRMED)
    }

    _selectRecordClick(recordId) {
        let selectedRecord = _data.people
            .filter(record => record.id === recordId)[0]

        _data.people = [selectedRecord]
        _data.isSending = true;
        _data.info = false;
        this.__emitChange();

        this._startSendTrackedEmailSequence(SEQUENCE.CHECK_IF_SEND_WARNING_CONFIRMED)
    }

    _searchForNewRecords(recordType) {
        _data.recordCreate.searchingForNewRecords = true
        _data.recordCreate.searchingForNewRecordsComplete = false
        this.__emitChange()

        let search = (attempts = 1) => {
            return Api.searchForRecordType(recordType, _data.email)
                .then((records) => {
                    if(records.length || attempts === 3) {
                        return records
                    }

                    return setTimeoutPromise(1000).then(() => {
                        return search(++attempts)
                    })
                })
        }

        search()
            .then((records) => {
                _data.recordCreate.searchingForNewRecords = false
                _data.recordCreate.searchingForNewRecordsComplete = true
                _data.recordCreate.newRecords = mapRecordsToPeople(records, recordType, _data.email)
                dispatchChanges()
            })
    }

    _startSendTrackedEmailSequence(skipTo = null) {
        let startTime = new Date()

        let chain = [
            {
                getPromise: () => getMappedEmailFields(),
                exitIf: () => _data.preSendError || _data.postSendError,
                name: SEQUENCE.GET_EMAIL_FIELDS
            },
            {
                getPromise: () => searchForRecords(startTime),
                exitIf: () => _data.recordCreate.needsRecordCreated || _data.info,
                name: SEQUENCE.SEARCH_FOR_RECORDS
            },
            {
                getPromise: () => checkIfSendWarningConfirmed(startTime),
                exitIf: () => _data.warning,
                name: SEQUENCE.CHECK_IF_SEND_WARNING_CONFIRMED
            },
            {
                getPromise: () => getTrackedEmailBody(startTime),
                exitIf: () => !_data.trackedEmailBody,
                name: SEQUENCE.GET_TRACKED_EMAIL_BODY
            },
            {
                getPromise: () => sendTrackedEmail(startTime),
                name: SEQUENCE.SEND_EMAIL
            }
        ]

        cancellableSequence({
            afterEach: dispatchChanges,
            chain,
            skipTo
        })
    }

    _asyncDataReceived(data) {
        _data = Object.assign(_data, data)
        this.__emitChange()
    }

    _cancelRecordCreateClicked() {
        _data.recordCreate = {
            needsRecordCreated: false,
            searchingForNewRecords: false,
            searchingForNewRecordsComplete: false,
            newRecords: []
        }
        _data.isSending = false

        this.__emitChange()
    }

}

function dispatchChanges() {
    Dispatcher.dispatch({
        type: ActionTypes.TRACKED_EMAIL_ASYNC_DATA_RECEIVED,
        data: _data
    })
}

function exit() {
    throw EXIT_FROM_PROMISE_CHAIN
}

function getMappedEmailFields() {
    return ComposeWrapper.getEmailFields()
        .then((emailFields) => {
            _data.emailFields = mapEmailFieldsToEmailTrackingParams(emailFields)

            let result = validate(_data.emailFields)

            if (result.valid) {
                _data.email = _data.emailFields.recipients[0].email
            } else {
                _data.preSendError = result.message
                _data.isSending = false
            }
        })
}

function searchForRecords(startTime) {
    let email = _data.email

    return timePromise('Search for records', Api.searchForAssignedRecordsByEmail(email))
        .then((matches) => {
            matches.prospects = removeSyncedProspects(matches)
            _data.people = mapMatchesToPeople(matches, email)
            if (_data.people.length > 1) {
                _data.info = true;
            }
            _data.recordCreate.needsRecordCreated = _data.people.length === 0
        })
}

function checkIfSendWarningConfirmed(startTime) {
    return ComposeWrapper.getRoamingSettings(['doNotConfirmBeforeSendingTrackedEmail'])
        .then((preference) => {
            if (preference.doNotConfirmBeforeSendingTrackedEmail) {
                _data.isSending = true
                _data.warning = false
            } else {
                _data.warning = true
            }
        })
}

function rememberDoNotShowSendWarning() {
    ComposeWrapper.setRoamingSettings({
        doNotConfirmBeforeSendingTrackedEmail: true
    })
}

function getTrackedEmailBody(startTime) {
    return getHostInfo()
        .then((hostInfo) => {
            let fields = _data.emailFields
            if(_data.people[0].type === 'lead' || _data.people[0].type === 'contact') {
                fields.crmfid = _data.people[0].id;
                fields.crmRecordType = _data.people[0].type;
            }
            let clientType = getClientType(_data.hostInfo.hostName)

            return timePromise('Get tracked email body', Api.getTrackedEmailBody(fields, clientType, log))
                .catch(handleApiError)
        })
        .then((trackedEmailBody) => {
            _data.trackedEmailBody = trackedEmailBody
        })
        .catch(handleUnknownError)
}

function handleUnknownError(error) {
    let err = error.message || error
    _data.preSendError = err
    dispatchChanges()
}

function sendTrackedEmail(startTime) {
    let email = {
        subject: _data.emailFields.subject,
        recipient: _data.emailFields.recipients[0].email,
        body: _data.trackedEmailBody
    }

    return ComposeWrapper.sendTrackedEmail(email, startTime)
        .then(() => {
            _data.sendingComplete = true
        })
        .catch((error) => {
            _data.isSending = false

            if(error.code === ERROR_CODES.POST_SEND_ERROR) {
                _data.postSendError = error.message
            } else {
                _data.preSendError = error.message
            }
        })
}

function getHostInfo() {
    let hostInfo = _data.hostInfo
    if(hostInfo.hostName && hostInfo.hostVersion) {
        return Promise.resolve(hostInfo)
    }

    return ComposeWrapper.getHostInfo()
}

function getClientType(hostName) {
    switch(hostName) {
        case 'Outlook':
            return 'Outlook' + ( getMajorVersion() >= 16 ? '2016' : '2013')
        case 'OutlookWebApp':
        default:
            return 'Outlook365'
    }
}

function getMajorVersion() {
    return _data.hostInfo.hostVersion.split('.')[0]
}

function validate(fields) {
    var valid = true
    var message
    var analyticsMessage
    var tooManyRecipients = false

    if (fields.recipients.length < 1) {
        valid = false
        message = 'You must enter a recipient'
        analyticsMessage = 'No recipients'
    } else if (fields.recipients.length > 1) {
        valid = false
        message = 'Salesforce Engage can only send to one recipient at a time.  Please remove any additional recipients.'
        analyticsMessage = 'More than 1 recipients'
    }

    setTimeout(() => {
        Dispatcher.dispatch({
            type: ActionTypes.SEND_TRACKED_EMAIL_VALIDATION_ERROR,
            analyticsMessage
        })
    })

    return {
        valid,
        message
    }
}

function removeSyncedProspects(matches) {
    return matches.prospects.filter((prospect) => {
        let syncedRecords = ['lead', 'contact']
            .map((type) => {
                return matches[type + 's']
                    .filter(record => {
                        return record.Id === prospect['crm_' + type + '_fid']
                    })
            })
            .reduce((prev, next) => {
                return prev.concat(next)
            }, [])

        return syncedRecords.length === 0
    })
}


function mapMatchesToPeople(matches, email) {
    return ['lead', 'contact', 'prospect']
        .map((type) => {
            return mapRecordsToPeople(matches[type + 's'], type, email)
        })
        .reduce((prev, curr) => {
            return prev.concat(curr)
        }, [])
}

function mapRecordsToPeople(records, type, email) {
    return records
        .map((record) => {
            return mapRecordToPerson(type, email, record)
        })
}

function mapRecordToPerson(type, email, record) {
    return {
        name: mapName(type, record),
        id: record.id || record.Id,
        type,
        email
    }
}

function mapName(type, record) {
    if (type === 'prospect') {
        if (record.first_name && record.last_name) {
            return `${record.first_name} ${record.last_name}`
        } else if (record.first_name) {
            return record.first_name
        } else {
            return record.last_name
        }
    }

    return record.Name
}

function mapEmailFieldsToEmailTrackingParams(fields) {
    return {
        subject: fields.subject,
        body: fields.body,
        recipients: getRecipientsFromOutlookFields(fields),
        messageType: 'html'
    }
}

function getRecipientsFromOutlookFields(fields) {
    return ['to', 'cc', 'bcc']
        .map((fieldName) => {
            return fields[fieldName]
                .map((recipient) => {
                    return {
                        name: recipient.displayName,
                        email: recipient.emailAddress
                    }
                })
        })
        .reduce((prev, next) => {
            return prev.concat(next)
        }, [])
}

function handleApiError(error) {
    log('error occured during api call', error)
    handleUnknownError('An error occurred while communicating with the server')
}

function log() {
    ComposeWrapper.log.apply(null, arguments)
}

function timePromise(name, promise) {
    log(`${name} started`)
    let start = new Date()
    return promise.then((result) => {
        log(`${name} took ${new Date() - start}ms`)
        return result
    })
}

export default new TrackedEmailStore(Dispatcher)
