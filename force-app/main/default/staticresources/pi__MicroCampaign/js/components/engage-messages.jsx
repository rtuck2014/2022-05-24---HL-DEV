import React from 'react'
import {
	SendOnBehalfOfOptions,
} from '../constants';
import EngageEmailStore from '../stores/engage-email-store'
import SelectTemplateModal from './messages/select-template-modal.jsx';
import PolicyModal from './messages/policy-modal.jsx'
import SalesforceTagsErrorModal from './messages/salesforce-tags-error-modal.jsx'
import SendLimitAlert from './messages/send-limit-alert.jsx'
import UnmailableRecipientsAlert from './messages/unmailable-recipients-alert.jsx'
import RecipientsWithoutEmailAlert from './messages/recipients-without-email-alert.jsx'
import DuplicateEmailsAlert from './messages/duplicate-emails-alert.jsx'
import AllRecipientsRemovedModal from './messages/all-recipients-removed-modal.jsx'
import EmailBlockedModal from './messages/email-blocked-modal.jsx'
import NoRecipientsHaveEmailModal from './messages/no-recipients-have-email-modal.jsx'
import AllRecipientsOptedOutModal from './messages/all-recipients-opted-out-modal.jsx'
import EmailErrorModal from './messages/email-error-modal.jsx'
import PreviewErrorModal from './messages/preview-error-modal.jsx'
import UnsupportedTagsAlert from './messages/unsupported-tags-alert.jsx'
import UnsoboableRecipientsAlert from './messages/unsoboable-recipients-alert.jsx'
import UnsupportedTagsModal from './messages/unsupported-tags-modal.jsx'
import UnsoboableSendWarningModal from './messages/unsoboable-send-warning-modal.jsx'
import FileUploadModal from './messages/file-upload-modal.jsx'
import ImageAttachmentModal from './messages/image-attachment-modal.jsx'
import ImageAttachmentEditorModal from './messages/image-attachment-editor-modal.jsx'
import AttachmentUploadErrorModal from './messages/attachment-upload-error-modal.jsx'
import HmlFieldPicker from './messages/hml-field-picker.jsx'
import Tabs from '../tabs'
import { isArrayWithElements } from '../util'

export default class EngageMessages extends React.Component {
	constructor(props) {
		super(props);
		this.state = EngageEmailStore.get();
	}

	componentWillMount() {
		EngageEmailStore.addListener(() => {
			let state = Object.assign({}, this.state, EngageEmailStore.get())
			this.setState(state)
		});
	}

	render() {
		return (
			<div>
				{this.renderAlerts()}
				{this.renderModal()}
			</div>
		);
	}

	renderAlerts() {
		let {
			sendLimit,
			recipients,
			recipientType,
			alertsVisible,
			unsupportedTagsFoundInBody,
			unsupportedTagsFoundInSubject,
			userFullName,
			sendingUserPardotEmail,
			sendOnBehalfOf
		} = this.state;
		let recipientsWithEmail = recipients.withEmail();
		let numberOfRecipients = recipientsWithEmail.length;
		let unmailableRecipients = recipients.thatCannotReceiveEmail();
		let duplicateRecipients = recipients.thatHaveDuplicateEmailAddresses();
		let recipientsWithoutEmail = recipients.withoutEmail();
		let badTagsInEmail;

		unsupportedTagsFoundInBody = isArrayWithElements(unsupportedTagsFoundInBody) ? unsupportedTagsFoundInBody : [];
		unsupportedTagsFoundInSubject = isArrayWithElements(unsupportedTagsFoundInSubject) ? unsupportedTagsFoundInSubject : [];
		badTagsInEmail = unsupportedTagsFoundInBody.concat(unsupportedTagsFoundInSubject);

		let alerts = [];

		if (unmailableRecipients.length > 0) {
			alerts.push(
				<UnmailableRecipientsAlert unmailableRecipients={unmailableRecipients} type={recipientType} key={alerts.length}/>
			);
		}

		if (duplicateRecipients.length > 0) {
			alerts.push(
				<DuplicateEmailsAlert duplicateRecipients={duplicateRecipients} type={recipientType} key={alerts.length}/>
			);
		}

		if (recipientsWithoutEmail.length > 0) {
			alerts.push(
				<RecipientsWithoutEmailAlert recipients={recipientsWithoutEmail} type={recipientType} key={alerts.length}/>
			);
		}

		if (sendLimit) {
			alerts.push(
				<SendLimitAlert numberOfRecipients={numberOfRecipients} {...sendLimit} key={alerts.length}/>
			);
		}

		if (badTagsInEmail.length > 0 && !sendOnBehalfOf.allOwnersInPardot) {
			alerts.push(
				<UnsupportedTagsAlert unsupportedTagsFound={badTagsInEmail} key={alerts.length}/>
			);
		}

		let {soboStatusByRecipientId} = sendOnBehalfOf.recipientPermissions;
		let numUnsoboables = Object.values(soboStatusByRecipientId).reduce((total, r) => (total + !r.canSobo), 0);
		if (numUnsoboables > 0) {
			let props = {
				soboStatusByRecipientId,
				recipients: recipientsWithEmail,
				userFullName,
				sendingUserPardotEmail,
				selected: sendOnBehalfOf.selected,
				unsoboableModal: sendOnBehalfOf.unsoboableModal
			};
			alerts.push(
				<UnsoboableRecipientsAlert {...props} key={alerts.length}/>
			);
		}

		let hideClass = !alertsVisible ? 'hide-alerts' : '';
		let i = 0;
		return (
			<div className={`alerts-wrapper slds-text-body--small ${hideClass}`}>
				{alerts}
			</div>
		);
	}

	renderModal() {
		let {
			editorDirty,
			subjectDirty,
			selectedTemplateId,
			template,
			needToConfirmPermissionPolicy,
			templateContainsSalesforceTags,
			recipientListHasChanged,
			recipients,
			recipientType,
			isEmailBlockedForAccount,
			sendError,
			mergeTagError,
			unsupportedTagsFoundInBody,
			unsupportedTagsFoundInSubject,
			unsupportedTagsNeedConfirming,
			unsupportedTagsConfirmed,
			sendOnBehalfOf,
			attachments,
			hmlFieldPicker
		} = this.state;

		if (isEmailBlockedForAccount) {
			return <EmailBlockedModal />;
		} else if (sendError) {
			return <EmailErrorModal sendError={sendError} />;
		} else if (recipients.withEmail().length === 0) {
			if (recipientListHasChanged) {
				return <AllRecipientsRemovedModal />;
			} else if (recipients.thatCannotReceiveEmail().length > 0) {
				return <AllRecipientsOptedOutModal recipientType={recipientType} />;
			} else {
				return <NoRecipientsHaveEmailModal recipientType={recipientType} />;
			}
		} else if ((editorDirty || subjectDirty || attachments.allFiles.included.length > 0) && selectedTemplateId !== template.id) {
			return <SelectTemplateModal />;
		} else if (needToConfirmPermissionPolicy) {
			return <PolicyModal />;
		} else if (templateContainsSalesforceTags) {
			return <SalesforceTagsErrorModal />;
		} else if (mergeTagError) {
			return <PreviewErrorModal />;
		} else if (sendOnBehalfOf.warningModal.needsConfirming && !sendOnBehalfOf.warningModal.confirmed) {
			return <UnsoboableSendWarningModal soboStatusByRecipientId={sendOnBehalfOf.recipientPermissions.soboStatusByRecipientId} selected={sendOnBehalfOf.selected}/>;
		} else if (attachments.allFiles.modalShowing) {
			return <FileUploadModal />;
		} else if (attachments.image.selectorModalShowing) {
			return <ImageAttachmentModal />;
		} else if (attachments.image.editorModalShowing) {
			return <ImageAttachmentEditorModal />;
		} else if (attachments.uploadErrorModalShowing) {
			return <AttachmentUploadErrorModal uploadError={attachments.uploadError} />;
		} else if (hmlFieldPicker.isShowing) {
			return <HmlFieldPicker  />;
		}

		let badTagsInEmail;
		unsupportedTagsFoundInBody = isArrayWithElements(unsupportedTagsFoundInBody) ? unsupportedTagsFoundInBody : [];
		unsupportedTagsFoundInSubject = isArrayWithElements(unsupportedTagsFoundInSubject) ? unsupportedTagsFoundInSubject : [];
		badTagsInEmail = unsupportedTagsFoundInBody.concat(unsupportedTagsFoundInSubject);

		let isSOBOing = sendOnBehalfOf.selected && sendOnBehalfOf.selected !== SendOnBehalfOfOptions.Self;
		let showModal = !unsupportedTagsConfirmed && badTagsInEmail.length > 0 && !sendOnBehalfOf.allOwnersInPardot;
		if (isSOBOing && showModal && unsupportedTagsNeedConfirming) {
			return <UnsupportedTagsModal unsupportedTags={badTagsInEmail} />;
		}

		return null;
	}
}
