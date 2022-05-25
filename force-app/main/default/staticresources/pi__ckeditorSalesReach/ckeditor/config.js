/**
 * @license Copyright (c) 2003-2018, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see https://ckeditor.com/legal/ckeditor-oss-license
 */
CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here.
	// For complete reference see:
	// http://docs.ckeditor.com/#!/api/CKEDITOR.config

	config.skin = 'pardot';
	config.language = 'en';
	config.uiColor = '#ffffff';

	// IE 9+ iframe permissions fix
	//config.forceCustomDomain = true;

	// Add the piImage plugin for sales reach.
	config.extraPlugins = 'jqueryspellchecker,pilink,font,colorbutton,richcombo,panelbutton,floatpanel,panel,button,listblock';

	if (window.EngageAttachmentsEnabled && window.ContentDeliveriesAndPubLinkEnabled) {
		config.extraPlugins+= ',piattachments,piimageattachments';
	}

	if (window.hasHmlEnabled) {
		config.extraPlugins+=',pihmlemailfield';
	} else {
		config.extraPlugins+=',piemailfield';
	}

	config.removePlugins = 'magicline, tableresize, dragdrop, basket, link';

	// The toolbar groups arrangement, optimized for two toolbar rows.
	config.toolbar = 'EngageCampaigns';

	config.toolbar_SalesEdge = [
		{ name: 'font', items: [ 'Font' ] },
		{ name: 'fontSize', items: [ 'FontSize' ] },
		{ name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline' ] },
		{ name: 'color', items: [ 'TextColor', 'BGColor'] },
		'/',
		{ name: 'align', items: [ 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock'] },
		{ name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote'] },
		{ name: 'links', items: [ 'Link', 'Unlink', 'Anchor' ] }
	];

	config.toolbar_OriginalSalesEdge = [
		{ name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', '-', 'PiFormat', 'RemoveFormat' ] },
		{ name: 'links', items: [ 'Link', 'Unlink', 'Anchor' ] },
		{ name: 'document', items: [ 'Source' ] },
		{ name: 'imageInsert', items: [ 'Image' ] },
		{ name: 'color', items: [ 'TextColor', 'BGColor'] },
		{ name: 'paragraph', items: [ 'NumberedList', 'BulletedList'] },
		'/',
		{ name: 'align', items: [ 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock'] },
		{ name: 'insert', items: [ 'PasteText', 'PasteFromWord', '-', 'Table', 'HorizontalRule', 'SpecialChar' ] },
		{ name: 'font', items: [ 'Font' ] },
		{ name: 'fontSize', items: [ 'FontSize' ] },
		{ name: 'format', items: [ 'Format' ] }
	];

	config.toolbar_SalesEdgeSimple = [
		{ name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', '-', 'PiFormat', 'RemoveFormat' ] },
		{ name: 'links', items: [ 'Link', 'Unlink', 'Anchor' ] },
		{ name: 'color', items: [ 'TextColor', 'BGColor'] }
	];

	config.toolbar_EngageCampaigns = [
		{ name: 'font', items: [ 'Font', 'FontSize' ] },
		{ name: 'colorbutton', items: [ 'TextColor', 'BGColor'] },
		{ name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline' ] },
		{ name: 'links', items: [ 'Link' ] },
		{ name: 'paragraph', items: [ 'BulletedList'] },
		{ name: 'piemailfield', items: ['variablefield'] },
		{ name: 'pihmlemailfield', items: ['hmlvariablefield'] },
		{ name: 'piattachments', items: ['engageattachments'] },
		{ name: 'piimageattachments', items: ['engageimageattachments'] },

	];

	// Remove some buttons provided by the standard plugins, which are
	// not needed in the Standard(s) toolbar.
	config.removeButtons = 'Subscript,Superscript';

	// Set the most common block elements.
	config.format_tags = 'p;h1;h2;h3;pre';
	// config.format_p = { element: 'p', attributes: { 'style': 'display: inline !important;' } };

	// Simplify the dialog windows.
	config.removeDialogTabs = 'image:advanced;link:advanced';

	// Allows for <doctype> and <html> tags from the template to be edited and retrieved with .getData()
	config.fullPage = true;

	// Allow all content.
	config.allowedContent = {
		$1: {
			elements: CKEDITOR.dtd,
			attributes: true,
			styles: true,
			classes: true
		}
	};

	// Ensures the default spellchecker is on.
	config.disableNativeSpellChecker = false;

	// Allows the toolbar to collapse.
	config.toolbarCanCollapse = false;

	// The enter key inserts <br>(2) tags instead of creating paragraphs(1) or divs(3).
	config.enterMode = CKEDITOR.ENTER_BR;

	// Default to no variable tags
	config.pardotVariableTags = "";

	//Default error message for no tags
	config.pardotVariableTagErrorMessage = "";

	config.fillEmptyBlocks = false;
};
