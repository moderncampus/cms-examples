<?php
	ini_set("display_errors","on");
	
	/**THE FOLLOWING GENERATES THE INFORMATION FROM THE BLOG POSTS**/
	class blogFile{
		public function __construct($f,$p) {
			$file = simplexml_load_file($p . "/" . $f);
			$this->fname = $f;
			$this->path = $p;
			$this->topdir = between($_SERVER['DOCUMENT_ROOT'], "/", $p);
			$this->display = (string)$file->attributes()->display;
			$this->featured = ((string)$file->attributes()->featured == 'true') ? "true" : "false";
			$this->guest = ((string)$file->attributes()->guest == 'true') ? "true" : "false";
			$this->title = utf8_encode(iconv("UTF-8", "ISO-8859-1//TRANSLIT",str_replace("//","<br/>",(string)$file->title)));
			$this->dateTime =  strtotime((string)$file->pubDate);
			$this->date = date("F d, Y",  strtotime((string)$file->pubDate));
			$this->dateYear = date("Y", strtotime((string)$file->pubDate));
			$this->dateMonth = date("n", strtotime((string)$file->pubDate));
			$this->pubDate = (string)$file->pubDate;
			$this->author = (string)$file->author;
			$this->email = (string)$file->email;
			$this->desc = (string)$file->description;
			$this->link = (string)$file->attributes()->link;
			$this->tags = explode(",",$file->tags);
			$this->image = ($file->image) ? array("src"=>htmlspecialchars((string)$file->image->img->attributes()->src), "alt"=>(string)$file->image->img->attributes()->alt) : "false";
			$this->quote = ($file->quote) ? (string)$file->quote : "false";
			$this->comments = ((string)$file->attributes()->comments == 'true') ? "true" : "false";
		}
	}

	/**
	 * acquire_blog_json -- DEPRECATED
	 *
	 * JSON encodes the post data before returning for to allow JS to handle
	 * pagination. However as PHP now handles pagination, this is no longer needed
	 * and only adds processing time.
	 *
	 * @param (dirpath) where to begin searching
	 * @param (conditions) the conditions that each post found must meet
	 * @return the array of post objects ordered by date JSON encoded
	 */
	function acquire_blog_json($dirpath = "/", $conditions = array()){
		$posts = get_all_post_files($dirpath,$conditions);
		usort($posts,"sort_by_date_time");
		return json_encode($posts);
	}

	/**
	 * get_all_post_files
	 *
	 * Searches the directory tree for blog post xml files that match search criteria 
	 * in $conditions starting from $dirpath 
	 *
	 * @param (dirpath) where to begin searching
	 * @param (conditions) the conditions that each post found must meet
	 * @return the array of post objects ordered by date
	 */
	function get_all_post_files($dirpath = "/", $conditions = array()){
		$dir = array("fullpath"=>$_SERVER["DOCUMENT_ROOT"].$dirpath,"currentpath"=>$dirpath);
		$exclude = array(".","..","_resources", "_dev");
		$files = array();

		foreach(array_diff(scandir($dir["fullpath"]),$exclude) as $sd){
			$tmp =  $dir["fullpath"]."/$sd";
			if(is_dir($tmp)){
				$files = array_merge($files,get_all_post_files($dir["currentpath"]."/$sd",$conditions));
			}elseif(pathinfo($tmp,PATHINFO_EXTENSION) == "xml"){
				$nf = new blogFile($sd,$dir["fullpath"]);
				if(post_meets_conditions($nf,$conditions)){$files[] = $nf; }
			}
		}

		usort($files,"sort_by_date_time");
		return $files;
	}

	/**
	 * post_meets_conditions
	 *
	 * Determines whether a post object has attributes that satisfy the conditions 
	 * established in the $conditions array.
	 *
	 * @param (post) the post to analyze
	 * @param (conditions) the conditions that the post must meet
	 * @return true if all conditions are met, otherwise false
	 */
	function post_meets_conditions($post,$conditions = array()){
		//Check to see if the post is to be displayed or not
		if($post->display != "true"){ return false; }
		//Condition #1: Featured
		if(isset($conditions["featured"]) && $post->featured != $conditions["featured"]){ return false; }
		//Condition #2: Year
		if(isset($conditions["year"]) && !empty($conditions["year"]) && !in_array($conditions["year"],array("", $post->dateYear))){ return false; }
		if(isset($conditions["month"]) && !empty($conditions["month"]) && ($conditions["month"] != $post->dateMonth)){ return false; }
		//Condition #3: Author
		if(isset($conditions["author"]) && !empty($conditions["author"]) && !in_array($conditions["author"],array("", $post->author))){ return false; }
		//Condition #4: Tags
		if(isset($conditions["tags"]) && !empty($conditions["tags"])){
			// if we are filtering by tags we want to avoid the current post
			if(!(strpos($post->link, $_SERVER["REQUEST_URI"]) === FALSE || $_SERVER["REQUEST_URI"] == '/' || $_SERVER["REQUEST_URI"] == '/index.php')) { return false; }
			// Post must have all tags in the filter to pass strict filtering
			if(isset($conditions["filtering"]) && $conditions["filtering"] == "strict") {
				if(is_array($conditions["tags"]) && count(array_intersect($conditions["tags"],$post->tags)) < count($conditions["tags"])){ return false; }
				if(!is_array($conditions["tags"]) && count(array_intersect(explode(",",$conditions["tags"]),$post->tags)) < count(explode(",",$conditions["tags"]))){ return false; }
			}
			// Post only needs at least one of the current tag filter to pass loose filtering
			else {
				if(is_array($conditions["tags"]) && count(array_intersect($conditions["tags"],$post->tags)) == 0){ return false; }
				if(!is_array($conditions["tags"]) && count(array_intersect(explode(",",$conditions["tags"]),$post->tags)) == 0){ return false; }
			}
		}
		//All conditions met; return true
		return true;
	}

	/**
	 * convert_tags_to_links
	 *
	 * Converts all $tags into url encoded links relative to the
	 * path specified by $dir.
	 *
	 * @param (tags) the list of tags to output
	 * @param (dir) the relative directory to attach the link
	 * @return the string of tag links
	 */
	function convert_tags_to_links($tags,$dir){
		foreach($tags as $t){ $tmp[] = "<a href='".$dir."?tags=".urlencode($t)."'>$t</a>"; }
		return implode(", ",$tmp);
	}

	/**
	 * filter_posts_by_conditions
	 *
	 * Takes an array of post objects and passes them through the
	 * conditional checks found in post_meets_conditions.
	 *
	 * @param (post) the posts to validate
	 * @param (conditions) the conditions that the post must meet
	 * @return the array of posts that passed the conditions parameter.
	 */
	function filter_posts_by_conditions($posts,$conditions = array()){
		$filtered = array();
		foreach($posts as $p){
			if(post_meets_conditions($p,$conditions)){array_push($filtered, $p);}
		}
		return $filtered;
	}

	/**
	 * display_featured_posts_list
	 *
	 * Outputs a list of featured posts as links.
	 *
	 * @param (dirpath) where to begin searching
	 * @param (limit) the number of post objects to display
	 * @param (conditions) the conditions that each post found must meet
	 * @return the array of posts that passed the conditions parameter.
	 */
	function display_featured_posts_list($dirpath = '/', $limit = 0, $conditions = array()){
		$conditions["featured"] = "true";
		// $posts = json_decode(acquire_blog_json($dirpath,$conditions));
		$posts = get_all_post_files($dirpath,$conditions);
		usort($posts,"sort_by_date_time");
		$limit = ( $limit==0 ) ? 999 : $limit;
		$i = 0;
		?>
		<ul>
		 	<?php foreach($posts as $p) :
				$title = str_replace("<br/>","",$p->title);
			 ?>
				<?php if($i < $limit) echo '<li><a href="'. $p->link .'" title="'. $p->title .'">'. $p->title .'</a></li>'; $i++; ?>
			<?php endforeach; ?>
		</ul>
		<?php
	}

	/**
	 * display_popular_tags
	 *
	 * Aggregates all tags from post found within $dirpath and sorts
	 * them by number of occurrences. The most frequently used tags are
	 * displayed until $limit is reached.
	 *
	 * @param (dirpath) the post object to format and display
	 * @param (limit) the number of featured posts to display
	 * @param (conditions) any extra conditions to filter posts
	 * @return none
	 */
	function display_popular_tags($dirpath, $limit = 0, $conditions = array()) {
		$tags = array();
		$posts = get_all_post_files($dirpath,$conditions);
		foreach($posts as $t){ 
			foreach($t->tags as $tag){
				if($tag != '') {
					$tags[] = $tag;
				}
			}
		}
		array_walk($tags, 'trim_value'); // 	trim tag values
		$acv=array_count_values($tags); //  	get # occurences of each tag
		arsort($acv); 					 //     sort the array by most occurences
		$tags=array_keys($acv);		 	 //		save keys
		
		$i = 0;
		$limit = ( $limit==0 ) ? 999 : $limit;
		?>
		<ul class="tag-list">
			<?php foreach(explode(", ",convert_tags_to_links($tags,$dirpath)) as $key=>$t) : ?>
				<?php if($i < $limit) echo "<li class=\"link-bullets\">".$t."</li>"; $i++; ?>
			<?php endforeach; ?>
		</ul>
		<?php
	}

	/**
	 * display_available_tags
	 *
	 * Aggregates all tags from posts found within $dirpath and sorts
	 * them by number of occurrences. The most frequently used tags are
	 * displayed until $limit is reached.
	 *
	 * @param (dirpath) the directory to begin search
	 * @param (limit) the number of tags to display
	 * @param (conditions) any extra conditions to filter posts
	 * @return none
	 */
	function display_available_tags($dirpath, $limit = 0, $conditions = array()){
		$tags = array();
		// $posts = json_decode(acquire_blog_json($dirpath,$conditions));
		$posts = get_all_post_files($dirpath,$conditions);
		foreach($posts as $t){ 
			foreach($t->tags as $tag){
				if($tag != '') {
					$tags[] = $tag;
				}
			}
		}
		array_walk($tags, 'trim_value');
		$tags = array_unique($tags);
		natcasesort($tags);
		
		//echo (strpos($dirpath, '/posts/') );
		/*if (strpos($dirpath, '/posts/') === false)
			$dirpath = $dirpath . 'posts/';
		else 
			$dirpath = before('/posts/', $dirpath) . '/posts/';*/
		
		$limit = ( $limit==0 ) ? 999 : $limit;
		$i = 0;
		?>
		<ul>
			<?php foreach(explode(", ",convert_tags_to_links($tags,$dirpath)) as $key=>$t) : ?>
				<?php if($i < $limit) echo "<li>".$t."</li>"; $i++; ?>
			<?php endforeach; ?>
		</ul>
		<?php
	}

	/**
	 * display_archive_links
	 * 
	 * A function for displaying a list of links to a listing page filtered by month/year
	 * 
	 * @param (domain) the httproot for building listing path
	 * @param (path) root relative path to listing page to be used.
	 * @param (month) the first month to begin creating archive links for
	 * @param (year) the first year to begin creating archive links for
	 * @return none
	 */
	function display_archive_links($domain, $path, $month, $year) {
		$startDateTime = (new DateTime($year.'-'.$month.'-01'));
		$start = $startDateTime -> modify('first day of this month');
		$endDateTime = (new DateTime('now'));
		$end = $endDateTime -> modify('first day of this month');
		$interval = DateInterval::createFromDateString('1 month');
		$period   = new DatePeriod($start, $interval, $end);
		$months = array();
		$years = array();
		$display = array();
		foreach ($period as $p) {
			$months[] = $p->format("n");
			$years[] = $p->format("Y");
			$display[] = $p->format("F Y");
		}
		
		// sets the order of archives to most recent months first. 
		// comment out these next 3 lines to list from oldest to most recent month.
		$months = array_reverse($months);
		$years = array_reverse($years);
		$display = array_reverse($display);
		?>
		<div class="sidebar-region">
			<h3>Archives</h3>
			<ul>
				<?php
				for($i = 0; $i < count($months); $i++) {
					// only display links to months that have posts associated with them
					if(count(get_all_post_files($path, array("year" => $years[$i], "month" => $months[$i])))) {
						echo '<li><a href="'.$domain.$path.'?year='.$years[$i].'&month='.$months[$i].'">'.$display[$i].'</a></li>';
					}
				}?>
			</ul>
		</div>
		<?php
	}

	/**
	 * display_recent_posts
	 *
	 * Displays the most recent posts within the search directory.
	 * Outputs posts as a list of links
	 *
	 * @param (dirpath) the directory to begin search
	 * @param (limit) the number of posts to display
	 * @param (conditions) any extra conditions to filter posts
	 * @return none
	 */
	function display_recent_posts($dirpath, $limit = 0, $conditions = array()){
		// $posts = json_decode(acquire_blog_json($dirpath,$conditions));
		$posts = get_all_post_files($dirpath,$conditions);
		usort($posts,"sort_by_date_time");
		$limit = ( $limit==0 ) ? 999 : $limit;
		$i = 0;
		?>
		<ul>
			<?php foreach($posts as $p) : ?>
				<?php if($i < $limit) echo '<li><a href="'. $p->link .'" title="'. $p->title .'">'. $p->title .'</a></li>'; $i++; ?>
			<?php endforeach; ?>
		</ul>
		<?php
	}

	/**
	 * display_related_tag
	 *
	 * Displays the most recent posts within the search directory that
	 * have the specified tag.
	 * Outputs posts as a list of links
	 *
	 * @param (dirpath) the directory to begin search
	 * @param (limit) the number of posts to display
	 * @param (datTag) the tag to search for
	 * @return none
	 */
	function display_related_tag($dirpath = '/', $limit = 3, $datTag){
		$conditions["tags"] = $datTag;
		// $posts = json_decode(acquire_blog_json($dirpath,$conditions));
		$posts = get_all_post_files($dirpath,$conditions);
		usort($posts,"sort_by_date_time");
		$i = 0;
		?>
		<ul>
		 	<?php foreach($posts as $p) :
			    if($i < $limit)
			    	//don't display own post item
		    		if (strpos($p->link, $_SERVER["REQUEST_URI"]) === FALSE || $_SERVER["REQUEST_URI"] == '/' || $_SERVER["REQUEST_URI"] == '/index.html')
					    echo '<li><a href="'. $p->link .'" title="'. $p->title .'">'. $p->title .'</a></li>';
					    $i++;
	 		 endforeach; ?>
		</ul>
		<?php
	}


	/**
	 * Truncate passed string to space nearest limit when size exceeds limit.
	 *
	 * @param string $txt string to be inspected
	 * @param integer $limit maximum length of $txt before it is truncated
	 * @return truncated string
	 */
	function clean_truncate($txt,$limit){
		if(strlen($txt) <= $limit)
			return $txt;
		
		$space = strpos($txt," ",($limit-5));
		return ($space > 0) ? substr($txt,0,$space).'...' : substr($txt,0,$limit).'...';
	}
	
	/**
	 * Build a query string based on url params
	 *
	 * @param $t - include tags in query string? 0 or 1
	 * @param $a - include author in query string? 0 or 1
	 * @param $y - include year in query string? 0 or 1
	 * @param $m - include month in query string? 0 or 1
	 * @return query string
	 */
	function getQueryString($t = 0, $a = 0, $y = 0, $m = 0) {
		$qstr = "";
		$qstr .= (isset($_GET["tags"]) && $t > 0) ? "&tags=".htmlspecialchars($_GET["tags"]) : "";
		$qstr .= (isset($_GET["author"]) && $a > 0) ? "&author=".htmlspecialchars($_GET["author"]) : "";
		$qstr .= (isset($_GET["year"]) && $y > 0) ? "&year=".htmlspecialchars($_GET["year"]) : "";
		$qstr .= (isset($_GET["month"]) && $m > 0) ? "&month=".htmlspecialchars($_GET["month"]) : "";
		return $qstr;
	}

	function sort_by_date_time($a,$b){ return ($a->dateTime >= $b->dateTime) ? -1 : 1; }
	//substring after function
	function after($this, $inthat) { if (!is_bool(strpos($inthat, $this))) return substr($inthat, strpos($inthat,$this) + strlen($this)); }
    //substring before
	function before($this, $inthat) { return substr($inthat, 0, strpos($inthat, $this)); }
    //substring in between
	function between($this, $that, $inthat) { return before($that, after($this, $inthat)); }
    //trim array values
    function trim_value(&$value){ $value = trim($value); }
    //string starts with
    function starts_with($haystack, $needle) { /* search backwards starting from haystack length characters from the end */ return $needle === "" || strrpos($haystack, $needle, -strlen($haystack)) !== FALSE; }
    
?>
