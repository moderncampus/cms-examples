<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="xs ou ouc">

	<xsl:import href="../_shared/variables.xsl" />
	<xsl:import href="blog-functions.xsl" />

	<xsl:strip-space elements="*" />
	<xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>

	<xsl:template match="/document">
		<post link="{concat($domain,replace($ou:path,'\.blog','.aspx'))}" display="{post-info/ouc:div[@label='post-display']}">
			<xsl:if test="post-info/ouc:div[@label='post-featured'] = 'true'">
				<xsl:attribute name="featured">true</xsl:attribute>
			</xsl:if>
			<xsl:if test="ouc:properties[@label='config']/parameter[@name='disqus-enable']/option[@value='true']/@selected='true'">
				<xsl:attribute name="comments">true</xsl:attribute>
			</xsl:if>
			<title><xsl:value-of select="post-info/ouc:div[@label='post-title']" /></title>
			<author><xsl:value-of select="if (normalize-space(post-info/ouc:div[@label='post-author']) != '') then post-info/ouc:div[@label='post-author'] else ''" /></author>
			<email><xsl:value-of select="if (normalize-space(post-info/ouc:div[@label='post-email']) != '') then post-info/ouc:div[@label='post-email'] else ''" /></email>
			<description><xsl:value-of select="post-info/ouc:div[@label='post-description']" /></description>
			<pubDate><xsl:value-of select="ou:to-pub-date(post-info/ouc:div[@label='post-date'])"/></pubDate>
			<tags><xsl:value-of select="$tags"/></tags>
			<xsl:if test="post-info/ouc:div[@label='post-img'] = 'img'">
				<image><img><xsl:copy-of select="post-info/ouc:div[@label='post-image']/img/attribute()" /></img></image>
			</xsl:if>
		</post>
	</xsl:template>

</xsl:stylesheet>
