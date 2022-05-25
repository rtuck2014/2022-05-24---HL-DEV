import React from 'react';
import ConfirmModal from './confirm-modal.jsx';
import Dispatcher from '../../dispatcher'
import ActionTypes from '../../action-types'

export default class SelectTemplateModal extends React.Component {
	confirmed() {
		Dispatcher.dispatch({
			type: ActionTypes.CONFIRM_EDITS_OVERWRITTEN
		})
	}

	canceled() {
		Dispatcher.dispatch({
			type: ActionTypes.CANCEL_EDITS_OVERWRITTEN
		})
	}

	render() {
		return (
			<ConfirmModal title='Select Engage Template'
				confirmText='Yes, I want to use a new template'
				callback={this.confirmed.bind(this)}
				cancelCallback={this.canceled.bind(this)}
				>

				<p>
					Are you sure you want to use a different template? If you
					select another template, you will lose your work on the
					template you were working on.
				</p>
			</ConfirmModal>
		);
	}
}
