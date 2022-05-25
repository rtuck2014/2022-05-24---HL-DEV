/**
 * Basic sample plugin inserting current date and time into CKEditor editing area.
 *
 * Created out of the CKEditor Plugin SDK:
 * http://docs.ckeditor.com/#!/guide/plugin_sdk_intro
 */

// Register the plugin within the editor.
CKEDITOR.plugins.add('piemailfield', {
	hidpi: true,
	icons: 'variablefield',
	init : function(editor) {
	var config = editor.config,
	lang = editor.lang.format;

	editor.addCommand('variabletag', new CKEDITOR.dialogCommand('variablefieldDialog'));

	editor.ui.addButton('variablefield', {
		label: 'Variable Tag',
        command: 'variabletag',
        toolbar: 'insert'
    });
        
	CKEDITOR.dialog.add('variablefieldDialog', this.path + 'dialogs/dialog.js');
	}
});
