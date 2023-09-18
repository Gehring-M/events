/**
 * This file includes the required ext-all css file based upon "theme" 
 * url parameter.
 */
(function () {
	function getQueryParam(name) {
		var regex = RegExp('[?&]' + name + '=([^&]*)');

		var match = regex.exec(location.search) || regex.exec(path);
		return match && decodeURIComponent(match[1]);
	}

	function hasOption(opt, queryString) {
		var s = queryString || location.search;
		var re = new RegExp('(?:^|[&?])' + opt + '(?:[=]([^&]*))?(?:$|[&])', 'i');
		var m = re.exec(s);

		return m ? (m[1] === undefined || m[1] === '' ? true : m[1]) : false;
	}

	var path = 'ext-4.2.1.883',
	theme = getQueryParam('theme') || 'neptune',
	suffix = [],
	i = 3;

	if (theme && theme !== 'classic') {
		suffix.push(theme);
	}

	suffix = (suffix.length) ? ('-' + suffix.join('-')) : '';

	document.write('<link rel="stylesheet" type="text/css" href="' + path + '/resources/css/ext-all' + suffix + '.css"/>');

})();
