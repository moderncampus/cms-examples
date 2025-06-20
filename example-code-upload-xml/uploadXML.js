const fs = require('fs');
const path = require('path');

/**
 * Logs into the CMS - returns a token, which is used for API calls.
 *
 * @skin: the skin for the desired CMS
 * @account: the account CMS
 * @username: the username of the user to login to
 * @password: the password of the user to login to
 */
async function cmsLogin(skin, account, username, password) {
	const connect = async () => {
		// Sets the params needed for logging in
		const body = new URLSearchParams();
		body.append('skin', skin);
		body.append('account', account);
		body.append('username', username);
		body.append('password', password);
		const response = await fetch('https://a.cms.omniupdate.com/authentication/login', {
			method: 'POST',
			body,
		});
		return response.json()
	}

	// Runs the connection and gets the token
	const data = await connect();
	const token = await data.gadget_token;

	console.log('token: ' + token);

	return token;
}

/**
 * Uploads an XML
 *
 * @token: the token from cmsLogin
 * @site: the desired site to upload to
 * @xmlPath: the local path to the xml file
 * @uploadPath: the path the xml file will be uploaded to
 */
async function uploadXML(token, site, xmlPath, uploadPath) {
	const filename = path.basename(xmlPath);
	// Gets the binary data for the desired XML file
	const xmlBuffer = fs.readFileSync(xmlPath);
	const blob = new Blob([xmlBuffer], { type: 'text/xml' });

	// Sets the params for uploading files
	const params = new URLSearchParams({
		'site': site,
		'path': uploadPath
	}).toString();

	// Sets up the body, which is just the file to upload
	const body = new FormData();
	body.append(filename, blob);

	// Performs the upload API call
	const response = await fetch(`https://a.cms.omniupdate.com/files/upload?${params}`, {
		method: 'POST',
		body: body,
		headers: {
			'X-Auth-Token': token
		}
	});

	const result = await response.json();

	// Returns a key for the upload
	return result;
}

(async () => {
	// Ensure the UPLOAD_PATH exists in the CMS, or the API call may fail quietly 
	const token = await cmsLogin('[SKIN]', '[ACCOUNT]', '[USERNAME]', '[PASSWORD]');
	console.log(await uploadXML(token, '[SITE]', '[XML_PATH]', '[UPLOAD_PATH]'));
})();
