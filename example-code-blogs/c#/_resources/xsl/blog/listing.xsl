<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY copy   "&#169;">
]>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xsl xs ou ouc">

	<!--	Importing files to acquire their functionality of templates and parameters. All imported templates and parameters have lower priority.
This makes it possible to define templates or parameters with the same name/match conditions and redefine their functionality.
This XSL file is called first by the PCF file to guarantee that it will maintain the highest priority for all templates and parameters. -->
<xsl:import href="blog-functions.xsl" />
<xsl:import href="../common.xsl" />

	<xsl:param name="feature-limit" select="if(string-length(/document/ouc:properties[@label='config']/parameter[@name='feature-limit']) > 0) then /document/ouc:properties[@label='config']/parameter[@name='feature-limit'] else 3" />
	<xsl:param name="post-year" select="/document/ouc:properties[@label='config']/parameter[@name='post-year']" />
	<xsl:param name="post-author" select="/document/ouc:properties[@label='config']/parameter[@name='post-author']" />
	<xsl:param name="post-limit" select="if(string-length(/document/ouc:properties[@label='config']/parameter[@name='post-limit']) > 0) then /document/ouc:properties[@label='config']/parameter[@name='post-limit'] else 3" />
	<xsl:param name="add-tags" select="/document/ouc:properties[@label='config']/parameter[@name='add-tags']" />
	<xsl:param name="search-root" select="if(string-length(/document/ouc:properties[@label='config']/parameter[@name='search-root']) > 0) then /document/ouc:properties[@label='config']/parameter[@name='search-root'] else '/'"/>

	<xsl:template name="template-headcode">
		<!-- <link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/jquery.slick/1.3.15/slick.css"/> -->
		<!-- <link rel="stylesheet" type="text/css" href="/_resources/css/blog/blog.css"/> -->
	</xsl:template>

<xsl:template name="page-content">
	<div class="row">
		<div class="large-12 columns">
			<h1><xsl:value-of select="ou:pcf-param('heading')"/></h1>
		</div>
	</div>
	<div class="row">
		<div class="small-10 columns">
			<ul class="breadcrumbs">
				<xsl:call-template name="breadcrumb">
					<xsl:with-param name="path" select="$ou:dirname"/>
				</xsl:call-template>
			</ul>
		</div>
		<div class="small-2 columns">
			<a href="http://gpitts.w.oudemo.com/_resources/cs/get-blog-rss.ashx"><i title="RSS Subscribe" class="fi-rss subscribe"></i></a>
		</div>
	</div>
	<div class="row">
		<div class="large-12 columns">
			<xsl:if test="ouc:properties[@label='config']/parameter[@name='featured-posts']/option[@value='true']/@selected='true'">
				<div class="featured-posts panel">
					<h4>Featured post</h4>
					<hr/>
					<xsl:choose>
						<xsl:when test="$ou:action = 'pub'">
							<xsl:text disable-output-escaping="yes">&lt;%</xsl:text>
							Response.Write(OUC.Blog.DisplayFeaturedSlide("<xsl:value-of select="$search-root" />", "<xsl:value-of select="$feature-limit"/>"));
							<xsl:text disable-output-escaping="yes">%&gt;</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<p>Features posts on production only.</p>
							<p style="color:red;">Featured post limit: <xsl:value-of select="$feature-limit"/></p>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:if>
		</div>
	</div>
	<div class="row">
		<div class="{if (ou:pcf-param('right-enable') = 'true') then 'large-8' else 'large-12'} columns">
			<!-- Main Content Region -->
			<xsl:apply-templates select="ouc:div[@label='maincontent']" />
			<xsl:choose>
				<xsl:when test="$ou:action = 'pub'">
					<xsl:text disable-output-escaping="yes">&lt;%</xsl:text>
					string page = "0";
					if(Request.QueryString["page"] != null){ page = HttpContext.Current.Server.HtmlEncode(Request.QueryString["page"]); }
					
					string limit = "<xsl:value-of select="$post-limit" />";
					if(Request.QueryString["limit"] != null){ limit = HttpContext.Current.Server.HtmlEncode(Request.QueryString["limit"]); }
					
					string tags = "<xsl:value-of select="$tags"/>";
					if(Request.QueryString["tags"] != null){ tags = HttpContext.Current.Server.HtmlEncode(Request.QueryString["tags"]); }
					
					string addTags = "<xsl:value-of select="$add-tags" />";
					if(Request.QueryString["addtags"] != null){ addTags = HttpContext.Current.Server.HtmlEncode(Request.QueryString["addtags"]); }
					
					string year = "<xsl:value-of select="$post-year" />";
					if(Request.QueryString["year"] != null){ year = HttpContext.Current.Server.HtmlEncode(Request.QueryString["year"]); }

					string author = "<xsl:value-of select="$post-author" />";
					if(Request.QueryString["author"] != null){ author = HttpContext.Current.Server.HtmlEncode(Request.QueryString["author"]); }
					
					Response.Write(OUC.Blog.DisplayGlobalListingPage("<xsl:value-of select="$search-root" />", "<xsl:value-of select="$dirname" />", addTags, page, limit, tags, year, author));
					<xsl:text disable-output-escaping="yes">%&gt;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<div class="panel" style="text-align:center;">
						<h4>Blog listing on production only.</h4>
						<p>Year filter: <strong><xsl:value-of select="if($post-year != '') then $post-year else 'none'"/></strong>
							<br/>Author filter: <strong><xsl:value-of select="if($post-author != '') then $post-author else 'none'"/></strong>
							<br/>Tag filter: <strong><xsl:value-of select="if($tags != '') then $tags else 'none'"/></strong>
							<br/>Post per page: <strong><xsl:value-of select="$post-limit"/></strong></p>
					</div>
				</xsl:otherwise>
			</xsl:choose>
		</div>
		<xsl:if test="ou:pcf-param('right-enable') = 'true'">
			<aside class="large-4 columns">
				<xsl:if test="ou:pcf-param('regions') = 'panel'">
					<xsl:call-template name="panel-region"/>
				</xsl:if>
				<xsl:if test="ou:pcf-param('regions') = 'region'">
					<xsl:call-template name="right-column"/>
				</xsl:if>
			</aside>
		</xsl:if>
	</div>
</xsl:template>

<xsl:template name="panel-region">
	<div class="panel">
		<xsl:apply-templates select="ouc:div[@label='panel']"/>
	</div>
</xsl:template>

<xsl:template name="right-column">
	<xsl:apply-templates select="ouc:div[@label='right-content']" />
</xsl:template>

<xsl:template name="template-footcode">
<!-- 	<script type="text/javascript" src="//cdn.jsdelivr.net/jquery.slick/1.3.15/slick.min.js"></script>

	<xsl:if test="$ou:action = 'pub'">
		<script>
			$(function(){
			//$("#blog-posts").blogPagination("<xsl:value-of select="$search-root" />",{tags:"<xsl:processing-instruction name="php"> echo $tags; ?</xsl:processing-instruction>",author:"<xsl:processing-instruction name="php"> echo $tmp["author"]; ?</xsl:processing-instruction>",year:"<xsl:processing-instruction name="php"> echo $tmp["year"]; ?</xsl:processing-instruction>"},<xsl:value-of select="$post-limit" />);
			<xsl:if test="ouc:properties[@label='config']/parameter[@name='featured-posts']/option[@value='true']/@selected='true'">
				$(".featured-posts").has(".hide-featured").hide();
				$(".featured-posts").slick({autoplay:true,autoplaySpeed:9500});
			</xsl:if>
			});
		</script>
	</xsl:if> -->

</xsl:template>

</xsl:stylesheet>


