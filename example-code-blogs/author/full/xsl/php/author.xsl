<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE stylesheet [
	<!ENTITY nbsp  "&#160;" >
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
    <xsl:import href="helper.xsl" />
    <xsl:import href="../common.xsl"/>

	<xsl:param name="search-root" select="if(string-length(/document/ouc:properties[@label='config']/parameter[@name='search-root']) > 0) then /document/ouc:properties[@label='config']/parameter[@name='search-root'] else '/'"/>
	<xsl:param name="post-limit" select="if(string-length(/document/ouc:properties[@label='config']/parameter[@name='post-limit']) > 0) then /document/ouc:properties[@label='config']/parameter[@name='post-limit'] else 3" />
    
    <xsl:template name="template-headcode">
		<xsl:if test="$ou:action = 'pub'">
			<xsl:processing-instruction name="php">
				require_once($_SERVER["DOCUMENT_ROOT"] . "/_resources/php/blog/listing.php");
				$tmp = array();
				$tmp["author"] = "<xsl:value-of select="/document/author/ouc:div[@label='a-name']" />";
				$posts = get_all_post_files("<xsl:value-of select="$search-root" />", $tmp);
			?</xsl:processing-instruction>
		</xsl:if>
    </xsl:template>
    
    
    <xsl:template name="page-content"> 
        <div class="main">
            <div class="container">
            	<div class="row">
            		<div class="col-md-8">
            			<xsl:call-template name="content"/>
            		</div>
            		<div class="col-md-4">
            			<xsl:apply-templates select="/document/author"/>
            		</div>

            	</div>
            </div>
        </div><!-- /.main -->
    </xsl:template>
    
    
    
    <xsl:template match="author" expand-text="yes">
        <p><img class="spotlt" style="display: block; margin-left: auto; margin-right: auto;" 
            src="{ouc:div[@label='a-image']/img/@src}" alt="{ouc:div[@label='a-image']/img/@alt}" width="200" height="200" /></p>
        <div class="byline"><p style="text-align: center;"><span style="color: #993366;"><strong>{ouc:div[@label='a-title']}<br/>{ouc:div[@label='a-department']}</strong></span></p></div>
        <p style="text-align: justify;"><span style="color: #999999;">
            <xsl:value-of select="ouc:div[@label='a-bio']"/>
            <br /></span></p>
        <hr />
    </xsl:template>
    
    
    
    <xsl:template name="content">
    	<xsl:choose>
    		<xsl:when test="/document/descendant::author">
	            <h1><xsl:value-of select="/document/author/ouc:div[@label='a-name']"/></h1>
	            <p>&nbsp;</p>
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
	        </xsl:when>
	        <xsl:otherwise>
	        	<xsl:apply-templates select="ouc:div[@label='maincontent']"/>
	            <xsl:call-template name="aggregate-authors"/>
	        </xsl:otherwise>
	    </xsl:choose>
    </xsl:template>
    
    
    <xsl:template name="aggregate-authors" expand-text="yes">
        <xsl:variable name="authors" select="ou:get-authors($ou:dirname, 'images')"/>
        <xsl:for-each-group select="$authors/author" group-by="(position() - 1) idiv 3">
            <div class="row">
                <ul class="small-block-grid-1 medium-block-grid-2 large-block-grid-3">
                    <xsl:for-each select="current-group()">
                        <li>
                            <p class="author-name">{name}</p>
                            <div id="author" align="center"><img src="{image/img/@src}" alt="{image/img/@alt}" width="250px" height="250px"/></div>
                            <p class="title">{title}<br/>{department}</p>
                            <p>{ou:truncate(bio, 200, '...')}</p>
                            <a href="{concat($domain, substring-after(link, $ou:site))}">Read more about this author</a>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:for-each-group>
        
    </xsl:template>
    
    
</xsl:stylesheet>
