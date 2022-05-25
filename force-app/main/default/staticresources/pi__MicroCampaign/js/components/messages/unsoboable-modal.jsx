import React from 'react'
import Dispatcher from '../../dispatcher'
import ActionTypes from '../../action-types'
import ConfirmModal from './confirm-modal.jsx'
import { capitalize } from '../../util'
import { SendOnBehalfOfOptions } from '../../constants'
import { Svg } from '../../salesforce-lightning-design-system'
const staticWidth = { width: '3.25rem' }

const noAccountCopy = 'No Account'

export default class UnsoboableModal extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            selectedRecipientIds: []
        }
    }

    render() {
        let {
            soboStatusByRecipientId,
            selected,
            userFullName,
            submitCallback,
            cancelCallback
        } = this.props

        let selectedIds = this.state.selectedRecipientIds

        let recipients = this.props.recipients.map((r) => ({
            ...r,
            owner: soboStatusByRecipientId[r.id].owner,
            accountOwner: soboStatusByRecipientId[r.id].accountOwner,
            canSobo: soboStatusByRecipientId[r.id].canSobo
        }))

        let numUnsobo = recipients.reduce((total, r) => total + !r.canSobo, 0)

        const saveClicked = () => {
            Dispatcher.dispatch({
                type: ActionTypes.SUBMIT_REMOVED_RECIPIENTS,
                ids: selectedIds
            })
            submitCallback()
        }

        let modalProps = {
            title: 'Insufficient Permission to Send on Behalf of',
            tagline: renderTagline(selected, numUnsobo),
            confirmText: 'Remove Recipients',
            confirmDisabled: selectedIds.length === 0,
            callback: saveClicked,
            cancelCallback,
            large: true
        }

        return (
            <div className='modal-content-no-inner-padding'>
                <ConfirmModal {...modalProps}>
                    <table className='slds-table slds-table_bordered slds-table_fixed-layout slds-table_cell-buffer'>
                        {this.renderTableHeader(selected, selectedIds, recipients, soboStatusByRecipientId)}
                        <tbody>
                            {this.renderRecipients(recipients, soboStatusByRecipientId, selectedIds, selected)}
                        </tbody>
                    </table>
                </ConfirmModal>
            </div>
        )
    }

    renderTableHeader(selected, selectedIds, recipients, soboStatusByRecipientId) {
        const toggleAllChanged = (event) => {
            this.setState({
                selectedRecipientIds: event.target.checked ? recipients.map(r => r.id) : []
            })
        }

        let toggleAllChecked = selectedIds.length === recipients.length

        return (
            <thead>
                <tr className='slds-line-height_reset slds-text-title_caps'>
                    <th style={staticWidth}></th>
                    <th style={{ width: '2rem' }}>
                        <input type='checkbox' checked={toggleAllChecked} onChange={toggleAllChanged} />
                    </th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>{selected}</th>
                    <th>Sent From</th>
                </tr>
            </thead>
        )
    }

    renderRecipients(recipients, soboStatusByRecipientId, selectedIds, selected) {
        const checkboxChanged = (id, event) => {
            this.setState({
                selectedRecipientIds: event.target.checked ? selectedIds.concat(id) : selectedIds.filter(rId => rId !== id)
            })
        }

        return recipients.sort((a, b) => {
            if (!a.canSobo && b.canSobo) {
                return -1
            } else if (a.canSobo && !b.canSobo) {
                return 1
            } else {
                return 0
            }
        }).map((recipient) => {
            let {
                owner,
                accountOwner,
                canSobo
            } = recipient

            let ownerName = getOwnerName(owner, accountOwner, selected)
            let ownerNameElement = ownerName === noAccountCopy ? <b>{ownerName}</b> : ownerName

            return (
                <tr key={recipient.id}>
                    <td style={staticWidth}>
                        {(() => {
                            if (canSobo) {
                                return null
                            }

                            return <Svg aria-hidden='true' className='slds-icon slds-icon--x-small slds-m-right--x-small slds-icon-text-warning' type={Svg.Types.Utility} symbol='warning' />
                        })()}
                    </td>
                    <td style={{ width: '2rem' }}>
                        <input type='checkbox' onChange={checkboxChanged.bind(null, recipient.id)} checked={selectedIds.includes(recipient.id)} />
                    </td>
                    <td className='slds-truncate'>{recipient.name}</td>
                    <td className='slds-truncate'>{recipient.email}</td>
                    <td className='slds-truncate'>{ownerNameElement}</td>
                    <td className='slds-truncate'>{canSobo ? ownerName : userFullName}</td>
                </tr>
            )
        })
    }

}

const getOwnerName = (owner, accountOwner, selected) => {
    if (selected === SendOnBehalfOfOptions.AccountOwner) {
        return accountOwner ? accountOwner.name : noAccountCopy
    } else {
        return owner.name
    }
}


const renderTagline = (selected, numUnsobo) => {
    let plural = numUnsobo > 1
    let s = plural ? 's' : ''
    let the = plural ? '' : 'the'

    return (
        <div>
            You don't have permission to send as {selected} to the following {plural ? numUnsobo : ''} recipient{s}.
            Your email address (instead of the {selected}'s) will be used for sender. Remove {the} recipient{s} if
            you don't want to be listed as the sender.
        </div>
    )
}
