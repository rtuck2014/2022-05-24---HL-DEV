import React from 'react';
import ConfirmModal from './confirm-modal.jsx';
import Dispatcher from '../../dispatcher'
import ActionTypes from '../../action-types'

const policyUrl = 'http://www.pardot.com/company/legal/permission-based-marketing-policy/';

export default class PolicyModal extends React.Component {
	confirmClicked() {
		Dispatcher.dispatch({
			type: ActionTypes.CONFIRM_POLICY
		})
	}

	cancelClicked() {
		Dispatcher.dispatch({
			type: ActionTypes.CANCEL_POLICY
		})
	}

	render() {
		return (
			<ConfirmModal title='Send Engage Email'
				confirmText='Confirm and Send'
				callback={this.confirmClicked} cancelCallback={this.cancelClicked}>

				<p>
					I confirm that I have a business relationship with these
					leads and contacts and I am in compliance with&nbsp;
					<a href={policyUrl} target='_blank'>Pardot's permission based marketing policy</a>.
				</p>
			</ConfirmModal>
		);
	}
}
