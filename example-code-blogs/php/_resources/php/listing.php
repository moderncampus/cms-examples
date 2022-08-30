<?php
    ini_set("display_errors","on");
	include("blog-functions.php");
	
	if(isset($_POST["action"]) && !empty($_POST["action"])){
		switch($_POST["action"]){
			case "display": display_listing($_POST["posts"],$_POST["page"],$_POST["limit"]); break;
			case "acquire": print_r(acquire_blog_json($_POST["path"],$_POST["conditions"])); break;
		}
	}

	/**
	 * display_listing
	 *
	 * Generates a listing of blog posts and calls the pagination function.
	 *
	 * @param (posts) the post objects to display
	 * @param (limit) the number of post objects to display
	 * @return none
	 */
	function display_listing($files,$page = 1,$limit = 4, $page_range = 3){
		$totalFiles = count($files);
		if ($totalFiles < 1) {
			echo '<h3 style="opacity:0.6;font-weight:700;text-align:center;padding-top:50px;">No posts to display</h3>';
		}
		else {
			$totalPages = ceil(count($files) / $limit);
			$page = (isset($_GET["page"])) ? htmlspecialchars($_GET["page"]) : $page;
			$page = ($page > $totalPages) ? $totalPages : ($page < 1 ? 1 : $page);
			$files = array_slice($files,$limit * (($page-1 >=0) ? $page-1 : 1));
			for($i = 0; $i < $limit && $i < count($files); $i++){display_blog_post($files[$i]);}
			display_pagination($page, $totalPages, $page_range);
		}
	}

	/**
	 * display_blog_post
	 *
	 * Outputs styled listing html for a blog post object.
	 *
	 * @param (post) the post object to format and display
	 * @return none
	 */
	function display_blog_post($post){
		?>
			<article>
				<div class="row">
					<?php if($post->image != "false") : ?>
						<div class="show-for-medium-up medium-2 columns">
							<img class="post-image" src="<?php echo $post->image["src"]; ?>" alt="<?php echo $post->image["alt"]; ?>" />
						</div>
					<?php endif; ?>
					<div class="small-12 medium-10 columns">
						<h3><a title="<?php echo $post->title; ?>" href="<?php echo $post->link; ?>"><?php echo $post->title; ?></a></h3>
						<p><a href="mailto:<?php echo $post->email; ?>"><?php echo $post->author; ?></a> - <em><?php echo $post->date; ?></em></p>
						<p><?php echo $post->desc; ?></p>
						<?php if(!empty($post->tags)) : ?>
							<p><em>tags: </em> <?php echo convert_tags_to_links($post->tags,$post->topdir); ?></p>
						<?php endif; ?>
						<?php if($post->comments != "false") : ?>
							<a class="comments" href="<?php echo $post->link; ?>#disqus_thread">0 comments</a>
						<?php endif; ?>
					</div>
				</div>
			</article>
		<?php
	}

	/**
	 * display_asset_listing
	 *
	 * Used for blog asset template matches -- no pagination. Calls a lightweight 
	 formatting option as most assets will be used in areas of constrained space.
	 *
	 * @param (posts) the post objects to display
	 * @param (limit) the number of post objects to display
	 * @return none
	 */
	function display_asset_listing($posts,$limit = 4){
		for($i = 0; $i < $limit && $i < count($posts); $i++){
			display_post_teaser($posts[$i]);
		}
	}

	/**
	 * display_post_teaser
	 *
	 * what the function does
	 *
	 * @param (post) the post object to format and display
	 * @return none
	 */
	function display_post_teaser($post) {
		?>
		<div class="spost clearfix">
			<?php if($post->image != "false") : ?>
			<div class="entry-image">
				<a href="<?php echo $post->link; ?>" target="_blank" class="nobg"><img src="<?php echo $post->image["src"]; ?>" alt="<?php echo $post->image["alt"]; ?>"></a>
			</div>
			<?php endif; ?>
			<div class="entry-c">
				<div class="entry-title">
					<h4><a href="<?php echo $post->link; ?>" target="_blank"><?php echo $post->title; ?></a></h4>
				</div>
				<ul class="entry-meta">
					<li><i class="icon-calendar3"></i> <?php echo $post->date; ?></li>
				</ul>
			</div>
		</div>
		<?php
	}

	/**
	 * display_featured_slides
	 *
	 * Outputs featured style listing of blog posts.
	 *
	 * @param (post) the post object to format and display
	 * @param (limit) the number of featured posts to display
	 * @return none
	 */
	function display_featured_slides($posts, $limit){
		$conditions["featured"] = "true";
		$tags = (isset($_GET["tags"])) ? htmlspecialchars($_GET["tags"]) : "";
		$posts = filter_posts_by_conditions($posts,$conditions);
		//hide if no featured posts or a tag has been selected
		if(count($posts) == 0 || $tags != ''){ echo "<div class='hide-featured'></div>"; }
		$i = 0;
		foreach($posts as $p) : ?>
			<?php if($i < $limit) : ?>
				<div>
					<div class="row">
						<div class="show-for-medium-up  medium-2 columns">
							<a href="<?php echo $p->link; ?>" data-cycle-title="<?php echo $p->title; ?>" data-cycle-desc="<?php echo $p->desc; ?>"><img src="<?php echo $p->image["src"]; ?>" alt="<?php echo $p->image["alt"]; ?>" /></a>
						</div>
						<div class="small-12 medium-8 columns">
							<h5 class="show-for-medium-up"><?php echo $p->title; ?></h5>
							<h5 class="show-for-small-only"><a href="<?php echo $p->link; ?>"><?php echo $p->title; ?></a></h5>
							<p class="small-bottom-margin"><a href="mailto:<?php echo $p->email; ?>"><?php echo $p->author; ?></a> - <em><?php echo $p->date; ?></em></p>
							<p class="no-bottom-margin show-for-medium-up"><?php echo $p->desc; ?></p>
						</div>
						<div class="show-for-medium-up medium-2 columns">
							<a href="<?php echo $p->link; ?>" class="radius tiny button right">read more</a>
						</div>
					</div>
				</div>
		    <?php $i++; endif; ?>
		<?php endforeach;
	}

	

	/**
	 * display_pagination
	 *
	 * Outputs a ul/li style pagination with ellipsys
	 *
	 * @param (currentPage) the current page
	 * @param (limit) the number of featured posts to display
	 * @param (totalFiles) the total number of blog posts being paginated.
	 * @param (page_range) the number of page links to display.
	 * @return none
	 */
	function display_pagination($currentPage, $totalPages, $page_range) {
		//////////////////////////////
		// START Visible Pagination Logic
		//////////////////////////////
		if ($page_range < 3)
			$page_range = 3; // min
		elseif ($page_range > $totalPages)
			$page_range = $totalPages; // max

		$page_left  = floor(($page_range-1)/2);
		$page_right = ceil( ($page_range-1)/2);
		$page_start = $currentPage - $page_left;
		$page_end   = $currentPage + $page_right;
		$shift = 0; // accommodate under/over
		if ($page_end > $totalPages) $shift += $totalPages - $page_end;
		if ($page_start < 1)		$shift += 1 - $page_start;
		$page_start += $shift;
		$page_end   += $shift;
		//////////////////////////////
		// END Visible Pagination Logic
		//////////////////////////////
		
		$qstr = getQueryString(1,1,1,1);
		echo '<nav class="pagination"><ul>';
		
		if ($currentPage > 1) {
			if ($page_start > 1) {
				echo '<li><a href="?page=1'.$qstr.'" class="pagelink">1</a></li>';
				if ($page_start > 2) {
					echo '<li><a href="?page='.($page_start-1).$qstr.'" class="pagelink">...</a></li>';
				}
			}
			
		}

		for ($i=$page_start; $i < $page_end+1; $i++) {
			$class = ($i == $currentPage)? ' class="active"' : 'class="pagelink"';
			// float vs int
			echo '<li><a href="?page='.$i.$qstr.'"'.$class.'>'.$i.'</a></li>';
		}
		
		if ($currentPage < $totalPages) {
			if ($page_end < $totalPages) {
				echo '<li><a href="?page='.($page_end + 1).$qstr.'" class="pagelink">...</a></li>';
				echo '<li><a href="?page='.$totalPages.$qstr.'" class="pagelink">'.$totalPages.'</a></li>';
			}
		}
		
		echo '</ul></nav>';
	}

	/**
	 * display_pagination_simple
	 *
	 * Outputs a simple pager with links for older and previous page as well as
	 * a page input option displaying the current page out of the total.
	 *
	 * @param (currentPage) the current page
	 * @param (limit) the number of featured posts to display
	 * @param (totalFiles) the total number of blog posts being paginated.
	 * @return none
	 */
	function display_pagination_simple($currentPage, $totalPages) {
		$tags = (isset($_GET["tags"])) ? htmlspecialchars($_GET["tags"]) : "";
		?>
		<div class="pagination">
			<div class="newer">
				<p><a <?php if($currentPage <= 1) : ?>class="hide"<?php endif; ?> href="<?php echo("?page=".($currentPage - 1)."&tags=".$tags); ?>">← Newer Posts</a></p>
			</div>
			<div class="pageNum">
				<form id="pageNum" method="GET">
					<label>Page: <input name="page" value="<?php echo $currentPage; ?>" /> of <?php echo $totalPages; ?></label>
					<input type="hidden" name="tags" value="<?php echo $tags ?>" />
				</form> 
			</div>
			<div class="older">
				<p class="right"><a <?php if($currentPage >= $totalPages) : ?>class="hide"<?php endif; ?> href="<?php  echo("?page=".($currentPage + 1)."&tags=".$tags); ?>">Older →</a></p>
			</div>
		</div>
		<div class="clear-pagination"></div>
	 <?php 
	}

?>
