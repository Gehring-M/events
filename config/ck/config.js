config.extraPlugins = 'sourcedialog';
config.width = '805px';
config.stylesSet = [
	{
		name: 'Artikel Sub-Headline',
		element: 'p',
		attributes: {
			'class': 'ag-sub-headline'
		}
	},{
		name: '"CTA" Verlinkung',
		element: 'a',
		attributes: {
			'class': 'ag-cta'
		}
	},{
		name: '"CTA" Button',
		element: 'a',
		attributes: {
			'class': 'ag-cta-button'
		}
	},{
		name: 'PIWIK Download Tracking',
		element: 'a',
		attributes: {
			'class': 'piwik_download'
		}
	},{
		name: 'Bild linksbündig',
		element: 'img',
		attributes: {
			'class': 'ag-img-left'
		}
	},{
		name: 'Bild zentriert',
		element: 'img',
		attributes: {
			'class': 'ag-img-center'
		}
	},{
		name: 'Bild rechtsbündig',
		element: 'img',
		attributes: {
			'class': 'ag-img-right'
		}
	},{
		name: 'Special Container',
		element: 'div',
		attributes: {
			'style':"background:#eee; border: 1px solid #ccc; padding: 5px 10px;"
		}
	},{
		name: 'Small',
		element: 'small'
	}
];
config.disallowedContent = "h1";

config.toolbar = [
	{ name: 'document', items: [ 'Sourcedialog' ] },
	{ name: 'clipboard', groups: [ 'clipboard', 'undo' ], items: [ 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo' ] },
	{ name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ], items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ] },
	{ name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align', 'bidi' ], items: [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock' ] },
	'/',
	{ name: 'insert', items: [ 'Image', '-', 'Link', 'Unlink', 'Anchor', '-', 'Table', 'SpecialChar'] },
	{ name: 'styles', items: [ 'Styles', 'Format' ] },
	{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
	{ name: 'editing', groups: [ 'find', 'selection', 'spellchecker' ], items: [ 'Find', 'Replace', '-', 'SelectAll', '-' ] },
	{ name: 'tools', items: [ 'Maximize', 'ShowBlocks' ] }
];
