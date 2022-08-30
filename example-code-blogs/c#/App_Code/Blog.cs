using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Xml;
using System.Xml.XPath;
using System.Linq;
using System.Xml.Linq;
using System.IO;
using OUC;

namespace OUC{

	public static class Blog{

		public static List<string> excludeDirectories = new List<string>(){"/_resources", "/_trash", "/_feeds"};

		/* Listing
		========== */

		public static string DisplayGlobalListingPage(string dir, string currentDir, string addTags, string page, string limit, string tags, string year, string author){
			Dictionary<string, string> conditions = new Dictionary<string, string>(){
				{"dir", dir},
				{"currentdir", currentDir},
				{"mode", "listing"},
				{"limit", limit}
			};

			if(addTags != ""){
				conditions.Add("addtags", addTags);
			}

			if(page != ""){
				conditions.Add("page", page);
			}

			if(tags != ""){
				conditions.Add("tags", tags);
			}

			if(year != ""){
				conditions.Add("year", year);
			}

			if(author != ""){
				conditions.Add("author", author);
			}

			BlogPosts blogPosts = GetPosts(conditions);

			return DisplayListing(blogPosts, conditions);
		}

		public static string DisplayListingPage(string dir,  string page, string limit, string tags, string year, string author){
			Dictionary<string, string> conditions = new Dictionary<string, string>(){
				{"dir", dir},
				{"mode", "listing"},
				{"limit", limit}
			};

			if(page != ""){
				conditions.Add("page", page);
			}

			if(tags != ""){
				conditions.Add("tags", tags);
			}

			if(year != ""){
				conditions.Add("year", year);
			}

			if(author != ""){
				conditions.Add("author", author);
			}

			BlogPosts blogPosts = GetPosts(conditions);

			return DisplayListing(blogPosts, conditions);
		}

		public static string DisplayListing(BlogPosts blogPosts, string limit){
			Dictionary<string, string> conditions = new Dictionary<string, string>(){
				{"mode", "listing"},
				{"limit", limit}
			};

			return DisplayListing(blogPosts, conditions);
		}

		public static string DisplayListing(BlogPosts blogPosts, Dictionary<string, string> conditions){

			int limit = -1;
			if(conditions.ContainsKey("limit")){
				limit = Convert.ToInt32(conditions["limit"]);
			}

			int page = 0;
			if(conditions.ContainsKey("page")){
				page = Convert.ToInt32(conditions["page"]);
			}

			BlogPosts displayPosts = null;

			if(limit != -1){
				displayPosts = new BlogPosts(blogPosts.posts.Skip(page * limit).Take(limit).ToList());
			}
			else{
				displayPosts = new BlogPosts(blogPosts.posts);
			}

			//Persist query string
			string queryString = "";

			string limitString = (conditions.ContainsKey("limit")) ? conditions["limit"] : "10";
			queryString += (limitString != "") ? "&limit=" + limitString : "";

			string tags = (conditions.ContainsKey("tags")) ? conditions["tags"] : "";
			queryString += (tags != "") ? "&tags=" + tags : "";

			string year = (conditions.ContainsKey("year")) ? conditions["year"] : "";
			queryString += (year != "") ? "&year=" + year : "";

			string author = (conditions.ContainsKey("author")) ? conditions["author"] : "";
			queryString += (author != "") ? "&author=" + author : "";
			
			string addtags = (conditions.ContainsKey("addtags")) ? conditions["addtags"] : "";
			queryString += (addtags != "") ? "&addtags=" + addtags : "";

			string pageString = (conditions.ContainsKey("page")) ? conditions["page"] : "0";

			int pageNumber = Convert.ToInt32(pageString);
			int pageLimit = Convert.ToInt32(limit);

			//Blog posts
			string markUp = "<p>";

			markUp += FormatPosts(displayPosts, conditions);

			//Pagination
			markUp += "</p><div class=\"row\">";

			if(pageNumber > 0){
				markUp += String.Format("<div class=\"newer pull-left\"><p><a href=\"?page={0}{1}\">&#8592; Newer Posts</a></p></div>",
					pageNumber-1, queryString);
			}

			if((pageNumber * pageLimit) < (blogPosts.total - pageLimit)){
				markUp += String.Format("<div class=\"older pull-right\"><p class=\"right\"><a href=\"?page={0}{1}\">Older Posts &#8594;</a></p></div>",
					pageNumber+1, queryString);
			}

			markUp += "</div></div>";

			return markUp;
		}

		/* Recent Posts
		=============== */

		public static string DisplayRecentPosts(string dir, string limit){
			Dictionary<string, string> conditions = new Dictionary<string, string>(){
				{"dir", dir},
				{"mode", "recent"},
				{"limit", limit}
			};

			return DisplayRecentPosts(conditions);
		}

		public static string DisplayRecentPosts(Dictionary<string, string> conditions){
			return String.Format("<ul>{0}</ul>", FormatPosts(conditions));
		}

		/* Featured Posts
		================= */

		public static string DisplayFeaturedPosts(string dir, string limit){
			Dictionary<string, string> conditions = new Dictionary<string, string>(){
				{"dir", dir},
				{"mode", "featured"},
				{"featured", "true"},
				{"limit", limit}
			};

			return DisplayFeaturedPosts(conditions);
		}

		public static string DisplayFeaturedPosts(Dictionary<string, string> conditions){
			return String.Format("<ul>{0}</ul>", FormatPosts(conditions));
		}

		/* Featured Slide Posts
		======================= */

		public static string DisplayFeaturedSlide(BlogPosts blogPosts, string limit){
			Dictionary<string, string> conditions = new Dictionary<string, string>(){
				{"mode", "featuredslide"},
				{"featured", "true"},
				{"limit", limit}
			};

			return FormatPosts(blogPosts, conditions);
		}

		public static string DisplayFeaturedSlide(string dir, string limit){
			Dictionary<string, string> conditions = new Dictionary<string, string>(){
				{"dir", dir},
				{"mode", "featuredslide"},
				{"featured", "true"},
				{"limit", limit}
			};

			BlogPosts blogPosts = GetPosts(conditions);

			string markUp = "<div class=\"flex-container\"><div class=\"flexslider\"><ul class=\"slides\">";

			markUp += FormatPosts(blogPosts, conditions);

			markUp += "</ul></div></div>";

			return markUp;
		}

		/* Related Posts
		================ */

		public static string DisplayRelatedPosts(string dir, string currentPost, string tags, string limit){
			Dictionary<string, string> conditions = new Dictionary<string, string>(){
				{"dir", dir},
				{"currentpost", currentPost},
				{"mode", "related"},
				{"tags", tags},
				{"limit", limit}
			};

			return DisplayRelatedPosts(conditions);
		}

		public static string DisplayRelatedPosts(Dictionary<string, string> conditions){

			return String.Format("<ul>{0}</ul>", FormatPosts(conditions));
		}

		/* Available Tags
		================= */

		public static string DisplayAvailableTags(string dir){
			Dictionary<string, string> conditions = new Dictionary<string, string>(){
				{"dir", dir},
				{"mode", "tags"}
			};

			return String.Format("<ul>{0}</ul>", DisplayAvailableTags(conditions));
		}

		public static string DisplayAvailableTags(Dictionary<string, string> conditions){
			string markUp = "";
			BlogPosts blogPosts = GetPosts(conditions);
			List<string> tagList = new List<string>();

			foreach(BlogPost blogPost in blogPosts.posts){
				foreach(string tag in blogPost.tags){
					if(tag != ""){
						tagList.Add(tag);
					}
				}
			}

			List<string> sortedList = tagList.OrderBy(s => s).ToList();

			var grouped = sortedList.GroupBy(s => s).Select(group => new {
				Tag = group.Key, Count = group.Count()
				});

			foreach(var group in grouped){
				markUp += String.Format("<li><a href=\"{0}?tags={1}\">{1}</a> ({2})</li>", conditions["dir"], group.Tag, group.Count);
			}

			return markUp;
		}

		/* RSS Feed
		=========== */

		public static string DisplayRSSFeed(string dir){
			Dictionary<string, string> conditions = new Dictionary<string, string>(){
				{"dir", dir},
				{"mode", "rss"}
			};

			return DisplayRSSFeed(conditions);
		}

		public static string DisplayRSSFeed(string dir, string tags){
			Dictionary<string, string> conditions = new Dictionary<string, string>(){
				{"dir", dir},
				{"mode", "rss"},
				{"tags", tags}
			};

			return DisplayRSSFeed(conditions);
		}

		public static string DisplayRSSFeed(Dictionary<string, string> conditions){
			string rssFeed = String.Format("<?xml version=\"1.0\" encoding=\"utf-8\" ?>{0}", Environment.NewLine);
			string title = "Blog Feed - Dev";
			string url = (conditions.ContainsKey("dir")) ? conditions["dir"] : "/";
			string link = String.Format("http://{0}{1}", HttpContext.Current.Request.Url.Host, url);
			string description = "Development Feed";
			string language = "en-us";
			string lastBuildDate = String.Format("{0:ddd, dd MMM yyyy HH:mm:ss zzz}", DateTime.Now);
			string docs = "http://blogs.law.harvard.edu/tech/rss";
			string generator = "OmniUpdate (OU Publish)";

			rssFeed += "<rss xmlns:media=\"http://search.yahoo.com/mrss/\" version=\"2.0\"><channel>";

			rssFeed += String.Format("<title>{0}</title>", title);
			rssFeed += String.Format("<link>{0}</link>", link);
			rssFeed += String.Format("<description>{0}</description>", description);
			rssFeed += String.Format("<language>{0}</language>", language);
			rssFeed += String.Format("<lastBuildDate>{0}</lastBuildDate>", lastBuildDate);
			rssFeed += String.Format("<docs>{0}</docs>", docs);
			rssFeed += String.Format("<generator>{0}</generator>", generator);

			rssFeed += FormatPosts(conditions);

			rssFeed += "</channel></rss>";

			return rssFeed;
		}

		/* Format Posts
		=============== */

		public static string FormatPosts(Dictionary<string, string> conditions){
			BlogPosts blogPosts = GetPosts(conditions);

			return FormatPosts(blogPosts, conditions);
		}

		public static string FormatPosts(BlogPosts blogPosts, Dictionary<string, string> conditions){
			string markUp = "";

			foreach(BlogPost blogPost in blogPosts.posts){
				markUp += blogPost.Format(conditions["mode"]);
			}

			return markUp;
		}

		/* Get Posts
		============ */

		public static BlogPosts GetPosts(string dir, string mode){
			return GetPosts(dir, mode, "", "", "", "", "");
		}

		public static BlogPosts GetPosts(string dir, string mode, string page, string limit, string tags, string year, string author){
			Dictionary<string, string> conditions = new Dictionary<string, string>(){
				{"dir", dir},
				{"mode", mode}
			};

			if(page != ""){
				conditions.Add("page", page);
			}

			if(limit != ""){
				conditions.Add("limit", limit);
			}

			if(tags != ""){
				conditions.Add("tags", tags);
			}

			if(year != ""){
				conditions.Add("year", year);
			}

			if(author != ""){
				conditions.Add("author", author);
			}

			return GetPosts(conditions);
		}

		public static BlogPosts GetPosts(Dictionary<string, string> conditions){
			List<BlogPost> posts = new List<BlogPost>();

			string serverDirectory = HttpContext.Current.Server.MapPath(conditions["dir"]);

			List<string> filePaths = new List<string>();
			WalkDirectoryTree(serverDirectory, filePaths);

			foreach(string filePath in filePaths){
				XmlDocument xmlDocument = new XmlDocument();
				try{
					using(XmlReader reader = XmlReader.Create(filePath)){
						xmlDocument.Load(reader);
					}

					XmlNode postNode = xmlDocument.DocumentElement.SelectSingleNode("/post");

					if(postNode != null){
						BlogPost blogPost = new BlogPost(postNode);

						//global blog stuff
						if(conditions.ContainsKey("currentdir")){
							string serverCurrentDir = HttpContext.Current.Server.MapPath(conditions["currentdir"]);

							if(filePath.Contains(serverCurrentDir)){
								if(PostMeetsConditions(blogPost, conditions)){
									posts.Add(blogPost);
								}
							}
							else if(conditions.ContainsKey("addtags")){
								string[] addTags = conditions["addtags"].Split(',');
								bool matchedAddTag = false;

								foreach(string postTag in blogPost.tags){
									foreach(string addTag in addTags){
										if(addTag == postTag || addTag == "all"){
											matchedAddTag = true;
											break;
										}
									}

									if(matchedAddTag){
										break;
									}
								}

								if(matchedAddTag && PostMeetsConditions(blogPost, conditions)){
									posts.Add(blogPost);
								}
							}
						}
						else if(PostMeetsConditions(blogPost, conditions)){
								posts.Add(blogPost);
						}
					}
				}
				catch(Exception e){}
			}

			List<BlogPost> sortedList = new List<BlogPost>();

			if(conditions["mode"] == "listing"){
				sortedList = posts.OrderByDescending(post => post.dateTime).ToList();
			}
			else{
				if(conditions.ContainsKey("limit")){
					int limit = Convert.ToInt32(conditions["limit"]);
					sortedList = posts.OrderByDescending(post => post.dateTime).ToList().Take(limit).ToList();
				}
				else{
					/* If no conditions we get all posts */ 
					sortedList = posts.OrderByDescending(post => post.dateTime).ToList();
				}
				
			}

			BlogPosts blogPosts = new BlogPosts(sortedList);

			return blogPosts;
		}

		public static bool PostMeetsConditions(BlogPost blogPost, Dictionary<string, string> conditions){

			if(blogPost.display != "true"){
				return false;
			}

			if(conditions.ContainsKey("featured")){
				if(conditions["featured"] != blogPost.featured){
					return false;
				}
			}

			if(conditions.ContainsKey("year")){
				if(conditions["year"] != blogPost.year){
					return false;
				}
			}

			if(conditions.ContainsKey("author")){
				if(conditions["author"] != blogPost.author){
					return false;
				}
			}

			if(conditions.ContainsKey("tags")){
				string[] conditionTags = conditions["tags"].Split(',');
				bool matchedTag = false;

				if(conditionTags.Intersect(blogPost.tags,
					StringComparer.OrdinalIgnoreCase).ToList().Count > 0){
					matchedTag = true;
				}

				if(!matchedTag){
					return false;
				}
			}

			//don't display the current page link in a related links asset
			if(conditions.ContainsKey("currentpost")){
				if(conditions["currentpost"] == blogPost.link){
					return false;
				}
			}

			return true;
		}

		public static void WalkDirectoryTree(string serverDirectory, List<string> filePaths){
			DirectoryInfo directoryInfo = new DirectoryInfo(serverDirectory);
			FileInfo[] files = null;
			DirectoryInfo[] subDirectories = null;

			try{
				files = directoryInfo.GetFiles("*.blog");
			}
			catch (UnauthorizedAccessException e){
				filePaths.Add(e.Message);
			}
			catch (System.IO.DirectoryNotFoundException e){
				filePaths.Add(e.Message);
			}

			if (files != null){

				foreach(FileInfo fileInfo in files){
					filePaths.Add(fileInfo.FullName);
				}

				subDirectories = directoryInfo.GetDirectories();

				foreach(DirectoryInfo dirInfo in subDirectories){
					bool processDirectory = true;

					//skip exclude directories
					foreach(string excludeDirectory in excludeDirectories){
						string excludeServerDirectory = HttpContext.Current.Server.MapPath(excludeDirectory);

						if(dirInfo.FullName.Contains(excludeServerDirectory)){
							processDirectory = false;
							break;
						}
					}

					if(processDirectory){
						WalkDirectoryTree(dirInfo.FullName, filePaths);
					}
				}
			}
		}
	}

	public class BlogPosts{
		public int total{ get; set; }
		public List<BlogPost> posts{ get; set; }


		public BlogPosts(){}
		public BlogPosts(List<BlogPost> blogPosts){
			posts = blogPosts;
			total = posts.Count;
		}
	}

	public class BlogPost{
		public string display{ get; set; }
		public string featured{ get; set; }
		public string comments{ get; set; }
		public string link{ get; set; }
		public string title{ get; set; }
		public string author{ get; set; }
		public string email{ get; set; }
		public string description{ get; set; }
		public string pubDate{ get; set; }
		public string year{ get; set; }
		public string date{ get; set; }
		public string[] tags{ get; set; }
		public string imageSrc{ get; set; }
		public string imageAlt{ get; set; }
		public DateTime dateTime{ get; set;}
		public bool displayed{ get; set; }

		public BlogPost(){}
		public BlogPost(XmlNode postNode){
			displayed = false;

			display = postNode.Attributes["display"].Value;

			featured = (postNode.Attributes["featured"] != null) ? "true" : "false";
			comments = (postNode.Attributes["comments"] != null) ? "true" : "false";
			link = postNode.Attributes["link"].Value;

			title = postNode["title"].InnerText;
			author = postNode["author"].InnerText;
			email = postNode["email"].InnerText;
			description = postNode["description"].InnerText;

			pubDate = postNode["pubDate"].InnerText;
			pubDate = pubDate.Remove(pubDate.IndexOf("-"));
			dateTime = DateTime.Parse(pubDate);
			year = String.Format("{0:yyyy}", dateTime);
			date = String.Format("{0:MMMM dd, yyyy}", dateTime);

			tags = postNode["tags"].InnerText.Split(',');
			imageSrc = "";
			imageAlt = "";

			if(postNode["image"] != null && postNode["image"]["img"] != null){
				imageSrc = postNode.SelectSingleNode("image/img/@src").Value;
				imageAlt = postNode.SelectSingleNode("image/img/@alt").Value;
			}
		}

		public string Format(string mode){
			string markUp = "";

			if(mode == "rss"){
				markUp += FormatRSSItem();
			}
			else if(mode == "recent"){
				markUp += FormatLink();
			}
			else if(mode == "featured"){
				markUp += FormatLink();
			}
			else if(mode == "related"){
				markUp += FormatLink();
			}
			else if(mode == "listing"){
				markUp += FormatListing();
			}
			else if(mode == "featuredslide"){
				markUp += FormatFeaturedSlide();
			}

			displayed = true;

			return markUp;
		}

		public string FormatRSSItem(){
			string markUp = "<item>";

			markUp += String.Format("<title>{0}</title>", title);
			markUp += String.Format("<link>{0}</link>", link);
			markUp += String.Format("<description>{0}</description>", description);
			markUp += String.Format("<author>{0}</author>", author);
			markUp += String.Format("<pubDate>{0}</pubDate>", pubDate);
			markUp += String.Format("<media:content url=\"{0}\" type=\"image/jpg\">", imageSrc);
			markUp += String.Format("<media:title>{0}</media:title>", title);
			markUp += String.Format("<media:description>{0}</media:description>", description);
			markUp += String.Format("<media:thumbnail url=\"{0}\" />", imageSrc);
			markUp += String.Format("<media:keywords>{0}</media:keywords></media:content>", imageAlt);
			markUp += String.Format("<guid>{0}</guid>", link);

			markUp += "</item>";

			return markUp;
		}

		public string FormatLink(){
			return String.Format("<li><a href=\"{0}\" title=\"{1}\">{1}</a></li>", link, title);
		}

		public string FormatListing(){
			string markUp = "";

			markUp += "<div class=\"row\"><div class=\"col-xs-12\"><p>";

			markUp += String.Format("<a title=\"{0}\" href=\"{1}\">",
				title, link);

			if(imageSrc != ""){

				markUp += String.Format("<img class=\"post-image\" src=\"{0}\" alt=\"{1}\" align=\"left\" style=\"width: 223px; height: 161px;\"  />",
					imageSrc, title);
			}

			markUp += String.Format("<h3>{0}</strong></a></h3>",
				title);


			markUp += String.Format("<a href=\"mailto:{0}\">{1}</a> - <em>{2}</em></p><p>{3}</p>",
				email, author, date, description);

			markUp += "<p>";

			if(tags.Length != 0){

				markUp += "<em>tags: </em>";

				for(int i = 0; i < tags.Length; i++){
					markUp += String.Format("<a href=\"?tags={0}\">{0}</a>",
						tags[i]);

					if(i+1 < tags.Length){
						markUp += ", ";
					}
				}
			}

			if(comments == "true"){
				markUp += String.Format(" - <a class=\"comments\" href=\"{0}#disqus_thread\">0 comments</a>",
					link);
			}

			markUp += "</p><hr /></div></div>";

			return markUp;
		}

		public string FormatFeaturedSlide(){
			string markUp = "";

			markUp += String.Format("<li data-thumb=\"{0}\"><a href=\"{1}\"><img src=\"{0}\" alt=\"{2}\" title=\"{2}\" /></a>",
				imageSrc, link, title);

			markUp += String.Format("<p class=\"flex-caption\"><a href=\"{0}\">{1}</a> - {2}</p>",
				link, title, description);

			markUp += "</li>";

			return markUp;
		}
	}
}
