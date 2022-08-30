<%@ WebHandler Language="C#" Class="GetNav" %>

using System;
using System.Net;
using System.Web;
using System.Text.RegularExpressions;
using OUC;

public class GetNav : IHttpHandler {

    public void ProcessRequest (HttpContext context) {

        context.RewritePath(context.Server.HtmlDecode(context.Request.Url.PathAndQuery));

        string navfile = "/_nav.inc";
        if(context.Request.QueryString["navfile"] != null){
            navfile = context.Request.QueryString["navfile"];
        }

        NestedNav nestedNav = new NestedNav();
        string html = nestedNav.GetNav(navfile);

        context.Response.ContentType = "text/HTML";
        context.Response.Write(html);
        context.Response.End();
    }

    public bool IsReusable {
        get {
            return false;
        }
    }
}
