import React from 'react';
import ReactDOM from 'react-dom';
import Dispatcher from '../dispatcher';
import ActionTypes from '../action-types';
import TemplateChooser from './template-chooser.jsx';
import ComposerRecipients from './composer-recipients.jsx';
import EngageMessages from './engage-messages.jsx';
import SendOnBehalfOf from './send-on-behalf-of.jsx';
import EngageEmailStore from '../stores/engage-email-store';
import {
	Spinner,
	Combobox
} from '../salesforce-lightning-design-system';
import IFrame from './iframe.jsx';
import Tabs from '../tabs';
import { handleEventOnRequestAnimation, getWindowScrollOffset, getWindowHeight } from '../util';
import '../../../../js/googleAnalytics';
import {
	AttachmentContainerClass,
	AttachmentContainerEditTabClass,
	SendOnBehalfOfOptions,
    MaximumEngageEmailRecipients,
	ClassicFooterOffset
} from '../constants';
import { AttachmentCard } from './attachment-card.jsx';
import EmailTemplateConstants from '../email_template_constants';
import SubjectField from './subject-field.jsx';
import { htmlDecode } from '../decoder';

export default class EngageEmail extends React.Component {
	constructor(props) {
		super(props);
		this.state = {...EngageEmailStore.get()};
		this.setPreviewHeight = this.setPreviewHeight.bind(this);
	}

	cancelButtonClicked() {
		Dispatcher.dispatch({
			type: ActionTypes.CLICK_CANCEL_BUTTON
		});
	}

	sendButtonClicked() {
		Dispatcher.dispatch({
			type: ActionTypes.CLICK_SEND_BUTTON
		});
	}

	componentWillMount() {
		EngageEmailStore.addListener(() => {
			this.setState({
				...this.state,
				...EngageEmailStore.get(),
			})
		});
	}

	componentDidMount() {
		this.updateLayoutOnWindowEvent('scroll');
		this.updateLayoutOnWindowEvent('resize');
		document.addEventListener('CKEditor:initialized', this.toggleButtonsPosition.bind(this));
		this.toggleButtonsPosition();
	}

	componentDidUpdate(prevProps, prevState, snapshot) {
		let oldIncludedAttachments = prevState.attachments.allFiles.included;
		let newIncludedAttachments = this.state.attachments.allFiles.included;
		let {selectedTab} = this.state;

		if (newIncludedAttachments.length !== oldIncludedAttachments.length) {
			setTimeout(() => {
				Dispatcher.dispatch({
					type: ActionTypes.REQUEST_EDITOR_RESIZE,
				});
			}, 1);
		}

		if (selectedTab !== prevState.selectedTab) {
			this.toggleButtonsPosition();
			this.setPreviewHeight();
		}
	}

	sendGoogleAnalytics() {
		googleAnalytics('send', 'event', 'Sales Edge', 'Lightning Updates Pdf Select');
	}

	updateLayoutOnWindowEvent(eventName) {
		handleEventOnRequestAnimation(window, eventName, () => {
			this.toggleButtonsPosition()
			this.setPreviewHeight(eventName)
		});
	}

	setPreviewHeight(eventName) {
		if (eventName && this.state.selectedTab === Tabs.Edit) {
			return;
		}
		// get ready for some brittle hacky shit
		let {
			iframe,
			composer,
			buttons
		} = this.refs;
		iframe = iframe.childNodes[0];

		let {
			height: iframeHeight,
			bottom: iframeBottom
		} = iframe.getBoundingClientRect();

		let {
			bottom: composerBottom
		} = composer.getBoundingClientRect();

		let {
			height: buttonsHeight,
			top: buttonsTop
		} = buttons.getBoundingClientRect();

		let classicFooterOffset = (this.state.isClassicEnabled ? ClassicFooterOffset - getWindowScrollOffset() - (buttonsTop - (getWindowHeight() - buttonsHeight)) : 0);

		iframe.style.height = `${ iframeHeight + (composerBottom - iframeBottom) - buttonsHeight - classicFooterOffset }px`;
	}

	toggleButtonsPosition() {
		/**
		 Normally it is best practice to use this.setState() to set a boolean to toggle a css class
		 for the desired style, but since this function is called in a handler for scroll events,
		 the number of computations have been reduced significantly by toggling the class of the
		 element directly.
		 */
		let {buttons} = this.refs;
		let composerRect = this.refs.composer.getBoundingClientRect();

		if (buttons.classList.contains('absolute')) {
			if (composerRect.bottom >= window.innerHeight) {
				buttons.classList.remove('absolute');
			}
		} else {
			let buttonsRect = buttons.getBoundingClientRect()
			if (buttonsRect.bottom > composerRect.bottom) {
				buttons.classList.add('absolute');
			}
		}
	}

	editorTabClicked() {
		Dispatcher.dispatch({
			type: ActionTypes.CLICK_EDIT_TAB
		});
	}

	previewerTabClicked() {
		Dispatcher.dispatch({
			type: ActionTypes.CLICK_PREVIEW_TAB
		});
	}

	render() {
		let {
			templateFoldersSanitized,
			errorFetchingTemplatesData,
		} = this.state;

		return (
			<div className='slds-grid slds-grid--frame slds-wrap'>
				<div className='slds-size--1-of-1'>
					<div className='slds-page-header' role='banner'>
						<div className='slds-page-header__title slds-text-align--center' title='Send Engage Email'>
							Send Engage Email
						</div>
					</div>
				</div>
				<div className='slds-size--1-of-4'>
					<div className='frame-height'>
						<TemplateChooser templateFolders={templateFoldersSanitized} emailTemplates={this.getTemplatesFromFolders(templateFoldersSanitized)} errorFetchingTemplatesData={errorFetchingTemplatesData}/>
					</div>
				</div>
				<div className='slds-size--3-of-4'>
					<div className='frame-height'>
						<div className='full-height slds-col--rule-left slds-p-horizontal--small' ref='composer'>
							<div className='full-height'>
								{this.renderSendingEmailSpinner()}
								{this.renderTabs()}
								{this.renderButtons()}
							</div>
						</div>
					</div>
				</div>
			</div>
		);
	}

	renderTabs() {
		let editTabActiveClass = '';
		let previewTabActiveClass = '';
		let editorAreaHideClass = '';
		let previewAreaHideClass = '';

		let isEditorTab = this.state.selectedTab === Tabs.Edit;

		if (isEditorTab) {
			editTabActiveClass = 'slds-active';
			previewAreaHideClass = 'slds-hide';
		} else {
			previewTabActiveClass = 'slds-active';
			editorAreaHideClass = 'slds-hide';
		}

		let recipients = this.state.recipients.withEmail();

		return (
			<div className='slds-tabs--default full-height'>
				<section className="slds-clearfix">
					<ul className='slds-tabs--default__nav' role='tablist'>
						<li className={'slds-tabs--default__item slds-text-heading--label ' + editTabActiveClass} title='Edit' role='presentation'>
							<a onClick={this.editorTabClicked.bind(this)} id='email_form_link' className='slds-tabs--default__link' role='tab' tabIndex='0' aria-selected='true' aria-controls='email_form'>
								EDIT
							</a>
						</li>
						<li className={'slds-tabs--default__item slds-text-heading--label ' + previewTabActiveClass} title='Preview' role='presentation'>
							<a onClick={this.previewerTabClicked.bind(this)} id='preview_area_link' className='slds-tabs--default__link' role='tab' tabIndex='0' aria-selected='false' aria-controls='preview_area'>
								PREVIEW
							</a>
						</li>
					</ul>
				</section>
				<EngageMessages />
				<div className='slds-grid full-height'>
					<div className='slds-col full-width'>
						<div id='preview_area' className={'full-height slds-tabs--default__content ' + previewAreaHideClass} role='tabpanel' aria-labelledby='preview_area_link'>
							{this.renderPreviewArea(recipients, isEditorTab)}
						</div>
						<div className={'email-form slds-tabs--default__content ' + editorAreaHideClass} role='tabpanel' aria-labelledby='email_form_link'>
							{this.renderEditArea(recipients, isEditorTab)}
						</div>
					</div>
				</div>
			</div>
		);
	}

	renderSendingEmailSpinner() {
		if (this.state.sendingEmail) {
			return (
				<Spinner type={Spinner.Types.Brand} size={Spinner.Sizes.Large}>
					<div className='slds-text-heading--medium'>
						Sending...
					</div>
				</Spinner>
			);
		}
	}

	getTemplatesFromFolders(templateFolders) {
        return templateFolders.reduce((templates, folder) => {
            if (folder.templates && folder.templates.length > 0) {
                templates.push(...folder.templates);
            }
            return templates;
        }, [])
    }

	previewAsRecipientSelected(id) {
		const recipient = id ? this.state.recipients.get(id) : null;

		Dispatcher.dispatch({
			type: ActionTypes.POPULATE_MERGE_TAGS,
			recipient
		});
	}

	renderRecipientsPreviewSelect(recipients) {
		const items = recipients.map((r) => ({
			key: r.id,
			value: `${r.name} (${r.email})`
		}));

		return (
			<div className='form-control slds-clearfix slds-m-top--x-small'>
				<Combobox label='Preview as'
						  placeholder='Select a recipient'
						  items={items}
						  onSelect={this.previewAsRecipientSelected.bind(this)}/>
			</div>
		);
	}

	renderPreviewArea(recipients) {
		let {
			template,
			previewHtml,
			previewSubject,
			sendOnBehalfOf
		} = this.state;
		let html = stripHighlightedVariableTagsFromHtml(previewHtml);

		let iframeHideClass = template.loading ? 'slds-hide' : '';
		let subjectFieldProps = {
			isPreviewing: true,
			isSoboing: isSoboingAsOther(sendOnBehalfOf.selected),
			subject: previewSubject,
			sendOnBehalfOf
		};

		return (
			<div>
				<ComposerRecipients recipients={recipients}/>
				{this.renderSendOnBehalfOf(false)}
				{this.renderRecipientsPreviewSelect(recipients)}
				<SubjectField {...subjectFieldProps} />
				<div className='preview-area slds-m-top--small'>
					{this.renderLoadingTemplate()}
					{this.renderPopulatingMergeTags()}
					<div className={iframeHideClass + ' full-size'} ref='iframe'>
						<IFrame html={html} shouldUpdate={this.state.selectedTab === Tabs.Preview} setPreviewHeight={this.setPreviewHeight} />
					</div>
				</div>
			</div>
		);
	}

	renderSendOnBehalfOf(includeControls = true) {
		let {
			sendOnBehalfOf
		} = this.state;

		let {
			leadOwner,
			contactOwner,
			accountOwner
		} = sendOnBehalfOf.abilities;

		let soboProps = {
			...sendOnBehalfOf,
			recipients: this.state.recipients.withEmail(),
			includeControls
		};

		if (leadOwner || contactOwner || accountOwner) {
			return <SendOnBehalfOf { ...soboProps } />;
		}

		return null;
	}

	renderPopulatingMergeTags() {
		let spinnerHideClass = !this.state.populatingMergeTags ? 'slds-hide' : '';
		let populatingText = this.state.hmlEnabled ? ' merge fields' : ' variable tags';

		return (
			<div className={spinnerHideClass + ' full-size'}>
				<Spinner size={Spinner.Sizes.Large} type={Spinner.Types.Brand} container={Spinner.Containers.Fixed}>
					<div className='slds-text-heading--medium'>
						Populating{populatingText}&hellip;
					</div>
				</Spinner>
			</div>
		);
	}

	renderLoadingTemplate() {
		let spinnerHideClass = !this.state.template.loading ? 'slds-hide' : '';

		return (
			<div className={spinnerHideClass + ' full-size'}>
				<Spinner size={Spinner.Sizes.Large} type={Spinner.Types.Brand} container={Spinner.Containers.Fixed}>
					<div className='slds-text-heading--medium'>
						Loading Template...
					</div>
				</Spinner>
			</div>
		);
	}

	/**
	 * Handles a click on the delete X icon on an attachment card
	 *
	 * @param {string} targetKey Unique key for this attachment
	 * @param {MouseEvent} event
	 */
	deleteAttachmentCallback(targetKey, event) {
		Dispatcher.dispatch({
			type: ActionTypes.REMOVE_ATTACHMENT_FILE,
			key: targetKey,
		});
	}

	renderAttachmentsForEdit() {
		let {
			attachments: {
				allFiles: {
					included: includedAttachments,
					currentProgress,
					progressTracker,
				},
			},
		} = this.state;

		if (includedAttachments.length <= 0) {
			return;
		}
		return <div className={`${AttachmentContainerClass} ${AttachmentContainerEditTabClass}`}>
			{includedAttachments.map((attachment) => {
				return <AttachmentCard
					progress={(progressTracker && progressTracker.getCurrentFileKey() === attachment.key) ? currentProgress : 0}
					deleteCallback={this.deleteAttachmentCallback.bind(this, attachment.key)}
					{...attachment}
				/>;
			})}
		</div>;
	}

	renderEditArea(recipients, isEditorTab) {
		return (
			<div className=''>
				<ComposerRecipients recipients={recipients} isEditorTab={isEditorTab}/>
				{this.renderSendOnBehalfOf()}
				{this.renderSubjectInput()}
				<div id='ck_editor_wrapper' className='slds-m-top--small'>
					{this.renderLoadingTemplate()}
				</div>
				{this.renderAttachmentsForEdit()}
			</div>
		);
	}

	renderSubjectInput() {
		let {
			template,
			sendOnBehalfOf,
			subjectLastCursorPosition
		} = this.state;

		let props = {
			isPreviewing: false,
			isSoboing: isSoboingAsOther(sendOnBehalfOf.selected),
			lastCursorPosition: subjectLastCursorPosition,
			subject:  htmlDecode(template.subject).replace(/\\'/g, "'"),
			onChange(subject, lastCursorPosition) {
				Dispatcher.dispatch({
					type: ActionTypes.SUBJECT_CHANGED,
					subject,
					lastCursorPosition
				})
			},
			sendOnBehalfOf
		};

		return (
			<div className='form-control slds-clearfix slds-m-top--x-small'>
				<label htmlFor='subject' className='label slds-float--left slds-m-top--x-small slds-text-align--right slds-p-right--small slds-text-color--weak'>
					Subject
				</label>
				<div className='control slds-float--right'>
					<div className='slds-form-element__control'>
						<SubjectField {...props} />
					</div>
				</div>
			</div>
		);
	}

	renderButtons() {
		let {
			template,
			editorDirty,
			sendingEmail,
			sendError,
			sendLimit,
			recipients,
			emailSuccessfullySent,
			sendOnBehalfOf: sobo,
			attachments: {
				allFiles: {
					progressTracker,
					included,
				},
				image: {
					fileUploading: imageUploading,
				}
			}
		} = this.state;

		let sendProps = {};

		let hasSubject = template.subject && template.subject.trim();
		let overSendLimit = sendLimit && sendLimit.remaining - recipients.withEmail().length < 0;
		let maxRecipients = sendLimit ? sendLimit.remaining : MaximumEngageEmailRecipients;
		let tooManyRecipients = recipients.withEmail().length > maxRecipients;
		let hasDraftedEmail = template.id != -1 || editorDirty || included.length > 0;
		let checkingSobo = ['lead', 'contact', 'account'].find(t => sobo.abilities[t + 'Owner'])
			&& sobo.selected && sobo.selected !== SendOnBehalfOfOptions.Self
			&& !sobo.recipientPermissions.hasChecked;

		if (!hasDraftedEmail || !hasSubject || sendingEmail || overSendLimit || tooManyRecipients || emailSuccessfullySent || checkingSobo || progressTracker || imageUploading) {
			sendProps.disabled = 'disabled';
		}

		return (
			<div className='fixed-buttons-wrapper' ref='buttons'>
				<div className='slds-m-around--small slds-text-align--right'>
					<button onClick={this.cancelButtonClicked.bind(this)} className='slds-button slds-button--neutral'>Cancel</button>
					<button onClick={this.sendButtonClicked.bind(this)} className='slds-button slds-button--brand' {...sendProps}>Send</button>
				</div>
			</div>
		);
	}
}

const stripHighlightedVariableTagsFromHtml = (previewHtml) => {
	if (!previewHtml) {
		return '';
	}

	let showRegex = new RegExp('class="' + EmailTemplateConstants.unsupportedTagIdentifier + '"', 'g');
	let hideRegex = 'class="' + EmailTemplateConstants.unsupportedTagIdentifier + '" style="display: none;"';
	return previewHtml.replace(/contenteditable=(\")?true(\")?/gi, '').replace(showRegex, hideRegex);

}

const isSoboingAsOther = (selected) => selected && selected !== SendOnBehalfOfOptions.Self;
