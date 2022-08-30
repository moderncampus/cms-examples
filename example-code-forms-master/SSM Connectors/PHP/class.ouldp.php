<?php
$debug = false; // enable "debug mode" for this script

class ouldp {
    public $config;
    
    public function __construct($config) {
        $this->config = $config;
    }

    public function send($method, $param) {
        global $debug;
        
        $curlError = "";
        $result = array('active' => false, 'message' => '','data' => '');
        
        
        // turns form data into xmlrpc
        $request = xmlrpc_encode_request($method, $param);

        //  this is the original way we sent data when using file_get_contents, when using curl to post the xmlrpc this step is not needed
        //  $context = stream_context_create(array("http" => array( 'method'  => "POST",'header'  => "Content-Type: text/xml",'content' => $request )));
        
        $port = $this->config['ssm_port'] ? ':'.$this->config['ssm_port'] : '';
        $path = $this->config['ssm_path'] ? $this->config['ssm_path'] : '';
        
        $url = $this->config['ssm_host'].$port.$path;
        // using curl to post the data to the SSM this is a change to the default 
        // this is a more secure way than allowing url_open when the SSM is on a different server than the website
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: text/xml'));
        curl_setopt($ch, CURLOPT_POSTFIELDS, $request);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $ssmResponse = curl_exec($ch);
        // preserve curl error if present
        if(curl_error($ch)) {
            $curlError = curl_error($ch);
        }
        curl_close($ch);
        
        // direct decode of ssmResponse from curl method
        $value = xmlrpc_decode($ssmResponse);
        
        // to decode ssm response when using file_get_contents instead of curl
//         $value = xmlrpc_decode(file_get_contents($url, false, $context));
        
        if (isset($value['faultCode'])) {
            $result['message'] = "Faultcode : " . $value['faultCode'];
            $result['data']    = $value['faultString'];
        }
        elseif (isset($value['success'])) {
            
            if($value['success']  == true) { //POST: Form submisson correct
                $result['active']  = $value['success'];
                $result['message'] = $value['message'];
            }
            else { //POST: Submission is not active.
                $result['active']  = $value['success'];
                $result['message'] = $value['message'];
                $result['data']    = $value['errors'];
            }
        }
        elseif (isset($value['active'])) { //GET: Form is active.
            //Active is true
            if($value['active'] == true){
                $result['active']  = true;
                $result['message'] = "form ID";
                $result['data']    = $value['formid'];
            }
            else {//GET: Form is inactive.
                $result['message'] = $value['message'];
            }
        }
        elseif (isset ($value['errors'])) { //POST: Incorrect data provided
            $result['active']  = true;
            $result['message'] = "errors";
            $result['data']    = $value['errors'];
        }
        elseif ($curlError != "") { //Curl encountered an error.
            $result['message'] = "Curl Error";
            $result['data']    = "An error with curl contacting the server. Please enable debug mode for more info.";
            if ($debug) {
                $result['data']    = $curlError;
            }
        }
        else { //Form encountered an error.
            $result['message'] = "Faultcode : unknown";
            $result['data']    = "An unknown error when contacting the server. Please Check the logs.";
        }
        
        return $result;
    }
    
    public function validateCaptcha(){
        $response = isset($_POST['g-recaptcha-response']) ? $_POST['g-recaptcha-response'] : '';
        
        if($response == ''){
            // captcha validation failed
            return false;   
        }
        
        $url = 'https://www.google.com/recaptcha/api/siteverify';
        $secret = $this->config['captcha_secret'];
        $remoteip = $_SERVER['REMOTE_ADDR'];
        
        $params = array(
            'secret' => $secret,
            'response' => $response,
            'remoteip' => $remoteip
        );
        
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_POST, true);
        // curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: text/xml'));
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($params));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        curl_close($ch);

        $response = json_decode($response,true);
        
        if(isset($response['success']) && $response['success'] == true){
            // captcha validation passed
            return true;
        }else{
            // captcha validation failed
            return false;
        }
    }
}

?>
