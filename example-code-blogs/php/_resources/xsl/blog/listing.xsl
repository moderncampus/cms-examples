<?xml version="1.0" encoding="UTF-8" ?>
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
	<xsl:param name='tag-filtering' select="/document/ouc:properties[@label='config']/parameter[@name='tag-filter-strength']/option[@selected='true']/@value"/>
	<xsl:param name="search-root" select="if(string-length(/document/ouc:properties[@label='config']/parameter[@name='search-root']) > 0) then /document/ouc:properties[@label='config']/parameter[@name='search-root'] else $ou:dirname"/>
	
	<xsl:template name="template-headcode">
		<xsl:if test="$ou:action = 'pub'">
			<xsl:processing-instruction name="php">
				require_once($_SERVER["DOCUMENT_ROOT"] . "/_resources/php/listing.php");
				$tmp = array();
				$tmp["tags"] = (isset($_GET["tags"])) ? htmlspecialchars($_GET["tags"]) : "<xsl:value-of select="$tags"/>";
				$tmp["author"] = (isset($_GET["author"])) ? htmlspecialchars($_GET["author"]) : "<xsl:value-of select="$post-author" />";
				$tmp["year"] = (isset($_GET["year"])) ? htmlspecialchars($_GET["year"]) : "<xsl:value-of select="$post-year" />";
				$tmp["month"] = (isset($_GET["month"])) ? htmlspecialchars($_GET["month"]) : "";
				$tmp["filtering"] = "<xsl:value-of select="$tag-filtering" />";
				$posts = get_all_post_files("<xsl:value-of select="$search-root" />", $tmp);
			?</xsl:processing-instruction>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="template-footcode"/>
	
	<xsl:template name="page-content">
		<div class="row">
			<div class="large-12 columns">
				<h1><xsl:value-of select="ou:pcf-param('heading')"/></h1>
			</div>
		</div>
		<div class="row">
			<div class="large-12 columns">
				<xsl:if test="ouc:properties[@label='config']/parameter[@name='featured-posts']/option[@value='true']/@selected='true'">
					<div class="featured-posts panel">
						<h4>Featured Post</h4>
						<hr/>
						<xsl:choose>
							<xsl:when test="$ou:action = 'pub'">
								<xsl:processing-instruction name="php">
									display_featured_slides($posts, <xsl:value-of select="$feature-limit"/>);
								?</xsl:processing-instruction>
							</xsl:when>
							<xsl:otherwise>
								<p>Featured posts on production only.</p>
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
						<div id="blog-posts">
							<xsl:processing-instruction name="php">
							display_listing($posts,1,<xsl:value-of select="$post-limit" />);
						?</xsl:processing-instruction>
						</div>
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
	
</xsl:stylesheet>
