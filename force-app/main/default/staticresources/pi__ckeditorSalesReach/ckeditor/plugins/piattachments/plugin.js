/**
 * Basic sample plugin inserting current date and time into CKEditor editing area.
 *
 * Created out of the CKEditor Plugin SDK:
 * http://docs.ckeditor.com/#!/guide/plugin_sdk_intro
 */

// Register the plugin within the editor.
CKEDITOR.plugins.add('piattachments', {
    hidpi: true,
    icons: 'engageattachments',
    init : function(editor) {
        var config = editor.config,
            lang = editor.lang.format;

        //This dummy button has no function within CKEditor.
        //An onClick event listener in email_template_editor.js gives it purpose (trigger modal).
        editor.ui.addButton('engageattachments', {
            label: '',
            toolbar: 'insert',
        });
    }
});
