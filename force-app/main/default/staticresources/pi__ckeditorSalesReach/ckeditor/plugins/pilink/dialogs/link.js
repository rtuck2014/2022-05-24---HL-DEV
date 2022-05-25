/*
 * @license Copyright (c) 2003-2013, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.dialog.add( 'link', function( editor ) {
	var url = window.location.href,
		arr = url.split("/"),
		domain = arr[0] + "//" + arr[2],
		dropdownAjaxCalls = {
			'customUrl': null,
			'emailPreferencesPage': null,
			'file': null,
			'form': null,
			'landingPage': null
		};

	var colorCodes = ['aliceblue','antiquewhite','aqua','aquamarine','azure','beige','bisque','black','blanchedalmond','blue','blueviolet','brown','burlywood','cadetblue','chartreuse','chocolate','coral','cornflowerblue','cornsilk','crimson','cyan','darkblue','darkcyan','darkgoldenrod','darkgray','darkgreen','darkkhaki','darkmagenta','darkolivegreen','darkorange','darkorchid','darkred','darksalmon','darkseagreen','darkslateblue','darkslategray','darkturquoise','darkviolet','deeppink','deepskyblue','dimgray','dodgerblue','firebrick','floralwhite','forestgreen','fuchsia','gainsboro','ghostwhite','gold','goldenrod','gray','green','greenyellow','honeydew','hotpink','indianred','indigo','ivory','khaki','lavender','lavenderblush','lawngreen','lemonchiffon','lightblue','lightcoral','lightcyan','lightgoldenrodyellow','lightgray','lightgreen','lightpink','lightsalmon','lightseagreen','lightskyblue','lightslategray','lightsteelblue','lightyellow','lime','limegreen','linen','magenta','maroon','mediumaquamarine','mediumblue','mediumorchid','mediumpurple','mediumseagreen','mediumslateblue','mediumspringgreen','mediumturquoise','mediumvioletred','midnightblue','mintcream','mistyrose','moccasin','navajowhite','navy','oldlace','olive','olivedrab','orange','orangered','orchid','palegoldenrod','palegreen','paleturquoise','palevioletred','papayawhip','peachpuff','peru','pink','plum','powderblue','purple','red','rosybrown','royalblue','saddlebrown','salmon','sandybrown','seagreen','seashell','sienna','silver','skyblue','slateblue','slategray','snow','springgreen','steelblue','tan','teal','thistle','tomato','turquoise','violet','wheat','white','whitesmoke','yellow','yellowgreen'];

	var pdSelectBuild = function (data, dropdown, module) {
		var vals;
		// Manually clear all options in the select instead of calling dropdown.clear()
		// since it removes each option in a loop one-by-one
		jQuery(dropdown.getElement().$).find('select').get(0).options.length = 0;

		function parseData (vals) {
			// need to get all values lazy loading on window open
			var matchedValue = null;
			if(vals.length) {
				dropdown.add('');
				for(var i=0; i<vals.length; i++) {
					var url = vals[i].url,
						  name = vals[i].name;
					dropdown.add(name, url);

					if(data.type == 'url' && data.url) {
						var strippedUrl = getUrlFromString(url);
						if(strippedUrl == data.url.url) {
							matchedValue = url;
						}
					}
				}
			}

			// Once the values come in, we can look to see if any of those values match the initial data
			// If so, we can set the selected options appropriately
			if (matchedValue && data.type == 'url') {
				var actualLinkType = null;
				switch(module) {
					case 'form':
					case 'file':
					case 'landingPage':
						actualLinkType = 'pd' + module.charAt(0).toUpperCase() + module.slice(1);
						break;
					case 'customUrl':
						actualLinkType = "pdCustomRedirect";
						break;
					default:
						return;
				}
				var linkTypeDropdown = dropdown.getDialog().getContentElement("info", "linkType");
				linkTypeDropdown.setValue(actualLinkType, false);
				dropdown.setValue(matchedValue, true);
			}
		}

		dropdownAjaxCalls[module] = jQuery.ajax({
			url: domain + "/" + module + "/getAll",
			cache: false,
			beforeSend: function() {
				// Aborts the previous AJAX call if it's still running
				if (dropdownAjaxCalls[module] !== null) {
					dropdownAjaxCalls[module].abort();
				}
			},
			success: function(d){									
				if(d) {
					d = JSON.parse(d);
					vals = d;
					parseData(vals);
				}
			},
		    error:function (xhr, errorText, thrownError){
			    console.log(xhr.statusText);
		    }
		}, "json");
	};

	var plugin = CKEDITOR.plugins.link;
	// Handles the event when the "Target" selection box is changed.
	var targetChanged = function() {
			var dialog = this.getDialog(),
				popupFeatures = dialog.getContentElement( 'target', 'popupFeatures' ),
				targetName = dialog.getContentElement( 'target', 'linkTargetName' ),
				value = this.getValue();

			if ( !popupFeatures || !targetName )
				return;

			popupFeatures = popupFeatures.getElement();
			popupFeatures.hide();
			targetName.setValue( '' );

			switch ( value ) {
				case 'frame':
					targetName.setLabel( editor.lang.link.targetFrameName );
					targetName.getElement().show();
					break;
				case 'popup':
					popupFeatures.show();
					targetName.setLabel( editor.lang.link.targetPopupName );
					targetName.getElement().show();
					break;
				default:
					targetName.setValue( value );
					targetName.getElement().hide();
					break;
			}

		};

	// Handles the event when the "Type" selection box is changed.
	var linkTypeChanged = function() {
			var dialog = this.getDialog(),
				partIds = [ 'urlOptions', 'anchorOptions', 'emailOptions', 'pdCustomRedirectOptions', 'pdEmailPreferencesPageOptions', 'pdFileOptions', 'pdFormOptions', 'pdLandingPageOptions', 'pdUnsubscribeLinkOptions', 'pdResubscribeLinkOptions' ],
				typeValue = this.getValue(),
				uploadTab = dialog.definition.getContents( 'upload' ),
				uploadInitiallyHidden = uploadTab && uploadTab.hidden;

			if ( typeValue == 'url' ) {
				if ( editor.config.linkShowTargetTab )
					dialog.showPage( 'target' );
				if ( !uploadInitiallyHidden )
					dialog.showPage( 'upload' );
			} else {
				dialog.hidePage( 'target' );
				if ( !uploadInitiallyHidden )
					dialog.hidePage( 'upload' );
			}

			for ( var i = 0; i < partIds.length; i++ ) {
				var element = dialog.getContentElement( 'info', partIds[ i ] );
				if ( !element )
					continue;

				element = element.getElement().getParent().getParent();
				if ( partIds[ i ] == typeValue + 'Options' )
					element.show();
				else
					element.hide();
			}

			dialog.layout();
		};

	// Loads the parameters in a selected link to the link dialog fields.
	var javascriptProtocolRegex = /^javascript:/,
		emailRegex = /^mailto:([^?]+)(?:\?(.+))?$/,
		emailSubjectRegex = /subject=([^;?:@&=$,\/]*)/,
		emailBodyRegex = /body=([^;?:@&=$,\/]*)/,
		anchorRegex = /^#(.*)$/,
		urlRegex = /^((?:http|https|ftp|news):\/\/)?(.*)$/,
		selectableTargets = /^(_(?:self|top|parent|blank))$/,
		encodedEmailLinkRegex = /^javascript:void\(location\.href='mailto:'\+String\.fromCharCode\(([^)]+)\)(?:\+'(.*)')?\)$/,
		functionCallProtectedEmailLinkRegex = /^javascript:([^(]+)\(([^)]+)\)$/,
		unsubTag = "%%unsubscribe%%",
		resubTag = "%%resubscribe%%",
		emailPrefRegex = /^%%email_preference_center_(\d+)%%$/;

	var getUrlFromString = function(str) {
		var matches = str.match(urlRegex);
		return matches[2];
	};

	var popupRegex = /\s*window.open\(\s*this\.href\s*,\s*(?:'([^']*)'|null)\s*,\s*'([^']*)'\s*\)\s*;\s*return\s*false;*\s*/;
	var popupFeaturesRegex = /(?:^|,)([^=]+)=(\d+|yes|no)/gi;

	var parseLink = function( editor, element ) {
			var href = ( element && ( element.data( 'cke-saved-href' ) || element.getAttribute( 'href' ) ) ) || '',
				javascriptMatch, emailMatch, anchorMatch, urlMatch,
				retval = {};

			if ( ( javascriptMatch = href.match( javascriptProtocolRegex ) ) ) {
				if ( emailProtection == 'encode' ) {
					href = href.replace( encodedEmailLinkRegex, function( match, protectedAddress, rest ) {
						return 'mailto:' +
							String.fromCharCode.apply( String, protectedAddress.split( ',' ) ) +
							( rest && unescapeSingleQuote( rest ) );
					});
				}
				// Protected email link as function call.
				else if ( emailProtection ) {
					href.replace( functionCallProtectedEmailLinkRegex, function( match, funcName, funcArgs ) {
						if ( funcName == compiledProtectionFunction.name ) {
							retval.type = 'email';
							var email = retval.email = {};

							var paramRegex = /[^,\s]+/g,
								paramQuoteRegex = /(^')|('$)/g,
								paramsMatch = funcArgs.match( paramRegex ),
								paramsMatchLength = paramsMatch.length,
								paramName, paramVal;

							for ( var i = 0; i < paramsMatchLength; i++ ) {
								paramVal = decodeURIComponent( unescapeSingleQuote( paramsMatch[ i ].replace( paramQuoteRegex, '' ) ) );
								paramName = compiledProtectionFunction.params[ i ].toLowerCase();
								email[ paramName ] = paramVal;
							}
							email.address = [ email.name, email.domain ].join( '@' );
						}
					});
				}
			}

			if ( !retval.type ) {
				if ( ( anchorMatch = href.match( anchorRegex ) ) ) {
					retval.type = 'anchor';
					retval.anchor = {};
					retval.anchor.name = retval.anchor.id = anchorMatch[ 1 ];
				}
				// Protected email link as encoded string.
				else if ( ( emailMatch = href.match( emailRegex ) ) ) {
					var subjectMatch = href.match( emailSubjectRegex ),
						bodyMatch = href.match( emailBodyRegex );

					retval.type = 'email';
					var email = ( retval.email = {} );
					email.address = emailMatch[ 1 ];
					subjectMatch && ( email.subject = decodeURIComponent( subjectMatch[ 1 ] ) );
					bodyMatch && ( email.body = decodeURIComponent( bodyMatch[ 1 ] ) );
				} else if (href == unsubTag) {
					retval.type = "pdUnsubscribeLink";
					retval.url = href;
				} else if (href == resubTag) {
					retval.type = "pdResubscribeLink";
					retval.url = href;
				} else if (href.match(emailPrefRegex)) {
					retval.type="pdEmailPreferencesPage";
					retval.url = href;
				}
				// urlRegex matches empty strings, so need to check for href as well.
				else if ( href && ( urlMatch = href.match( urlRegex ) ) ) {
					retval.type = 'url';
					retval.url = {};
					retval.url.protocol = urlMatch[ 1 ];
					retval.url.url = urlMatch[ 2 ];
				} else {
					retval.type = 'url';
				}
			}
			// Load target and popup settings.
			if ( element ) {
				var target = element.getAttribute( 'target' );
				retval.target = {};
				retval.adv = {};

				// IE BUG: target attribute is an empty string instead of null in IE if it's not set.
				if ( !target ) {
					var onclick = element.data( 'cke-pa-onclick' ) || element.getAttribute( 'onclick' ),
						onclickMatch = onclick && onclick.match( popupRegex );
					if ( onclickMatch ) {
						retval.target.type = 'popup';
						retval.target.name = onclickMatch[ 1 ];

						var featureMatch;
						while ( ( featureMatch = popupFeaturesRegex.exec( onclickMatch[ 2 ] ) ) ) {
							// Some values should remain numbers (#7300)
							if ( ( featureMatch[ 2 ] == 'yes' || featureMatch[ 2 ] == '1' ) && !( featureMatch[ 1 ] in { height:1,width:1,top:1,left:1 } ) )
								retval.target[ featureMatch[ 1 ] ] = true;
							else if ( isFinite( featureMatch[ 2 ] ) )
								retval.target[ featureMatch[ 1 ] ] = featureMatch[ 2 ];
						}
					}
				} else {
					var targetMatch = target.match( selectableTargets );
					if ( targetMatch )
						retval.target.type = retval.target.name = target;
					else {
						retval.target.type = 'frame';
						retval.target.name = target;
					}
				}

				var me = this;
				var advAttr = function( inputName, attrName ) {
						var value = element.getAttribute( attrName );
						if ( value !== null )
							retval.adv[ inputName ] = value || '';
					};
				advAttr( 'advId', 'id' );
				advAttr( 'advLangDir', 'dir' );
				advAttr( 'advAccessKey', 'accessKey' );

				retval.adv.advName = element.data( 'cke-saved-name' ) || element.getAttribute( 'name' ) || '';
				advAttr( 'advLangCode', 'lang' );
				advAttr( 'advTabIndex', 'tabindex' );
				advAttr( 'advTitle', 'title' );
				advAttr( 'advContentType', 'type' );
				CKEDITOR.plugins.link.synAnchorSelector ? retval.adv.advCSSClasses = getLinkClass( element ) : advAttr( 'advCSSClasses', 'class' );
				advAttr( 'advCharset', 'charset' );
				advAttr( 'advStyles', 'style' );
				advAttr( 'advRel', 'rel' );
			}

			// Find out whether we have any anchors in the editor.
			var anchors = retval.anchors = [],
				i, count, item;

			// For some browsers we set contenteditable="false" on anchors, making document.anchors not to include them, so we must traverse the links manually (#7893).
			if ( CKEDITOR.plugins.link.emptyAnchorFix ) {
				var links = editor.document.getElementsByTag( 'a' );
				for ( i = 0, count = links.count(); i < count; i++ ) {
					item = links.getItem( i );
					if ( item.data( 'cke-saved-name' ) || item.hasAttribute( 'name' ) )
						anchors.push({ name: item.data( 'cke-saved-name' ) || item.getAttribute( 'name' ), id: item.getAttribute( 'id' ) } );
				}
			} else {
				var anchorList = new CKEDITOR.dom.nodeList( editor.document.$.anchors );
				for ( i = 0, count = anchorList.count(); i < count; i++ ) {
					item = anchorList.getItem( i );
					anchors[ i ] = { name: item.getAttribute( 'name' ), id: item.getAttribute( 'id' ) };
				}
				// look for passed in anchors
				if(typeof allAnchors !== "undefined") {
					for ( i = 0, count = allAnchors.length; i < count; i++ ) {
						item = allAnchors[i];
						if(item['id'] === undefined) {
							item['id'] = "";
						}
						if(item['name'] === undefined) {
							item['name'] = "";
						}
						anchors[ i ] = { name: item['name'], id: item['id'] };
					}
				}
			}

			if ( CKEDITOR.plugins.link.fakeAnchor ) {
				var imgs = editor.document.getElementsByTag( 'img' );
				for ( i = 0, count = imgs.count(); i < count; i++ ) {
					if ( ( item = CKEDITOR.plugins.link.tryRestoreFakeAnchor( editor, imgs.getItem( i ) ) ) )
						anchors.push({ name: item.getAttribute( 'name' ), id: item.getAttribute( 'id' ) } );
				}
			}

			// sort by name
			function compare(a,b) {
				if (a.name < b.name)
					return -1;
				if (a.name > b.name)
					return 1;
				return 0;
			}
			anchors.sort(compare);

			// remove dupes
			for ( i = anchors.length-1; i > 0; i-- ) { // start at end so don't change index when removing
				if( i===0 )
					continue;
				if (anchors[i]['name'] === anchors[i-1]['name']) {
					anchors.splice(i, 1);
				}
			}

			// Record down the selected element in the dialog.
			this._.selectedElement = element;
			return retval;
		};

	var setupParams = function( page, data ) {
			if ( data[ page ] ) {
				this.setValue( data[ page ][ this.id ] || '' );

				var advStyles = data[ page ][ 'advStyles' ];
				if(this.id == 'advUnderline' && advStyles) {
					if(advStyles.indexOf('text-decoration:none;') >= 0){
						this.setValue( 'none' );
					}
					else if (advStyles.indexOf('text-decoration:underline;') >= 0) {
						this.setValue( 'underline' );						
					}					
				}
				if(this.id == 'advColor' && advStyles && advStyles.indexOf('color:') >= 0){
					var regex = /color:([\s]*[^;]*)/gi;
					var color = regex.exec(advStyles);
					color = CKEDITOR.tools.convertRgbToHex(color[1]);
					this.setValue( color );
				}
				if(this.id == 'advStyles' && advStyles && advStyles.indexOf('color:') >= 0) {
					var regex = /color:([\s]*[^;]*)/gi;
					var color = regex.exec(advStyles);
					color = CKEDITOR.tools.convertRgbToHex(color[1]);
					this.setValue( advStyles.replace(regex, 'color: ' + color) );
				}
			}
		};

	var setupPopupParams = function( data ) {
			return setupParams.call( this, 'target', data );
		};

	var setupAdvParams = function( data ) {
			return setupParams.call( this, 'adv', data );
		};

	var commitParams = function( page, data ) {
			if ( !data[ page ] )
				data[ page ] = {};

			data[ page ][ this.id ] = this.getValue() || '';
		};

	var commitPopupParams = function( data ) {
			return commitParams.call( this, 'target', data );
		};

	var commitAdvParams = function( data ) {
			return commitParams.call( this, 'adv', data );
		};

	function unescapeSingleQuote( str ) {
		return str.replace( /\\'/g, '\'' );
	}

	function escapeSingleQuote( str ) {
		return str.replace( /'/g, '\\$&' );
	}

	var emailProtection = editor.config.emailProtection || '';

	// Compile the protection function pattern.
	if ( emailProtection && emailProtection != 'encode' ) {
		var compiledProtectionFunction = {};

		emailProtection.replace( /^([^(]+)\(([^)]+)\)$/, function( match, funcName, params ) {
			compiledProtectionFunction.name = funcName;
			compiledProtectionFunction.params = [];
			params.replace( /[^,\s]+/g, function( param ) {
				compiledProtectionFunction.params.push( param );
			});
		});
	}

	function protectEmailLinkAsFunction( email ) {
		var retval,
			name = compiledProtectionFunction.name,
			params = compiledProtectionFunction.params,
			paramName, paramValue;

		retval = [ name, '(' ];
		for ( var i = 0; i < params.length; i++ ) {
			paramName = params[ i ].toLowerCase();
			paramValue = email[ paramName ];

			i > 0 && retval.push( ',' );
			retval.push( '\'', paramValue ? escapeSingleQuote( encodeURIComponent( email[ paramName ] ) ) : '', '\'' );
		}
		retval.push( ')' );
		return retval.join( '' );
	}

	function protectEmailAddressAsEncodedString( address ) {
		var charCode,
			length = address.length,
			encodedChars = [];
		for ( var i = 0; i < length; i++ ) {
			charCode = address.charCodeAt( i );
			encodedChars.push( charCode );
		}
		return 'String.fromCharCode(' + encodedChars.join( ',' ) + ')';
	}

	function getLinkClass( ele ) {
		var className = ele.getAttribute( 'class' );
		return className ? className.replace( /\s*(?:cke_anchor_empty|cke_anchor)(?:\s*$)?/g, '' ) : '';
	}

	// Use this function as isChanged function for url type dropdowns (form, landingPage, file, customRedirect)
	var urlOptionsHaveChanges = function() {
		// Is this dropdown currently being displayed
		var linkTypeDropdown = this.getDialog().getContentElement("info", "linkType");
		var dropdownRelevant = linkTypeDropdown.getValue() == this.id;
		// Get the original url and the currently selected url
		var initializedWithUrlData = this.initialData.type == 'url' && this.initialData.url;
		var originalUrl = initializedWithUrlData ? this.initialData.url.url : null;
		var selectedUrl = getUrlFromString(this.getValue());

		return dropdownRelevant && (!initializedWithUrlData || originalUrl != selectedUrl);
	};

	var commonLang = editor.lang.common,
		linkLang = editor.lang.link;
	var linkItems = [
		[ linkLang.toUrl, 'url' ],
		[ linkLang.toAnchor, 'anchor' ],
		[ linkLang.toEmail, 'email' ],
		[ 'Unsubscribe Link', 'pdUnsubscribeLink' ],
		['Email Preference Center', 'pdEmailPreferencesPage'],
		[ 'Resubscribe Link', 'pdResubscribeLink' ]
	];

	return {
		title: linkLang.title,
		minWidth: 350,
		minHeight: 230,
		contents: [
			{
			id: 'info',
			label: linkLang.info,
			title: linkLang.info,
			elements: [
				{
				id: 'linkType',
				type: 'select',
				label: linkLang.type,
				'default': 'url',
				items: linkItems,
				onChange: linkTypeChanged,
				setup: function( data ) {
					if ( data.type ) {
						this.setValue( data.type );
					}
					this.initialData = data;
				},
				commit: function( data ) {
					data.type = this.getValue();
				},
				isChanged: function() {
					var currentValue = this.getValue();
					var hasChanged = currentValue != this.initialData.type;
					var specialUrlTypes = ['pdForm', 'pdLandingPage', 'pdCustomRedirect', 'pdFile'];
					if(this.initialData.type == 'url' && specialUrlTypes.indexOf(currentValue) != -1) {
						// For url types, we check the value against form, landingPage, customUrl, and file
						// dropdowns to see if the url matches and set the ui appropriately.
						// So, we need to do some extra checks to see if the value has actually changed
						var optionsDropdown = this.getDialog().getContentElement( 'info', currentValue);
						var selectedUrl = getUrlFromString(optionsDropdown.getValue());
						var initialUrl = this.initialData.url ? this.initialData.url.url : '';
						hasChanged = !initialUrl || selectedUrl != initialUrl;
					}
					return hasChanged;
				}
			},
				{
				type: 'vbox',
				id: 'urlOptions',
				children: [
					{
					type: 'hbox',
					widths: [ '25%', '75%' ],
					children: [
						{
						id: 'protocol',
						type: 'select',
						label: commonLang.protocol,
						'default': 'http://',
						items: [
							// Force 'ltr' for protocol names in BIDI. (#5433)
							[ 'http://\u200E', 'http://' ],
							[ 'https://\u200E', 'https://' ],
							// [ 'ftp://\u200E', 'ftp://' ],
							// [ 'news://\u200E', 'news://' ],
							[ linkLang.other, '' ]
							],
						setup: function( data ) {
							if ( data.url )
								this.setValue( data.url.protocol || '' );
						},
						commit: function( data ) {
							if ( !data.url )
								data.url = {};

							data.url.protocol = this.getValue();
						}
					},
						{
						type: 'text',
						id: 'url',
						label: commonLang.url,
						required: true,
						onLoad: function() {
							this.allowOnChange = true;
						},
						onKeyUp: function() {
							this.allowOnChange = false;
							var protocolCmb = this.getDialog().getContentElement( 'info', 'protocol' ),
								url = this.getValue(),
								urlOnChangeProtocol = /^(http|https|ftp|news):\/\/(?=.)/i,
								urlOnChangeTestOther = /^((javascript:)|[#\/\.\?])/i;

							var protocol = urlOnChangeProtocol.exec( url );
							if ( protocol ) {
								this.setValue( url.substr( protocol[ 0 ].length ) );
								protocolCmb.setValue( protocol[ 0 ].toLowerCase() );
							} else if ( urlOnChangeTestOther.test( url ) )
								protocolCmb.setValue( '' );
							else if (/^%%unsubscribe%%$/i.test(url)) {
								// Automatically remove the protocol to create
								// valid unsubscribe links
								protocolCmb.setValue('');
							}

							this.allowOnChange = true;
						},
						onChange: function() {
							if ( this.allowOnChange ) // Dont't call on dialog load.
							this.onKeyUp();
						},
						validate: function() {
							var dialog = this.getDialog();

							if ( dialog.getContentElement( 'info', 'linkType' ) && dialog.getValueOf( 'info', 'linkType' ) != 'url' )
								return true;

							if ( (/javascript\:/).test( this.getValue() ) ) {
								alert( commonLang.invalidValue );
								return false;
							}

							// Ensure protocol is set to <other> for %%unsubscribe%%
							if (/^%%unsubscribe%%$/i.test(this.getValue()) &&
								dialog.getValueOf('info', 'protocol')) {
								return false;
							}

							if ( this.getDialog().fakeObj ) // Edit Anchor.
							return true;

							var func = CKEDITOR.dialog.validate.notEmpty( linkLang.noUrl );
							return func.apply( this );
						},
						setup: function( data ) {
							this.allowOnChange = false;
							if ( data.url )
								this.setValue( data.url.url );
							this.allowOnChange = true;

						},
						commit: function( data ) {
							// IE will not trigger the onChange event if the mouse has been used
							// to carry all the operations #4724
							this.onChange();

							if ( !data.url )
								data.url = {};

							data.url.url = this.getValue();
							this.allowOnChange = false;
						}
					}
					],
					setup: function( data ) {
						if ( !this.getDialog().getContentElement( 'info', 'linkType' ) )
							this.getElement().show();
					}
				},
					{
					type: 'button',
					id: 'browse',
					hidden: 'true',
					filebrowser: 'info:url',
					label: commonLang.browseServer
				}
				]
			},
				{
				type: 'vbox',
				id: 'pdCustomRedirectOptions',
				children: [
					{
						id: 'pdCustomRedirect',
						type: 'select',
						label: '',
						'default': '',
						items: [
							// Get items via ajax
							[ '' ],
						],
						setup: function( data ) {
							pdSelectBuild(data, this, 'customUrl');
							this.initialData = data;
						},
						commit: function( data ) {
							if ( !data.url )
								data.url = {};
							data.url.pdCustomRedirect = this.getValue();
						},
						isChanged: urlOptionsHaveChanges
					}
				],
					setup: function( data ) {
						if ( !this.getDialog().getContentElement( 'info', 'linkType' ) )
							this.getElement().show();
					}
				},
				{
				type: 'vbox',
				id: 'pdEmailPreferencesPageOptions',
				children: [
					{
						id: 'pdEmailPreferencesPage',
						type: 'text',
						label: '',
						setup: function( data ) {
							if (window.hasHmlEnabled) {
								this.setValue('{{EmailPreferenceCenter}}');
							} else {
								this.setValue('%%email_preference_center%%​​​​​​​');
							}
						},
						commit: function( data ) {
							if ( !data.url )
								data.url = {};
							data.url.pdEmailPreferencesPage = this.getValue();
						}
					}
				],
					setup: function( data ) {
						if ( !this.getDialog().getContentElement( 'info', 'linkType' ) )
							this.getElement().show();
					}
				},
				{
				type: 'vbox',
				id: 'pdFileOptions',
				children: [
					{
						id: 'pdFile',
						type: 'select',
						label: '',
						'default': '',
						items: [
							// Get items via ajax
							[ '' ],
						],
						setup: function( data ) {
							pdSelectBuild(data, this, 'file');
							this.initialData = data;
						},
						commit: function( data ) {
							if ( !data.url )
								data.url = {};
							data.url.pdFile = this.getValue();
						},
						isChanged: urlOptionsHaveChanges
					}
				],
					setup: function( data ) {
						if ( !this.getDialog().getContentElement( 'info', 'linkType' ) )
							this.getElement().show();
					}
				},
				{
				type: 'vbox',
				id: 'pdFormOptions',
				children: [
					{
						id: 'pdForm',
						type: 'select',
						label: '',
						'default': '',
						items: [
							// Get items via ajax
							[ '' ],
						],
						setup: function( data ) {
							pdSelectBuild(data, this, 'form');
							this.initialData = data;
						},
						commit: function( data ) {
							if ( !data.url )
								data.url = {};
							data.url.pdForm = this.getValue();
						},
						isChanged: urlOptionsHaveChanges
					}
				],
					setup: function( data ) {
						if ( !this.getDialog().getContentElement( 'info', 'linkType' ) )
							this.getElement().show();
					}
				},
				{
				type: 'vbox',
				id: 'pdLandingPageOptions',
				children: [
					{
						id: 'pdLandingPage',
						type: 'select',
						label: '',
						'default': '',
						items: [
							// Get items via ajax
							[ '' ],
						],
						setup: function( data ) {
							pdSelectBuild(data, this, 'landingPage');
							this.initialData = data;
						},
						commit: function( data ) {
							if ( !data.url )
								data.url = {};
							data.url.pdLandingPage = this.getValue();
						},
						isChanged: urlOptionsHaveChanges
					}
				],
					setup: function( data ) {
						if ( !this.getDialog().getContentElement( 'info', 'linkType' ) )
							this.getElement().show();
					}
				},
				{
				type: 'vbox',
				id: 'pdUnsubscribeLinkOptions',
				children: [
					{
						id: 'pdUnsubscribeLink',
						type: 'text',
						label: '',
						setup: function( data ) {
							if (window.hasHmlEnabled) {
								this.setValue('​​​​​​​{{Unsubscribe}}');
							} else {
								this.setValue('%%unsubscribe%%');
							}
						},
						commit: function( data ) {
							if ( !data.url )
								data.url = {};
							data.url.pdUnsubscribeLink = this.getValue();
						}
					}
				],
					setup: function( data ) {
						if ( !this.getDialog().getContentElement( 'info', 'linkType' ) )
							this.getElement().show();
					}
				},
				{
					type: 'vbox',
					id: 'pdResubscribeLinkOptions',
					children: [
						{
							id: 'pdResubscribeLink',
							type: 'text',
							label: '',
							setup: function( data ) {
								if (window.hasHmlEnabled) {
									this.setValue('​​​​​​​{{Resubscribe}}');
								} else {
									this.setValue('%%resubscribe%%');
								}
							},
							commit: function( data ) {
								if ( !data.url )
									data.url = {};
								data.url.pdResubscribeLink = this.getValue();
							}
						}
					],
					setup: function( data ) {
						if ( !this.getDialog().getContentElement( 'info', 'linkType' ) )
							this.getElement().show();
					}
				},
				{
				type: 'vbox',
				id: 'anchorOptions',
				width: '100%',
				align: 'center',
				padding: 0,
				children: [
					{
					type: 'fieldset',
					id: 'selectAnchorText',
					label: linkLang.selectAnchor,
					setup: function( data ) {
						if ( data.anchors.length > 0 )
							this.getElement().show();
						else
							this.getElement().hide();
					},
					children: [
						{
						type: 'hbox',
						id: 'selectAnchor',
						children: [
							{
							type: 'select',
							id: 'anchorName',
							'default': '',
							label: linkLang.anchorName,
							style: 'width: 100%;',
							items: [
								[ '' ]
								],
							setup: function( data ) {
								this.clear();
								this.add( '' );
								for ( var i = 0; i < data.anchors.length; i++ ) {
									if ( data.anchors[ i ].name )
										this.add( data.anchors[ i ].name );
								}

								if ( data.anchor )
									this.setValue( data.anchor.name );

								var linkType = this.getDialog().getContentElement( 'info', 'linkType' );
								if ( linkType && linkType.getValue() == 'email' )
									this.focus();
							},
							commit: function( data ) {
								if ( !data.anchor )
									data.anchor = {};

								data.anchor.name = this.getValue();
							}
						},
							{
							type: 'select',
							id: 'anchorId',
							'default': '',
							label: linkLang.anchorId,
							style: 'width: 100%;',
							items: [
								[ '' ]
								],
							setup: function( data ) {
								this.clear();
								this.add( '' );
								for ( var i = 0; i < data.anchors.length; i++ ) {
									if ( data.anchors[ i ].id )
										this.add( data.anchors[ i ].id );
								}

								if ( data.anchor )
									this.setValue( data.anchor.id );
							},
							commit: function( data ) {
								if ( !data.anchor )
									data.anchor = {};

								data.anchor.id = this.getValue();
							}
						}
						],
						setup: function( data ) {
							if ( data.anchors.length > 0 )
								this.getElement().show();
							else
								this.getElement().hide();
						}
					}
					]
				},
					{
					type: 'html',
					id: 'noAnchors',
					style: 'text-align: center;',
					html: '<div role="note" tabIndex="-1">' + CKEDITOR.tools.htmlEncode( linkLang.noAnchors ) + '</div>',
					// Focus the first element defined in above html.
					focus: true,
					setup: function( data ) {
						if ( data.anchors.length < 1 )
							this.getElement().show();
						else
							this.getElement().hide();
					}
				}
				],
				setup: function( data ) {
					if ( !this.getDialog().getContentElement( 'info', 'linkType' ) )
						this.getElement().hide();
				}
			},
				{
				type: 'vbox',
				id: 'emailOptions',
				padding: 1,
				children: [
					{
					type: 'text',
					id: 'emailAddress',
					label: linkLang.emailAddress,
					required: true,
					validate: function() {
						var dialog = this.getDialog();

						if ( !dialog.getContentElement( 'info', 'linkType' ) || dialog.getValueOf( 'info', 'linkType' ) != 'email' )
							return true;

						var func = CKEDITOR.dialog.validate.notEmpty( linkLang.noEmail );
						return func.apply( this );
					},
					setup: function( data ) {
						if ( data.email )
							this.setValue( data.email.address );

						var linkType = this.getDialog().getContentElement( 'info', 'linkType' );
						if ( linkType && linkType.getValue() == 'email' )
							this.select();
					},
					commit: function( data ) {
						if ( !data.email )
							data.email = {};

						data.email.address = this.getValue();
					}
				},
					{
					type: 'text',
					id: 'emailSubject',
					label: linkLang.emailSubject,
					setup: function( data ) {
						if ( data.email )
							this.setValue( data.email.subject );
					},
					commit: function( data ) {
						if ( !data.email )
							data.email = {};

						data.email.subject = this.getValue();
					}
				},
					{
					type: 'textarea',
					id: 'emailBody',
					label: linkLang.emailBody,
					rows: 3,
					'default': '',
					setup: function( data ) {
						if ( data.email )
							this.setValue( data.email.body );
					},
					commit: function( data ) {
						if ( !data.email )
							data.email = {};

						data.email.body = this.getValue();
					}
				}
				],
				setup: function( data ) {
					if ( !this.getDialog().getContentElement( 'info', 'linkType' ) )
						this.getElement().hide();
				}
			}
			]
		},
			{
			id: 'target',
			label: linkLang.target,
			title: linkLang.target,
			elements: [
				{
				type: 'hbox',
				widths: [ '50%', '50%' ],
				children: [
					{
					type: 'select',
					id: 'linkTargetType',
					label: commonLang.target,
					'default': 'notSet',
					style: 'width : 100%;',
					'items': [
						[ commonLang.notSet, 'notSet' ],
						[ linkLang.targetFrame, 'frame' ],
						[ linkLang.targetPopup, 'popup' ],
						[ commonLang.targetNew, '_blank' ],
						[ commonLang.targetTop, '_top' ],
						[ commonLang.targetSelf, '_self' ],
						[ commonLang.targetParent, '_parent' ]
						],
					onChange: targetChanged,
					setup: function( data ) {
						if ( data.target )
							this.setValue( data.target.type || 'notSet' );
						targetChanged.call( this );
					},
					commit: function( data ) {
						if ( !data.target )
							data.target = {};

						data.target.type = this.getValue();
					}
				},
					{
					type: 'text',
					id: 'linkTargetName',
					label: linkLang.targetFrameName,
					'default': '',
					setup: function( data ) {
						if ( data.target )
							this.setValue( data.target.name );
					},
					commit: function( data ) {
						if ( !data.target )
							data.target = {};

						data.target.name = this.getValue().replace( /\W/gi, '' );
					}
				}
				]
			},
				{
				type: 'vbox',
				width: '100%',
				align: 'center',
				padding: 2,
				id: 'popupFeatures',
				children: [
					{
					type: 'fieldset',
					label: linkLang.popupFeatures,
					children: [
						{
						type: 'hbox',
						children: [
							{
							type: 'checkbox',
							id: 'resizable',
							label: linkLang.popupResizable,
							setup: setupPopupParams,
							commit: commitPopupParams
						},
							{
							type: 'checkbox',
							id: 'status',
							label: linkLang.popupStatusBar,
							setup: setupPopupParams,
							commit: commitPopupParams

						}
						]
					},
						{
						type: 'hbox',
						children: [
							{
							type: 'checkbox',
							id: 'location',
							label: linkLang.popupLocationBar,
							setup: setupPopupParams,
							commit: commitPopupParams

						},
							{
							type: 'checkbox',
							id: 'toolbar',
							label: linkLang.popupToolbar,
							setup: setupPopupParams,
							commit: commitPopupParams

						}
						]
					},
						{
						type: 'hbox',
						children: [
							{
							type: 'checkbox',
							id: 'menubar',
							label: linkLang.popupMenuBar,
							setup: setupPopupParams,
							commit: commitPopupParams

						},
							{
							type: 'checkbox',
							id: 'fullscreen',
							label: linkLang.popupFullScreen,
							setup: setupPopupParams,
							commit: commitPopupParams

						}
						]
					},
						{
						type: 'hbox',
						children: [
							{
							type: 'checkbox',
							id: 'scrollbars',
							label: linkLang.popupScrollBars,
							setup: setupPopupParams,
							commit: commitPopupParams

						},
							{
							type: 'checkbox',
							id: 'dependent',
							label: linkLang.popupDependent,
							setup: setupPopupParams,
							commit: commitPopupParams

						}
						]
					},
						{
						type: 'hbox',
						children: [
							{
							type: 'text',
							widths: [ '50%', '50%' ],
							labelLayout: 'horizontal',
							label: commonLang.width,
							id: 'width',
							setup: setupPopupParams,
							commit: commitPopupParams

						},
							{
							type: 'text',
							labelLayout: 'horizontal',
							widths: [ '50%', '50%' ],
							label: linkLang.popupLeft,
							id: 'left',
							setup: setupPopupParams,
							commit: commitPopupParams

						}
						]
					},
						{
						type: 'hbox',
						children: [
							{
							type: 'text',
							labelLayout: 'horizontal',
							widths: [ '50%', '50%' ],
							label: commonLang.height,
							id: 'height',
							setup: setupPopupParams,
							commit: commitPopupParams

						},
							{
							type: 'text',
							labelLayout: 'horizontal',
							label: linkLang.popupTop,
							widths: [ '50%', '50%' ],
							id: 'top',
							setup: setupPopupParams,
							commit: commitPopupParams

						}
						]
					}
					]
				}
				]
			}
			]
		},
			{
			id: 'upload',
			label: linkLang.upload,
			title: linkLang.upload,
			hidden: true,
			filebrowser: 'uploadButton',
			elements: [
				{
				type: 'file',
				id: 'upload',
				label: commonLang.upload,
				style: 'height:40px',
				size: 29
			},
				{
				type: 'fileButton',
				id: 'uploadButton',
				label: commonLang.uploadSubmit,
				filebrowser: 'info:url',
				'for': [ 'upload', 'upload' ]
			}
			]
		},
			{
			id: 'advanced',
			label: linkLang.advanced,
			title: linkLang.advanced,
			elements: [
				{
				type: 'vbox',
				padding: 1,
				children: [
					{
					type: 'hbox',
					widths: [ '45%', '55%' ],
					children: [
						{
						type: 'text',
						id: 'advId',
						label: linkLang.id,
						setup: setupAdvParams,
						commit: commitAdvParams
					},
						{
						type: 'text',
						label: linkLang.cssClasses,
						'default': '',
						id: 'advCSSClasses',
						setup: setupAdvParams,
						commit: commitAdvParams

					}
					]
				},
					{
					type: 'hbox',
					widths: [ '45%', '35%', '20%' ],
					children: [
						{
						type: 'text',
						label: linkLang.name,
						id: 'advName',
						setup: setupAdvParams,
						commit: commitAdvParams

					},
						{
						type: 'text',
						id: 'advAccessKey',
						width: '80px',
						label: linkLang.acccessKey,
						maxLength: 1,
						setup: setupAdvParams,
						commit: commitAdvParams

					},
						{
						type: 'text',
						label: linkLang.tabIndex,
						id: 'advTabIndex',
						width: '80px',
						maxLength: 5,
						setup: setupAdvParams,
						commit: commitAdvParams

					}
					]
				}
				]
			},
				{
				type: 'vbox',
				padding: 1,
				children: [
					{
					type: 'hbox',
					widths: [ '45%', '55%' ],
					children: [
						{
						type: 'text',
						label: linkLang.advisoryTitle,
						'default': '',
						id: 'advTitle',
						setup: setupAdvParams,
						commit: commitAdvParams

					},
						{
						type: 'text',
						label: linkLang.advisoryContentType,
						'default': '',
						id: 'advContentType',
						setup: setupAdvParams,
						commit: commitAdvParams

					}
					]
				},
					{
					type: 'hbox',
					widths: [ '45%', '55%' ],
					children: [
						{
						type: 'text',
						label: linkLang.rel,
						'default': '',
						id: 'advRel',
						setup: setupAdvParams,
						commit: commitAdvParams
					},
						{
						type: 'text',
						label: linkLang.styles,
						'default': '',
						id: 'advStyles',
						validate: CKEDITOR.dialog.validate.inlineStyle( editor.lang.common.invalidInlineStyle ),
						setup: setupAdvParams,
						commit: commitAdvParams
					}
					]
				}
				]
			}
			]
		}
		],
		onShow: function() {
			var editor = this.getParentEditor(),
				selection = editor.getSelection(),
				element = null;

			// Fill in all the relevant fields if there's already one link selected.
			if ( ( element = plugin.getSelectedLink( editor ) ) && element.hasAttribute( 'href' ) )
				selection.selectElement( element );
			else
				element = null;

			this.setupContent( parseLink.apply( this, [ editor, element ] ) );
		},
		onOk: function() {
			var attributes = {},
				removeAttributes = [],
				data = {},
				me = this,
				editor = this.getParentEditor();

			this.commitContent( data );

			// Compose the URL.
			switch ( data.type || 'url' ) {
				case 'pdCustomRedirect':
					attributes[ 'data-cke-saved-href' ] = data.url.pdCustomRedirect;
					break;
				case 'pdEmailPreferencesPage':
					attributes[ 'data-cke-saved-href' ] = data.url.pdEmailPreferencesPage;
					attributes[ 'data-cke-saved-rel' ] = 'nofollow,noreferrer';
					break;
				case 'pdFile':
					attributes[ 'data-cke-saved-href' ] = data.url.pdFile;
					break;
				case 'pdForm':
					attributes[ 'data-cke-saved-href' ] = data.url.pdForm;
					break;
				case 'pdLandingPage':
					attributes[ 'data-cke-saved-href' ] = data.url.pdLandingPage;
					break;
				case 'pdUnsubscribeLink':
					// ckeditor sometimes adds zero width space characters to the href,
					// causing hrefs to not render correctly, this removes any zero width
					// space characters from the link, fixing href functionlity
					var pdUnsubscribeLinkString = data.url.pdUnsubscribeLink;
					var sanitizedPdUnsubscribeLinkString = pdUnsubscribeLinkString.replace(/\u200B/g,'');
					attributes[ 'data-cke-saved-href' ] = sanitizedPdUnsubscribeLinkString;
					attributes[ 'data-cke-saved-rel' ] = 'nofollow,noreferrer';
					break;
				case 'pdResubscribeLink':
					// see above comment about zero width space
					var pdResubscribeLinkString = data.url.pdResubscribeLink;
					var sanitizedPdResubscribeLinkString = pdResubscribeLinkString.replace(/\u200B/g,'');
					attributes[ 'data-cke-saved-href' ] = sanitizedPdResubscribeLinkString;
					attributes[ 'data-cke-saved-rel' ] = 'nofollow,noreferrer';
					break;
				case 'url':
					var protocol = ( data.url && data.url.protocol != undefined ) ? data.url.protocol : 'http://',
						url = ( data.url && CKEDITOR.tools.trim( data.url.url ) ) || '';
					attributes[ 'data-cke-saved-href' ] = ( url.indexOf( '/' ) === 0 ) ? url : protocol + url;
					break;
				case 'anchor':
					var name = ( data.anchor && data.anchor.name ),
						id = ( data.anchor && data.anchor.id );
					attributes[ 'data-cke-saved-href' ] = '#' + ( name || id || '' );
					break;
				case 'email':

					var linkHref,
					email = data.email,
						address = email.address;

					switch ( emailProtection ) {
						case '':
						case 'encode':
							{
								var subject = encodeURIComponent( email.subject || '' ),
									body = encodeURIComponent( email.body || '' );

								// Build the e-mail parameters first.
								var argList = [];
								subject && argList.push( 'subject=' + subject );
								body && argList.push( 'body=' + body );
								argList = argList.length ? '?' + argList.join( '&' ) : '';

								if ( emailProtection == 'encode' ) {
									linkHref = [ 'javascript:void(location.href=\'mailto:\'+',
																															protectEmailAddressAsEncodedString( address ) ];
									// parameters are optional.
									argList && linkHref.push( '+\'', escapeSingleQuote( argList ), '\'' );

									linkHref.push( ')' );
								} else
									linkHref = [ 'mailto:', address, argList ];

								break;
							}
						default:
							{
								// Separating name and domain.
								var nameAndDomain = address.split( '@', 2 );
								email.name = nameAndDomain[ 0 ];
								email.domain = nameAndDomain[ 1 ];

								linkHref = [ 'javascript:', protectEmailLinkAsFunction( email ) ];
							}
					}

					attributes[ 'data-cke-saved-href' ] = linkHref.join( '' );
					break;
			}

			// Popups and target.
			if ( data.target ) {
				if ( data.target.type == 'popup' ) {
					var onclickList = [ 'window.open(this.href, \'',
																			data.target.name || '', '\', \'' ];
					var featureList = [ 'resizable', 'status', 'location', 'toolbar', 'menubar', 'fullscreen',
																			'scrollbars', 'dependent' ];
					var featureLength = featureList.length;
					var addFeature = function( featureName ) {
							if ( data.target[ featureName ] )
								featureList.push( featureName + '=' + data.target[ featureName ] );
						};

					for ( var i = 0; i < featureLength; i++ )
						featureList[ i ] = featureList[ i ] + ( data.target[ featureList[ i ] ] ? '=yes' : '=no' );
					addFeature( 'width' );
					addFeature( 'left' );
					addFeature( 'height' );
					addFeature( 'top' );

					onclickList.push( featureList.join( ',' ), '\'); return false;' );
					attributes[ 'data-cke-pa-onclick' ] = onclickList.join( '' );

					// Add the "target" attribute. (#5074)
					removeAttributes.push( 'target' );
				} else {
					if ( data.target.type != 'notSet' && data.target.name )
						attributes.target = data.target.name;
					else
						removeAttributes.push( 'target' );

					removeAttributes.push( 'data-cke-pa-onclick', 'onclick' );
				}
			}

			var selection = editor.getSelection();

			// Browser need the "href" fro copy/paste link to work. (#6641)
			attributes.href = attributes[ 'data-cke-saved-href' ];

			if ( !this._.selectedElement ) {
				var range = selection.getRanges( 1 )[ 0 ];

				// Use link URL as text with a collapsed cursor.
				if ( range.collapsed ) {
					// Short mailto link text view (#5736).
					var text = new CKEDITOR.dom.text( data.type == 'email' ? data.email.address : attributes[ 'data-cke-saved-href' ], editor.document );
					range.insertNode( text );
					range.selectNodeContents( text );
				}

				// Apply style.
				var style = new CKEDITOR.style({ element: 'a', attributes: attributes } );
				style.type = CKEDITOR.STYLE_INLINE; // need to override... dunno why.
				style.applyToRange( range );
				range.select();
			} else {
				// We're only editing an existing link, so just overwrite the attributes.
				var element = this._.selectedElement,
					href = element.data( 'cke-saved-href' ),
					textView = element.getHtml();

				element.setAttributes( attributes );
				element.removeAttributes( removeAttributes );

				if ( data.adv && data.adv.advName && CKEDITOR.plugins.link.synAnchorSelector )
					element.addClass( element.getChildCount() ? 'cke_anchor' : 'cke_anchor_empty' );

				// Update text view when user changes protocol (#4612).
				if ( href == textView || data.type == 'email' && textView.indexOf( '@' ) != -1 ) {
					// Short mailto link text view (#5736).
					element.setHtml( data.type == 'email' ? data.email.address : attributes[ 'data-cke-saved-href' ] );
				}

				selection.selectElement( element );
				delete this._.selectedElement;
			}
		},
		onLoad: function() {
			if ( !editor.config.linkShowAdvancedTab )
				this.hidePage( 'advanced' ); //Hide Advanded tab.

			if ( !editor.config.linkShowTargetTab )
				this.hidePage( 'target' ); //Hide Target tab.
		},
		// Inital focus on 'url' field if link is of type URL.
		onFocus: function() {
			var linkType = this.getContentElement( 'info', 'linkType' ),
				urlField;
			if ( linkType && linkType.getValue() == 'url' ) {
				urlField = this.getContentElement( 'info', 'url' );
				urlField.select();
			}
		}
	};
});

/*
 * The e-mail address anti-spam protection option. The protection will be
 * applied when creating or modifying e-mail links through the editor interface.
 *
 * Two methods of protection can be choosed:
 *
 * 1. The e-mail parts (name, domain and any other query string) are
 *     assembled into a function call pattern. Such function must be
 *     provided by the developer in the pages that will use the contents.
 * 2. Only the e-mail address is obfuscated into a special string that
 *     has no meaning for humans or spam bots, but which is properly
 *     rendered and accepted by the browser.
 *
 * Both approaches require JavaScript to be enabled.
 *
 *		// href="mailto:tester@ckeditor.com?subject=subject&body=body"
 *		config.emailProtection = '';
 *
 *		// href="<a href=\"javascript:void(location.href=\'mailto:\'+String.fromCharCode(116,101,115,116,101,114,64,99,107,101,100,105,116,111,114,46,99,111,109)+\'?subject=subject&body=body\')\">e-mail</a>"
 *		config.emailProtection = 'encode';
 *
 *		// href="javascript:mt('tester','ckeditor.com','subject','body')"
 *		config.emailProtection = 'mt(NAME,DOMAIN,SUBJECT,BODY)';
 *
 * @since 3.1
 * @cfg {String} [emailProtection='' (empty string = disabled)]
 * @member CKEDITOR.config
 */
