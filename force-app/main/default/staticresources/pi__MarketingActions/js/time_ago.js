var moment = require('moment-timezone');
var jQuery = require('jquery');
require('timeago');

function getTimeAgo(_dateString){
	var dateString = getDSTDateString(_dateString);
	var date = moment(dateString, 'YYYY-MM-DD HH:mm:ss Z').toDate();
	return jQuery.timeago(date);
}

function getDSTDateString(dateString) {
	var SERVER_TIMEZONE_OFFSET = '-0500';
	var SERVER_TIMEZONE_OFFSET_DLS = '-0400';

	// Handle timezone differences
	dateString = dateString.toUpperCase();
	// Check if activity time occurred during DST (specify America/New_York timezone to observe DST)
	var isDST = moment(dateString).tz('America/New_York').isDST();
	var offset = isDST ? SERVER_TIMEZONE_OFFSET_DLS : SERVER_TIMEZONE_OFFSET;
	// Add offset
	if ((dateString.indexOf('EST') < 0)) {
		dateString = dateString + ' ' + offset;
	}
	else {
		// Convert EST to be -0500 since its coming in EST
		dateString = dateString.replace(/EST/g, offset);
	}
	return dateString;
}

module.exports = {
	getTimeAgo: getTimeAgo,
	getDSTDateString: getDSTDateString
}
