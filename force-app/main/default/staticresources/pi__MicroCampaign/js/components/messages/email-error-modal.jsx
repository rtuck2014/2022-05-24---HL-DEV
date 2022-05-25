import React from 'react';
import PropTypes from 'prop-types';
import ConfirmModal from './confirm-modal.jsx';
import Dispatcher from '../../dispatcher';
import ActionTypes from '../../action-types';
import {
	InsufficientPrivilegeError,
	SomeRecipientsInaccessibleErrorTitle,
	SomeRecipientsInaccessibleErrorMessage,
	AllRecipientsInaccessibleErrorTitle,
	AllRecipientsInaccessibleErrorMessage,
} from '../../constants';
import EngageEmailStore from '../../stores/engage-email-store';

export default class EmailErrorModal extends React.Component {
	constructor(props) {
		super(props);
		this.state = EngageEmailStore.get();
		this.errorMessage = {
			...this.props
		};
	}

	componentWillMount() {
		let sendError;
		try {
			sendError = JSON.parse(this.props.sendError.message);
		} catch (e) {
			sendError = {};
		}
		if (sendError.name && sendError.name.includes(InsufficientPrivilegeError)) {
			if (sendError.data.length !== this.state.recipients.withEmail().length) {
				this.errorMessage.messageTitle = SomeRecipientsInaccessibleErrorTitle;
				this.errorMessage.messageBody = sendError.data.length + SomeRecipientsInaccessibleErrorMessage;
				this.errorMessage.confirmClicked = () => {
					Dispatcher.dispatch({
						type: ActionTypes.SUBMIT_REMOVED_RECIPIENTS,
						ids: sendError.data
					});
					Dispatcher.dispatch({
						type: ActionTypes.CONFIRM_EMAIL_ERRORS
					})
				};
			} else {
				this.errorMessage.messageTitle = AllRecipientsInaccessibleErrorTitle;
				this.errorMessage.messageBody = AllRecipientsInaccessibleErrorMessage;
				this.errorMessage.confirmClicked = () => {
					Dispatcher.dispatch({
						type: ActionTypes.CONFIRM_ALL_RECIPIENTS_OPTED_OUT
					})
				};
			}
		}
	}

	render() {
		let sendError = this.props.sendError;
		// We don't want to expose internal non-actionable errors to the customer, but at least log them to the console
		// so support etc. can find and follow up on them
		console.log('Engage Campaign send error: ' + sendError.message);
		return (
			<ConfirmModal title={this.errorMessage.messageTitle}
				singleButton={true}
				callback={this.errorMessage.confirmClicked.bind(this)}
				isError={true}
			>
				{this.errorMessage.messageBody}
			</ConfirmModal>
		);
	}
}

EmailErrorModal.defaultProps = {
	messageBody: 'We\'ve encountered an unexpected error sending your email. Please try again later and contact our support team if the problem persists?',
	messageTitle: 'Send Engage Email',
	confirmClicked: () => {
		Dispatcher.dispatch({
			type: ActionTypes.CONFIRM_EMAIL_ERRORS
		})
	}
}

EmailErrorModal.propTypes = {
	sendError: PropTypes.object.isRequired,
	messageBody: PropTypes.string,
	messageTitle: PropTypes.string,
	confirmClicked: PropTypes.func
}