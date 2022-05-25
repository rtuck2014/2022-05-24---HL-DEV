/**
 * Basic sample plugin inserting abbreviation elements into CKEditor editing area.
 *
 * Created out of the CKEditor Plugin SDK:
 * http://docs.ckeditor.com/#!/guide/plugin_sdk_sample_1
 */

// Register the plugin within the editor.
CKEDITOR.plugins.add( 'piformat', {

	icons: 'piformat',

	init: function( editor ) {

		editor.addCommand( 'piformat', new CKEDITOR.dialogCommand( 'piformatDialog' ) );

		editor.ui.addButton( 'PiFormat', {
			label: 'Additional Formatting Options',
			command: 'piformat',
			toolbar: 'insert'
		});

		CKEDITOR.dialog.add( 'piformatDialog', this.path + 'dialogs/dialog.js' );
	}
});

