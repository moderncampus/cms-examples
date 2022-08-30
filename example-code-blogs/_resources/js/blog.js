$.fn.blogPagination = function(path, conditions, limit){
	var x = $(this);
	x.data("page",0);
	$.ajax({ type:"POST",url:"/_resources/php/blog/listing.php",data:{action:"acquire",path:path,conditions:conditions}}).done(function(data){
		x.data("posts",data);
		loadBlogs(x);
	});
	function loadBlogs(x){
		if(x.data("posts") && eval(x.data("posts")).length > 0 ){
			x.data("maxPage",Math.ceil(eval(x.data("posts")).length / limit) );
		} else { x.data("maxPage",0); }
		
		$(".pagination a[href='#prev']").addClass("hide");
		
		if(x.data("maxPage") == 1){
			$(".pagination a[href='#next']").addClass("hide");
		}
		
		$("#pageNum label").append(" of " + x.data("maxPage"));

		$(".pagination a").click(function(e){
			e.preventDefault();
			var page = x.data("page");

			switch($(this).attr("href").substring($(this).attr("href").indexOf("#")+1)){
				case "next" : if(page + 1 < x.data("maxPage")) x.data("page",page + 1); break;
				case "prev" : if(page != 0) x.data("page",page - 1); break;
			}
			updatePage(x.data("page"),limit,x.data("posts"));
		});
		
		$(".pagination #pageNum").submit(function(e){
			e.preventDefault();
			x.data("page", ($(this).find("input").val() - 1 < x.data("maxPage")) ? $(this).find("input").val() - 1 : x.data("maxPage"));
					
			updatePage(x.data("page"),limit,x.data("posts"));
			
		});
	}
	
	function updatePage(pageNum, limit, posts){
		$.ajax({ type:"POST", url:"/_resources/php/blog/listing.php", data:{action:"display", posts:posts, page:pageNum, limit:limit}})
		.done(function( msg ) {
			x.html(msg);
			$(".pagination #pageNum input").val(pageNum+1);
			if(pageNum < 1){ $(".pagination a[href='#prev']").addClass("hide"); } else { $(".pagination a[href='#prev']").removeClass("hide"); }
			if(pageNum + 1 == x.data("maxPage")){ $(".pagination a[href='#next']").addClass("hide"); } else { $(".pagination a[href='#next']").removeClass("hide"); }
			$(window).scrollTop(0);
			window.DISQUSWIDGETS = undefined;
            $.getScript("//" + disqus_shortname + ".disqus.com/count.js");
		});
	}
}