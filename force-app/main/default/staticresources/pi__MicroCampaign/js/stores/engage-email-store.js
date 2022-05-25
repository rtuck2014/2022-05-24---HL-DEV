import { Store } from 'flux/utils'
import Dispatcher from '../dispatcher'
import ActionTypes from '../action-types'
import { NO_TEMPLATE_ID } from '../email_template_constants'
import TemplateRepo from '../../../../js/repos/email-template-prod'
import MergeTagsRepo from '../../../../js/repos/merge-tags-prod'
import AttachmentFileRepo from '../repos/attachment-file-repo'
import { sendMicroCampaign, getNumberRemaining } from '../../../../js/services/send-email-prod'
import VariableTagRepo from '../../../../js/repos/variable-tag-prod'
import Tabs from '../tabs'
import {
	SendOnBehalfOfOptions,
	AttachmentFilterOptions,
	UploadErrors,
	MayNotRenderOnClientFileSizeInBytes,
	UnsubscribeLinkHtml,
	UnsubscribeLinkHtmlHML
} from '../constants';
import { checkRecipientSobos, checkOwnersExistInPardot } from '../repos/sobo-prod.js'
import { decodeTemplateHtml } from '../decoder'
import { flatArraysEqual, parsePardotVariableTags } from '../util'
import uuid from 'node-uuid';
import { UploadProgressTracker } from '../upload-progress-tracker'
import {
	removeHighlightDivs,
	addHighlightDivs,
	getUnsupportedTagsFoundInText,
	getEditorBodyText,
	insertAttachmentHtml,
	updateAttachmentCardPublicUrl,
	deleteAttachmentCardFromEditor,
	insertAttachmentImage,
	templateEditorDispatchToken,
	insertHmlMergeField,
	showErrorLoadingLexTemplateToastMessage,
	showPmlValidationFailedToastMessage
} from '../email_template_editor';

let getEditedTemplate = () => {};
let data = {
	accountAddress: undefined,
	recipients: [],
	errorFetchingTemplatesData: false,
	templateFoldersSanitized: undefined,
	template: undefined,
	previewHtml: undefined,
	previewSubject: undefined,
	userFullName: undefined,
	userId: undefined,
	userEmail: undefined,
	sendingUserPardotEmail: undefined,
	recipientType: undefined,
	invalidObjectType: undefined,
	sldsAssetsPath: undefined,
	customRedirect: undefined,
	editorDirty: false,
	subjectDirty: false,
	selectedTemplateId: undefined,
	selectedFolderId: undefined,
	emailSuccessfullySent: undefined,
	sendingEmail: undefined,
	hasConfirmedPermissionPolicy: false,
	needToConfirmPermissionPolicy: false,
	isEmailBlockedForAccount: false,
	sendError: null,
	sendLimit: null,
	overSendLimit: false,
	recipientListHasChanged: false,
	goBack: false,
	variableTags: null,
	selectedTab: Tabs.Edit,
	alertsVisible: true,
	soboEnabled: undefined,
	uiUpdatesPdfUrl: undefined,
	unsubscribeFooterThreshold: null,
	sendOnBehalfOf: {
		abilities: {
			leadOwner: false,
			contactOwner: false,
			accountOwner: false,
		},
		selected: SendOnBehalfOfOptions.Self,
		recipientPermissions: {
			hasChecked: false,
			loading: false,
			soboStatusByRecipientId: {},
		},
		owners: {
			recipientOwners: {},
			accountOwners: {},
			loading: false,
		},
		unsoboableModal: {
			showing: false,
		},
		warningModal: {
			needsConfirming: false,
			confirmed: false,
		},
		allOwnersInPardot: undefined,
	},
	subjectLastCursorPosition: 0,
	populatingMergeTags: false,
	selectedPreviewRecipient: null,
	mergeTagError: false,
	unsupportedTagsFoundInBody: undefined,
	unsupportedTagsFoundInSubject: undefined,
	unsupportedTagsConfirmed: false,
	unsupportedTagsNeedConfirming: false,
	sessionId: undefined,
	isClassicEnabled: false,
	editorResizeRequested: false,
	originObject: undefined,
	attachments: {
		canUploadFiles: true,
		filterOption: AttachmentFilterOptions.OwnedByMe,
		filesLoading: true,
		files: undefined,
		uploadErrorModalShowing: false,
		uploadError: {
			fileName: null,
			errorType: null,
			fileSize: null,
		},
		allFiles: {
			fileSelected: undefined,
			modalShowing: false,
			included: [],
			progressTracker: null,
			currentProgress: 0,
			// Used to keep track of the keys of uploads that were canceled so we don't display an error for them
			// when the xhr request dies and throws an error
			cancelledUploadKeys: {},
		},
		image: {
			fileSelected: undefined,
			selectorModalShowing: false,
			editorModalShowing: false,
			fileUploading: false,
			uploadedFileId: undefined,
		},
	},
	hmlFieldPicker: {
		isShowing: false,
		filesLoading: true
	},
	hmlEnabled: false
};

class EngageEmailStore extends Store {
	get() {
		return data;
	}

	setGetEditedTemplateFn(fn) {
		getEditedTemplate = () => {
			let {subject} = data.template;
			let template = fn();
			template.subject = data.template.subject;
			return template;
		}
	}

	__onDispatch(action) {
		const a = ActionTypes;

		switch (action.type) {
			case a.CLICK_PREVIEW_TAB:
				data.selectedTab = Tabs.Preview;
				data.template = getEditedTemplate();
				appendUnsubLinkToTemplateIfNecessary(true);
				data.previewHtml = data.template.html;
				data.previewSubject = data.template.subject;

				if (data.selectedPreviewRecipient) {
					data.populatingMergeTags = true;
					populateMergeTags.call(this, data.selectedPreviewRecipient.id, data.selectedPreviewRecipient.email);
				}

				this.__emitChange();
				break;
			case a.CLICK_EDIT_TAB:
				data.selectedTab = Tabs.Edit;
				appendUnsubLinkToTemplateIfNecessary(true);
				this.__emitChange();
				break;
			case a.SET_RECIPIENT_LIST:
				data.recipients = action.recipients;
				data.isEmailBlockedForAccount = getIsEmailBlockedForAccount(action.recipients.all());
				this.__emitChange();
				break;
			case a.TEMPLATE_SELECTED:
				templateSelected.call(this, action.id);
				break;
			case a.TEMPLATE_RECEIVED: {
				data.editorDirty = false;
				data.subjectDirty = false;
				data.selectedTab = Tabs.Edit;
				data.template = action.template;
				data.template.hasLockedRegions = data.template.html.includes('pardot-region') || (data.template.html.includes('locked="1"') && isNaN(data.template.id));
				data.selectedTemplateId = action.template.id;
				let soboSelected = data.sendOnBehalfOf.selected;
				let allOwnersInPardot = data.sendOnBehalfOf.allOwnersInPardot;
				if (allOwnersInPardot === null) {
					allOwnersInPardot = true;
				}
				data.unsupportedTagsNeedConfirming = false;
				data.unsupportedTagsConfirmed = false;
				if (soboSelected && soboSelected !== SendOnBehalfOfOptions.Self && !allOwnersInPardot) {
					data.unsupportedTagsFoundInBody = getUnsupportedTagsFoundInText(data.template.html);
					data.unsupportedTagsFoundInSubject = getUnsupportedTagsFoundInText(data.template.subject);
				} else {
					data.unsupportedTagsFoundInBody = null;
					data.unsupportedTagsFoundInSubject = null;
				}
				removeAllAttachments();
				let progressTracker = data.attachments.allFiles.progressTracker;
				if (progressTracker) {
					cancelUpload(progressTracker);
				}
				this.__emitChange();
				break;
			}
			case a.SET_INITIAL_DATA:
				data.sessionId = window.SessionId;
				data.isClassicEnabled = window.isClassicEnabled;
				Object.assign(data, action.data, {
					sendOnBehalfOf: {
						...data.sendOnBehalfOf,
						...action.data.sendOnBehalfOf
					},
					isEmailBlockedForAccount: getIsEmailBlockedForAccount(action.data.recipients.all())
				});
				data.attachments.canUploadFiles = window.ContentDeliveriesAndPubLinkProfileUserPermEnabled && window.RESTAPIEnabled;
				this.__emitChange();
				if (data.recipients.withEmail().length > 1) {
					getSendLimit(data.recipients.withEmail().length, data.originObject);
				}
				getVariableTags();
				// Don't get data if attachments are disabled for this org
				if (window.ContentDeliveriesAndPubLinkEnabled) {
					// OwnedByMe is default filter
					getAttachmentFilesFromFilter(data.attachments.filterOption);
				}
				data.hmlEnabled = window.hasHmlEnabled;
				break;
			case a.TEMPLATE_BODY_CHANGED:
				data.unsupportedTagsFoundInBody = action.unsupportedTagsFound;
				data.unsupportedTagsConfirmed = !action.needsTagConfirming;
				data.unsupportedTagsNeedConfirming = false;
				data.editorDirty = true;
				this.__emitChange();
				break;
			case a.CONFIRM_EDITS_OVERWRITTEN:
				templateSelected.call(this, data.selectedTemplateId, true);
				break;
			case a.CANCEL_EDITS_OVERWRITTEN:
				data.selectedTemplateId = data.template.id;
				this.__emitChange();
				break;
			case a.CLICK_SEND_BUTTON:
				sendEmail.call(this);
				break;
			case a.CLICK_CANCEL_BUTTON:
			case a.CONFIRM_ALL_RECIPIENTS_REMOVED:
			case a.CONFIRM_ALL_RECIPIENTS_OPTED_OUT:
			case a.CONFIRM_NO_RECIPIENTS_HAVE_EMAIL:
			case a.CONFIRM_EMAIL_BLOCKED:
				data.goBack = true;
				this.__emitChange();
				break;
			case a.CONFIRM_EMAIL_ERRORS:
				data.sendError = null;
				this.__emitChange();
				break;
			case a.SUBJECT_CHANGED:
				let isSoboing = data.sendOnBehalfOf.selected && data.sendOnBehalfOf.selected !== SendOnBehalfOfOptions.Self;
				data.template.subject = action.subject;
				data.subjectLastCursorPosition = action.lastCursorPosition;
				data.subjectDirty = true;
				let allOwnersInPardot = data.sendOnBehalfOf.allOwnersInPardot;
				if (allOwnersInPardot === null) {
					allOwnersInPardot = true;
				}

				if (isSoboing && action.subject.length > 0 && !allOwnersInPardot) {
					data.unsupportedTagsFoundInSubject = getUnsupportedTagsFoundInText(action.subject);
				} else {
					data.unsupportedTagsFoundInSubject = null;
				}
				this.__emitChange();
				break;
			case a.SUBMIT_REMOVED_RECIPIENTS:
				data.recipients.remove(action.ids);
				data.recipientListHasChanged = true;
				let recipients = data.recipients.withEmail();
				let soboStatusByRecipientId = {...data.sendOnBehalfOf.recipientPermissions.soboStatusByRecipientId};
				action.ids.forEach((id) => {
					if (soboStatusByRecipientId[id]) {
						delete soboStatusByRecipientId[id]
					}
				});
				data.sendOnBehalfOf.recipientPermissions.soboStatusByRecipientId = soboStatusByRecipientId;
				data.sendOnBehalfOf.allOwnersInPardot = checkAllUsersExistsInPardot();
				if (data.sendOnBehalfOf.allOwnersInPardot) {
					removeHighlightDivs();
					data.unsupportedTagsFoundInBody = null;
				}
				if (recipients.length == 1) {
					data.sendLimit = null;
				}
				this.__emitChange();
				break;
			case a.CANCEL_POLICY:
				data.needToConfirmPermissionPolicy = false;
				this.__emitChange();
				break;
			case a.CONFIRM_POLICY:
				data.needToConfirmPermissionPolicy = false;
				data.hasConfirmedPermissionPolicy = true;
				sendEmail.call(this);
				break;
			case a.CONFIRM_SALESFORCE_TAGS:
				data.templateContainsSalesforceTags = false;
				this.__emitChange();
				break;
			case a.SEND_EMAIL_SUCCESS:
				data.emailSuccessfullySent = true;
				data.sendingEmail = false;
				data.alertsVisible = false;
				this.__emitChange();
				break;
			case a.SEND_EMAIL_FAIL:
				data.emailSuccessfullySent = false;
				data.sendingEmail = false;
				data.sendError = action.error;
				this.__emitChange();
				break;
			case a.SEND_LIMIT_RECEIVED:
				data.sendLimit = action.sendLimit;
				this.__emitChange();
				break;
			case a.VARIABLE_TAGS_RECEIVED:
				data.variableTags = action.tags;
				data.hmlFieldPicker.filesLoading = false;
				this.__emitChange();
				break;
			case a.SELECT_SOBO:
				let isSelf = action.value === SendOnBehalfOfOptions.Self;
				data.sendOnBehalfOf = {
					...data.sendOnBehalfOf,
					selected: action.value,
					recipientPermissions: {
						hasChecked: false,
						loading: !isSelf,
						soboStatusByRecipientId: {},
					},
					warningModal: {
						confirmed: false,
						needsConfirming: false
					}
				};

				//need to clean up div and trigger "on change" events so switching between SOBO settings trigger correct user feedback.
				removeHighlightDivs();
				if (!isSelf) {
					checkRecipientSoboables();
				} else {
					data.unsupportedTagsFoundInBody = null;
					data.unsupportedTagsFoundInSubject = null;
					data.sendOnBehalfOf.allOwnersInPardot = null;
				}

				this.__emitChange();
				break;
			case a.SOBO_CHECK_RECEIVED:
				data.sendOnBehalfOf.recipientPermissions = {
					...data.sendOnBehalfOf.recipientPermissions,
					soboStatusByRecipientId: action.soboStatusByRecipientId,
					hasChecked: true,
					loading: false,
				};
				if (data.sendOnBehalfOf.allOwnersInPardot === undefined) {
					checkOwnersInPardot(action.soboStatusByRecipientId, data.userId);
				} else {
					data.sendOnBehalfOf.allOwnersInPardot = checkAllUsersExistsInPardot();
					if (data.sendOnBehalfOf.allOwnersInPardot === false) {
						let bodyText = getEditorBodyText();
						data.unsupportedTagsFoundInSubject = getUnsupportedTagsFoundInText(data.template.subject);
						data.unsupportedTagsFoundInBody = getUnsupportedTagsFoundInText(bodyText);
						addHighlightDivs(data.unsupportedTagsFoundInBody, null);
						data.unsupportedTagsNeedConfirming = false;
					} else {
						data.unsupportedTagsFoundInBody = null;
					}
				}

				this.__emitChange();
				break;
			case a.PARDOT_OWNERS_CHECK_RECEIVED:
				data.sendOnBehalfOf.owners = {
					...data.sendOnBehalfOf.owners,
					recipientOwners: action.recipientOwners,
					accountOwners: action.accountOwners,
					loading: false
				};
				data.sendingUserPardotEmail = action.sendingUserEmail;
				data.sendOnBehalfOf.allOwnersInPardot = checkAllUsersExistsInPardot();
				if (data.sendOnBehalfOf.allOwnersInPardot === false) {
					let bodyText = getEditorBodyText();
					data.unsupportedTagsFoundInSubject = getUnsupportedTagsFoundInText(data.template.subject);
					data.unsupportedTagsFoundInBody = getUnsupportedTagsFoundInText(bodyText);
					addHighlightDivs(data.unsupportedTagsFoundInBody, null);
					data.unsupportedTagsNeedConfirming = false;
				} else {
					data.unsupportedTagsFoundInBody = null;
				}
				this.__emitChange();
				break;
			case a.CLOSE_UNSOBOABLES_MODAL:
				data.sendOnBehalfOf.unsoboableModal.showing = false;
				this.__emitChange();
				break;
			case a.CLOSE_ATTACHMENTS_MODAL:
				resetAttachmentFileData();
				data.attachments.filesLoading = true;
				this.__emitChange();
				break;
			case a.CLOSE_IMAGE_ATTACHMENTS_MODAL:
				let cancel = action.cancel;
				let checkImageSize = action.checkImageSize;
				if (checkImageSize) {
					if (data.attachments.image.fileSelected.contentSize > MayNotRenderOnClientFileSizeInBytes) {
						let imageErrorAction = {
							error: UploadErrors.ImageMayNotRender,
							fileName: data.attachments.image.fileSelected.title,
							fileSize: data.attachments.image.fileSelected.contentSize
						};
						data.attachments.image.editorModalShowing = false;
						setUploadErrorData(imageErrorAction);
						data.attachments.uploadErrorModalShowing = true;
						cancel = true;
					}
				}
				if (cancel) {
					resetAttachmentFileData('image');
				} else {
					data.attachments.image.selectorModalShowing = false;
					data.attachments.image.editorModalShowing = true;
				}
				this.__emitChange();
				break;
			case a.CONFIRM_UNSUPPORTED_TAGS:
				data.unsupportedTagsConfirmed = true;
				data.unsupportedTagsNeedConfirming = false;
				sendEmail.call(this);
				break;
			case a.CANCEL_UNSUPPORTED_TAGS:
				data.unsupportedTagsConfirmed = true;
				data.unsupportedTagsNeedConfirming = false

				this.__emitChange();
				break;
			case a.UPLOAD_ATTACHMENT_FILE_BROWSER_START:
				// Inline image files are handled differently and are not displayed as attachment cards
				if (action.imageFileLoading) {
					data.attachments.image.fileUploading = action.imageFileLoading;
				} else {
					// Otherwise it's not an inline image, add an attachment card with progress tracking
					if (data.attachments.allFiles.progressTracker) {
						console.log(`Trying to start another upload while an upload is in progress, aborting.`);
						return;
					}
					data.attachments.allFiles.progressTracker = new UploadProgressTracker(Dispatcher, action.fileName, action.key);
					updateProgressUiFromTracker.call(this, action.type);
					addAttachmentCardToEditor({
						iconType: action.iconType,
						title: action.fileName,
					}, action.key);
				}
				this.__emitChange();
				break;
			case a.UPLOAD_ATTACHMENT_FILE_CONTENT_VERSION_START:
				if (!data.attachments.image.fileUploading) {
					updateProgressUiFromTracker.call(this, action.type);
				}
				let attachmentFile = action.fileData;
				let fileName = action.fileName;
				this.__emitChange();
				// Progress tracker will be null for inline image uploading, which is fine
				uploadFileToSF.call(this, attachmentFile, fileName, data.attachments.allFiles.progressTracker);
				break;
			case a.UPLOAD_ATTACHMENT_FILE_CONTENT_DISTRIBUTION_START:
				if (!data.attachments.image.fileUploading) {
					updateProgressUiFromTracker.call(this, action.type);
				}
				this.__emitChange();
				break;
			case a.UPLOAD_ATTACHMENT_FILE_SERVER_COMPLETE:
				if (!data.attachments.image.fileUploading) {
					let attachmentsArray = data.attachments.allFiles.included;
					let key = data.attachments.allFiles.progressTracker.getCurrentFileKey();
					let attachmentIndex = attachmentsArray.findIndex((attachment) => attachment.key === key);
					let showErrorModal = false;

					if (action.success) {
						if (attachmentIndex >= 0) {
							// Copy array so React detects that it changed
							attachmentsArray = attachmentsArray.slice();
							attachmentsArray[attachmentIndex].publicUrl = action.publicUrl;
						} else {
							console.log(`Failed to find attachment data for completed upload key ${key}`);
							// This has probably happened because the attachment was removed, but the cancellation didn't make it to the upload before it completed
							removeAttachmentFromStore(key);
						}
					} else {
						attachmentsArray = removeAttachmentFromStore(key);
						setUploadErrorData(action);
						// Don't show the error modal if this failure came from a user cancellation
						showErrorModal = !data.attachments.allFiles.cancelledUploadKeys.hasOwnProperty(key);
						delete data.attachments.allFiles.cancelledUploadKeys[key];
					}
					data.attachments = {
						...data.attachments,
						uploadErrorModalShowing: showErrorModal,
						allFiles: {
							...data.attachments.allFiles,
							included: attachmentsArray,
							progressTracker: null,
							currentProgress: 0,
						}
					};
				} else if (!action.success && data.attachments.image.fileUploading) {
					resetImageFileLoading();
					setUploadErrorData(action);
					data.attachments = {
						...data.attachments,
						uploadErrorModalShowing: true,
					};
				}
				this.__emitChange();
				break;
			case a.UPLOAD_ATTACHMENT_FILE_PROGRESS:
				data.attachments.allFiles.currentProgress = action.progress;
				this.__emitChange();
				break;
			case a.ATTACHMENT_FILES_RECEIVED:
				// if selected filter option is not same as option coming from resolved promise, ignore it.
				if(action.filterOption && action.filterOption != data.attachments.filterOption) {
					break;
				}
				data.attachments.filesLoading = false;
				data.attachments.files = action.files;
				// If we just uploaded an image, we need to grab it from files to be able to edit and display
				if (data.attachments.image.fileUploading && data.attachments.image.uploadedFileId) {
					let file = data.attachments.files.find(function (file) { return file.id === data.attachments.image.uploadedFileId });
					if (file) {
						if (data.attachments.image.editorModalShowing) {
							data.attachments.image.fileSelected = file;
						}
						data.attachments.image.fileUploading = false;
					}
				}
				this.__emitChange();
				break;
			case a.SUBMIT_SELECTED_ATTACHMENT_FILE:
				addAttachmentCardToEditor(data.attachments.allFiles.fileSelected, getAttachmentCardKey());
				this.__emitChange();
				break;
			case a.SUBMIT_SELECTED_IMAGE_ATTACHMENT_FILE:
				//use data.attachmentFileSelected since it's set when file is clicked
				insertAttachmentImage(data.attachments.image.fileSelected, action.width, action.height);
				resetAttachmentFileData('image');
				data.editorDirty = true;
				this.__emitChange();
				break;
			case a.REMOVE_ATTACHMENT_FILE:
				removeAttachmentFromStore(action.key);
				let progressTracker = data.attachments.allFiles.progressTracker;
				if (progressTracker && progressTracker.getCurrentFileKey() === action.key) {
					cancelUpload(progressTracker);
				}
				this.__emitChange();
				break;
			case a.POPULATE_MERGE_TAGS:
				let {recipient} = action;
				data.selectedPreviewRecipient = recipient;

				if (recipient) {
					data.populatingMergeTags = true;
					populateMergeTags.call(this, recipient.id, recipient.email);
				} else {
					data.previewHtml = data.template.html;
					data.previewSubject = data.template.subject;
				}

				this.__emitChange();
				break;
			case a.POPULATED_MERGE_TAGS_RECEIVED:
				data.populatingMergeTags = false;
				if (action.err) {
					data.mergeTagError = true;
				} else {
					data.previewHtml = action.html;
					data.previewSubject = action.subject;
				}
				this.__emitChange();
				break;
			case a.CLOSE_PREVIEW_ERROR_MODAL:
				data.mergeTagError = false;
				this.__emitChange();
				break;
			case a.SHOW_UNSOBOABLE_MODAL_CLICKED:
				data.sendOnBehalfOf.unsoboableModal = {
					showing: true
				};

				if (action.fromWarningModal) {
					data.sendOnBehalfOf.warningModal.needsConfirming = false;
					data.sendOnBehalfOf.warningModal.confirmed = true;
				}

				this.__emitChange();
				break;
			case a.SHOW_ATTACHMENTS_MODAL_CLICKED:
				// reset files to default filter
				data.attachments.filesLoading = true;
				getAttachmentFilesFromFilter(data.attachments.filterOption);
				data.attachments.allFiles.modalShowing = true;
				this.__emitChange();
				break;
			case a.CLICK_UNSOBOABLE_WARNING_SEND:
				data.sendOnBehalfOf.warningModal.needsConfirming = false;
				data.sendOnBehalfOf.warningModal.confirmed = true;
				sendEmail.call(this);
				break;
			case a.CANCEL_UNSOBOABLE_WARNING:
				data.sendOnBehalfOf.warningModal.needsConfirming = false;
				data.sendOnBehalfOf.warningModal.confirmed = true;
				this.__emitChange();
				break;
			case a.ATTACHMENT_FILTER_OPTION:
				data.attachments.filterOption = action.filterLabel;
				data.attachments.filesLoading = true;
				this.__emitChange();
				break;
			case a.ATTACHMENT_FILE_SELECTED:
				data.attachments.allFiles.fileSelected = action.file;
				this.__emitChange();
				break;
			case a.SHOW_IMAGE_ATTACHMENTS_MODAL_CLICKED:
				// reset files to default filter
				data.attachments.filesLoading = true;
				getAttachmentFilesFromFilter(data.attachments.filterOption);
				data.attachments.image.uploadedFileId = undefined;
				data.attachments.image.selectorModalShowing = true;
				this.__emitChange();
				break;
			case a.IMAGE_ATTACHMENT_FILE_SELECTED:
				data.attachments.image.fileSelected = action.file;
				this.__emitChange();
				break;
			case a.CLOSE_IMAGE_ATTACHMENTS_EDITOR_MODAL:
				data.attachments.image.editorModalShowing = false;
				data.attachments.image.uploadedFileId = undefined;
				resetAttachmentFileData('image');
				this.__emitChange();
				break;
			case a.CLOSE_UPLOAD_ERROR_MODAL:
				data.attachments.uploadErrorModalShowing = false;
				resetUploadErrorData();
				this.__emitChange();
				break;
			case a.UPDATE_IMAGE_UPLOADING:
				data.attachments.image.uploadedFileId = action.uploadedImageId;
				data.attachments.filesLoading = true;
				getAttachmentFilesFromFilter();
				this.__emitChange();
				break;
			case a.REQUEST_EDITOR_RESIZE:
				data.editorResizeRequested = true;
				this.__emitChange();
				break;
			case a.COMPLETE_EDITOR_RESIZE:
				data.editorResizeRequested = false;
				break;
			case a.EXPAND_TO_FOLDER:
				data.selectedFolderId = action.id;
				this.__emitChange();
				break;
			case a.SHOW_HML_FIELD_PICKER_MODAL_CLICKED:
				data.hmlFieldPicker.isShowing = true;
				this.__emitChange();
				break;
			case a.SUBMIT_SELECTED_HML_MERGE_FIELD:
				data.editorDirty = true;
			case a.CLOSE_HML_MERGE_FIELD_MODAL:
				data.hmlFieldPicker.isShowing = false;
				this.__emitChange();
				break;

		}
	}
}

function setUploadErrorData(action) {
	data.attachments = {
		...data.attachments,
		uploadError: {
			...data.attachments.uploadError,
			errorType: action.error,
			fileName: action.fileName,
			fileSize: action.fileSize,
		}
	};
}

function resetUploadErrorData() {
	data.attachments = {
		...data.attachments,
		uploadError: {
			...data.attachments.uploadError,
			errorType: null,
			fileName: null,
			fileSize: null,
		}
	};
}

function resetImageFileLoading() {
	data.attachments = {
		...data.attachments,
		image: {
			...data.attachments.image,
			fileUploading: false,
			editorModalShowing: false,
		}
	};
}

function getAttachmentFilesFromFilter(filter) {
	switch (filter) {
		case AttachmentFilterOptions.OwnedByMe:
			getFilesOwnedByMe();
			break;
		case AttachmentFilterOptions.SharedWithMe:
			getFilesSharedWithMe();
			break;
		default:
			getAllFiles();
	}
}

function resetAttachmentFileData(attachmentsType) {
	data.attachments.filterOption = AttachmentFilterOptions.OwnedByMe;

	if (attachmentsType === 'image') {
		data.attachments = {
			...data.attachments,
			filterOption: AttachmentFilterOptions.OwnedByMe,
			image: {
				...data.attachments.image,
				selectorModalShowing: false,
				editorModalShowing: false,
				fileSelected: undefined,
			}
		};
	} else {
		data.attachments = {
			...data.attachments,
			filterOption: AttachmentFilterOptions.OwnedByMe,
			allFiles: {
				...data.attachments.allFiles,
				modalShowing: false,
				fileSelected: undefined,
			}
		};
	}
}

function removeSoboStatusByIds(ids) {
	return Object.keys(data.sendOnBehalfOf.recipientPermissions.soboStatusByRecipientId)
		.filter(id => !ids.includes(id))
		.reduce((acc, id) => ({
			...acc,
			[id]: data.sendOnBehalfOf.recipientPermissions.soboStatusByRecipientId[id]
		}), {});
}

function checkRecipientSoboables() {
	let recipients = data.recipients.withEmail();
	let recipientIds = recipients.map(r => r.id);
	let permission = data.sendOnBehalfOf.selected;
	return checkRecipientSobos(recipientIds, permission).then((results) => {
		let recipientIds = data.recipients.withEmail().map(r => r.id);
		let recipientsChanged = !flatArraysEqual(recipientIds, Object.keys(results));
		let soboSelectionChanged = data.sendOnBehalfOf.selected !== permission;
		if (recipientsChanged || soboSelectionChanged) {
			return;
		}

		Dispatcher.dispatch({
			type: ActionTypes.SOBO_CHECK_RECEIVED,
			soboStatusByRecipientId: results
		});

	});
}

function checkOwnersInPardot(recipientsById, sendingUserId) {
	data.sendOnBehalfOf.owners.loading = true;

	return checkOwnersExistInPardot(recipientsById, sendingUserId).then((userMap) => {
		Dispatcher.dispatch({
			type: ActionTypes.PARDOT_OWNERS_CHECK_RECEIVED,
			recipientOwners: userMap.recipientOwners,
			accountOwners: userMap.accountOwners,
			sendingUserEmail: userMap.sendingUserEmail
		});
	});
}

function checkAllUsersExistsInPardot() {
	let {LeadOwner, ContactOwner, AccountOwner, Self} = SendOnBehalfOfOptions;
	let selectedSobo = data.sendOnBehalfOf.selected;
	if (selectedSobo === Self) {
		return null;
	}

	let accountOwnerSelected = selectedSobo === AccountOwner;
	let owners = data.sendOnBehalfOf.owners[(accountOwnerSelected ? 'account' : 'recipient') + `Owners`];
	let {soboStatusByRecipientId} = data.sendOnBehalfOf.recipientPermissions;
	let ownerKey = accountOwnerSelected ? 'accountOwner' : 'owner';
	let numSoboables = 0;
	let numOwnersInPardot = 0;
	let recipients = data.recipients.withEmail();

	for (let i = 0; i < recipients.length; i++) {
		let recipientId = recipients[i].id;
		let soboStatus = soboStatusByRecipientId[recipientId];
		if (!soboStatus.canSobo) {
			continue;
		}
		numSoboables += soboStatus.canSobo;
		let owner = soboStatus[ownerKey];
		if (owner) {
			numOwnersInPardot += owners[owner.id];
		}
	}

	if (!numSoboables) {
		return null;
	}

	return numSoboables === numOwnersInPardot;
}

/**
 *
 * @param calledOnTabSwitch boolean - only make unsub link editable if called on tab switch,
 * since this is called *after* we strip out contenteditable in getEmailParamsForSend, and
 * doesn't need to be edited in that case
 */
function appendUnsubLinkToTemplateIfNecessary(calledOnTabSwitch) {
	let {
		html,
		text
	} = data.template;

	const unsubscribeHtmlFooter = getUnsubLinkHtml(calledOnTabSwitch);
	const unsubscribeTextFooter = ' Unsubscribe: %%unsubscribe%% ';
	const unsubscribeTextFooterHML = ' Unsubscribe: {{Unsubscribe}} ';
	const accountAddressHtmlFooter = '<br />%%account_address%% ';
	const accountAddressTextFooter = ' %%account_address%% ';
	const accountAddressHtmlFooterHML = '<br />{{Organization.Address}} ';
	const accountAddressTextFooterHML = ' {{Organization.Address}} ';
	//if the unsubscribe threshold is available then we want to use that value and make sure account address is present
	var isUnsubscribeThresholdSet = data.unsubscribeFooterThreshold != 'null';
	var unsubscribeThreshold = isUnsubscribeThresholdSet ? data.unsubscribeFooterThreshold : 10;
	if (data.recipients.withEmail().length > unsubscribeThreshold) {
		if (isUnsubscribeThresholdSet) {
			if (html !== null && html.indexOf('%%account_address%%') === -1 && html.indexOf('{{Organization.Address}}') === -1) {
				if (window.hasHmlEnabled) {
					html = html.concat(accountAddressHtmlFooterHML);
				} else {
					html = html.concat(accountAddressHtmlFooter);
				}
			}
			if (text !== null && text.indexOf('%%account_address%%') === -1 && text.indexOf('{{Organization.Address}}') === -1) {
				if (window.hasHmlEnabled) {
					text = text.concat(accountAddressTextFooterHML);
				} else {
					text = text.concat(accountAddressTextFooter);
				}
			}
		}
		if (html !== null &&
			(html.indexOf('%%unsubscribe%%') === -1 && html.indexOf('{{Unsubscribe}}') === -1)
			&& (!html.match(/\%\%email_preference_center_?[0-9]*\%\%/g) && !html.match(/\{\{EmailPreferenceCenter_?[0-9]*\}\}/g))) {
			html = html.concat(unsubscribeHtmlFooter);
		}
		if (text !== null &&
			(text.indexOf('%%unsubscribe%%') === -1 && text.indexOf('{{Unsubscribe}}') === -1)
			&& (!html.match(/\%\%email_preference_center_?[0-9]*\%\%/g) && !html.match(/\{\{EmailPreferenceCenter_?[0-9]*\}\}/g))) {
			if (window.hasHmlEnabled) {
				text = text.concat(unsubscribeTextFooterHML);
			} else {
				text = text.concat(unsubscribeTextFooter);
			}
		}
	}
	data.template.html = html;
	data.template.text = text;
}

function getUnsubLinkHtml(calledOnTabSwitch) {
	var unsubscribeHtmlFooter = '<br /><br />' + UnsubscribeLinkHtml;

	if (window.hasHmlEnabled) {
		unsubscribeHtmlFooter = '<br /><br />' + UnsubscribeLinkHtmlHML;
	}

	if ((data.template.html.includes('pardot-region') || (data.template.html.includes('locked="1"') && isNaN(data.template.id))) && calledOnTabSwitch) {
		if (window.hasHmlEnabled) {
			unsubscribeHtmlFooter = '<br /><br /><span contenteditable="true">' + UnsubscribeLinkHtmlHML + '</span>';
		} else {
			unsubscribeHtmlFooter = '<br /><br /><span contenteditable="true">' + UnsubscribeLinkHtml + '</span>';
		}
	}

	return unsubscribeHtmlFooter;
}

function getSendLimit(numRecipients, originObject) {
	getNumberRemaining(numRecipients,  originObject, (response) => {
		Dispatcher.dispatch({
			type: ActionTypes.SEND_LIMIT_RECEIVED,
			sendLimit: {
				remaining: parseInt(response.remaining),
				total: parseInt(response.total),
				resetMessage: response.resetMessage
			}
		});
	});
}

function sendEmail() {
	if (!validateForSend()) {
		this.__emitChange();
		return;
	}

	data.sendingEmail = true;
	this.__emitChange();

	let emailParams = getEmailParamsForSend();
	let recipientIds = data.recipients.withEmail().map(r => r.id);
	let originObject = data.originObject;
	let soboType = Object.keys(SendOnBehalfOfOptions).find(key => data.sendOnBehalfOf.selected === SendOnBehalfOfOptions[key]);
	let ownersExistInPardot = data.sendOnBehalfOf.allOwnersInPardot;
	if (ownersExistInPardot === undefined) {
		ownersExistInPardot = null; //this means user kept option as 'Self' the entire time of send. We send self sends as null
	}


	sendMicroCampaign(emailParams, recipientIds, soboType, ownersExistInPardot, originObject)
		.then((response) => {
			Dispatcher.dispatch({
				type: ActionTypes.SEND_EMAIL_SUCCESS,
				response
			})
		})
		.catch((error) => {
			Dispatcher.dispatch({
				type: ActionTypes.SEND_EMAIL_FAIL,
				error: {
					message: error
				}
			})
		});
}

function getVariableTags() {
	VariableTagRepo.get((tags) => {
		Dispatcher.dispatch({
			type: ActionTypes.VARIABLE_TAGS_RECEIVED,
			tags
		});
	});
}

function getAllFiles() {
	AttachmentFileRepo.get().then((files) => {
		Dispatcher.dispatch({
			type: ActionTypes.ATTACHMENT_FILES_RECEIVED,
			files
		});
	});
}

function getFilesOwnedByMe() {
	AttachmentFileRepo.getMyFiles().then((files) => {
		Dispatcher.dispatch({
			type: ActionTypes.ATTACHMENT_FILES_RECEIVED,
			files
		});
	});
}

function getFilesSharedWithMe() {
	AttachmentFileRepo.getFilesSharedWithMe().then((files) => {
		Dispatcher.dispatch({
			type: ActionTypes.ATTACHMENT_FILES_RECEIVED,
			files
		});
	});
}


/**
 * Impure. Validates that the state of the Engage Send is ready for sending.
 * Validation is done in a specific order. State will be modified to flag the first invalidity found.
 * @return {Boolean}
*/
function validateForSend() {
	let isValid = false;
	if (window.hasHmlEnabled) {
		isValid = validateEmailContentForPmlTags()
			&& validateTemplate()
			&& validateSendLimits()
			&& validateSendOnBehalf()
			&& validatePermissionPolicy();
	} else {
		isValid = validateTemplate()
			&& validateSendLimits()
			&& validateSendOnBehalf()
			&& validatePermissionPolicy();
	}
	return isValid;
}

function validatePermissionPolicy() {
	let recipients = data.recipients.withEmail();
	if (recipients.length > 10 && !data.hasConfirmedPermissionPolicy) {
		data.needToConfirmPermissionPolicy = true;
		return false;
	}

	return true;
}

function validateSendLimits() {
	let recipients = data.recipients.withEmail();
	if (recipients.length > 1 && (!data.sendLimit || data.sendLimit.remaining - recipients.length < 0)) {
		data.overSendLimit = true;
		return false;
	}

	return true;
}

function validateSendOnBehalf() {
	let selectedSobo = data.sendOnBehalfOf.selected;
	if (selectedSobo && selectedSobo !== SendOnBehalfOfOptions.Self) {
		let {
			hasChecked,
			loading,
			soboStatusByRecipientId
		} = data.sendOnBehalfOf.recipientPermissions;
		let unsupportedTagsConfirmed = data.unsupportedTagsConfirmed;
		let unsoboableIds = Object.keys(soboStatusByRecipientId).filter(id => !soboStatusByRecipientId[id].canSobo);
		let unsupportedTagsFoundInBody = data.unsupportedTagsFoundInBody ? data.unsupportedTagsFoundInBody : [];
		let unsupportedTagsFoundInSubject = data.unsupportedTagsFoundInSubject ? data.unsupportedTagsFoundInSubject : [];
		if ((unsupportedTagsFoundInBody.length > 0 || unsupportedTagsFoundInSubject.length > 0) && !unsupportedTagsConfirmed && !data.sendOnBehalfOf.allOwnersInPardot) {
			data.unsupportedTagsNeedConfirming = true;
			return false;
		}
		if (unsoboableIds.length > 0 && !data.sendOnBehalfOf.warningModal.confirmed) {
			data.sendOnBehalfOf.warningModal.needsConfirming = true;
			return false;
		}
	}
	return true;
}

function getEmailParamsForSend() {
	//remove the divs from email html before sending
	removeHighlightDivs();

	data.template = getEditedTemplate();
	appendUnsubLinkToTemplateIfNecessary();

	const { template, recipientType } = data;
	const templateId = (isNaN(template.id) ? NO_TEMPLATE_ID : template.id);
	const lexTemplateFid = (isNaN(template.id) ? template.id : null);

	return {
		recipientType,
		templateId,
		lexTemplateFid,
		subject: template.subject,
		htmlMessage: template.html,
		textMessage: template.text,
		templateName: template.name,
		type: template.type,
		attachmentType: data.template.attachmentType,
	};
}

function getIsEmailBlockedForAccount(recipients) {
	if (recipients.length > 0) {
		return recipients[0].accountHasEmailBlocked;
	}

	return false;
}

function validateTemplate() {
	let valid = true;
	if (!data.template.subject) {
		data.needSubjectForSend = true;
		valid = false;
	} else if (templateContainsSalesforceTags()) {
		data.templateContainsSalesforceTags = true;
		valid = false;
	}

	if (!valid) {
		data.templateErrorsNeedCorrecting = true;
	}

	return valid;
}

function validateEmailContentForPmlTags() {
	let bodyText = getEditorBodyText();
	let pmlTagsInContent = [...parsePardotVariableTags(bodyText, true), ...parsePardotVariableTags(data.template.subject, true)];
	if (pmlTagsInContent.length) {
		showPmlValidationFailedToastMessage();
		return false;
	}
	return true;
}

function templateContainsSalesforceTags() {
	let template = getEditedTemplate();
	let salesforceTagRegex = /\{\!.*\}/;

	return salesforceTagRegex.test(template.html) || salesforceTagRegex.test(template.text);
}

function templateSelected(actionId, override = false) {
	if ((data.editorDirty || data.subjectDirty || data.attachments.allFiles.included.length > 0) && !override) {
		data.selectedTemplateId = actionId;
	} else {
		data.template = {
			id: actionId,
			loading: true
		};
		fetchTemplate(actionId);
	}

	this.__emitChange();
}

function fetchTemplate(id) {
	if (isNaN(id)) {
		TemplateRepo.getLex(id, (template, event) => {
			if (event.status) {
				Dispatcher.dispatch({
					type: ActionTypes.TEMPLATE_RECEIVED,
					template
				});
			} else {
				const template = window.lexTemplates.filter((folder) => { if (folder.templates) { return folder.templates.some((template) => { return template.id === id; }); } });
				let templateName;
				if (template.length > 0) {
					templateName = template[0].name;
				}
				showErrorLoadingLexTemplateToastMessage(templateName);
			}
		});
	} else {
		TemplateRepo.get(id, (template) => {
			Dispatcher.dispatch({
				type: ActionTypes.TEMPLATE_RECEIVED,
				template
			});
		});
	}
}

function populateMergeTags(id, email) {
	let {html, subject} = data.template;
	let {soboStatusByRecipientId} = data.sendOnBehalfOf.recipientPermissions;
	let soboType = data.sendOnBehalfOf.selected;
	let soboOwnersInPardot = data.sendOnBehalfOf.allOwnersInPardot;
	let userFullName = data.userFullName;
	let userEmail = data.userEmail;
	if (typeof soboOwnersInPardot === "undefined" || soboOwnersInPardot === null) {
		soboOwnersInPardot = true;
	}

	let isSoboEnabled = data.soboEnabled;
	if (typeof isSoboEnabled === "undefined") {
		isSoboEnabled = false;
	}

	isSoboEnabled = isSoboEnabled.toString();
	soboOwnersInPardot = soboOwnersInPardot.toString();

	// Highlight all variable tags by wrapping variable tags in a span
	// Add some reset rules to make sure the spans aren't styled
	const rules = {
		'background-color': '#D5EAFB',
		'margin': 0,
		'padding': 0,
		'border': 0,
		'font-size': '100%',
		'font': 'inherit',
		'vertical-align': 'baseline'
	};

	const style = Object.keys(rules).map((k) => `${k}:${rules[k]}!important;`).join('');

	if (data.hmlEnabled) {
		html = html.replace(/(?![^<]*>)({{{?[^{]+}}}?)/g, `<span style="${style}">$1</span>`);
	} else {
		html = html.replace(/(?![^<]*>)(%%[^%]+%%)/g, `<span style="${style}">$1</span>`);
	}

	// Replace subject tag so we don't need to send the subject up to pardot
	html = html.replace(/%%subject%%/gi, subject);

	let recipientSoboData = soboStatusByRecipientId[id];
	let userId;
	if (soboType === 'self' || soboType === null) {
		userId = data.userId;
	} else {
		if (recipientSoboData.canSobo) {
			if (soboType === 'lead owner' || soboType === 'contact owner') {
				userId = recipientSoboData.owner.id;
				userFullName = recipientSoboData.owner.name;
				userEmail = recipientSoboData.owner.email;
			} else if (soboType === 'account owner') {
				userId = recipientSoboData.accountOwner.id;
				userFullName = recipientSoboData.accountOwner.name;
				userEmail = recipientSoboData.accountOwner.email;
			}
		} else {
			userId = data.userId;
		}
	}


	MergeTagsRepo.get(id, email, isSoboEnabled, soboOwnersInPardot, userId, userFullName, userEmail, html, subject).then((result) => {
		// double decode, things like <br> in address don't decode properly without it
		let decoded = decodeTemplateHtml(decodeTemplateHtml(result.body));
		let subject = result.subject;

		Dispatcher.dispatch({
			type: ActionTypes.POPULATED_MERGE_TAGS_RECEIVED,
			html: decoded,
			subject: subject
		});
	}).catch((err) => {
		Dispatcher.dispatch({
			type: ActionTypes.POPULATED_MERGE_TAGS_RECEIVED,
			err
		});
	});
}

/**
 * Uploads a file to Salesforce
 *
 * @param {File} attachmentFile
 * @param {string} fileName
 * @param {UploadProgressTracker} uploadProgressTracker
 */
function uploadFileToSF(attachmentFile, fileName, uploadProgressTracker) {
	AttachmentFileRepo.createMultipart(attachmentFile, fileName, data.sessionId, uploadProgressTracker).then((result) => {
		AttachmentFileRepo.renameUploadedFile(result.compositeResponse[1].body.ContentVersionId, fileName).then(() => {
			if (data.attachments.image.fileUploading) {
				let uploadedImageId = result.compositeResponse[1].body.ContentVersionId;
				Dispatcher.dispatch({
					type: ActionTypes.UPDATE_IMAGE_UPLOADING,
					imageFileLoading: false,
					uploadedImageId: uploadedImageId
				});
			} else {
				let publicUrl = result.compositeResponse[1].body.DistributionPublicUrl;
				Dispatcher.dispatch({
					type: ActionTypes.UPLOAD_ATTACHMENT_FILE_SERVER_COMPLETE,
					fileName,
					success: Boolean(publicUrl),
					publicUrl: publicUrl,
				});
			}
		})
	}).catch((err) => {
		console.log(`Upload error: ${err}`);
		setTimeout(() => {
			Dispatcher.dispatch({
				type: ActionTypes.UPLOAD_ATTACHMENT_FILE_SERVER_COMPLETE,
				fileName,
				success: false,
				publicUrl: null,
				error: err && Array.isArray(err) && err.includes(UploadErrors.StorageLimitExceededError) ? UploadErrors.StorageLimitExceededError : UploadErrors.GenericUploadError,
				fileSize: null,
			});
		}, 1);
	});
}

/**
 * Adds a new attachment to the store and UI
 *
 * @param {Object} fileData
 * @param {string} fileData.iconType Icon identifier for the attachment's file type
 * @param {string} fileData.title Attachment file name
 * @param {string} fileData.publicURl ContentDistribution URL for the attachment file
 * @param {string} fileData.key Unique key for this attachment (currently a hash of the URL)
 * @param {string} key Unique string internally identifying this attachment card
 */
function addAttachmentCardToEditor(fileData, key) {
	if (!fileData) {
		console.log(`Attachment submit fired without any file data, ignoring`);
		return;
	}

	fileData.key = key;
	// Create a new array so there's a new array reference so react's change detection works correctly
	let newIncludedArray = data.attachments.allFiles.included.slice();
	newIncludedArray.push(fileData);
	immutableUpdateIncludedAttachments(newIncludedArray);
	resetAttachmentFileData();
	// Reset files to default filter
	getAttachmentFilesFromFilter(data.attachments.filterOption);
}


/**
 * Removes the data for a given attachment from the store
 *
 * @param {string} key
 */
function removeAttachmentFromStore(key) {
	let index = data.attachments.allFiles.included.findIndex((attachment) => attachment.key === key);
	if (index >= 0) {
		let newIncludedArray = data.attachments.allFiles.included.slice();
		newIncludedArray.splice(index, 1);
		immutableUpdateIncludedAttachments(newIncludedArray);
		return data.attachments.allFiles.included;
	}
}

/**
 * Removes all attachments from the store
 */
function removeAllAttachments() {
	immutableUpdateIncludedAttachments([]);
}

function immutableUpdateIncludedAttachments(newIncludedAttachments) {
	// And this is why they recommend you don't deeply nest your react data
	data.attachments = {
		...data.attachments,
		allFiles: {
			...data.attachments.allFiles,
			included: newIncludedAttachments,
		}
	};
}

/**
 * @param {UploadProgressTracker} progressTracker
 */
function cancelUpload(progressTracker) {
	progressTracker.cancelUpload();
	data.attachments.allFiles.cancelledUploadKeys[progressTracker.getCurrentFileKey()] = true;
}

/**
 * Updates the current upload's progress to the milestone corresponding to a given action
 *
 * @param {string} actionType
 */
function updateProgressUiFromTracker(actionType) {
	data.attachments.allFiles.progressTracker.uploadChangeAction(actionType);
	data.attachments.allFiles.currentProgress = data.attachments.allFiles.progressTracker.getCurrentProgress();
}

/**
 * Generates a new key is used to internally identify that attachment in the DOM etc.
 * This key is based on a type 1 UUID and is thus not deterministically derived from the file data.
 *
 * @returns {string}
 */
export function getAttachmentCardKey() {
	return `file-attachment-${uuid.v1()}`;
}


export default new EngageEmailStore(Dispatcher);
