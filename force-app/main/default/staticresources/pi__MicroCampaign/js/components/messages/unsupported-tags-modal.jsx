import React from 'react'
import Dispatcher from '../../dispatcher'
import ActionTypes from '../../action-types'
import ConfirmModal from './confirm-modal.jsx'
import { capitalize } from '../../util'

export default class UnsupportedTagsModal extends React.Component {
    constructor(props) {
        super(props)
    }

    render() {
        const saveClicked = () => Dispatcher.dispatch({
            type: ActionTypes.CONFIRM_UNSUPPORTED_TAGS,
        })

        const cancelClicked = () => Dispatcher.dispatch({
            type: ActionTypes.CANCEL_UNSUPPORTED_TAGS
        })

        let modalProps = {
            title: 'Are you sure you want to send your campaign?',
            tagline: renderTagline(),
            confirmText: 'Send',
            callback: saveClicked,
            cancelCallback: cancelClicked
        }

        let dedupedTags = this.props.unsupportedTags.reduce((dedupedTags, tag) => {
            return dedupedTags.includes(tag) ? dedupedTags : dedupedTags.concat(tag)
        }, [])

        return (
            <ConfirmModal {...modalProps}>
                <div>
                    {dedupedTags.map(tag =>
                        <p>{tag}</p>
                    )}
                </div>
            </ConfirmModal>
        )
    }
}

UnsupportedTagsModal.defaultProps = {
    unsupportedTags: []
}

const renderTagline = () => {
    return (
        <div>
            These variable tags aren't supported for this template, so they appear blank to your recipients. We suggest
            that you remove them from the campaign.
        </div>
    )
}
