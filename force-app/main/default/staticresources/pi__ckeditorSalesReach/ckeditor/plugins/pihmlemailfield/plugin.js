/**
 * Basic sample plugin inserting current date and time into CKEditor editing area.
 *
 * Created out of the CKEditor Plugin SDK:
 * http://docs.ckeditor.com/#!/guide/plugin_sdk_intro
 */

// Register the plugin within the editor.
CKEDITOR.plugins.add('pihmlemailfield', {
	hidpi: true,
	icons: 'hmlvariablefield',
	init : function(editor) {
		var config = editor.config,
		lang = editor.lang.format;

		editor.ui.addButton('hmlvariablefield', {
			label: 'Merge Fields',
			toolbar: 'insert'
		});
	}
});
