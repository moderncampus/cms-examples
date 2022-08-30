<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- 
Implementations Skeletor v3 - 5/10/2014

IDENTITY TEMPLATE MATCH
This template ensures that all content is copied, or applied to any existing template matches. Edit sparingly.

Contributors: Your Name Here
Last Updated: Enter Date Here
-->
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ou="http://omniupdate.com/XSL/Variables"
  xmlns:fn="http://omniupdate.com/XSL/Functions"
  xmlns:ouc="http://omniupdate.com/XSL/Variables"
  exclude-result-prefixes="xs ou fn ouc">
	
    <!-- 
    
    Identity Matches
    
    -->
	
    <!-- The following template matches all items except processing instructions, copies them, then processes any children. -->
    <xsl:template match="attribute()|text()|comment()">
        <xsl:copy />
    </xsl:template>
    
    <xsl:template match="element()">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="attribute()|node()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- The following template matches processing instructions, outputs the proper syntax with the code escaped properly. -->
    <xsl:template match="php">
        <xsl:processing-instruction name="php">
			<xsl:value-of select="." disable-output-escaping="yes" />
		?</xsl:processing-instruction>
    </xsl:template>
    
    <!--
       
    OUC Matches   
       
    -->
    
    <!-- OUC Dynamic 3rd Level Tagging -->
    <xsl:template match="ouc:div">
        <xsl:copy>
            <xsl:attribute name="wysiwyg-class"><xsl:value-of select="$body-class" /></xsl:attribute>
            <xsl:apply-templates select="attribute()|node()" />
        </xsl:copy>
    </xsl:template>
	
    <xsl:template match="ouc:*[$ou:action !='edt']">
        <xsl:apply-templates />
    </xsl:template>
    
    <!--
        
    MISC 
    
    -->
    
    <!-- Visual warning for broken dependencies tags -->
    <xsl:template match="a[contains(@href,'*** Broken')]">
        <a href="{@href}" style="color: red;"><xsl:value-of select="."/></a> <span style="color: red;">[BROKEN LINK]</span>
    </xsl:template>
 
 	<!--Google Custom Search code-->
	<xsl:template match="gcsesearch">
		<xsl:text disable-output-escaping="yes">&lt;gcse:searchresults-only&gt;&lt;/gcse:searchresults-only&gt;</xsl:text>
	</xsl:template>


    <!-- blog asset with specific structure <blog type="page-related" limit="3" dir="/blog/posts" filtering="strict"/> -->
    <xsl:template match="blog">
        <xsl:variable name="type" select="if(@type) then @type else ''"/>
        <xsl:variable name="dir" select="if(@dir and @dir != '') then @dir else if(contains($ou:dirname, '/posts')) then substring-before($ou:dirname, '/posts') else $ou:dirname"/>
        <xsl:variable name="year" select="if(@year) then @year else ''"/>
        <xsl:variable name="filtering" select="if(@filtering) then @filtering else 'loose'"/>
        <xsl:variable name="limit" select="if (@limit != '') then @limit else 3"/>
        <!--$tags is a global variable contained in ouvariables.xsl, outputs as csv-->
        <xsl:variable name="page-tags" select="if($tags) then $tags else ''"/>
        <xsl:variable name="tags-from-asset">
            <xsl:if test="@tags">
                <xsl:try>
                    <xsl:for-each select="tokenize(@tags, ',')">
                        <xsl:value-of select="if (position() != last()) then concat(normalize-space(.), ',') else normalize-space(.)"/>
                    </xsl:for-each>
                    <xsl:catch></xsl:catch>
                </xsl:try>
            </xsl:if>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not($ou:action='pub')">
                <div class="panel" style="text-align:center">
                    <h4>Posts displayed on production.</h4>
                    <p>Type: <strong><xsl:value-of select="$type"/></strong>
                    <br/>Search Dir: <strong><xsl:value-of select="$dir" /></strong>
                    <br/>Limit: <strong><xsl:value-of select="$limit"/></strong>
                    <xsl:if test="$type='page-related'"><br/>Page Tag(s): <strong><xsl:value-of select="$tags"/></strong></xsl:if>
                    <xsl:if test="$type='tag-related'"><br/>Asset Tag(s): <strong><xsl:value-of select="$tags-from-asset"/></strong></xsl:if></p>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:processing-instruction name="php">
                    $conditions = array();
                    if("<xsl:value-of select="$type"/>" == "popular-tags") {display_popular_tags("<xsl:value-of select="$dir"/>", <xsl:value-of select="$limit"/>, $conditions);}
                    else if("<xsl:value-of select="$type"/>" == "available-tags") {display_available_tags("<xsl:value-of select="$dir"/>", <xsl:value-of select="$limit"/>, $conditions);}
                    else {
                        $conditions["filtering"] = "<xsl:value-of select="$filtering"/>";
                        if("<xsl:value-of select="$year"/>" != '') {$conditions["year"] = "<xsl:value-of select="$year"/>";}
                        if("<xsl:value-of select="$type"/>" == "page-related") {$conditions["tags"] = "<xsl:value-of select="$page-tags"/>";}
                        elseif("<xsl:value-of select="$type"/>" == "tag-related") {$conditions["tags"] = "<xsl:value-of select="$tags-from-asset"/>";}
                        elseif("<xsl:value-of select="$type"/>" == "featured") {$conditions["featured"] = "true";}
                        display_asset_listing(get_all_post_files("<xsl:value-of select="$dir"/>", $conditions), <xsl:value-of select="$limit"/>);
                    }
                ?</xsl:processing-instruction>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="blog-archive">
        <xsl:param name="dir" select="if(@dir) then @dir else if(contains($ou:dirname, '/posts')) then substring-before($ou:dirname, 'posts') else $ou:dirname"/>
        <xsl:param name="month" select="if(@month) then @month else 1"/>
        <xsl:param name="year" select="if(@year) then @year else 2016"/>
        <xsl:choose>
            <xsl:when test="not($ou:action='pub')">
                <div class="panel" style="text-align:center">
                    <h4>Archive Links displayed on production.</h4>
                    <p>Listing page: <strong><xsl:value-of select="$path"/></strong>
                        <br/>Start Month: <strong><xsl:value-of select="$month" /></strong>
                        <br/>Start Year: <strong><xsl:value-of select="$year"/></strong></p>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:processing-instruction name="php">
                    display_archive_links("<xsl:value-of select="$domain"/>", "<xsl:value-of select="$path"/>", <xsl:value-of select="$month"/>, <xsl:value-of select="$year"/>);
                ?</xsl:processing-instruction>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
</xsl:stylesheet>
