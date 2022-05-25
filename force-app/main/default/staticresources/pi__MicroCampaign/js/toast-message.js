/**
  For all supported params in lightning toast messages, see:
    https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/ref_force_showToast.htm

  The React component may not support all the same params. These need to implemented one by one.
*/
import 'babel-polyfill'
import React from 'react'
import ReactDOM from 'react-dom'
import { Toast } from './salesforce-lightning-design-system';
var element;

export const Types = {
    Default: 'default',
    Success: 'success',
    Error: 'error',
    Warning: 'warning'
}

export function showToast(params = {}) {
    return new Promise((resolve, reject) => {
        if (canShowLightningToastMessage()) {
            sendShowToastEvent(params, resolve);
        } else {
            renderToastMessageReactComponent(params, resolve);
        }
    });
}

export function setElementForSFDCClassicToastMessage(el) {
    element = el;
}

export function canShowLightningToastMessage() {
    return typeof SfdcApp === 'object'
        && typeof SfdcApp.projectOneNavigator === 'object'
        && typeof SfdcApp.projectOneNavigator.fireContainerEvent === 'function'
}

function sendShowToastEvent(params, callback) {
    setupDefaultParams(params);

    // message param is required in force:showToast
    if (params.title && ! params.message) {
        params.message = params.title
        delete params.title
    }

    /**
        At the time of this writing, SfdcApp.projectOneNavigator.fireContainerEvent() is an undocumented function
        and is not officially supported by salesforce. See:
        https://gus.my.salesforce.com/_ui/core/chatter/groups/GroupProfilePage?g=0F9B000000006kI&fId=0D5B0000007ipwB&s1oid=00DT0000000Dpvc&OpenCommentForEdit=1&emkind=chatterCommentNotification&s1nid=000000000000000&emtm=1469465821310&s1uid=005B00000016AcX&s1ext=0
    */
    try {
        SfdcApp.projectOneNavigator.fireContainerEvent('force:showToast', params);
        callback();
    } catch (e) {
        renderToastMessageReactComponent(params, callback);
    }
}

function renderToastMessageReactComponent(params, resolve) {
    if (!element) {
        throw 'No element set for toastMessage.showToast(). Use toastMessage.setElementForSFDCClassicToastMessage(element)';
    }

    setupDefaultParams(params);
    renderReactComponentToElement(element, params, resolve);
}

function renderReactComponentToElement(element, params, onCloseCallback) {
    let component = <Toast {...params} onClose={onCloseCallback} />;
    ReactDOM.render(component, element);
}

function setupDefaultParams(params) {
    if (!params.type || !isValidType(params.type)) {
        params.type = Types.Default;
    }

    if (!params.duration) {
        params.duration = 5000;
    }

    if (typeof params.collapsed === 'undefined') {
        params.collapsed = false;
    }
}

function isValidType(type) {
    return Object.keys(Types).filter(t => Types[t] === type).length === 1
}

export default {
    canShowLightningToastMessage,
    showToast,
    setElementForSFDCClassicToastMessage,
    Types
}
