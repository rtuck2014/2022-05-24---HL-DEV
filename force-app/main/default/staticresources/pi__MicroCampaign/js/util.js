import HtmlConverter from '../../../js/html_converter'
import { Environment, Environments } from './constants'
import { uiDebug } from '../../../js/config-built'
import toastMessage from './toast-message'
import { callAction } from '../../../js/remoting-wrapper';

export function handleEventOnRequestAnimation(element, eventName, callback) {
    let ticking = false

    element.addEventListener(eventName, () => {
        if (!ticking) {
            ticking = true

            window.requestAnimationFrame(() => {
                callback()
                ticking = false
            })
        }
    })
}

export function showToastMessage (message, type) {
    if (!message || !type) {
        return;
    }
    var toastParams = {
        message: message,
        type: type
    };
    if (toastMessage.canShowLightningToastMessage()) {
        toastMessage.showToast(toastParams);
    } else {
        toastMessage.showToast(toastParams).then(() => {});
    }
}

export function setTimeoutPromise(timeout) {
    return new Promise(r => setTimeout(r, timeout))
}

export function capitalize(str) {
    return str[0].toUpperCase() + str.slice(1, str.length)
}

export function lowerCaseFirstLetter(str) {
    return str[0].toLowerCase() + str.slice(1, str.length)
}

export function getFirstObjectKeyWithValue(obj, val) {
    return Object.keys(obj).find(key => obj[key] === val)
}

export function flatArraysEqual(arr1, arr2) {
    if (arr1.length !== arr2.length) {
        return false
    }

    // make copy of arr2, which will have matches removed
    let arr2Copy = arr2.slice()
    for (let i = 0; i < arr1.length; i++) {
        let matchFound = false
        for (let j = 0; j < arr2Copy.length; j++) {
            if (arr1[i] === arr2Copy[j]) {
                // remove matched item at j
                arr2Copy.splice(j, 1)
                matchFound = true
                break
            }
        }

        if (!matchFound) {
            return false
        }
    }

    // arrays are equal if all items have been removed from the copy of the second array
    return arr2Copy.length === 0
}

export function identicalArrays(arr1, arr2) {
    if (arr1 == null && arr2 == null) {
        return true;
    } else if (arr1 == null || arr2 == null || arr1.length != arr2.length) {
        return false;
    }

    for (let i = 0; i < arr1.length; i++) {
        if (arr1[i] != arr2[i]) {
            return false;
        }
    }
    return true;
}

export function isArrayWithElements(arr) {
    return Array.isArray(arr) && arr.length > 0;
}

export function dedupeArray(arr) {
    return arr.reduce((dedupedArr, item) => {
        return dedupedArr.includes(item) ? dedupedArr : dedupedArr.concat(item)
    }, [])
}

export function parsePardotVariableTags(text, pmlValidator = false) {
	let useHML = window.hasHmlEnabled && !pmlValidator;
	let regex;
	if (useHML) {
		regex = /(({)?{{[a-zA-Z0-9._]+}}(})?)/g;
	} else {
		regex = /(%%[a-zA-Z0-9._]+%%)/g;
	}
    // let regex = /(%%[a-zA-Z0-9._]+%%)/g
    let matches = [], found
    // do at least 2 passes in case of overlap: '%%moom%%meem%%' => ['%%moom%%', '%%meem%%']
    while (found = regex.exec(text)) {
        matches.push(found[0]);
		if (useHML) {
			let partialSplit = found[0].split('{{')[1];
			regex.lastIndex -= partialSplit.split('}}')[0].length;
		} else {
			regex.lastIndex -= found[0].split('%%')[1].length;
		}
    }

    return matches
}

export function getCaretCharacterOffsetWithin(element) {
    if (isTextInput(element)) {
        return getCaretCharacterOffsetWithinTextInput(element)
    }

    let caretOffset = 0
    let doc = element.ownerDocument || element.document
    let win = doc.defaultView || doc.parentWindow
    let sel
    if (typeof win.getSelection != 'undefined') {
        sel = win.getSelection()
        if (sel.rangeCount > 0) {
            let range = win.getSelection().getRangeAt(0)
            let preCaretRange = range.cloneRange()
            preCaretRange.selectNodeContents(element)
            preCaretRange.setEnd(range.endContainer, range.endOffset)
            caretOffset = preCaretRange.toString().length
        }
    } else if ((sel = doc.selection) && sel.type != 'Control') {
        let textRange = sel.createRange()
        let preCaretTextRange = doc.body.createTextRange()
        preCaretTextRange.moveToElementText(element)
        preCaretTextRange.setEndPoint('EndToEnd', textRange)
        caretOffset = preCaretTextRange.text.length
    }
    return caretOffset
}

function getCaretCharacterOffsetWithinTextInput(input) {
    if (document.selection) {
        input.focus()
        let selection = document.selection.createRange()
        selection.moveStart('character', -input.value.length)
        return selection.text.length
    } else if (input.selectionStart || input.selectionStart == '0') {
        return input.selectionStart
    }
}

function isTextInput(el) {
    return el.nodeName.toLowerCase() === 'input' && el.getAttribute('type') === 'text'
}

export function setCaretPosition(element, offset = 0) {
    if (isTextInput(element)) {
        setCaretPositionOnTextInput(element, offset)
        return
    }

    let range = document.createRange()
    let sel = window.getSelection()

    //select appropriate node
    let currentNode = null
    let previousNode = null

    for (let i = 0; i < element.childNodes.length; i++) {
        //save previous node
        previousNode = currentNode

        //get current node
        currentNode = element.childNodes[i]

        while (currentNode.childNodes.length > 0) {
            for (let j = 0; j < currentNode.childNodes.length; j++) {
                if (currentNode.childNodes[j].nodeName !== 'svg') {
                    currentNode = currentNode.childNodes[j]
                    break
                }
            }
        }
        //calc offset in current node
        if (previousNode != null) {
            offset -= previousNode.length
        }
        //check whether current node has enough length
        if (offset <= currentNode.length) {
            break
        }
    }
    //move caret to specified offset
    if (currentNode != null) {
        range.setStart(currentNode, offset)
        range.collapse(true)
        sel.removeAllRanges()
        sel.addRange(range)
    }
}

function setCaretPositionOnTextInput(input, pos) {
    if(input.createTextRange){
        var textRange = input.createTextRange()
        textRange.collapse(true)
        textRange.moveEnd('character', pos)
        textRange.moveStart('character', pos)
        textRange.select()
    } else if(input.setSelectionRange){
        input.setSelectionRange(pos,pos)
    }
}

export function htmlToText(html) {
    let converter = new HtmlConverter()
    return converter.toText(html).replace('\n', '')
}

/*ƒ
 * Returns a copy of inputted object, with all keys lowercased, recusively.
 * Will also recusively lowercase keys of objects within nested arrays.
 * @param obj {Any}
 * @return {Any}
*/
export function lowerCaseObjectKeys(obj) {
    if (isArray(obj)) {
        return obj.map(lowerCaseObjectKeys)
    }

    if (!isObject(obj)) {
        return obj
    }

    return Object.keys(obj).reduce((newObj, key) => ({
        ...newObj,
        [key.toLowerCase()]: lowerCaseObjectKeys(obj[key])
    }), {})
}

function isObject(val) {
    return Object.prototype.toString.call(val) === '[object Object]'
}

function isArray(val) {
    return val instanceof Array
}

export function isDev() {
    return Environment === Environments.Dev
}

export function uiDebugEnabled() {
    return uiDebug === true
}

export function getWindowScrollOffset() {
    return Math.max(document.documentElement.scrollTop, window.pageYOffset || 0);
}

export function getWindowHeight() {
    return Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
}
