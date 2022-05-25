import { setTimeoutPromise } from '../util'

function getTrackedEmailBody(email){
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            resolve('tracked!!')
        })
    })
}

function searchForAssignedRecordsByEmail(email){
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            resolve({
                prospects: [],
                leads: [],
                contacts: []
            })
        }, 1000)
    })
}

function setRootElement(element){}

function searchForRecordType(recordType, email) {
    return setTimeoutPromise(1000)
        .then(() => {
            // return []
            return [
                {
                    Name: 'Kyle Roxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
                    Id: recordType + '_123',
                    Email: email
                }
            ]
        })
}

export default {
    getTrackedEmailBody,
    searchForAssignedRecordsByEmail,
    setRootElement,
    searchForRecordType
}
