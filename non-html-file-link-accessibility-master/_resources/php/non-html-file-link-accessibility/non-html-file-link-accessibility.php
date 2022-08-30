<?php
/**
 * This file will take a file path and a friendly display for the file type. It will retrieve the byte size of the file at the given path and return a string representation of the file type and size within parentheses, which is intended to be used as an accessibility aid. 
*/

// get the target file path and file type display string from the query string (passed from the XSL)
$myFile = isset($_GET['path']) ? htmlspecialchars($_GET['path']) : '';
$fileTypeDisplay = isset($_GET['ftd']) ? htmlspecialchars($_GET['ftd']) : '';

$bytes = get_file_size($myFile);
$bytes = get_friendly_bytes($bytes);

// final output
if ($bytes == '0 bytes') { // if filesize is 0 bytes, something went wrong
	echo " (*Check File Path*)";
} else {
	echo " (" . $fileTypeDisplay . " " . $bytes . ")";
}


/**
 * Gets a friendly, human-readable output based on a raw byte size
 *
 * @param integer @bytes	A number in bytes to display
 *
 * @return	A friendly display of the provided byte value
*/
function get_friendly_bytes($bytes) {
	if     ($bytes >= 1073741824) { return number_format($bytes / 1073741824, 2) . ' GB'; }
	elseif ($bytes >= 1048576)    { return number_format($bytes / 1048576, 2) . ' MB'; }
	elseif ($bytes >= 1024)       { return number_format($bytes / 1024, 2) . ' KB';}
	elseif ($bytes > 1)           { return $bytes . ' bytes';}
	elseif ($bytes == 1)          { return $bytes . ' byte';}
	else                          { return '0 bytes';};
}

/**
 * Gets the filesize for a file at the given URL.
 *
 * @param string $url	The path to a file you would like to get the filesize of
 *
 * @return	The raw filesize that was found at the given URL
*/
function get_file_size($url) {
	// remove full URL to current site if given
	$root = (!empty($_SERVER['HTTPS']) ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'] . '/';
	$url = str_replace($root, '', $url);
	
	if (strpos($url, '//') === false) {
		return intval(filesize($_SERVER['DOCUMENT_ROOT'] . $url));
	} else {
		$ch = curl_init($url);

		curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
		curl_setopt($ch, CURLOPT_HEADER, TRUE);
		curl_setopt($ch, CURLOPT_NOBODY, TRUE);

		$data = curl_exec($ch);
		$size = curl_getinfo($ch, CURLINFO_CONTENT_LENGTH_DOWNLOAD);

		curl_close($ch);
		return $size;	
	}
}
?>