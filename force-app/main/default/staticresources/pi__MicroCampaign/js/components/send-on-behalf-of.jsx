import React from 'react'
import Dispatcher from '../dispatcher'
import ActionTypes from '../action-types'
import UnsoboableModal from './messages/unsoboable-modal.jsx'
import Spinner from '../salesforce-lightning-design-system/spinner.jsx'
import Dropdown from '../salesforce-lightning-design-system/dropdown.jsx'
import {
    SendOnBehalfOfOptions,
    StandardObjects
} from '../constants'
import {
    lowerCaseFirstLetter,
    capitalize
} from '../util'

const SendOnBehalfOf = ({ abilities, selected, recipientPermissions, recipients, includeControls, owners }) => (
    <div className='form-control slds-m-top--medium slds-truncate overflow-visible'>
        <span className='label slds-float--left slds-text-align--right slds-p-right--small slds-text-color--weak'>
            From
        </span>
        <span>
            {(() => {
                if (includeControls) {
                    return renderDropdown(abilities, selected)
                } else {
                    return <span>{capitalize(selected || SendOnBehalfOfOptions.Self)}</span>
                }
            })()}

        </span>
        {renderLoading(recipientPermissions.loading || owners.loading)}
    </div>
)

const renderDropdown = (abilities, selected) => {
    let header = `Send from ${selected || SendOnBehalfOfOptions.Self}`

    let items = Object.keys(SendOnBehalfOfOptions)
        .filter((key) => {
            if (SendOnBehalfOfOptions[key] === SendOnBehalfOfOptions.ContactOwner && onlyHasPersonAccountRecipients(recipients)) {
                return false
            }
            return SendOnBehalfOfOptions[key] === SendOnBehalfOfOptions.Self || abilities[lowerCaseFirstLetter(key)]
        })
        .map(key => ({
            key,
            label: `Send from ${SendOnBehalfOfOptions[key]}`
        }))

    let props = {
        title: header,
        header,
        items,
        activeFilter: header,
        onItemSelected: item => Dispatcher.dispatch({
            type: ActionTypes.SELECT_SOBO,
            value: SendOnBehalfOfOptions[item.key]
        })
    }

    return <Dropdown {...props} />
}

const renderLoading = (loading) => {
    if (!loading) {
        return null
    }

    return (
        <span className='slds-is-relative sobo-spinner'>
            <Spinner type={Spinner.Types.Default} size={Spinner.Sizes.Small}>
                <span className='slds-m-left--xx-small slds-text-color--weak'>
                    Verifying the users you can send on behalf of...
                </span>
            </Spinner>
        </span>
    )
}

function onlyHasPersonAccountRecipients(recipients) {
    return recipients.filter(r => r.isPersonAccount).length === recipients.length
}

export default SendOnBehalfOf
