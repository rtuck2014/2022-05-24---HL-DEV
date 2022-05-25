import React from 'react'
import ReactDOMServer, {renderToString} from 'react-dom/server';
import {
	NO_TEMPLATE_ID,
	ckeditorClass,
	unsupportedTagIdentifier,
	unsupportedTagSvgIdPrefix,
	unsupportedTagBufferIdentifier,
	imageAttachmentIdentifier,
	hmlMergeFieldPlaceHolderIdentifier,
	types
} from './email_template_constants'
import EngageEmailStore from './stores/engage-email-store'
import toastMessage from './toast-message'
import { decodeTemplateHtml, htmlDecode } from './decoder'
import {
	AttachmentCard,
	AttachmentLinkRawHtml,
} from './components/attachment-card.jsx'
import { AttachmentDeleteButton } from './components/attachment-delete-button.jsx'
import Dispatcher from './dispatcher'
import ActionTypes from './action-types'
import createCustomEvent from '../../../js/event-creator'
import ErrorMessages from './error_messages'
import Tabs from './tabs'
import { handleEventOnRequestAnimation, identicalArrays, dedupeArray, parsePardotVariableTags, showToastMessage } from './util'
import {AttachmentContainerEditTabClass, SendOnBehalfOfOptions, UnsupportedUserTags} from './constants';
import { warningIconMarkup } from './svg'
import {
    AttachmentDeleteClass,
	AttachmentContainerClass,
	AttachmentLinkClass,
	AttachmentLinkTargetClass,
	AttachmentCardClass,
	AttachmentProgressBarContainerClass,
	AttachmentProgressBarClass,
	EditorMinimumHeight,
	EditorKyleSmidgeHeight,
	EditorAttachmentCardBreakpoint,
	AttachmentImageClass,
	AttachmentTypes
} from './constants'
import {
	isFireFox
} from '../../../js/browser-check'
import PopoverMsg from "./components/popover-msg.jsx";

const {
	TEXT_HTML,
	TEXT_ONLY
} = types;

/**
 * An email template editor.
 *
 * The email template editor is used to edit email templates based over from
 * pardot. Internally it uses an instance of CKEDITOR to manage the editing
 * of the templates.
 *
 * @param CKEDITOR an instance of CKEDITOR.
 * @param string id of where to place the editor on the DOM.
 * @param HtmlConverter an html to text converter.
 * @param jQuery a jQuery instance.
 */
export default function EmailTemplateEditor(ckEditor, containerId, htmlConverter, jQuery) {
	ckEditor.appendTo(containerId, null, null);
	ckEditor.config.height = 400;
	ckEditor.config.disallowedContent = '*[on*]';

	this.editor = ckEditor.instances.editor1;
	this.instanceReady = new Promise((resolve) => {
		CKEDITOR.on('instanceReady', resolve)
	})
	this.htmlConverter = htmlConverter;
	this.htmlHasChanged = false;
	this.$ = jQuery;
	this.hasLockedRegions = false;
	this.contextDefinitions = null;
	this.menuOptionsRemoved = false;
	this.lastIncludedAttachmentCount = 0;

	updateStateFromStore.call(this);
	EngageEmailStore.setGetEditedTemplateFn(this.getTemplate.bind(this));
	EngageEmailStore.addListener(updateStateFromStore.bind(this));

	// CKeditor does weird things if you press ctrl-z too many times and
	// takes you back to the previous template you were on regardless of
	// locked regions, this prevents that from happening
	//
	// prevent tab in IE, it has weird behavior regardless of locked regions
	this.editor.on('key', function(event) {
		let body = document.querySelector(ckeditorClass).contentWindow.document.body;
		let attachmentContainer = body.querySelector(`.${AttachmentContainerClass}`);
		// If there are attachments in the editor, check if we need to cancel this event to avoid editing the attachment cards
		if (attachmentContainer) {
			handleEditorKeyWithAttachment(event, body, attachmentContainer);
		}

		if (event.data.keyCode == 9) {
			var startElement = event.editor.getSelection().getStartElement();
			var isBulletListElement = startElement.getAscendant('ul');
			var isIE = !!navigator.userAgent.match(/Trident/g) || !!navigator.userAgent.match(/MSIE/g) || !!navigator.userAgent.match(/Edge/g);
			if (isIE && !isBulletListElement) {
				return false;
			}
		}
	});

	this.editor.on('change', function(event) {
		unsupportedTagCheckOnChange(event);
	})

	this.editor.on('focus', (e) => {
		let event = createCustomEvent('CKEditor:focus', {});
		document.dispatchEvent(event);
	});

	/**
	 * On selection change, check to see if selection is in an attachment card. If so, set it to the first editable
	 * position before the attachment container.
	 *
	 * This is a messy pile of crap. The first attempt was setting the attachment container or cards to contenteditable=false.
	 * That failed because of https://github.com/ckeditor/ckeditor-dev/blob/1e4ca706d26294e969e5048231f18bc5d39b7ff3/core/selection.js#L596-L599
	 * The next attempt was trying to cancel this event, but it's not cancelable because the cursor has already moved.
	 * The next attempt was handling native onselectstart events, which are cancelable, but don't include any information about
	 * the DOM position they target (if you can figure that one out, use it instead). Finally we arrive at this, which
	 * detects a selectionChange we don't like and moves the cursor back. In combination with handleEditorKeyWithAttachment
	 * suppressing keyboard arrows we don't like, we have a hacky contenteditable=false.
	 */
	this.editor.on('selectionChange', (event) => {
		let editor = event.editor;
		let body = editor.document.$.body;
		let attachmentContainer = body.querySelector(`.${AttachmentContainerClass}`);

		if (!attachmentContainer) {
			return;
		}

		let attachmentContainer_ckEditor = new CKEDITOR.dom.element(attachmentContainer);
		let ranges = event.data.selection.getRanges();

		if (ranges.length === 1) {
			let range = ranges[0];
			if (range.endContainer && range.endContainer.$.parentElement) {
				let parentContainer = range.endContainer.$.parentElement;
				if (this.$(parentContainer).closest(`.${AttachmentContainerClass}`)) {
					let newRange = editor.createRange();
					newRange.setStartBefore(attachmentContainer_ckEditor);
					newRange.setEndBefore(attachmentContainer_ckEditor);

					let previousEditableNode = newRange.getPreviousEditableNode();
					range.moveToPosition(previousEditableNode, CKEDITOR.POSITION_BEFORE_END);
					range.select();
				}
			}
		}
	});

	this.instanceReady.then(() => {
		let event = createCustomEvent('CKEditor:initialized', {});
		document.dispatchEvent(event);
		setupResize.call(this);
		resizeEditorToWindow.call(this);
		this.editor.on('afterSetData', () => {
			resizeEditorToWindow.call(this)
		});
		setFileAttachmentsListener.call(this);
		setImageFileAttachmentsListener.call(this);
		setHmlFieldPickerListener.call(this);

		showHmlFirstTimeNotification();
		closeHmlFirstTimeNotification.call(this);
		closeXHmlFirstTimeNotification.call(this);
	});

};

function unsupportedTagCheckOnChange(event = null) {
	let editor = event ? event.editor : CKEDITOR.instances.editor1;
	let data = editor.getData();

	let unsupportedTagsFound = null;
	let selectedSOBO = EngageEmailStore.get().sendOnBehalfOf.selected;
	let soboEnabled = EngageEmailStore.get().soboEnabled;
	let allOwnersExistInPardot = EngageEmailStore.get().sendOnBehalfOf.allOwnersInPardot;
	if (allOwnersExistInPardot === null) {
		allOwnersExistInPardot = true;
	}
	let needsTagConfirming = !EngageEmailStore.get().unsupportedTagsConfirmed;

	if (soboEnabled && selectedSOBO && selectedSOBO !== SendOnBehalfOfOptions.Self && !allOwnersExistInPardot){
		let unsupportedTagsFoundInBody = EngageEmailStore.get().unsupportedTagsFoundInBody;

		unsupportedTagsFound = getUnsupportedTagsFoundInText(data);
		if (!identicalArrays(unsupportedTagsFound, unsupportedTagsFoundInBody)) {
			handleUnsupportedTagFeedback(unsupportedTagsFound, editor);
			stripCkEditorBsTitleElement();

			//user added a new unsupported tag that needs to be confirmed
			if (unsupportedTagsFound.length >= unsupportedTagsFoundInBody.length) {
				needsTagConfirming = true;
			}
		}
	}

	Dispatcher.dispatch({
		type: ActionTypes.TEMPLATE_BODY_CHANGED,
		unsupportedTagsFound,
		needsTagConfirming
	});
}

/**
 * Determines if a keypress should be canceled to prevent editing of attachment cards. Suppresses keypresses at the end
 * of the editable document, right above the attachment container.
 *
 * @param {CKEDITOR.event} event
 * @param {Element} body
 * @param {Element} attachmentContainer
 */
function handleEditorKeyWithAttachment(event, body, attachmentContainer) {
	let key = event.data.domEvent.$.key;
	let editor = event.editor;

	if (key === 'ArrowRight' || key === 'ArrowDown') {
		let ranges = editor.getSelection(true).getRanges();
		ranges.some((range) => {
			let endContainer = range.endContainer.$;
			let isCursorAtEndOfBody = false;

			// endOffset has different meanings for different node types
			switch (endContainer.nodeType) {
				case Node.TEXT_NODE:
				case Node.COMMENT_NODE:
					// Anywhere is the edge of a text node if the down arrow is pressed. For the right arrow, only the end is the edge.
					let isCursorAtEdgeOfElement = key === 'ArrowDown' ? true : range.endOffset === endContainer.length;
					let nextSibling = endContainer.nextElementSibling;
					if (nextSibling) {
						// More random CKEditor BS for Firefox
						if (nextSibling.localName === 'br' && nextSibling.getAttribute('type') === '_moz') {
							nextSibling = nextSibling.nextElementSibling;
						}
						isCursorAtEndOfBody = nextSibling.classList.contains(AttachmentContainerClass) && isCursorAtEdgeOfElement;
					}
					break;
				case Node.ELEMENT_NODE:
					isCursorAtEndOfBody = range.endOffset === Array.from(endContainer.childNodes).indexOf(attachmentContainer);
					break;
				default:
					console.log(`Editor key attachment check failed for unhandled node type ${endContainer.nodeType}`);
					break;
			}
			if (isCursorAtEndOfBody) {
				event.cancel();
				return true;
			}
			return false;
		})
	}
}

/**
 * @param varTagsChanged
 * @param unsupportedTagsFound
 * @param editor
 *
 * This function triggers the user feedback for unsupported tags (anything that isn't user email, first/last/full name).
 * It first cleans the text of old divs and then adds new divs where unsupported tags are found.
 * The toast message is displayed anytime there are unsupported tags found.
 */

function handleUnsupportedTagFeedback(unsupportedTagsFound, editor) {
	let bodyBeforeBookmark = editor.document.getBody().getHtml();
	//save cursor spot so we can restore after replacing body
	let bookmark = editor.getSelection().createBookmarks(true);
	let body = editor.document.getBody().getHtml();
	let bookmarkIsInsideTag = parsePardotVariableTags(body).length !== parsePardotVariableTags(bodyBeforeBookmark).length;

	if (bookmarkIsInsideTag) {
		body = shiftBookMarkToEndOfVariableTag(bookmark, body);
	}

	//remove highlight divs -- will add back later if necessary.
	body = removeHighlightElementsFrom(body);

	//wrap current unsupported tags in body with highlighted divs
	if (unsupportedTagsFound !== null) {
		addHighlightDivs(unsupportedTagsFound, body);
	}
	//restore cursor location
	editor.getSelection().selectBookmarks(bookmark);
}

export function showPmlValidationFailedToastMessage() {
	showToastMessage(ErrorMessages.messageWhenPmlTagsFoundInHmlContent(), toastMessage.Types.Error);
}

export function showErrorLoadingLexTemplateToastMessage(templateName) {
	showToastMessage(ErrorMessages.messageWhenErrorLoadingLexTemplate(templateName), toastMessage.Types.Error);
}

function shiftBookMarkToEndOfVariableTag(bookmark, body) {
	let placeholder = `<span id="${bookmark[0].startNode}" style="display: none;">&nbsp;</span>`;
	let index = body.indexOf(placeholder);
	let nextClosingTagIndex = body.substring(index + placeholder.length).indexOf('%%');
	let [beginning, end] = body.split(placeholder);
	let restOfTag = end.substring(0, nextClosingTagIndex + 2);
	return beginning + restOfTag + placeholder + end.substring(nextClosingTagIndex + 2);
}

export function removeHighlightDivs() {
	let body = getEditorBodyText();
	body = removeHighlightElementsFrom(body);
	$(ckeditorClass).contents()[0].body.innerHTML = body;
}

function removeHighlightElementsFrom(body) {
	let unWrappedBody = $('<div />').append(body)
	//remove parent div (the highlighting)
		.find(`.${unsupportedTagIdentifier}`).children().unwrap().end().end()
		//remove warning icon
		.find(`svg[id^="${unsupportedTagSvgIdPrefix}"]`).each((index, node) => {
			node.parentNode.removeChild(node)
		}).end()
		//remove any empty spans (just in case)
		.find(`.${unsupportedTagIdentifier}:empty`).each((index, node) => {
			node.parentNode.removeChild(node)
		}).end();

	// If template locking is enabled, remove the buffer span
	if (unWrappedBody.html().includes("pardot-region")) {
		unWrappedBody
			//remove parent span - if there are child elements
			.find(`.${unsupportedTagBufferIdentifier}`).children().unwrap().end().end()
			//remove parent span - if there are only text children
			.find(`.${unsupportedTagBufferIdentifier}`).each(function() {
				$(this).replaceWith(this.childNodes)
			}).end()
			// remove empty buffer span
			.find(`.${unsupportedTagBufferIdentifier}`).each((index, node) => {
				node.parentNode.removeChild(node)
			}).end();
	}

	return unWrappedBody.html();
}

export function insertAttachmentImage(imageFile, width, height) {
	let body = document.querySelector(ckeditorClass).contentWindow.document.body;
	let bookmarks = CKEDITOR.instances.editor1.getSelection().createBookmarks();
	let isLockedTemplate = body.outerHTML.includes("pardot-region");
	let isFirefoxLockedTemplate = false;
	let isSelectionInUnlockedRegion = false;

	if (bookmarks.length > 0 && isFireFox() && isLockedTemplate) {
		isFirefoxLockedTemplate = true;
		let selectionParents = bookmarks[0].startNode.getParents();
		let unlockedParent = selectionParents.find(function(parent) { return parent.hasAttribute('pardot-region') });
		isSelectionInUnlockedRegion = unlockedParent ? true : false;
	}

	if (bookmarks.length > 0 && (!isFirefoxLockedTemplate || (isFirefoxLockedTemplate && isSelectionInUnlockedRegion))) {
		bookmarks[0].startNode.addClass(imageAttachmentIdentifier);
		let imagePlaceholder = body.querySelector(`.${imageAttachmentIdentifier}`);
		let image = getImage(imageFile, width, height);
		imagePlaceholder.parentNode.replaceChild(image, imagePlaceholder);
	} else if (isLockedTemplate) {
		let firstEditableRegion = body.querySelector("[pardot-region]");
		insertBeforeEditorSelection(firstEditableRegion, imageFile, width, height);
	} else {
		insertBeforeEditorSelection(body, imageFile, width, height);
	}
}

export function insertHmlMergeField(mergeField) {
	let body = document.querySelector(ckeditorClass).contentWindow.document.body;
	let bookmarks = CKEDITOR.instances.editor1.getSelection().createBookmarks();
	let mergeFieldTextNode = document.createTextNode(mergeField.code);

	if (bookmarks.length > 0) {
		bookmarks[0].startNode.addClass(hmlMergeFieldPlaceHolderIdentifier);
		let mergeFieldPlaceholder = body.querySelector(`.${hmlMergeFieldPlaceHolderIdentifier}`);
		mergeFieldPlaceholder.parentNode.replaceChild(mergeFieldTextNode, mergeFieldPlaceholder);
	} else {
		let isLockedTemplate = body.outerHTML.includes("pardot-region");
		if (isLockedTemplate) {
			let firstEditableRegion = body.querySelector("[pardot-region]");
			insertMergeFieldBeforeEditorSelection(firstEditableRegion, mergeFieldTextNode);
		} else {
			insertMergeFieldBeforeEditorSelection(body, mergeFieldTextNode);
		}
	}
	unsupportedTagCheckOnChange();
}

function insertMergeFieldBeforeEditorSelection(element, mergeField) {
	if (element.firstChild) {
		element.insertBefore(mergeField, element.firstChild);
	} else {
		element.appendChild(mergeField);
	}
}

function insertBeforeEditorSelection(element, imageFile, width, height) {
	let image = getImage(imageFile, width, height);
	if (element.firstChild) {
		element.insertBefore(image, element.firstChild);
	} else {
		element.appendChild(image);
	}
}

function getImage(imageFile, width, height) {
	let image = document.createElement('img');
	image.className = AttachmentImageClass;
	image.style.height = height + "px";
	image.style.width = width + "px";
	image.src = decodeURIComponent(imageFile.contentDownloadUrl);
	image.alt = imageFile.title;

	return image;
}

/**
 * @param {jQuery} $html
 */
function addAttachmentCardsToEmailHtml($html) {
	let {
		attachments: {
			allFiles: {
				included,
			},
		},
	} = EngageEmailStore.get();

	included.forEach((attachment) => $html.append(ReactDOMServer.renderToStaticMarkup(AttachmentCard(attachment))));
}

/**
 * @param {string} template
 * @return {string}
 */
function stripAttachmentCards(template) {
	return template.replace(/(<\s*div[\s\w=\-]*class="sfdc-internal-attachment-card".*)<\/body>/g, '</body>');
}

export function addHighlightDivs(tags, body) {
	let { sendOnBehalfOf } = EngageEmailStore.get();
	let allOwnersExistsInPardot = sendOnBehalfOf.allOwnersInPardot;
	//Treat the null case the same as if allOwnersExistsInPardot is true
	if (allOwnersExistsInPardot === null) {
		allOwnersExistsInPardot = true;
	}
	if(!tags || allOwnersExistsInPardot === true || sendOnBehalfOf.recipientPermissions.loading === true) {
		return;
	}

	//dont want to add nest a bunch of divs/svgs if multiple of the same tag - so need to dedupe list.
	let dedupedTags = dedupeArray(tags);

	if (!body) {
		body = $(ckeditorClass).contents()[0].body.innerHTML;
	}

	let svgPath = warningIconMarkup();
	let templateContainsLockedRegions = body.includes("pardot-region");

	for (let i = 0; i < dedupedTags.length; i++) {
		let span = getHighlightSpan(i, dedupedTags, svgPath, templateContainsLockedRegions);
		body = body.replace(new RegExp(dedupedTags[i], 'g'), span);
	}
	//replace ckeditor body with new body
	$(ckeditorClass).contents()[0].body.innerHTML = body;
}

function getHighlightSpan(i, dedupedTags, svgPath, templateContainsLockedRegions) {
	let span =
		`<span contenteditable="false" class="${unsupportedTagIdentifier}" title="Unsupported Variable Tag">` +
		`<svg id="${unsupportedTagSvgIdPrefix + i}" width="1em" height="1em" viewBox="0 0 24 24">` +
		svgPath +
		'</svg>' +
		dedupedTags[i] +
		'</span>';

	if (templateContainsLockedRegions) {
		span += `<span class="${unsupportedTagBufferIdentifier}"></span>`;
	}

	return span;
}

export function getUnsupportedTagsFoundInText(text) {
	if (!text) {
		return null;
	}
	let tags = parsePardotVariableTags(text);
	return tags.filter(tag => UnsupportedUserTags.includes(tag.toLowerCase()));
}

export function getEditorBodyText() {
	return $(ckeditorClass).contents()[0].body.innerHTML;
}

function showHmlFirstTimeNotification() {
	if (!$('#HML_NEW_FEATURE_NOTIFICATION').length && $(".cke_button__hmlvariablefield").parent().parent().length > 0) {
		if (!window.localStorage.getItem('HmlUpgradeNotificationMessage')){
			let hmlMergeFieldButton = $(".cke_button__hmlvariablefield");
			let popOverHtml = renderToString(<PopoverMsg closeButtonId='HmlNewFeatureCloseXButton' gotItButtonId='HML_NEW_FEATURE_NOTIFICATION_got_it_button' messageType='HmlUpgradeNotificationMessage' id='HML_NEW_FEATURE_NOTIFICATION' nubbinPosition='slds-nubbin_left-top' additionalStyles='feature-popover-styles-hml' shouldRenderIcon='false' heading='Upgraded to HML' msg='We’ve upgraded Salesforce Engage to Handlebars Merge Language (HML). You can now use HML everywhere you work in Salesforce Lightning Experience.' renderFooter={true} additionalText='Tell Me More'/>);
			hmlMergeFieldButton.parent().parent().append(popOverHtml);

			let hmlNotificationTopPosition = hmlMergeFieldButton.position().top - 10;
			$("#HML_NEW_FEATURE_NOTIFICATION").css({ top: hmlNotificationTopPosition + 'px' });
		}
	}
}

function closeHmlFirstTimeNotification() {
	$("#HML_NEW_FEATURE_NOTIFICATION_got_it_button").click(function () {
		$("#HML_NEW_FEATURE_NOTIFICATION").hide();
		window.localStorage.setItem('HmlUpgradeNotificationMessage', 'true');
	});
}

function closeXHmlFirstTimeNotification() {
	$("#HmlNewFeatureCloseXButton").click(function () {
		$("#HML_NEW_FEATURE_NOTIFICATION").hide();
		window.localStorage.setItem('HmlUpgradeNotificationMessage', 'true');
	});
}

function setFileAttachmentsListener() {
	$(".cke_button__engageattachments_icon").click(function () {
		Dispatcher.dispatch({
			type: ActionTypes.SHOW_ATTACHMENTS_MODAL_CLICKED
		});
	});
}

function setImageFileAttachmentsListener() {
	$(".cke_button__engageimageattachments_icon").click(function () {
		Dispatcher.dispatch({
			type: ActionTypes.SHOW_IMAGE_ATTACHMENTS_MODAL_CLICKED
		});
	});
}

function setHmlFieldPickerListener() {
	$(".cke_button__hmlvariablefield").click(function () {
		Dispatcher.dispatch({
			type: ActionTypes.SHOW_HML_FIELD_PICKER_MODAL_CLICKED
		});
	});
}

function updateStateFromStore() {
	let {
		variableTags,
		template,
		selectedTab,
		editorResizeRequested,
	} = EngageEmailStore.get();

	updateTemplateIfChanged.call(this, template);
	updateVariableTagsIfChanged.call(this, variableTags);
	handleSelectedTabChanges.call(this, selectedTab, template);
	if (editorResizeRequested) {
		resizeEditorToWindow.call(this);
	}
}

/**
 *
 * @param {string} selectedTab
 * @param {Object} template
 * @param {string} template.html
 * @param {string} template.text
 * @param {string} template.id
 * @param {string} template.name
 * @param {string} template.subject
 * @param {string} template.type
 */
function handleSelectedTabChanges(selectedTab, template) {
	if (this.selectedTab === selectedTab) {
		return;
	}

	this.selectedTab = selectedTab;

	if (selectedTab === Tabs.Edit) {
		template.html = stripAttachmentCards(template.html);
		this.editor.focus();
		this.setTemplate(template).then(() => {
			return setReadOnlyMode.call(this, false);
		}).then(() => {
			if (this.hasLockedRegions) {
				this.setTemplateBodyContentEditable('false');
			}
			stripCkEditorBsTitleElement();
			resizeEditorToWindow.call(this);
		})
	} else {
		setReadOnlyMode.call(this, true);
	}
}

function setReadOnlyMode(isReadOnly) {
	return this.instanceReady.then(() => {
		this.editor.setReadOnly(isReadOnly);
	});
}

function updateVariableTagsIfChanged(variableTags) {
	let thisVariableTags = this.editor.config.pardotVariableTags;
	if (!thisVariableTags && variableTags || thisVariableTags && thisVariableTags.length !== variableTags.length) {
		this.editor.config.pardotVariableTags = variableTags;
		this.editor.config.pardotVariableTagErrorMessage = ErrorMessages.errorPardotGettingVariableTags();
	}
}

function updateTemplateIfChanged(storeTemplate) {

	if ((storeTemplate && !this.template ||
			storeTemplate.id !== this.template.id) &&
		!storeTemplate.loading) {
		this.setTemplate(storeTemplate);
	}
}

function subjectsAreNotEqual(t1, t2) {
	let s1 = t1.subject;
	let s2 = t2.subject;

	return ((s1 || s2) && s1 !== s2);
}


EmailTemplateEditor.prototype.lockedRegionsListeners = function()
{
	// when there aren't locked regions ckeditor doesn't respect
	// shift+tab, ignoring it when there are locked regions
	CKEDITOR.instances.editor1.on('key', function(event) {
		if (event.data.keyCode == 2228233) {
			event.data.domEvent.preventDefault();
		}
	});
}

/**
 * Prevent weird backspace/delete behavior when there are locked regions; only check when
 * selection offset is <=1 so we aren't checking all this every time there's a backspace or delete.
 * Only add listener if there are locked regions in the template. Sorry this is hacky :(
 */
EmailTemplateEditor.prototype.preventElementDeleteWithLockedRegions = function ()
{
	CKEDITOR.instances.editor1.on('key', function(event) {
		var selectionOffset = null;
		var types = {
			img: 1,
			ul: 1,
			li: 1,
			td: 1,
			tr: 1
		};
		try {
			selectionOffset = event.editor.getSelection().getRanges()[0].endOffset;
		} catch(err){
			return false;
		}
		if ((event.data.keyCode == 8 || event.data.keyCode == 46 || event.data.keyCode == 1114120 || event.data.keyCode == 2228232) && selectionOffset <= 1) {
			var ceElement = event.editor.getSelection().getStartElement();
			if (ceElement.getAttribute("contenteditable") !== "true") {
				ceElement = ceElement.getAscendant( function(el) {
					return el.type == CKEDITOR.NODE_ELEMENT && (el.getAttribute("contenteditable") === "true");
				});
			}
			var isParentContext = ceElement.getText() === event.editor.getSelection().getStartElement().getText();
			if (!isParentContext && selectionOffset == 0) {
				isParentContext = ($.trim(ceElement.getText()) === $.trim(event.editor.getSelection().getStartElement().getText())) ||
					($.trim(ceElement.getText()).includes($.trim(event.editor.getSelection().getStartElement().getText())));
			}
			var elementText = $.trim(event.editor.getSelection().getStartElement().getText()).replace(/[\u200B]/g, '');
			var hasSelectionText = event.editor.getSelection().getSelectedText().length > 0;
			var isInIgnoredTypes = event.editor.getSelection().getStartElement().is(types);
			if (!isInIgnoredTypes) {
				var ignoredTypeParent = event.editor.getSelection().getStartElement().getAscendant( function(el) {
					return el.type == CKEDITOR.NODE_ELEMENT && el.is(types);
				});
				isInIgnoredTypes = ignoredTypeParent ? true : false;
			}
			var htmlHasBr = event.editor.getSelection().getStartElement().getHtml().includes("br");
			var html = event.editor.getSelection().getStartElement().getHtml();
			var htmltext = event.editor.getSelection().getStartElement().getText();
			console.log(htmltext);
			var htmlIsBr =  htmlHasBr && html == "<br>";
			if (!isInIgnoredTypes && isParentContext && (selectionOffset == 0 || elementText.length == 0) && !hasSelectionText && ((htmlHasBr && htmlIsBr) || !htmlHasBr)) {
				if (htmlIsBr) {
					event.editor.getSelection().getStartElement().setHtml("");
				}
				var selection = event.editor.getSelection().getStartElement();
				while ((selection.getAttribute("contenteditable") !== "true" && selection.getAttribute("engageEditableRegionNoDisplay") !== "true") && elementText.length == 0) {
					var child = selection;
					selection = selection.getParent();
					child.remove();
				}
				selection.focus();
				return false;
			}
		}

		if (event.data.keyCode == 8 || event.data.keyCode == 46 || event.data.keyCode == 1114120 || event.data.keyCode == 2228232) {
			var shouldPreventDelete = checkSelectAllLockRegionDelete(event) || checkBackspaceLockRegionDelete(event);
			if (shouldPreventDelete) {
				event.data.domEvent.preventDefault();
				throw "Error: Attempt to delete undeletable region.";
			}
		}
	});
}

/**
 * Return the current edited template.
 */
EmailTemplateEditor.prototype.getTemplate = function ()
{
	var templateHtml = this.editor.getData();
	if (templateHtml.length > 0) {
		templateHtml = this.processTemplateForPreviewOrSend(templateHtml);
	}

	if (this.template) {
		this.template.html = templateHtml;
		this.template.text = this.htmlConverter.toText(this.template.html);
		this.template.text = this.$('<textarea/>').html(this.template.text).text();
		this.template.attachmentType = getAttachmentType(templateHtml);


		return {
			text: this.template.text,
			html: this.template.html,
			id: this.template.id,
			name: this.template.name,
			type: TEXT_HTML,
			attachmentType: this.template.attachmentType,
		};
	}

	return null;
};

EmailTemplateEditor.prototype.processTemplateForPreviewOrSend = function(templateHtml)
{
	let {
		bodyContent,
		before,
		after
	} = splitHtmlByBodyContent(templateHtml);

	let $html = this.$('<div>').html(bodyContent);
	removeUnlockedRegionsTemplateDivAdd($html);
	removeUnlockedPardotRegionImagesDiv($html);
	stripContentEditable($html);
	addAttachmentCardsToEmailHtml($html);
	before = removeContentsCss(before);

	return before + $html.html() + after;
}

function getAttachmentType(templateHtml) {
	let hasAttachmentFiles = includesAttachmentFiles(templateHtml);
	let hasInlineImages = includesInlineImages(templateHtml);

	if (hasAttachmentFiles && hasInlineImages) {
		return AttachmentTypes.FileAndImage;
	} else if (hasAttachmentFiles) {
		return AttachmentTypes.File;
	} else if (hasInlineImages) {
		return AttachmentTypes.Image;
	} else {
		return AttachmentTypes.None;
	}
}

function includesAttachmentFiles(templateHtml) {
	return templateHtml.includes(AttachmentCardClass);
}

function includesInlineImages(templateHtml) {
	return templateHtml.includes(AttachmentImageClass);
}

function removeContentsCss(markup) {
	let regex = /<link\s+(?=[^>]*\bid\s*=\W*sfdc-internal-mc-contents-css\W*)[^>]*>/img;
	return markup.replace(regex, '');
}

function splitHtmlByBodyContent(html) {
	let pattern =  /((.|[\n\r])*<body[^>]*>)((.|[\n\r])*)(<\/body>(.|[\n\r])*)/im;
	let matches = pattern.exec(html);

	if (matches) {
		let before = matches[1];
		let bodyContent = matches[3];
		let after = matches[5];

		return {
			bodyContent,
			before,
			after
		};
	}

	return {
		bodyContent: html,
		before: '',
		after: ''
	};
}

/**
 * Strip contenteditable = true attr before send
 *
 * @return string
 */
function stripContentEditable($html)
{
	$html.find('[contenteditable="true"]').removeAttr('contenteditable');
}

/**
 * For some reason CKEditor feels the need to mangle the HTML in the editor when we set its content with setData().
 * Usually this is tolerable, but sometimes for unknown reasons it inserts a <title> element inside the <body>, which
 * is invalid HTML and breaks our regex in splitHtmlByBodyContent(), which in turn breaks other processing (attachment
 * cards, unsupported tag highlighting, etc).
 *
 * So here we strip out any BS <title> elements that are in the editor <body>
 */
function stripCkEditorBsTitleElement() {
	let editorBody = document.querySelector(ckeditorClass).contentWindow.document.body;
	let bsTitleElements = Array.from(editorBody.querySelectorAll('title'));
	// Extra indirection because IE11 doesn't support remove()
	bsTitleElements.forEach((bsTitleElement) => bsTitleElement.parentElement.removeChild(bsTitleElement));
}

/**
 * Returns if the field has changed or not.
 *
 * @param string
 * @return boolean
 */
EmailTemplateEditor.prototype.hasFieldChanged = function (field)
{
	if (field === 'html') {
		return this.htmlHasChanged;
	} else {
		return false;
	}
};

function setupResize() {
	// Set a bit so we only resize most elements if they haven't been set.
	this._editorFitToWindow = false;

	handleEventOnRequestAnimation(window, 'resize', () => {
		this._editorFitToWindow = false;
		resizeEditorToWindow.call(this);
	})

	handleEventOnRequestAnimation(window, 'scroll', () => {
		this._editorFitToWindow = false;
		resizeEditorToWindow.call(this);
	})
}

/**
 * Sets the template body contenteditable value
 *
 * @param string
 */
EmailTemplateEditor.prototype.setTemplateBodyContentEditable = function (contentEditable)
{
	// find the body, and set contenteditbale
	var doc = $(ckeditorClass).contents()[0];
	if (doc !== undefined){
		doc.body.contentEditable = contentEditable;
	}
}

/**
 * Need to add special divs because contenteditable isnt
 * supported with all element types in IE
 *
 * Need to add special divs to all browsers so bullet
 * list doesn't clone divs and mess up template styling
 */
function unlockedRegionsTemplateDivAdd()
{
	// setTemplate could be called more than once and add these twice, don't add again if already added
	var hasAddedIeDivs = $(ckeditorClass).contents()[0].querySelectorAll("[sfdc-internal-mc-ieSpecialAddedLockedTemplateDiv]").length > 0;
	if (hasAddedIeDivs) {
		return;
	}
	var nodeNames = ["TABLE", "COL", "COLGROUP", "TBODY", "TD", "TFOOT", "TH", "THEAD", "TR"];
	var pardotRegions = $(ckeditorClass).contents()[0].querySelectorAll("[pardot-region]");

	for (var i = 0; i < pardotRegions.length; i++) {
		var region = pardotRegions[i];
		if (nodeNames.indexOf(region.nodeName) >= 0) {
			var regionChildNodes = [];

			while (region.firstChild) {
				regionChildNodes.push(region.removeChild(region.firstChild));
			}

			var contentEditableDiv = $(ckeditorClass).contents()[0].createElement('div');
			contentEditableDiv.setAttribute("contenteditable", "true");
			contentEditableDiv.setAttribute("sfdc-internal-mc-ieSpecialAddedLockedTemplateDiv", "");

			for (var j = 0; j < regionChildNodes.length; j++) {
				contentEditableDiv.appendChild(regionChildNodes[j]);
			}

			region.appendChild(contentEditableDiv);
			region.removeAttribute("contenteditable");
		}
	}

}

/**
 * Adds special divs to images with the pardot-region attr so that the unlocked icon will show.
 */
function encapsulatePardotRegionImages()
{
	// setTemplate could be called more than once and add these twice, don't add again if already added
	var hasAddedImageDivs = $(ckeditorClass).contents()[0].querySelectorAll("[sfdc-internal-mc-unlockImagesWithDiv]").length > 0;
	if (hasAddedImageDivs) {
		return;
	}
	var images = $(ckeditorClass).contents()[0].querySelectorAll("img[pardot-region]");

	for (var i = 0; i < images.length; i++) {
		var contentEditableDiv = $(ckeditorClass).contents()[0].createElement('div');
		contentEditableDiv.setAttribute("contenteditable", "true");
		contentEditableDiv.setAttribute("sfdc-internal-mc-unlockImagesWithDiv", "");
		contentEditableDiv.setAttribute("style", "margin: 0; padding: 0;");
		$(images[i]).wrap(contentEditableDiv);
	}
}

/**
 * Removes the divs encapsulating images with the pardot-region attribute. This should be called during the send process.
 */
function removeUnlockedPardotRegionImagesDiv($html) {
	let targetAttr = '[sfdc-internal-mc-unlockImagesWithDiv]';
	$html.find(targetAttr).children().unwrap(targetAttr);
}

function removeUnlockedRegionsTemplateDivAdd($html)
{
	let targetAttr = '[sfdc-internal-mc-ieSpecialAddedLockedTemplateDiv]';
	$html.find(targetAttr).children().unwrap(targetAttr);
}

/**
 * On selection, CKEditor wraps contenteditable=true children with a p tag
 * to do what it thinks is maintaining the html integrity and prevent content
 * collapse. When this happens, it can alter the formatting of the selected element.
 * Adding styling to these added p tags prevents them from altering the template styling
 */
function removeCkeditorAddedParagraphStyling()
{
	var hasAddedParagraphStyle = $(ckeditorClass).contents()[0].getElementById('sfdc-internal-mc-sfEngagetemplateLockingAddedP');
	if (hasAddedParagraphStyle) {
		return;
	}
	var templateParagraphs = $(ckeditorClass).contents()[0].getElementsByTagName("P");
	var templateBody = $(ckeditorClass).contents()[0].head;

	for (var i=0; i < templateParagraphs.length; i++) {
		var paragraph = templateParagraphs[i];
		paragraph.classList.add("nonCkeditorAddedP");
	}

	var style = $(ckeditorClass).contents()[0].createElement('style');
	style.setAttribute('id', 'sfdc-internal-mc-sfEngagetemplateLockingAddedP');
	style.type = 'text/css';
	var css = 'p:not(.nonCkeditorAddedP){display: inline;}';
	style.appendChild($(ckeditorClass).contents()[0].createTextNode(css));

	templateBody.appendChild(style);
}

/**
 * Sets the template.
 *
 * @param object
 */
EmailTemplateEditor.prototype.setTemplate = function(newTemplate)
{
	this.template = newTemplate;
	this.template.html = decodeTemplateHtml(this.template.html);
	this.template.subject = htmlDecode(this.template.subject).replace(/\\'/g, "'");
	this.template.name = htmlDecode(this.template.name).replace(/\\'/g, "'");
	this.hasLockedRegions = false;
	let includesPardotRegion = this.template.html.includes("pardot-region");
	// Check that this is a lex template by checking id, since lex template ids are not numbers
	let includesLexLockedRegion = this.template.html.includes('locked="1"') && isNaN(this.template.id);

	// We don't need to do anything if the template doesn't include pardot
	// regions. Without them, all regions are considered editable.
	if (includesPardotRegion || includesLexLockedRegion) {
		this.lockedRegionsListeners();
		this.preventElementDeleteWithLockedRegions();
		this.hasLockedRegions = true;

		// find all pardot-regions, and make those regions contenteditable=true
		if (includesPardotRegion) {
			this.template.html = this.template.html.replace(/pardot-region/g, 'contenteditable="true" pardot-region');
		}
		if (includesLexLockedRegion) {
			this.template.html = this.template.html.replace(/locked="0"/g, 'contenteditable="true" locked="0" pardot-region');
		}

		//get missing definitions in case we need to add these menu items back
		if (this.contextDefinitions == null && CKEDITOR.instances.editor1.getMenuItem !== undefined) {
			this.setContextDefinitions();
		}

		//restrict menu options
		this.updateContextMenu("remove");

		//mark removed
		this.menuOptionsRemoved = true;
	} else {
		if (this.menuOptionsRemoved) {
			this.updateContextMenu("add");
			this.menuOptionsRemoved = false;
		}
	}

	let {
		text,
		html,
		type
	} = this.template;

	let data = type == TEXT_ONLY ? text : html;

	if (type == TEXT_ONLY) {
		data = data.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
		data = data.replace(/\n/g, '<br />');
	} else {
		// this fixes lack of cursor visibility when tabbed to W-4497228
		if (isFireFox() && this.template.id == NO_TEMPLATE_ID) {
			data = '&#8203' + data;
		}
	}

	return new Promise((resolve, reject) => {
		this.editor.setData(data, {
			noSnapshot: true,
			callback: resolve
		});
	}).then(() => {
		if (this.editor.getData().includes('pardot-region') || (this.editor.getData().includes('locked="1"') && isNaN(this.template.id))) {
			var isIE = !!navigator.userAgent.match(/Trident/g) || !!navigator.userAgent.match(/MSIE/g) || !!navigator.userAgent.match(/Edge/g);
			if (isIE) {
				unlockedRegionsTemplateDivAdd();
			}
			encapsulatePardotRegionImages();
			removeCkeditorAddedParagraphStyling();
			this.setTemplateBodyContentEditable("false");

		}
		let { soboEnabled, sendOnBehalfOf } = EngageEmailStore.get();
		let selectedSOBO = sendOnBehalfOf.selected;
		let allOwnersExistsInPardot = sendOnBehalfOf.allOwnersInPardot;
		//Treat the null case the same as if allOwnersExistsInPardot is true
		if (allOwnersExistsInPardot === null) {
			allOwnersExistsInPardot = true;
		}

		if (soboEnabled && selectedSOBO && selectedSOBO !== SendOnBehalfOfOptions.Self && !allOwnersExistsInPardot && !sendOnBehalfOf.recipientPermissions.loading) {
			let unsupportedTagsFound = getUnsupportedTagsFoundInText(this.template.html);
			if (unsupportedTagsFound) {
				handleUnsupportedTagFeedback(unsupportedTagsFound, this.editor);
			}
		}

		stripCkEditorBsTitleElement();
		this.addContentsCss();
	});
};

EmailTemplateEditor.prototype.addContentsCss = function() {
	let { contentsCss } = this.editor.config;
	let node = this.editor.document.$.createElement('link');
	$(node)
		.attr('id', 'sfdc-internal-mc-contents-css')
		.attr('rel', 'stylesheet')
		.attr('type', 'text/css')
		.attr('href', contentsCss);

	this.editor.document.find('head').$[0].appendChild(node);
}

/**
 * Set the
 */
EmailTemplateEditor.prototype.setContextDefinitions = function ()
{
	this.contextDefinitions = [
		CKEDITOR.instances.editor1.getMenuItem('removediv'),
		CKEDITOR.instances.editor1.getMenuItem('editdiv'),
		CKEDITOR.instances.editor1.getMenuItem('table'),
		CKEDITOR.instances.editor1.getMenuItem('tabledelete'),
		CKEDITOR.instances.editor1.getMenuItem('tablecell'),
		CKEDITOR.instances.editor1.getMenuItem('tablerow'),
		CKEDITOR.instances.editor1.getMenuItem('tablecolumn')
	];
};

EmailTemplateEditor.prototype.updateContextMenu = function (type) {
	var item = null;
	var x;

	if (type == "add") {
		if (this.contextDefinitions) {
			for (x = 0; x < this.contextDefinitions.length; x++) {
				item = this.contextDefinitions[x];
				if (item) {
					CKEDITOR.instances.editor1._.menuItems[item.name] = item;
				}
			}
		}
	} else if (type == "remove") {
		if (this.contextDefinitions) {
			for (x = 0; x < this.contextDefinitions.length; x++) {
				item = this.contextDefinitions[x];
				if (item) {
					CKEDITOR.instances.editor1.removeMenuItem(item.name);
				}
			}
		}
	}
};

/**
 * Returns flag that is set if the currently loaded template
 * has locked regions
 */
EmailTemplateEditor.prototype.templateHasLockedRegions = function() {
	return this.hasLockedRegions;
}

function checkBackspaceLockRegionDelete(event)
{
	var c = event.data.keyCode == 8
		, d = event.editor.getSelection().getRanges()[0]
		, b = d.startPath();
	if (d.collapsed) {
		var e;
		a: {
			var f = b.block;
			if (f)
				if (d[c ? "checkStartOfBlock" : "checkEndOfBlock"]())
					if (!d.moveToClosestEditablePosition(f, !c) || !d.collapsed)
						e = false;
					else {
						if (d.startContainer.type == CKEDITOR.NODE_ELEMENT) {
							var h = d.startContainer.getChild(d.startOffset - (c ? 1 : 0));
							if (h && h.type == CKEDITOR.NODE_ELEMENT && h.is("hr")) {
								return true;
							}
						}
						if ((d = d.startPath().block) && (!d || !d.contains(f))) {
							return true;
						}
					}
				else
					e = false;
			else
				e = false
		}
		if (!e)
			return e;
	}
}

function checkSelectAllLockRegionDelete(event)
{
	var f = {
		table: 1,
		ul: 1,
		ol: 1,
		dl: 1
	};

	function b(a) {
		return function (b, e) {
			e && (b.type == CKEDITOR.NODE_ELEMENT && b.is(f)) && (d = b);
			if (!e || d) {
				return false;
			}
		}
	}

	var d;
	var r = event.editor.getSelection().root;
	var n = event.editor.getSelection().getRanges()[0].clone();
	n.collapse(1);
	n.setStartAt(r, CKEDITOR.POSITION_AFTER_START);
	var a = new CKEDITOR.dom.walker(n);
	a.guard = b();
	a.checkBackward();
	if (d)
		return true;
	return false;
}

function resizeEditorToWindow() {
	let container = $('#engage_email_container');
	let buttonsWrapper = $('.fixed-buttons-wrapper');
	let contents = $('#cke_1_contents');
	if (container.length === 0 || buttonsWrapper.length === 0 || contents.length === 0) {
		return;
	}

	let { top: editorTop } = contents.offset();
	let containerBottom = container.offset().top + container.height();
	let buttonsHeight = buttonsWrapper.height();
	let buttonsTop = buttonsWrapper.offset().top;
	let buttonsBottom = buttonsTop + buttonsHeight;
	let height = containerBottom - editorTop - buttonsHeight;

	if (containerBottom > buttonsBottom) {
		height = height - (containerBottom - buttonsBottom);
	}

	height = height - EditorKyleSmidgeHeight;

	if (height > EditorMinimumHeight) {
		let attachmentContainerHeight = getAttachmentContainerHeight();
		let attachmentHeightAllocation;
		if (height > (EditorAttachmentCardBreakpoint + attachmentContainerHeight)) {
			// Attachment container is completely showing
			attachmentHeightAllocation = attachmentContainerHeight;
		} else if (height > EditorAttachmentCardBreakpoint) {
			// Attachment container is partly showing
			attachmentHeightAllocation = Math.max(height - EditorAttachmentCardBreakpoint, getAttachmentContainerMinimumHeight(attachmentContainerHeight));
		} else {
			attachmentHeightAllocation = getAttachmentContainerMinimumHeight(attachmentContainerHeight);
		}

		height -= attachmentHeightAllocation;
		this.editor.resize('100%', height, true);
	}

	let { editorResizeRequested } = EngageEmailStore.get();
	if (editorResizeRequested) {
		// Use setTimeout so we don't violate Flux's "no dispatch within a dispatch" restriction
		// I'm not proud of this and am open to other suggestions
		setTimeout(() => {
			Dispatcher.dispatch({
				type: ActionTypes.COMPLETE_EDITOR_RESIZE,
			});
		}, 1);
	}
}

function getAttachmentContainerMinimumHeight(attachmentContainerHeight) {
	let attachmentCards = $(`.${AttachmentCardClass}`);

	if (attachmentContainerHeight && attachmentCards && attachmentCards.length > 0) {
		return attachmentCards.first().height() + 2;
	}

	return 0;
}

function getAttachmentContainerHeight() {
	// There's an attachment container in the preview tab too, we don't want that one
	let container = $(`.${AttachmentContainerClass}.${AttachmentContainerEditTabClass}`);
	return container.length > 0 ? container.height() : 0;
}
