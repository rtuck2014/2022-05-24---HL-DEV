import createCustomEvent from '../../../../js/event-creator.js'
let rootElement

export function getTrackedEmailBody(email, clientType, log){
    var params = {
        body: email.body,
        subject: email.subject,
        messageType: email.messageType,
        recipient: email.recipients[0],
        clientType,
        crmfid: email.crmfid,
        crmRecordType: email.crmRecordType
    }

    return doRemoteAction('getTrackedEmail', params)
        .then(result => result.trackedBody)
}

export function searchForAssignedRecordsByEmail(email){
    return doRemoteAction('findMatchesByEmail', { email })
}

export function setRootElement(element){
    rootElement = element
}

export function searchForRecordType(type, email) {
    return doRemoteAction('findRecentRecord', { type, email })
}

function doRemoteAction(actionName, params){
    return new Promise((resolve, reject) => {
        if(!rootElement){
            reject('Root Element needed to make remote calls')
        }

        const id = `${actionName}_${new Date().getTime()}`

        rootElement.addEventListener('doRemoteActionResponse', function handler(event) {
            var detail = event.detail
            if(detail.id !== id){
                return
            }

            rootElement.removeEventListener('doRemoteActionResponse', handler)

            if(detail.result){
                resolve(detail.result)
            } else {
                reject(detail.error)
            }
        }, true)

        let name = 'doRemoteActionRequest'
        let detail = {
            id,
            params,
            actionName,
        }
        let event = createCustomEvent(name, detail)

        rootElement.dispatchEvent(event)
    })
}

export default {
    getTrackedEmailBody,
    searchForAssignedRecordsByEmail,
    setRootElement,
    searchForRecordType
}
