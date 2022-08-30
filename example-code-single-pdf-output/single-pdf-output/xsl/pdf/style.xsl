<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- 
=========================
PDF Styles
Interface to edit PDF styling via xsl:attribute-sets.
Applicable to individual and full pdf output.
=========================
-->
<xsl:stylesheet expand-text="yes" version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	exclude-result-prefixes="xsl xs ou fn ouc">

	<!-- ============================================		
		Page Level
	=============================================== -->
	
	<xsl:attribute-set name="default-page-attributes">
		<xsl:attribute name="page-height">11in</xsl:attribute>
		<xsl:attribute name="page-width">8.5in</xsl:attribute>
		<!-- this margin will apply to regions before,after,start, and end -->
		<xsl:attribute name="margin">0.5in</xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:attribute-set name="region-body-defaults">
		<!-- 
			these margins should encapsulate the body
			region so that it doesn't overlap 
			the before,after,start and end regions 
		-->
		<xsl:attribute name="margin">0.5in 0 0.5in 0</xsl:attribute>
	</xsl:attribute-set>

	<!-- ============================================
		Colors
	=============================================== -->
	<!-- Add colors and edit hex values as needed -->
	<!-- For ease of editing, avoid hex values in XSL templates when possible -->
	<xsl:param name="black">#000000</xsl:param>
	<xsl:param name="dark-gray">#1E1E1E</xsl:param>
	<xsl:param name="gray">#8E8E8E</xsl:param>
	<xsl:param name="light-gray">#C1C1C1</xsl:param>
	<xsl:param name="lightest-gray">#f1f1f1</xsl:param>
	<xsl:param name="link-color">#0B0080</xsl:param>  
	
	<!-- ============================================
		Font
	=============================================== -->
	
	<!-- Font Family -->
	<!-- Note: Certain fonts require seperate specification for bold and italic styling - specify when necescary. -->
	<xsl:param name="font-family">sans-serif</xsl:param>
	<xsl:param name="font-bold" select="$font-family"/>
	<xsl:param name="font-bold-italic"  select="$font-family"/>
	<xsl:param name="font-italic"  select="$font-family"/>
	
	<!-- Font Size -->
	<!-- editing this may effect all elements -->
	<xsl:param name="base-px">10</xsl:param>
	<xsl:param name="font-size" select="concat($base-px,'px')"/>
	<xsl:param name="font-color" select="$black"/>
	<xsl:param name="space-after" select="concat(format-number($base-px * 1.1,'#.00'),'px')"/>
	
	<!-- Basic Text -->
	<xsl:attribute-set name="text">
		<xsl:attribute name="font-family" select="$font-family"/>
		<xsl:attribute name="font-size" select="$font-size"/>
	</xsl:attribute-set>
	
	<!-- ============================================
		Text Elements
	=============================================== -->
	
	<!-- Headings -->
	<!-- Specify heading color & font family common to h1-h6 elements -->
	<!-- sizes based on w3c recommondation -->
	<xsl:attribute-set name="h">                    
		<xsl:attribute name="font-family" select="$font-bold"/>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		<xsl:attribute name="space-after" select="$space-after"/>
	</xsl:attribute-set>
	<xsl:attribute-set name="h1" use-attribute-sets="h">
		<xsl:attribute name="font-size">{$base-px * 2}px</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="h2" use-attribute-sets="h">
		<xsl:attribute name="font-size">{$base-px * 1.5}px</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="h3" use-attribute-sets="h">
		<xsl:attribute name="font-size">{$base-px * 1.17}px</xsl:attribute>		
	</xsl:attribute-set>
	<xsl:attribute-set name="h4" use-attribute-sets="h">
		<xsl:attribute name="font-size">{$base-px}px</xsl:attribute>		
	</xsl:attribute-set>
	<xsl:attribute-set name="h5" use-attribute-sets="h">
		<xsl:attribute name="font-size">{$base-px * 0.83}px</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="h6" use-attribute-sets="h">
		<xsl:attribute name="font-size">{$base-px * 0.75}px</xsl:attribute>
	</xsl:attribute-set>
	
	<!-- Paragraphs -->
	<xsl:attribute-set name="p">
		<xsl:attribute name="space-after" select="$space-after"/>
	</xsl:attribute-set>
	
	<!-- ============================================
		Inline Elements
	=============================================== -->
	
	<!-- Links -->
	<xsl:attribute-set name="a">
		<xsl:attribute name="color" select="$link-color"/>
	</xsl:attribute-set>
	
	<!-- Bold & Italic -->
	<!-- Note: Certain fonts families use different fonts for bold and italic styling - specify when necescary. -->
	<xsl:attribute-set name="em">
		<xsl:attribute name="font-style">italic</xsl:attribute>
	</xsl:attribute-set>    
	<xsl:attribute-set name="strong">
		<xsl:attribute name="font-weight">bold</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="em-strong" use-attribute-sets="em strong">
		<xsl:attribute name="font-family" select="$font-bold-italic"/>
	</xsl:attribute-set>
	
	<!-- Underline -->
	<xsl:attribute-set name="u">
		<xsl:attribute name="text-decoration">underline</xsl:attribute>
	</xsl:attribute-set>
	
	<!-- Strikethrough -->
	<xsl:attribute-set name="s">
		<xsl:attribute name="text-decoration">line-through</xsl:attribute>
	</xsl:attribute-set>
	
	<!-- Subtext -->
	<xsl:attribute-set name="sub">
		<xsl:attribute name="vertical-align">sub</xsl:attribute>
		<xsl:attribute name="font-size">{$base-px * 0.75}px</xsl:attribute>
	</xsl:attribute-set>
	
	<!-- Supertext -->
	<xsl:attribute-set name="sup">
		<xsl:attribute name="vertical-align">super</xsl:attribute>
		<xsl:attribute name="font-size">{$base-px * 0.75}px</xsl:attribute>
	</xsl:attribute-set>
	
	<!-- Code -->
	<xsl:attribute-set name="code">
		<xsl:attribute name="font-family">monospace</xsl:attribute>
		<xsl:attribute name="padding" select="concat($base-px/4,'px')"/>
		<xsl:attribute name="color" select="$dark-gray"/>
		<xsl:attribute name="background-color" select="$lightest-gray"/>
		<xsl:attribute name="border">1px solid {$light-gray}</xsl:attribute>
	</xsl:attribute-set>
	
	<!-- Small -->
	<xsl:attribute-set name="small">
		<xsl:attribute name="font-size">{$base-px * 0.75}px</xsl:attribute>
	</xsl:attribute-set>
	
	<!-- ============================================
		Block Elements
	=============================================== -->
	
	<!-- Images -->
	<xsl:attribute-set name="img">
		<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
		<xsl:attribute name="content-height">100%</xsl:attribute>
		<xsl:attribute name="scaling">uniform</xsl:attribute>
		<xsl:attribute name="space-after" select="$font-size"/>
	</xsl:attribute-set>
	
	<!-- ============================================
		Styled block elements.
	=============================================== -->
	
	<!-- Preformatted -->
	<xsl:attribute-set name="pre" use-attribute-sets="p">
		<xsl:attribute name="font-family">monospace</xsl:attribute>
	</xsl:attribute-set>
	
	<!-- Address -->
	<xsl:attribute-set name="address" use-attribute-sets="em p">
		<!-- no custom style defined -->
	</xsl:attribute-set>
	
	<!-- Blockquote -->
	<xsl:attribute-set name="blockquote" use-attribute-sets="p">
		<xsl:attribute name="font-size">{$base-px * 0.9}px</xsl:attribute>
		<xsl:attribute name="border-left">2px solid {$light-gray}</xsl:attribute>
		<xsl:attribute name="color" select="$dark-gray"/>
		<xsl:attribute name="padding-left">0.25in</xsl:attribute>
		<xsl:attribute name="start-indent">0.5in</xsl:attribute>
	</xsl:attribute-set>
	
	<!-- ============================================
		Tables.
	=============================================== -->
	
	<!-- Tables -->
	<xsl:attribute-set name="table" use-attribute-sets="p">
		<xsl:attribute name="table-layout">fixed</xsl:attribute>  
		<xsl:attribute name="space-after" select="$space-after"/>
	</xsl:attribute-set>
	<xsl:attribute-set name="thead">
		<xsl:attribute name="background-color" select="$lightest-gray"/>
	</xsl:attribute-set>
	<xsl:attribute-set name="tr">
		<!-- no custom style defined -->
	</xsl:attribute-set>
	<xsl:attribute-set name="th" use-attribute-sets="td strong">
		<!-- no custom style defined -->
	</xsl:attribute-set>
	<xsl:attribute-set name="td">
		<!-- vertical align: top; -->
		<xsl:attribute name="border">1pt solid black</xsl:attribute>
		<xsl:attribute name="display-align">before</xsl:attribute>		
		<xsl:attribute name="padding" select="concat($base-px/4,'px')"/>
	</xsl:attribute-set>
	
	<!-- Lists -->
	<xsl:attribute-set name="ol-ul">
		<xsl:attribute name="space-after" select="$space-after"/>
		<xsl:attribute name="provisional-distance-between-starts">3mm</xsl:attribute>
		<xsl:attribute name="start-indent">from-parent(start-indent) + 0.12in</xsl:attribute>
		<xsl:attribute name="end-indent">from-parent(start-indent) + 0.12in</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="ol-li">
		<xsl:attribute name="start-indent">body-start() + 3mm</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="ul-li">
		<xsl:attribute name="start-indent">body-start()</xsl:attribute>
	</xsl:attribute-set>
	
	<!-- ============================================
		Formatting
	=============================================== -->
	
	<!-- Horizontal Rule -->
	<xsl:attribute-set name="hr">
		<xsl:attribute name="border-bottom">1px solid {$dark-gray}</xsl:attribute>
		<xsl:attribute name="space-before" select="$space-after"/>
		<xsl:attribute name="space-after" select="$space-after"/>
	</xsl:attribute-set>
	
	<!-- ============================================
		Custom xsl:attribute-sets
	=============================================== -->
	
	<!-- insert custom xsl:attribute-sets here -->

</xsl:stylesheet>
