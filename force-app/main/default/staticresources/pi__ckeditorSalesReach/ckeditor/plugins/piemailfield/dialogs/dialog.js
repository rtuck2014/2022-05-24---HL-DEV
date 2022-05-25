(function() {
	CKEDITOR.dialog.add( 'variablefieldDialog', function ( editor ) {
		var config = editor.config;
		var minHeight = 200;
		var list = '';

		var hasError = false;
		var listHtml;


		if (config.pardotVariableTags) { //error getting variable tags
			listHtml = getListHtml(config.pardotVariableTags);
		} else {
			hasError = true;
			minHeight = 50;
			listHtml = getErrorHtml(config.pardotVariableTagErrorMessage)
		}

		return {
			title: 'Pardot Variable Tags',
			minWidth: 300,
			minHeight: minHeight,
			contents: [
				{
					id: 'tab-basic',
					label: 'Insert',
					elements: [
						{
							type: 'html',
							html : listHtml
						}
					]
				}
			],
			onShow: function() {
				if(hasError){
					$('.cke_dialog_contents').attr('style', 'background: #fdf3f4');
				}
				jQuery('.cke_dialog_footer').hide();
				jQuery('#tagListWrapper .active').removeClass('active');
			},
			onOk: function() {
				editor.insertHtml( jQuery('#tagListWrapper .active').attr('data-value') );
				jQuery('.cke_dialog_footer').show();
			},
			onCancel: function() {
				jQuery('.cke_dialog_footer').show();
			}
		};
	});

	function getErrorHtml(message) {
		var iconUrl = CKEDITOR.getUrl(CKEDITOR.plugins.get("piemailfield").path+"icons/error_icon.png");

		return (
			'<div>' +
				'<img src="' + iconUrl + '" class="cke_error_icon" />' +
				'<span class="cke_error_span">' +
					message +
				'/<span>' +
			'</div>'
		);
	}

	function getListHtml(fields) {
		return (
			'<div id="tagListWrapper" class="tag-list-wrapper">' +
				'<ul class="slds-has-dividers--bottom-space">' +
					getListItemsHtml(fields) +
				'</ul>' +
			'</div>'
		);
	}

	function getListItemsHtml(fields) {
		return Object.keys(fields).sort().map(function(key){
			var tagName = key.replace(/_/g, ' ').replace(/\./g, ' - ')
			return (
				'<li class="slds-item" ' +
					'data-value="'+fields[key]+'" ' +
					'onclick="' +
						'jQuery(this).addClass(\'active\');' +
						'window.CKEDITOR.dialog.getCurrent()._.buttons[\'ok\'].click();' +
					'">' +
					tagName +
				'</li>'
			);
		}).join('')
	}
})();
