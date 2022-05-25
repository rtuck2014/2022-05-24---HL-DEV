import Frame from '../frame'
import { getParentOrigin } from '../util'
let outlookFrame;

export function getEmailFields(){
    return getOutlookFrame().please('getEmailFields')
}

export function getRoamingSettings(keys) {
    return getOutlookFrame().please('getRoamingSettings', keys)
}

export function setRoamingSettings(settings) {
    return getOutlookFrame().please('setRoamingSettings', settings)
}

export function sendTrackedEmail(email, startTime) {
    return getOutlookFrame()
        .please('sendTrackedEmail', { email, startTime })
        .then((result) => {
            throw result
        })
}

export function setupComplete(){
    return getOutlookFrame().please('setupComplete')
}


export function trackEvent(action, label){
    getOutlookFrame().please('trackEvent', { action, label })
}

export function redirectToUnlicensedPage() {
    getOutlookFrame().please('redirectToUnlicensedPage')
}

export function openUrlInNewWindow(params = {}) {
    getOutlookFrame().please('openURL', params)
}

function getOutlookFrame() {
    if (!outlookFrame) {
        outlookFrame = new Frame(window.parent, getParentOrigin())
    }

    return outlookFrame
}

export function trackEvent(action, label){
    getOutlookFrame().please('trackEvent', { action, label })
}

export function redirectToUnlicensedPage() {
    getOutlookFrame().please('redirectToUnlicensedPage')
}

export function log() {
    getOutlookFrame().please('log', Array.prototype.slice.call(arguments))
}

export function toggleLogs() {
    getOutlookFrame().please('toggleLogs')
}

export function setOrgId(orgId) {
    let orgIdSet = false

    let sendOrgId = () => {
        getOutlookFrame().please('setOrgId', orgId).then(() => {
            orgIdSet = true
        })
    }

    let ensureOrgIdSet = () => {
        if(!orgIdSet) {
            sendOrgId()
            window.setTimeout(ensureOrgIdSet, 1000)
        }
    }

    ensureOrgIdSet()
}

export function getHostInfo() {
    return getOutlookFrame().please('getHostInfo')
}

export function reload() {
    getOutlookFrame().please('reload')
}

export function exit() {
    getOutlookFrame().please('exit')
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
    exit,
    openUrlInNewWindow
}
