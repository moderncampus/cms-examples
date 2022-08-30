<?php

// error_reporting(E_ALL);
// ini_set("display_errors", 1);

/***** CONFIGURATION *****/
$config = array(
	"ssm_host" => "http://127.0.0.1", //SSM Host location. Change this if the SSM is on a different server than the connector script.
	"ssm_port" => "7518",
	"ssm_path" => "",
	"captcha_secret" => "" // Set to Google reCAPTCHA secret. CAPTCHA validation is bypassed if this is left empty.
);
// ADD Site Names and UUIDs
$site_uuids = array(
	"CHANGE-THIS-SITE-NAME" => "102971fd-8a2b-4e8a-9e2a-03e19030d2ac",
    "test" => "3029sfd-8a2b-4e9a-9e2a-03e19030d2ac"
);
/*************************/



$config['site_uuid'] = $site_uuids[$_POST['site_name']];
$config['webroot'] = $_SERVER['DOCUMENT_ROOT'];

require_once('class.ouldp.php');
$ouldp = new ouldp($config);


$formValidated = true;

if(isset($_POST['form_grc'])){ // obfuscated form field that indictates google reCAPTCHA validation is required.
	$formValidated = $ouldp->validateCaptcha();
}

if($formValidated){
	$form_uuid = $_POST['form_uuid'];

	if(!count($_POST)) {
		$func = "ldp.form.enabled";
		$params = array($config['site_uuid'], $form_uuid);

		$result = $ouldp->send($func,$params);
		echo json_encode($result);
	}
	elseif(count($_POST)){
		$func = "ldp.form.submit";
		$params = array($config['site_uuid'], $form_uuid, $_REQUEST,
						array('OXLDP_FORM_SERVER_NAME'     => $_SERVER['SERVER_NAME'],
							  'OXLDP_FORM_SERVER_IP'       => $_SERVER['SERVER_ADDR'], // LOCAL_ADDR when ssm is on a windows server
							  'OXLDP_FORM_REQUEST_TIME'    => $_SERVER['REQUEST_TIME'],
							  'OXLDP_FORM_HTTP_HOST'       => $_SERVER['HTTP_HOST'],
							  'OXLDP_FORM_HTTP_REFERER'    => $_SERVER['HTTP_REFERER'],
							  'OXLDP_FORM_HTTP_USER_AGENT' => $_SERVER['HTTP_USER_AGENT'],
							  'OXLDP_FORM_REMOTE_IP'       => $_SERVER['REMOTE_ADDR'],
							  'OXLDP_FORM_SCRIPT_NAME'     => $_SERVER['SCRIPT_FILENAME'],
							  'OXLDP_FORM_REMOTE_PORT'     => $_SERVER['REMOTE_PORT']));

		$result = $ouldp->send($func,$params);
		echo json_encode($result);
	}
}else{
	echo '{"active":false,"message":"Form did not pass CAPTCHA validation!","data":""}';
}
   
?>
