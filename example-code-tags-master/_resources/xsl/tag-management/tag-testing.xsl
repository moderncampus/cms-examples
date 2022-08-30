<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="3.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="xs ou ouc">

<!--
TAG TESTING DOCUMENT XSL

This XSL file is linked to tagdemo.pcf. Used in conjunction with tag-management.xsl, this file calls functions that make API calls that return data about Tag Management.
Feel free to add to this file to test out additional tags functionality.
Refer to /tag-management.xsl to see the functions that make the API calls themselves.

Contributors: Brandon Scheirman and Robert Kiffe
Last updated: 7/26/16
-->

	<!-- If you don't want to import common.xsl (or whatever your default XSL file is named), make sure to import ou-variables.xsl and tag-management.xsl. Otherwise, the file will break. -->

	<xsl:import href="../common.xsl"/>
    <xsl:import href="tag-management.xsl"/>

	<xsl:template match="/document">
		<html>
			<head>
				<title>Tag Testing</title>
			</head>
			<body>
				<h3>GetAllTags</h3>
				<p>Returns all tags that have been created in the site, shows whether the tag has been disabled, and lists if the tag has any children (which means it's a collection).</p>
				<p><xsl:apply-templates select="ou:get-all-tags()"/></p>

				<h3>GetTags and GetCombinedTags</h3>
				<p>GetTags returns the tags that have been manually applied to a particular page. GetCombinedTags returns a list of all manually-applied tags and any fixed tags applied to the page at the directory level.</p>
				<p>You are viewing the tags that have been applied to <xsl:call-template name="current-page-test"/></p>

				<h3>GetFixedTags</h3>
				<p>Returns the list of fixed tags that have been applied to a particular directory.</p>
				<p>You are viewing the fixed tags of <xsl:call-template name="directory-test"/></p>

				<h3>GetParents</h3>
				<p>Returns any collections that this tag belongs to.</p>
				<p>You are viewing the parents of: <xsl:value-of select="ouc:properties/parameter[@name='tag-parents']" />.</p>
				<xsl:apply-templates select="ou:get-parent-tags(ouc:properties/parameter[@name='tag-parents'])"/>

				<h3>GetChildren</h3>
				<p>Returns the tags that comprise the selected collection.</p>
				<p>You are viewing the children of: <xsl:value-of select="ouc:properties/parameter[@name='collection-children']" />.</p>
				<p><xsl:apply-templates select="ou:get-children-tags(ouc:properties/parameter[@name='collection-children'])"/></p>

				<h3>GetFilesWithAnyTags</h3>
				<p>Returns any file that contains one or more of the listed tags.</p>
				<p>You are searching with these tags: <xsl:value-of select="ouc:properties/parameter[@name='tag-list-any']"/>.</p>
				<p><xsl:apply-templates select="ou:get-files-with-any-tags(ouc:properties/parameter[@name='tag-list-any'])"/></p>

				<h3>GetFilesWithAllTags</h3>
				<p>Returns any file that contains all of the listed tags.</p>
				<p>You are searching with these tags: <xsl:value-of select="ouc:properties/parameter[@name='tag-list-all']"/>.</p>
				<p><xsl:apply-templates select="ou:get-files-with-any-tags(ouc:properties/parameter[@name='tag-list-all'])"/></p>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="tags">
		<p><xsl:apply-templates select="tag"/></p>
	</xsl:template>

	<xsl:template match="tag">
		<xsl:for-each select=".">
			Name="<xsl:value-of select="name"/>", Disabled=<xsl:value-of select="disabled"/>, <xsl:apply-templates select="children" /><br/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="children">
		<xsl:choose>
			<xsl:when test="xs:integer(.) gt 0">
				This tag is a collection. Children=<xsl:value-of select="."/>
			</xsl:when>
			<xsl:otherwise>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="pages">
		<p><xsl:apply-templates select="page"/></p>
	</xsl:template>

	<xsl:template match="page">
		<xsl:variable name="pubdate">
			<xsl:copy-of select="last-pub-date/node()"/>
		</xsl:variable>
		Path="<xsl:value-of select="path"/>" Last Published Date=<xsl:value-of select="format-dateTime($pubdate, '[M01]/[D01]/[Y0001] at [h1]:[m1] [P]')"/><br/>
	</xsl:template>

	<xsl:template name="current-page-test">
		<xsl:variable name="staging-path" select="ouc:properties/parameter[@name='staging-path']" />
		<xsl:choose>
			<xsl:when test="string-length($staging-path) != 0">
				<xsl:value-of select="$staging-path" />.
				<ul>
					<li>Manually-added tags only: <xsl:apply-templates select="ou:get-page-tags(concat('/', substring-after($staging-path, '/')),substring-before($staging-path,'/'))"/></li>
					<li>Combined tags:<xsl:apply-templates select="ou:get-combined-tags(concat('/', substring-after($staging-path, '/')),substring-before($staging-path,'/'))"/></li>
				</ul>
			</xsl:when>
			<xsl:otherwise>
				the current page.
				<ul>
					<li>Manually-added tags only: <xsl:apply-templates select="ou:get-page-tags()" /></li>
					<li>Combined tags: <xsl:apply-templates select="ou:get-combined-tags()" /></li>
				</ul>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="directory-test">
		<xsl:variable name="directory-path" select="ouc:properties/parameter[@name='directory']"/>
		<xsl:choose>
			<xsl:when test="string-length($directory-path) != 0">
				<xsl:variable name="directory" select="string-join(tokenize($directory-path, '/')[position() lt last()], '/')"/>
				<xsl:value-of select="string-join(tokenize($directory-path, '/')[position() lt last()], '/')" />.
				<p><xsl:apply-templates select="ou:get-fixed-tags($directory)" /></p>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$ou:dirname" />.
				<p><xsl:apply-templates select="ou:get-fixed-tags()" /></p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
