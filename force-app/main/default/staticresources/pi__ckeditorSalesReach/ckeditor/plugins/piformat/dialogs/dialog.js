/**
 * The abbr dialog definition.
 *
 * Created out of the CKEditor Plugin SDK:
 * http://docs.ckeditor.com/#!/guide/plugin_sdk_sample_1
 */

// Our dialog definition.
CKEDITOR.dialog.add( 'piformatDialog', function( editor ) {
	var insertSpan = false;
	function parseStyle (key, styles) {
		var v = '';
		styles = styles.split(';');
		for(var i; i < styles.length; i++) {
			if(styles[i] === key) {
				v = styles[i].split(':')[1];
				break;
			}
		}
		return v;
	}

	return {

		// Basic properties of the dialog window: title, minimum size.
		title: 'Custom Formatting Options',
		minWidth: 200,
		minHeight: 120,

		// Dialog window contents definition.
		contents: [
			{
				// Definition of the Basic Settings dialog tab (page).
				id: 'tab-basic',
				label: 'Basic Settings',

				// The tab contents.
				elements: [
					{
						type: 'text',
						id: 'fontsize',
						label: 'Font Size',
						setup: function( element ) {
							this.setValue( element.getStyle('font-size') );
						},
						commit: function( element ) {
							if(this.getValue !== "")
								element.setStyle( "font-size", this.getValue() );
						}
					},
					{
						type: 'text',
						id: 'lineheight',
						label: 'Line Height',
						setup: function( element ) {
							this.setValue( element.getStyle('line-height') );
						},
						commit: function( element ) {
							if(this.getValue !== "")
								element.setStyle( "line-height", this.getValue() );
						}
					},
					{
						type: 'radio',
						id: 'applyto',
						label: 'Apply To',
						items : [ [ 'Entire block', '0' ], [ 'Just my selection', '1' ] ] ,
						'default' : '0',
						setup: function( element ) {
							if(element.getStyle('line-height') !== '' || element.getStyle('font-size') !== '') {
								this.setValue(1);
							} else {
								this.setValue(0);
							}
						},
						onChange: function() {
							var v = this.getValue();
							insertSpan = v === 1 || v === '1' ? true : false;
						},
						onClick: function() {
							var v = this.getValue();
							insertSpan = v === 1 || v === '1' ? true : false;
						}
					}

				]
			}
		],

		onShow: function() {
			var selection = editor.getSelection();
			var element = selection.getStartElement();

			if ( element )
				element = element.getAscendant( { span:1,p:1,div:1 }, true );

			this.element = element;

			if(selection.getType() == CKEDITOR.SELECTION_TEXT) {
				this.selection = selection.getSelectedText();
			} else if (selection.getType() == CKEDITOR.SELECTION_ELEMENT) {
				this.selection = selection.getSelectedElement();
			} else {
				this.selection = '';
			}

			this.setupContent( this.element );
		},

		onOk: function() {
			var dialog = this;
			var obj = this.element;

			if ( insertSpan ) { // 1 = create new span
				obj = editor.document.createElement( 'span' );
				obj.setHtml(this.selection);
			}

			this.commitContent( obj );

			if ( insertSpan )
				editor.insertElement( obj );
		}
	};
});