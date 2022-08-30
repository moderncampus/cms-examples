<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- 
=========================	
FULL PDF OUTPUT
Displays the entire course catalog per the XML gathered in full-xml.xsl.
=========================
FO Rules
- <FO:PAGE-SEQUENCE master-reference="" > defines layout set 
- Layout sets are defined in <FO:LAYOUT-MASTER-SET>, in common.xsl
- <FO:PAGE-SEQUENCE> cannot be nested inside another <FO:PAGE-SEQUENCE>
- <FO:PAGE-SEQUENCE> must have <FO:FLOW>, <FO:FLOW> must have <FO:BLOCK>
- Header, Footer templates must be declared in <FO:PAGE-SEQUENCE> & 
  before <FO:FLOW FLOW-NAME="XSL-REGION-BODY">.
- Different layout sets cannot exist within the same <FO:PAGE-SEQUENCE>.  
=========================
-->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ou="http://omniupdate.com/XSL/Variables" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:ouc="http://omniupdate.com/XSL/Variables" exclude-result-prefixes="xs ou ouc">

	<xsl:import href="common.xsl"/>
	<xsl:import href="full-xml.xsl"/>
	<xsl:param name="courses-doc" select="document($courses-xml)"/>

	<xsl:template match="/document">
		<fo:root xsl:use-attribute-sets="text" >
			<xsl:call-template name="master-set"/>
			<xsl:call-template name="metadata"/>
			<xsl:call-template name="content"/>
		</fo:root>
	</xsl:template>

	<!-- ============================================
		Table of Contents
		*Note 2 Column Sequence*
	=============================================== -->

	<xsl:template match="page[@type='toc']" mode="top-level">
		<xsl:comment>Table of Contents</xsl:comment>
		<fo:page-sequence master-reference="document-2col">
			<xsl:call-template name="header"/>
			<xsl:call-template name="footer"/>
			<fo:flow flow-name="xsl-region-body">
				<xsl:call-template name="page-heading"/>
				<!-- in the first level, sort page/directory together -->
				<xsl:apply-templates select="$full-xml/catalog/directory/index" mode="toc"/>
				<xsl:apply-templates select="$full-xml/catalog/directory/page|$full-xml/catalog/directory/directory" mode="toc">
					<xsl:sort select="@weight" data-type="number" order="descending"/>
					<xsl:sort select="@title"/>
				</xsl:apply-templates>			
			</fo:flow>
		</fo:page-sequence>
	</xsl:template>

	<!-- 2nd+ level Regulatory Directories - sort pages THEN directories -->
	<xsl:template match="directory" mode="toc">
		<xsl:apply-templates select="index" mode="toc"/>
		<fo:block-container margin-left="0.125in">
			<xsl:apply-templates select="page" mode="toc">
				<xsl:sort select="@weight" data-type="number" order="descending"/>
				<xsl:sort select="@title"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="directory" mode="toc">
				<xsl:sort select="@weight" data-type="number" order="descending"/>
				<xsl:sort select="@title"/>
			</xsl:apply-templates>
			<!-- In case no content -->
			<fo:block/>
		</fo:block-container>				
	</xsl:template>
	
	<!-- Index Pages -->
	<xsl:template match="index" mode="toc">
		<xsl:copy-of select="ou:toc-index(@title,@path)"/>
	</xsl:template>
	
	<!-- Regulatory Pages -->
	<xsl:template match="page" mode="toc">
		<xsl:copy-of select="ou:toc-page(@title,@path)"/>
	</xsl:template>

	<!-- Special cases -->

	<!-- Don't match TOC itself! -->
	<xsl:template match="page[@type='toc']" mode="toc"/>

	<!-- Don't output the Index page to the TOC if there are no index keywords -->
	<xsl:template match="page[@type='pdf-index']" mode="toc">
		<xsl:if test="$index-xml/descendant::letter-group">
			<xsl:copy-of select="ou:toc-index(@title,@path)"/>
		</xsl:if>
	</xsl:template>

	<!-- Course Descriptions Example -->
	<xsl:template match="directory[@type='courses']" mode="toc">
		<xsl:apply-templates select="index" mode="toc"/>
	</xsl:template>

	<!-- ============================================
		Content Display
		=============================================
		Sorting Rules
		- Index pages are always first
		- Higher page weight = appears first within the scope of the section
		- Directory page weight is pulled from index page
		- At the top level (ex. 'current') pages and directory weights are mixed.
		- In all subdirectories, pages are displayed before any subdirectories.
	=============================================== -->

	<!-- Top level -->
	<xsl:template name="content">
		<!-- cover page -->
		<xsl:call-template name="cover-page">
			<xsl:with-param name="image" select="$first-page"/>
		</xsl:call-template>
		<!-- start from inside the first directory -->
		<!-- the first directory is expected to be the version, ex 'current' -->
		<xsl:apply-templates select="$full-xml/catalog/directory/index" mode="top-level"/>
		<xsl:apply-templates select="$full-xml/catalog/directory/page|$full-xml/catalog/directory/directory" mode="top-level">
			<xsl:sort select="@weight" data-type="number" order="descending"/>
			<xsl:sort select="@title"/>
		</xsl:apply-templates>
		<!-- cover page -->
		<xsl:call-template name="cover-page">
			<xsl:with-param name="image" select="$last-page"/>
		</xsl:call-template>
	</xsl:template>

	<!-- Top level pages are their own sequence -->
	<xsl:template match="page|index" mode="top-level">
		<xsl:comment>Top level page</xsl:comment>
		<fo:page-sequence master-reference="document-1col">
			<xsl:call-template name="header"/>
			<xsl:call-template name="footer"/>
			<fo:flow flow-name="xsl-region-body">
				<xsl:call-template name="page-heading"/>
				<xsl:apply-templates select="content"/>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template>

	<!-- each Directory is its own sequence -->
	<xsl:template match="directory" mode="full-pdf top-level">
		<xsl:comment>Regulatory Directory</xsl:comment>
		<!-- We don't want to create a blank page when there are no pages pages set to display -->
		<xsl:if test="page|index">
			<fo:page-sequence master-reference="document-1col">
				<xsl:call-template name="header"/>
				<xsl:call-template name="footer"/>
				<fo:flow flow-name="xsl-region-body">
					<xsl:apply-templates select="index" mode="full-pdf"/>
					<xsl:apply-templates select="page" mode="full-pdf">
						<xsl:sort select="@weight" data-type="number" order="descending"/>
						<xsl:sort select="@title"/>
					</xsl:apply-templates>
					<!-- In case no content -->
					<fo:block/>
				</fo:flow>
			</fo:page-sequence>
		</xsl:if>
		<xsl:apply-templates select="directory" mode="full-pdf">
			<xsl:sort select="@weight" data-type="number" order="descending"/>
			<xsl:sort select="@title"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- Inner Pages are within Directory sequence -->
	<xsl:template match="page|index" mode="full-pdf">
		<xsl:comment>Regulatory Page</xsl:comment>
		<xsl:call-template name="page-heading"/>
		<fo:block>
			<xsl:apply-templates select="content"/>
		</fo:block>
	</xsl:template>

	<!-- Logic to display page heading - don't add ID if path is empty -->
	<!-- Apply h1 style and set ID for TOC linking. -->
	<xsl:template name="page-heading">
		<xsl:param name="id" select="@path"/>
		<xsl:param name="title" select="@title"/>
		<xsl:choose>
			<xsl:when test="@path!='' and @title!=''">
				<fo:block id="{@path}" xsl:use-attribute-sets="h1">
					<xsl:value-of select="@title"/>
				</fo:block>
			</xsl:when>
			<xsl:when test="@title!=''">
				<fo:block xsl:use-attribute-sets="h1">
					<xsl:value-of select="@title"/>
				</fo:block>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- ============================================
		Special Cases...
		remove sections that don't exist or 
		should be treated like Reglatory. 
		Add in logic to get external content if any.
	=============================================== -->

	<!-- ============================================
		Course Descriptions Example... 
		*Note 2 Column Sequence*
	=============================================== -->
	<xsl:template match="directory[@type='courses']" mode="top-level">
		<fo:page-sequence master-reference="document-2col">
			<xsl:call-template name="header"/>
			<xsl:call-template name="footer"/>
			<fo:flow flow-name="xsl-region-body">
				<!-- Example -->
				<xsl:apply-templates select="index" mode="full-pdf"/>
				<xsl:apply-templates select="$courses-doc/descendant::Subject" mode="toc"/>
				<xsl:apply-templates select="$courses-doc/descendant::Subject" mode="display-courses"/>
				<!-- In case no content (fo:flow requires fo:block) -->
				<fo:block/>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template>

	<!-- ============================================
		Index
		*Note 3 Column Sequence*
	=============================================== -->
	
	<xsl:template match="page[@type='pdf-index']" mode="top-level">
		<xsl:comment>Index</xsl:comment>
		<!-- We don't want a blank Index Page when no Index Keywords are set. -->
		<xsl:if test="$index-xml/descendant::letter-group">
			<fo:page-sequence master-reference="document-3col">
				<xsl:call-template name="header"/>
				<xsl:call-template name="footer"/>
				<fo:flow flow-name="xsl-region-body">
					<xsl:call-template name="page-heading"/>
					<xsl:apply-templates select="$index-xml/descendant::letter-group" mode="display-index">
						<xsl:sort select="@letter"/>
					</xsl:apply-templates>
				</fo:flow>
			</fo:page-sequence>
		</xsl:if>
	</xsl:template>
	
	<!-- display each Letter -->
	<xsl:template match="letter-group" mode="display-index">
		<fo:block xsl:use-attribute-sets="h2"><xsl:value-of select="@letter"/></fo:block>
		<fo:block space-after="{$space-after}">
			<xsl:apply-templates select="tag" mode="display-index">
				<xsl:sort select="@name"/>
			</xsl:apply-templates>
		</fo:block>
	</xsl:template>
	
	<!-- Display Name of Tag -->
	<xsl:template match="tag" mode="display-index">
		<fo:block text-align-last="justify">
			<xsl:value-of select="@name"/>
			<fo:leader leader-pattern="dots"/>
			<fo:leader leader-length="2pt"/>
			<xsl:apply-templates select="files/file" mode="display-index"/>
		</fo:block>
	</xsl:template>
	
	<!-- Link to each file w/ that tag -->
	<xsl:template match="file" mode="display-index">
		<fo:basic-link internal-destination="{@path}">
			<fo:page-number-citation ref-id="{@path}"/>
		</fo:basic-link>
		<!-- add a comma if there's another file following it -->
		<xsl:if test="following-sibling::file">
			<fo:inline>
				<xsl:value-of select="','"/>
			</fo:inline>
			<fo:leader leader-length="2pt"/>
		</xsl:if>
	</xsl:template>	

</xsl:stylesheet>