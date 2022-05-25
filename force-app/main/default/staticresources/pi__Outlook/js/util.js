import util from '../../../js/util'

export function getParentOrigin() {
    let matches = window.location.search.match(/parentOrigin=([^&]*)/)
    if(matches) {
        return window.decodeURIComponent(matches[1])
    }
}

export function setTimeoutPromise(timeout = 0) {
    return new Promise(resolve => window.setTimeout(resolve, timeout))
}

export function getOrigin(){
    return util.getLocationOrigin()
}
