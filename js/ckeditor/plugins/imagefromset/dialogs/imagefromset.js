/**
 * @license Copyright (c) 2003-2015, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

/**
 * @fileOverview Image plugin based on Widgets API
 */

'use strict';

CKEDITOR.dialog.add( 'imagefromset', function( editor ) {

	// RegExp: 123, 123px, empty string ""
	var regexGetSizeOrEmpty = /(^\s*(\d+)(px)?\s*$)|^$/i,

		lang = editor.lang.imagefromset,
		commonLang = editor.lang.common,

		helpers = CKEDITOR.plugins.imagefromset,

		// Editor instance configuration.
		config = editor.config,

		// Content restrictions defined by the widget which
		// impact on dialog structure and presence of fields.
		features = editor.widgets.registered.image.features,

		// Functions inherited from imagefromset plugin.
		getNatural = helpers.getNatural,

		// Global variables referring to the dialog's context.
		doc, widget, image,

		// Global variable referring to this dialog's image pre-loader.
		preLoader,

		// Global variables holding the original size of the image.
		domWidth, domHeight,

		// Global variables related to image pre-loading.
		preLoadedWidth, preLoadedHeight, srcChanged,

		// Global variables related to size locking.
		lockRatio, userDefinedLock,

		// Global variables referring to dialog fields and elements.
		widthField, heightField,

		natural;

	// Validates dimension. Allowed values are:
	// "123px", "123", "" (empty string)
	function validateDimension() {
		var match = this.getValue().match( regexGetSizeOrEmpty ),
			isValid = !!( match && parseInt( match[ 1 ], 10 ) !== 0 );

		if ( !isValid )
			alert( commonLang[ 'invalid' + CKEDITOR.tools.capitalize( this.id ) ] ); // jshint ignore:line

		return isValid;
	}

	// Creates a function that pre-loads images. The callback function passes
	// [image, width, height] or null if loading failed.
	//
	// @returns {Function}
	function createPreLoader() {
		var image = doc.createElement( 'img' ),
			listeners = [];

		function addListener( event, callback ) {
			listeners.push( image.once( event, function( evt ) {
				removeListeners();
				callback( evt );
			} ) );
		}

		function removeListeners() {
			var l;

			while ( ( l = listeners.pop() ) )
				l.removeListener();
		}

		// @param {String} src.
		// @param {Function} callback.
		return function( src, callback, scope ) {
			addListener( 'load', function() {
				// Don't use image.$.(width|height) since it's buggy in IE9-10 (#11159)
				var dimensions = getNatural( image );

				callback.call( scope, image, dimensions.width, dimensions.height );
			} );

			addListener( 'error', function() {
				callback( null );
			} );

			addListener( 'abort', function() {
				callback( null );
			} );

			image.setAttribute( 'src',
				( config.baseHref || '' ) + src );
		};
	}

	// This function updates width and height fields once the
	// "src" field is altered. Along with dimensions, also the
	// dimensions lock is adjusted.
	function onChangeSrc() {
		var value = this.getValue();

		// Remember that src is different than default.
		if ( value !== widget.data.src ) {
			// Update dimensions of the image once it's preloaded.
			preLoader( value, function( image, width, height ) {

				// Cache the new width.
				preLoadedWidth = width;

				// Cache the new height.
				preLoadedHeight = height;

			} );

			srcChanged = true;
		}

		// Value is the same as in widget data but is was
		// modified back in time. Roll back dimensions when restoring
		// default src.
		else if ( srcChanged ) {

			// Restore width field with cached width.
			//widthField.setValue( domWidth );

			// Restore height field with cached height.
			//heightField.setValue( domHeight );

			// Src equals default one back again.
			srcChanged = false;
		}
	}

	function onChangeDimension() {
		// If ratio is un-locked, then we don't care what's next.
		if ( !lockRatio )
			return;

		var value = this.getValue();

		// No reason to auto-scale or unlock if the field is empty.
		if ( !value )
			return;

		// If the value of the field is invalid (e.g. with %), unlock ratio.
		if ( !value.match( regexGetSizeOrEmpty ) )
			toggleLockRatio( false );

		// No automatic re-scale when dimension is '0'.
		if ( value === '0' )
			return;

		var isWidth = this.id == 'width',
			// If dialog opened for the new image, domWidth and domHeight
			// will be empty. Use dimensions from pre-loader in such case instead.
			width = domWidth || preLoadedWidth,
			height = domHeight || preLoadedHeight;

		// If changing width, then auto-scale height.
		if ( isWidth )
			value = Math.round( height * ( value / width ) );

		// If changing height, then auto-scale width.
		else
			value = Math.round( width * ( value / height ) );

		// If the value is a number, apply it to the other field.
		if ( !isNaN( value ) )
			( isWidth ? heightField : widthField ).setValue( value );
	}

	var srcBoxChildren = [];
	
	if (editor.config.imagefromset_imageSet.length) {
		srcBoxChildren.push({
			id: 'src',
			type: 'select',
			label: 'Verfügbare Bilder',
			width: '400px',
			items: editor.config.imagefromset_imageSet,
			//items: [ [ 'Blitzebild mit einem viel zu langen Dateinamen der die Dimension der Dialogbox über die Maßen sprengen würde und auch tut','/img/demo/cktest/pic-01.jpg' ], [ 'Wolkenbild','/img/demo/cktest/pic-02.jpg' ], [ 'Hunde','/img/demo/cktest/pic-03.jpg' ], [ 'Tortoise','/img/demo/cktest/pic-04.jpg' ] ],
			'default': editor.config.imagefromset_imageSet[0][1],
			
			onShow: onChangeSrc,
			onChange: onChangeSrc,
			setup: function( widget ) {
				if (widget.data.src) {
					this.setValue( widget.data.src );
				}
			},
			commit: function( widget ) {
				widget.setData( 'src', this.getValue() );
				widget.setData( 'hasCaption', true );
				widget.setData( 'width', preLoadedWidth );
				widget.setData( 'height', preLoadedHeight );
			}
		});
	} else {
		srcBoxChildren.push({
			type : 'html',
			html : editor.config.imagefromset_message
		});
	}
			/**/
		
	return {
		title: lang.title,
		minWidth: 250,
		minHeight: 200,
		onLoad: function() {
			// Create a "global" reference to the document for this dialog instance.
			doc = this._.element.getDocument();

			// Create a pre-loader used for determining dimensions of new images.
			preLoader = createPreLoader();
		},
		onShow: function() {
			// Create a "global" reference to edited widget.
			widget = this.widget;

			// Create a "global" reference to widget's image.
			image = widget.parts.image;

			// Reset global variables.
			srcChanged = userDefinedLock = lockRatio = false;

			// Natural dimensions of the image.
			natural = getNatural( image );

			// Get the natural width of the image.
			preLoadedWidth = domWidth = natural.width;

			// Get the natural height of the image.
			preLoadedHeight = domHeight = natural.height;
		},
		width: 400,
		contents: [
			{
				id: 'info',
				label: lang.infoTab,
				elements: [
					{
						type: 'vbox',
						padding: 0,
						children: srcBoxChildren
					}
				]
			}
		]
	};
} );
