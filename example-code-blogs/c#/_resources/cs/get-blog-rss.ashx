<%@ WebHandler Language="C#" Class="GetRSS" %>

using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Xml;
using System.Xml.XPath;
using System.Linq;
using System.Xml;
using System.Xml.Linq;
using System.IO;
using OUC;

public class GetRSS : IHttpHandler {

	public void ProcessRequest (HttpContext context) {

		context.RewritePath(context.Server.HtmlDecode(context.Request.Url.PathAndQuery));
		context.Response.ContentType = "text/xml;charset=utf-8";

		Dictionary<string, string> conditions = new Dictionary<string, string>();

		conditions.Add("mode", "rss");

		string dir = "/";
		if(context.Request.QueryString["dir"] != null){
			dir = context.Request.QueryString["dir"];
		}

		conditions.Add("dir", dir);

		if(context.Request.QueryString["limit"] != null){
			conditions.Add("limit", context.Request.QueryString["limit"]);
		}

		if(context.Request.QueryString["tags"] != null){
			conditions.Add("tags", context.Request.QueryString["tags"]);
		}

		if(context.Request.QueryString["featured"] != null){
			conditions.Add("featured", context.Request.QueryString["featured"]);
		}

		if(context.Request.QueryString["year"] != null){
			conditions.Add("year", context.Request.QueryString["year"]);
		}

		string feed = Blog.DisplayRSSFeed(conditions);


		context.Response.Write(feed);
		context.Response.End();
	}

	public bool IsReusable {
		get {
			return false;
		}
	}
}

