<?php
// Show all errors
error_reporting(E_ALL);

parse_str($_SERVER['QUERY_STRING']);
$nav = (isset($nav)) ? $nav : "/_nav.inc";

$server_file_path = $_SERVER["DOCUMENT_ROOT"] . $nav;
$current_directory = str_replace("_nav.inc", "", $nav);
$processed_section = array();
$nest_level = 0;
$nest_limit = -1;

$html = "<ul>";

process_nav_file($server_file_path);

$html .= "</ul>";

echo $html;

function process_nav_file($file_path){
	global $nest_level;

	$nest_level++;

	if(file_exists($file_path)){
		$file = file_get_contents($file_path);
		//remove html comments
		$file = preg_replace("<!\-\-.*?\-\->" , "", $file);
		$regex = '/(<li[^>]*?>[\s]*?<a[^>]*?href="([^"]+?)"[^>]*?>[\s\S]*?<\/a>[\s]*?<\/li>)/';

		if(preg_match($regex, $file))
			preg_replace_callback($regex,"match_li",$file);
	}

	$nest_level--;
}

function match_li($matches){
	global $html;

	$li = $matches[0];
	$regex = '/<li[^>]*?>[\s]*?<a[^>]*?href=\"(\/[^"]*?\/)(index\.php)?\"[^>]*?>([\s\S]*?)<\/a>[\s]*?<\/li>/';

	if(preg_match($regex, $li))
		preg_replace_callback($regex,"match_section_li",$li);
	else
		$html .= $li;
}

function match_section_li($matches){
	global $html;
	global $current_directory;
	global $nest_level;
	global $nest_limit;
	global $processed_section;

	$li = $matches[0];
	$href = $matches[1];
	$page = $matches[2];
	$title = $matches[3];

	$file_path = realpath($_SERVER["DOCUMENT_ROOT"].$href."_nav.inc");

	$process_nav = true;

	//check if file exists
	if(file_exists($file_path)){
		$file = file_get_contents($file_path);
		//remove html comments
		$file = preg_replace("<!\-\-.*?\-\->" , "", $file);

		//make sure the file contains at least one <li>
		//so an empty <ul> is not generated
		$regex = '/(<li[^>]*?>[\s]*?<a[^>]*?>[\s\S]*?<\/a>[\s]*?<\/li>)/';

		if(!preg_match($regex, $file))
			$process_nav = false;
	}
	else
		$process_nav = false;	//no _nav in section

	//check if this is the current sections index page link
	if(!strcmp($href, $current_directory))
		$process_nav = false;

	//check if class=ou-no-subnav within the li's node
	if(strpos($li, "class=\"ou-no-subnav\"") !== false)
		$process_nav = false;

	if($nest_level == $nest_limit)
		$process_nav = false;

	//check if we've already processed this section before (cross-link)
	if(in_array($href, $processed_section))
		$process_nav = false;

	if($process_nav){
		//add each processed section to array
		if($href != '')
			$processed_section[] = $href;

		$html .= "<li><a href=\"{$href}{$page}\">{$title}</a><ul class=\"level-{$nest_level}\">";

		$current_directory = $href;

		process_nav_file($file_path);

		$html .= "</ul></li>";
	}
	else
		$html .= $li;	//just copy the li
}

?>
