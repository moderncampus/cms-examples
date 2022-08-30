<!-- PULLING IN TAGS AS META KEYWORDS -->
<!-- Add this to <head> in common.xsl -->
<meta name="keywords" content="{$page-tags-csv}"/>
<!-- If already adding keywords to a page via a <meta> node in the PCF, you can keep those and also pull in tags like so -->
<meta name="keywords" content="{ouc:properties[@label='metadata']/meta[@name='keywords']/@content},{$page-tags-csv}"/>

<!-- DIV NODE THAT LISTS CURRENT PAGE TAGS -->
<!-- A nice little region on a page (added to a left or right column) that lists all tags for the current page. Functionality could be expanded using server-side scripting to make the tags linkable. When clicking a tag, a list of files that have that tag could appear. -->
<!-- Add this to an interior page XSL -->

	<div>
		<h3>Tags</h3>
		<p>This page has been tagged with:</p>
		<xsl:call-template name="page-tags" />
	</div>

	<xsl:template name="page-tags">
		<xsl:choose><xsl:when test="count(ou:get-combined-tags()/tag) gt 0">
			<ul>
				<xsl:for-each select="ou:get-combined-tags()/tag">
					<li><xsl:value-of select="name" /></li>
				</xsl:for-each>
			</ul>
			</xsl:when>
			<xsl:otherwise>
				<p>The page has not been tagged.</p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>