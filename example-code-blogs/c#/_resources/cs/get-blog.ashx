<%@ WebHandler Language="C#" Class="GetRSS" %>

using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Xml;
using System.Xml.XPath;
using System.Xml.Linq;
using System.Linq;
using System.IO;
using OUC;

public class GetRSS : IHttpHandler {

	public void ProcessRequest (HttpContext context) {

		context.RewritePath(context.Server.HtmlDecode(context.Request.Url.PathAndQuery));
		context.Response.ContentType = "text/html;charset=utf-8";

		Dictionary<string, string> conditions = new Dictionary<string, string>();

		string dir = "/blog";
		if(context.Request.QueryString["dir"] != null){
			dir = context.Request.QueryString["dir"];
		}

		conditions.Add("dir", dir);

		string mode = "listing";
		if(context.Request.QueryString["mode"] != null){
			mode = context.Request.QueryString["mode"];
		}

		conditions.Add("mode", mode);

		if(context.Request.QueryString["tags"] != null){
			conditions.Add("tags", context.Request.QueryString["tags"]);
		}

		if(context.Request.QueryString["featured"] != null){
			conditions.Add("featured", context.Request.QueryString["featured"]);
		}

		if(context.Request.QueryString["year"] != null){
			conditions.Add("year", context.Request.QueryString["year"]);
		}

		if(context.Request.QueryString["limit"] != null){
			conditions.Add("limit", context.Request.QueryString["limit"]);
		}

		if(context.Request.QueryString["page"] != null){
			conditions.Add("page", context.Request.QueryString["page"]);
		}

		string markUp = "";

		if(mode == "rss"){
			context.Response.ContentType = "text/xml;charset=utf-8";
			markUp += Blog.DisplayRSSFeed(conditions);
		}
		else if(mode == "tags"){
			markUp += Blog.DisplayAvailableTags(conditions);
		}
		else{
			markUp += Blog.FormatPosts(conditions);
		}

		context.Response.Write(markUp);
		context.Response.End();
	}

	public bool IsReusable {
		get {
			return false;
		}
	}
}
