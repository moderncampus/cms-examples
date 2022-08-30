# Server Side Nested Navigation Script

## Abstract

The purpose of the script is to recursively parse the ```_nav.inc``` files published to the production
server to generate nested navigation structure reflecting the navigation.

An inital navigation file is loaded and parsed for ```<li>``` nodes.

Given the ```/_nav.inc``` starting point:

	/_nav.inc contents
	<li><a href="/index.php">Home</a></li>
	<li><a href="/section_a/index.php">Section A</a></li>
	<li><a href="/about.php">About</a></li>

The script will simply render out the first link, then see the link to a sub-section on the
second link and attempt to load the navigation file for that section.

	/section_a/_nav.inc contents
	<li><a href="/section_a/freshmen_college.php">Why college?</a></li>
	<li><a href="/section_a/freshmen_ready.php">Get ready</a></li>

The script will render out the links in the section_a navigation file and then proceed to the third
link of the inital navigation file.  This happens recursively resulting in the following output:

	<ul>
		<li><a href="/index.php">Home</a></li>
		<li>
			<a href="/section_a/index.php">Section A</a>
			<ul>
				<li><a href="/section_a/freshmen_college.php">Why college?</a></li>
				<li><a href="/section_a/freshmen_ready.php">Get ready</a></li>
			</ul>
		</li>
		<li><a href="/about.php">About</a></li>
	</ul>

## Reference

The entry point of the script expects a query string parameter ```$nav``` to define the path of the
navigation starting point.  If no path is given ```/_nav.inc``` is the default.

	parse_str($_SERVER['QUERY_STRING']);
	$nav = (isset($nav)) ? $nav : "/_nav.inc";

* Change this value to reflect your navigation file names.

The path is also converted to the servers local file system path.

	$server_file_path = $_SERVER["DOCUMENT_ROOT"] . $nav;

You can set how many levels deep the script should process by setting the $nest\_limit.

	$nest_limit = -1;

* Set to -1 for limitless nesting.

Then the script initializes the variable $html as the opening root ```<ul>``` node.

	$html = "<ul>";

### process\_nav\_file()

The inital call to ```process_nav_file``` is then executed given the path to the first ```_nav.inc```
file

	process_nav_file($server_file_path);

This function maintains the current nesting level upon entry and exit of its scope:

	$nest_level++;
	...
	$nest_level--;

If the given navigation file exists a regex pattern is defined to identify ```<li>``` nodes within it.

	$regex = '/(<li[^>]*?>[\s]*?<a[^>]*?href="([^"]+?)">[\s\S]*?<\/a>[\s]*?<\/li>)/';

Using the regex callback function ```preg_replace_callback```, each matched ```<li>``` node will be passed as the argument to a call to ```match_li```. In other words, ```match_li``` will be called once for each ```<li>``` node in the navigation file.

	if(preg_match($regex, $file))
		preg_replace_callback($regex,"match_li",$file);

### match\_li()

A gloabl variable ```$html``` is mainted during the recursion containing the nested navigation HTML.

Another regex pattern is defined to determine if the current ```<li>``` node contains a link to a sub-section, that being a link ending
in the default page name ```index.html|default.aspx``` or a slash ```/```.

	$regex = '/<li[^>]*?>[\s]*?<a[^>]*?href=\"([^"]*?\/)(index\.php)?\"[^>]*?>([\s\S]*?)<\/a>[\s]*?<\/li>/';

* you will change the portion ```(index\.php)``` according to your implementation.

The current ```<li>``` node passed into the function is then tested with a regex to determine if it's a section link.

	if(preg_match($regex, $li))
		preg_replace_callback($regex,"match_section_li",$li);
	else
		$html .= $li;

* If it is ```<li><a href="/section_a/index.php">Section A</a></li>``` the ```match_section_li``` function is called with the current ```<li>``` as the paramater, if it's not it is simply
rendered out as the non section link that it is: ```<li><a href="/about.php">About</a></li>```

### match\_section\_li()

Global variables are made available to the function scope.

	global $html;
	global $current_directory;
	global $nest_level;
	global $nest_limit;
	global $processed_section;


The regex defined in ```match_li``` uses 3 capture groups so that portions of the section link can be copied into local variables.

	$li = $matches[0];
	$href = $matches[1];
	$page = $matches[2];
	$title = $matches[3];

The href value of the section link is translated into a server file system path.

	$file_path = $_SERVER["DOCUMENT_ROOT"] . $href . "_nav.inc";

And we start off by allowing this section link to cause a recursive callback to the ```process_nav_file``` function.

	$process_nav = true;

Many conditions will cause the section link to simply be copied as is without the ```_nav.inc``` file in the section this ```<li>```
links to being opened.

	//check if file exists
	if(file_exists($file_path)){
		$file = file_get_contents($file_path);

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

If all the conditions fail we can process the section's ```_nav.inc``` file.

Keep track of processed ```_nav.inc``` files so that they are only processed once.

	if($href != '')
		$processed_section[] = $href;

The current link is rendered 'manually' instead of simply being copied from the ```_nav.inc``` file.

	$html .= "<li><a href=\"{$href}{$page}\">{$title}</a><ul class=\"level-{$nest_level}\">";

* It will contain the nested ```<ul>```

Next the call to ```process_nav_file``` is executed moving this documentation to the process\_nav\_file section.
