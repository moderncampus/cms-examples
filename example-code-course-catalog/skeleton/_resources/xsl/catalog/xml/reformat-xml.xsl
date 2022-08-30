<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!--
Course Catalog - 05/2016
=========================
XML REFORMAT
Optional stylesheet reformat source XML.
This is desirable if additional sorting logic is required on multiple outputs or if XML format is not easily readible.
** Note: be sure to remove prefix example CrseCat when implementing this stylesheet - it is just an example **
=========================
-->
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	xmlns:CrseCat="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xsl xs ou fn ouc CrseCat">
	
	<!-- identity match -->
	<xsl:mode on-no-match="shallow-copy"/>
	
	<!-- xml output -->
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	
	<!-- 
		variables required for output...
		importing XSL not desirable, 
		in order to make this stylesheet as lightweight as possibe.
	-->
	
	<xsl:param name="ou:filename"/>
	<xsl:param name="ou:httproot"/>
	<xsl:param name="domain" select="substring($ou:httproot,1,string-length($ou:httproot)-1)"/> 

	<xsl:template match="processing-instruction()"/>

	<!-- ============================================
		Document listings...
		Add/Edit/Remove as needed based on output filename.
	=============================================== -->

	<!-- ============================================
		Course Descriptions (Example)
		It is recommended  to keep styling similar to input document,
		and include as much data as possible.
	=============================================== -->
	
	<xsl:template match="document[$ou:filename='_config.courses.xml']">
		<xsl:param name="input" select="descendant::parameter[@name='courses-xml']"/>
		<CourseDescriptions>
			<xsl:if test="$input!=''">
				<xsl:variable name="input-doc" select="document(concat($domain,$input))"/>
				<!-- do special stuff... this is just an example -->
				<xsl:for-each-group select="$input-doc/descendant::CourseInventory[CourseNumber]" group-by="CourseSubjectAbbreviation">
					<xsl:sort select="current-grouping-key()" data-type="text"/>
					<Subject code="{current-grouping-key()}">
						<xsl:for-each select="current-group()">
							<xsl:sort select="CourseNumber" data-type="number"/>
							<CourseInventory>
								<xsl:apply-templates/>
							</CourseInventory>
						</xsl:for-each>
					</Subject>
				</xsl:for-each-group>
			</xsl:if>
		</CourseDescriptions>
	</xsl:template>

</xsl:stylesheet>
