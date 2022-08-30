<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp   "&#160;">
<!ENTITY raquo "&#187;">
<!ENTITY amp "&#38;" >
<!ENTITY bull "&#8226;"> 
]>
<!--
	A to Z Index
	
	last updated 3/20/17
-->
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">
	
	<xsl:import href="common.xsl"/>
	<!--<xsl:param name="extension" select="'html'"/>--> <!-- If not in variables.xsl -->
	
	<xsl:template name="page-content">
		<xsl:variable name="xmlfile" select="concat($ou:httproot,'sitemap.xml')"/>
		
		<xsl:choose>
			<!-- check if sitemap is available -->
			<xsl:when test="doc-available($xmlfile)">
				
				<!-- Friendly message to content editors -->
				<xsl:if test="$ou:action='prv'">
					<style>
						#ou.message{
						background: rgb(50, 100, 143);
						border: 1px solid rgb(228, 228, 228);
						line-height: 1.25em;
						border-radius: 20px;
						padding: 10px;
						margin-bottom: 1em;
						}
						#ou.message h2, #ou.message p
						{
						text-shadow: rgba(0, 0, 0, 0.52) 0.1em 0.1em 0.2em;
						color: rgb(219, 219, 219);
						}
					</style>
					<div id="ou" class="message">
						<h2>System Message</h2>
						<p>Pages and directories can be excluded from the A to Z index by selecting "Exclude From Site Map" in access settings.</p>
						<p>After changes are made, the sitemap will need to be regenerated and this page republished.</p>
					</div>
				</xsl:if>
				
				<!-- site map -->
				<xsl:variable name="map" select="document($xmlfile)"/>
				
				<!-- generate xml of vaild pages with page titles -->
				<xsl:variable name="xml-with-titles">
					<pages>
						<!-- for each item that has the correct file extension -->
						<xsl:for-each select="$map/*:urlset/*:url/*:loc[contains(.,$extension)]">
							<xsl:variable name="this-url" select="concat('/',substring-after(.,$ou:httproot))"/>
							<xsl:variable name="this-pcf" select="concat($ou:root,$ou:site,replace($this-url,$extension,'pcf'))"/>
							<xsl:variable name="title" select="if(doc-available($this-pcf)) then(document($this-pcf)/document/ouc:properties/title) else(.)"/>
							
							<page published="{unparsed-text-available(.)}" first-letter="{upper-case(substring($title,1,1))}">
								<staging><xsl:value-of select="$this-pcf"/></staging>
								<url><xsl:value-of select="."/></url>
								<title><xsl:value-of select="$title"/></title>
							</page>
						</xsl:for-each>
					</pages>
				</xsl:variable>
				
				<!-- display links -->
				<ul class="nav nav-pills">
					<xsl:for-each-group select="$xml-with-titles/pages/page[@published='true']" group-by="@first-letter">
						<xsl:sort select="@first-letter"/>
						<!-- link to that letter -->
						<li><a href="#{@first-letter}"><xsl:value-of select="@first-letter"/></a></li>
					</xsl:for-each-group>
				</ul>
				
				<ul class="nav">
					<!-- display only published pages, sorted alphabetically -->
					<xsl:for-each-group select="$xml-with-titles/pages/page[@published='true']" group-by="@first-letter">
						<xsl:sort select="@first-letter"/>
						
						<!-- heading -->
						<li class="disabled"><a id="{@first-letter}"><xsl:value-of select="@first-letter"/></a></li>
						
						<!-- pages starting with that letter -->
						<xsl:for-each select="current-group()">
							<li><a href="{url}"><xsl:value-of select="title"/></a></li>
						</xsl:for-each>
					</xsl:for-each-group>
				</ul>
			</xsl:when>
			<xsl:otherwise>
				<p>Please generate a sitemap for the current site.</p>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
</xsl:stylesheet>
