function getEmailFields() {
    return Promise.resolve({
        subject: 'Hello',
        body: 'Hiya',
        to: [
            {
                displayName: 'Kyle Rox',
                emailAddress: 'krox@hotmail.com'
            // },
            // {
            //     displayName: 'Kyle Rox',
            //     emailAddress: 'krox@hostmail.com'
            }
        ],
        cc: [],
        bcc: []
    })
}

function sendTrackedEmail(trackedEmailBody) {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            resolve()
        }, 2000)
    })
}

function setupComplete() {}
function redirectToUnlicensedPage(){}
function log() {}
function toggleLogs() {}
function setOrgId() {}
function reload(){}
function openUrlInNewWindow(){}

function getRoamingSettings(){
    return new Promise(resolve => resolve({}))
}

function setRoamingSettings(){
    return new Promise(resolve => resolve())
}

function getHostInfo(){
    return new Promise(resolve => resolve({
        hostName: 'OutlookWebApp',
        hostVersion: '16.01'
    }))
}

function trackEvent(action, label) {
    console.log('trackEvent', {
        action, label
    })
}

export default {
    getEmailFields,
    redirectToUnlicensedPage,
    sendTrackedEmail,
    setupComplete,
    trackEvent,
    log,
    toggleLogs,
    setOrgId,
    getRoamingSettings,
    setRoamingSettings,
    getHostInfo,
    reload,
    openUrlInNewWindow
}
