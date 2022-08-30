<?xml version="1.0" encoding="utf-8"?>
<!--
	OU LDP GALLERIES
	
	DO NOT MODIFY THIS FILE.
	This file may be overwritten with updates in the future. To modify templates, override the templates in a different file.
	
	Transforms gallery asset XML into a dynamic gallery on the web page. 
	Type of gallery is determined by page property.
	
	Dependencies: 
	- ou:pcf-param (See kitchensink functions.xsl)
	- $domain  	<xsl:param name="domain" select="substring($ou:httproot,1,string-length($ou:httproot)-1)" /> 				
	
	Contributors: Akifumi Yamamoto
	Version: 1.0.1
	Last Updated: 2017/10/06
-->
<!DOCTYPE xsl:stylesheet SYSTEM "http://commons.omniupdate.com/dtd/standard.dtd">
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">
	
	<!-- Global Variables for the Gallery -->
	<xsl:param name="gallery-type" select="if (normalize-space(ou:pcf-param('gallery-type'))) then ou:pcf-param('gallery-type') else 'fancybox'" />
	
	<!--	
		The following templates match the LDP gallery nodes and output the proper HTML Code based on a specified parameter. 
		This will work with existing apply-templates.
		
		To override existing templates, create new template matches in another XSL file.
		To create new matches for new gallery types, create new conditional matches in another XSL file.
		
		Example:
		<xsl:template match="gallery[$gallery-type = 'new-gallery']"></template>
	-->
	<xsl:template match="gallery">
		<xsl:comment>The specified gallery is not available. Please ensure you have the supported Gallery Types in the Page Properties or create a template for the gallery type you have chosen.</xsl:comment>
	</xsl:template>
	
	<xsl:template match="gallery[$gallery-type = 'slick']" priority="2">
		<div class="slick">
			<xsl:for-each select="images/image">
				<div>
					<xsl:choose>
						<!-- Determine if caption field is empty -->
						<xsl:when test="link != ''">
							<!-- Not empty, create a link -->
							<a href="{link}">
								<img src="{@url}" alt="{description}" title="{title}" />
							</a>
						</xsl:when>
						<xsl:otherwise>
							<img src="{@url}" alt="{description}" title="{title}" />                 
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="caption != ''">
						<p class="slick-caption"><xsl:value-of select="string-join((title, caption), ' - ')" /></p>
					</xsl:if>
				</div>
			</xsl:for-each>
		</div>
	</xsl:template>
	
	<xsl:template match="gallery[$gallery-type = 'fancybox']" priority="2">
		<xsl:variable name="gallery-id" select="@asset_id"/>
		<xsl:variable name="positional-id" select="generate-id()"/>
		
		<ul class="thumbnails">
			<xsl:for-each select="images/image">
				<li>
					<a class="thumbnail" data-fancybox="{$gallery-id}-{$positional-id}" data-caption="{string-join((title, caption), ' - ')}" href="{@url}">
						<img src="{thumbnail/@url}" alt="{description}" title="{title}" />
					</a>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>
	
	<!--
		
		Gallery Headcode
		
		This is the CSS styling for displaying galleries.
		Include this in the common headcode as follows:
		<xsl:call-template name="gallery-headcode"/>
		
		This template supports up to 2 parameters:
		gallery-type: By default, the value in ou:pcf-param('gallery-type') is used. If the gallery-type parameter is not defined in a PCF, then the default value will be "fancybox"
		domain: By default, the value in variables.xsl will be used. Prepending the domain creates a safety-net for when a root folder is defined in the HTTP Root setting. It also enables access files in another subdomain.
	-->
	<xsl:template name="gallery-headcode">
		<xsl:param name="gallery-type" select="$gallery-type"/>
		<xsl:param name="domain" select="$domain"/>
		
		<xsl:if test="/document/descendant::gallery">
			<xsl:choose>
				<xsl:when test="$gallery-type = 'slick'">
					<link rel="stylesheet" href="{$domain}/_resources/ldp/galleries/slick/slick.css" type="text/css"/>
					<link rel="stylesheet" href="{$domain}/_resources/ldp/galleries/slick/slick-theme.css" type="text/css"/>
				</xsl:when>
				<xsl:when test="$gallery-type = 'fancybox'">
					<link rel="stylesheet" href="{$domain}/_resources/ldp/galleries/fancybox/bootstrap-thumbnails.css" media="screen" />
					<link rel="stylesheet" type="text/css" href="{$domain}/_resources/ldp/galleries/fancybox/jquery.fancybox.min.css" media="screen" />
					<link rel="stylesheet" type="text/css" href="{$domain}/_resources/ldp/galleries/fancybox/ou.fancybox.accessibility.css" media="screen" />
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<!--
		
		Gallery Footcode
		
		This is the javascript for displaying galleries.
		Include this in the footcode after jquery is loaded as follows:
		<xsl:call-template name="gallery-footcode"/>
		
		This template supports up to 2 parameters:
		gallery-type: By default, the value in ou:pcf-param('gallery-type') is used. If the gallery-type parameter is not defined in a PCF, then the default value will be "fancybox"
		domain: By default, the value in variables.xsl will be used. Prepending the domain creates a safety-net for when a root folder is defined in the HTTP Root setting. It also enables access files in another subdomain.
		
	-->
	<xsl:template name="gallery-footcode">
		<xsl:param name="gallery-type" select="$gallery-type"/>
		<xsl:param name="domain" select="$domain"/>
		
		<xsl:if test="/document/descendant::gallery">
			<xsl:choose>
				<xsl:when test="$gallery-type = 'slick'">
					<script type="text/javascript" src="{$domain}/_resources/ldp/galleries/slick/slick.min.js"></script>
					<script type="text/javascript">
						$(document).ready(function() {
							$('.slick').slick({
								dots: true,
								infinite: false,
								slidesToShow: 1,
								accessibility: true
							});
						});
					</script>
				</xsl:when>
				<xsl:when test="$gallery-type = 'fancybox'">
					<script type="text/javascript" src="{$domain}/_resources/ldp/galleries/fancybox/jquery.fancybox.min.js"></script>
					<xsl:if test="not($is-pub)">
						<script type="text/javascript">
							$(document).ready(function() {
								$('[data-fancybox]').fancybox({ hash: false });
							});
						</script>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
