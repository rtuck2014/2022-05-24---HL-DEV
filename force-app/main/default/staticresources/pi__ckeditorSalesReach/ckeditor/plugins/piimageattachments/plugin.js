// Register the plugin within the editor.
CKEDITOR.plugins.add('piimageattachments', {
	hidpi: true,
	icons: 'engageimageattachments',
	init : function(editor) {
		var config = editor.config,
			lang = editor.lang.format;

		//This dummy button has no function within CKEditor.
		//An onClick event listener in email_template_editor.js gives it purpose (trigger image modal).
		editor.ui.addButton('engageimageattachments', {
			label: '',
			toolbar: 'insert',
		});
	}
});
