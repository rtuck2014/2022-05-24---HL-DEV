import React from 'react'
import { Svg } from '../salesforce-lightning-design-system'
import { warningIconMarkup } from '../svg'
import {
    parsePardotVariableTags,
    htmlToText,
} from '../util'
import { htmlDecode } from '../decoder'
import { isEdge, isInternetExplorer, isSafari, isFireFox } from '../../../../js/browser-check'
import { UnsupportedUserTags } from '../constants'
import ContentEditable from './content-editable.jsx'
import SubjectInput from './subject-input.jsx'
import { debugLog } from '../actions'
const isMsBrowser = isEdge() || isInternetExplorer()

const SubjectField = ({ isPreviewing, isSoboing, lastCursorPosition, subject, onChange, sendOnBehalfOf }) => {
    let { allOwnersInPardot, recipientPermissions } = sendOnBehalfOf
    let allOwnersNotInPardot = recipientPermissions.loading === false && allOwnersInPardot === false
    let sanitizedSubject = htmlDecode(subject).replace(/\\'/g, "'") || ''
    let unsupportedTags = isSoboing ? getUnsupportedVariableTags(sanitizedSubject) : []

    if (isPreviewing) {
        let text = isSoboing && unsupportedTags.length && allOwnersNotInPardot ? stripUnsupportedTags(sanitizedSubject, unsupportedTags) : sanitizedSubject
        return renderSubjectPreview(text)
    } else {
        return renderEdit(subject, unsupportedTags, lastCursorPosition, isSoboing, onChange, sendOnBehalfOf)
    }
}

export default SubjectField

const renderSubjectPreview = (text) => {
    return (
        <div className="form-control slds-m-top--medium slds-truncate">
            <span className="label slds-float--left slds-text-align--right slds-p-right--small slds-text-color--weak" title={text}>Subject</span>
            <span>{text}</span>
        </div>
    )
}

const renderEdit = (subject, unsupportedTags, lastCursorPosition, isSoboing, onChange, sendOnBehalfOf) => {
    let { allOwnersInPardot, recipientPermissions } = sendOnBehalfOf
    let allOwnersNotInPardot = recipientPermissions.loading === false && allOwnersInPardot === false
    let shouldHighlightUnsupportedTags = isSoboing && unsupportedTags.length && allOwnersNotInPardot
    let errorClass = shouldHighlightUnsupportedTags && isMsBrowser ? 'slds-has-error' : ''

    return (
        <div className={errorClass}>
            <span>
                {(() => {
                    if (shouldHighlightUnsupportedTags && !isMsBrowser) {
                        let props = {
                            subject,
                            unsupportedTags,
                            lastCursorPosition,
                            onChange
                        }
                        return <EditWithHighlightTags {...props} />
                    } else {
                        let props = {
                            initialCursorPosition: lastCursorPosition,
                            onChange(event, lastCursorPosition) {
                                onChange(event.target.value, lastCursorPosition)
                            },
                            subject
                        }
                        return <SubjectInput {...props}/>
                    }
                })()}
            </span>
            {(() => {
                if (!isMsBrowser || !shouldHighlightUnsupportedTags) {
                    return null
                }

                let s = unsupportedTags.length > 1 ? 's' : ''

                return (
                    <div className='slds-form-element__help'>
                        <span>Please correct unsupported tag{s}: </span>
                        {unsupportedTags.map(tag => (
                            <span key={tag}>
                                <b>{tag}</b>
                                <span> </span>
                            </span>
                        ))}
                    </div>
                )
            })()}
        </div>
    )
}

class EditWithHighlightTags extends React.Component {
    render() {
        let { subject, unsupportedTags, lastCursorPosition, onChange } = this.props
        const contentChanged = (event, newLastCursorPosition) => {
            let value = htmlToText(event.target.value)
            if (value === subject) {
                return
            }

            onChange(value, newLastCursorPosition)
        }

        const shouldUpdate = (lastChildren) => {
            let numHighlightedDivs = lastChildren.reduce((total, child) => {
                return total + containsUnsupportedTagRef(child)
            }, 0)

            return unsupportedTags.length !== numHighlightedDivs
        }

        let contentEditableProps = {
            onChange: contentChanged,
            shouldUpdate: shouldUpdate,
            initialCursorPosition: lastCursorPosition,
            suppressLineBreaks: true,
            ref: 'subject'
        }

        let splitText = splitTextByUnsupportedTags(subject, unsupportedTags)
        let safari = isSafari() ? 'safari' : ''

        return (
            <div className={`slds-input highlighted ${safari}`}>
                <ContentEditable {...contentEditableProps} >
                    {splitText.map((subjectPart, i) => {
                        if (unsupportedTags.includes(subjectPart)) {
                            return this.renderHighlightedTag(subjectPart, i)
                        } else {
                            return <span key={i}>{subjectPart}</span>
                        }
                    })}
                </ContentEditable>
            </div>
        )
    }

    renderHighlightedTag(tag, i) {
        return (
            <span contentEditable={true} key={i}>
                <span contentEditable={isEdge() || isFireFox()} className='highlighted-variable-tag' title='Unsupported Variable Tag' ref={'unsupportedTag' + i}>
                    {renderWarningIcon()}
                    <span>{tag}</span>
                </span>
                <span>&#8203;</span>
            </span>
        )
    }

}

const renderWarningIcon = () => {
    let className = 'slds-input__icon slds-icon-text-default slds-icon--x-small slds-m-bottom--xx-small'
    if (isMsBrowser) {
        let props = {
            width: '1em',
            height: '1em',
            viewBox: '0 0 24 24'
        }

        return (
            <svg className={className} dangerouslySetInnerHTML={{ __html: warningIconMarkup() }} {...props} />
        )
    } else {
        return <Svg className={className} type={Svg.Types.Utility} symbol='warning' />
    }
}

const stripUnsupportedTags = (subject, tags) => {
    return tags.reduce((strippedSubject, tag) => {
        return strippedSubject.replace(new RegExp(tag, 'g'), '')
    }, subject)
}

const splitTextByUnsupportedTags = (text, tags) => {
    let regex = new RegExp(`(${tags.join('|')})`, 'g')
    return text.split(regex).filter(t => t)
}

const getUnsupportedVariableTags = (subject) => {
    return parsePardotVariableTags(subject).filter(tag => UnsupportedUserTags.includes(tag))
}

const containsUnsupportedTagRef = (child) => {
    if (child.ref && child.ref.indexOf('unsupportedTag') > -1) {
        return true
    } else if (child.props && child.props.children instanceof Array) {
        return !!child.props.children.find(containsUnsupportedTagRef)
    } else {
        return false
    }
}
