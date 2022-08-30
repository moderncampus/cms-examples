<?php
	ini_set("display_errors","on");
	include("blog-functions.php");

	date_default_timezone_set('America/Los_Angeles');

	$dir = (isset($_GET["dir"])) ? htmlspecialchars($_GET["dir"]) : "/blog";
	$limit = (isset($_GET["limit"])) ? htmlspecialchars($_GET["limit"]) : 50;
	$conditions = array();
	$skip = 0;
	
	if (isset($_GET["tags"])){ $conditions["tags"] = htmlspecialchars($_GET["tags"]); }
	if (isset($_GET["featured"])) { $conditions["featured"] = htmlspecialchars($_GET["featured"]); }
	if (isset($_GET["year"])) { $conditions["year"] = htmlspecialchars($_GET["year"]); }
	if (isset($_GET["author"])) { $conditions["author"] = htmlspecialchars($_GET["author"]); }
	if (isset($_GET["skip"])) { $skip = htmlspecialchars($_GET["skip"]); }
	
	$posts = get_all_post_files($dir,$conditions);
	
	header("Content-Type: text/xml;charset=utf-8");
	$url = "http://".$_SERVER['SERVER_NAME'] . $dir;
	echo "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n";
?>
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
	<channel>
		<title>SCHOOL_NAME | RSS Feed</title>
		<link><?php echo $url; ?></link>
		<description>A Blog managed by SCHOOL_NAME.</description>
		<language>en-us</language>
		<lastBuildDate><?php echo date("D, d M o H:i:s O"); ?></lastBuildDate>
		<docs>http://blogs.law.harvard.edu/tech/rss</docs>
		<generator>OmniUpdate (OU Publish)</generator>
		<?php  if (count($posts) > 0) :
		$items = 0;
		foreach($posts as $key=>$p): 
		if ($items < $limit && $key >= $skip) :
			add_item($p);
		$items++; endif; endforeach; endif; ?>
	</channel>
</rss>


<?php
	function add_item($p) {
		$pubDate = strtotime($p->pubDate);
		$title = $p->title; ?>
		<item>
			<title><?php echo htmlentities($title); ?></title>
			<link><?php echo $p->link; ?></link>
			<description><?php echo htmlentities($p->desc;) ?></description>
			<author><?php echo $p->email; ?> (<?php echo $p->author; ?>)</author>
			<pubDate><?php echo date("D, d M o H:i:s O", $pubDate); ?></pubDate>
			<?php if($p->image != "false") : $image = (starts_with($p->image["src"], "/")) ? "http://".$_SERVER['SERVER_NAME'].$p->image["src"] : $p->image["src"]; ?>
			<media:content url="<?php echo $image; ?>" type="image/jpg">
				<media:title><?php echo $title; ?></media:title>
				<media:description><?php echo $p->image["alt"]; ?></media:description>
				<media:thumbnail url="<?php echo $image; ?>"/>
				<media:keywords><?php echo $p->image["alt"]; ?></media:keywords>
			</media:content>
			<?php endif; ?>
			<guid><?php echo $p->link; ?></guid>
		</item>
<?php
	}

?>
