<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet>
<!-- 
  Table Transformation Snippets
  All the HTML structures presented in these snippets is based upon Bootstrap. Each template match targets a table with a specific class and transforms the content into a different HTML structure.  
  
  1. Accordion
  - This is a table transformation snippet that renders as an accordion element. The layout of the table editing experience will be a sequence of rows, with each accordion element in its own row. Adding a row to the table will add a corresponding accordion element.
  2. Tabs
  - This is a table transformation snippet that renders as tabbed content. The layout of the table editing experience will be a sequence of rows, with each tab in its own row. Adding a row to the table will add a corresponding tab.
  3. Columns (2 or 3)
  - These are two separate table transformation snippets that will split the current editable region into either 2 or 3 rows, depending on which of these two snippets are used. The layout of the table editing experience will be a 2 or 3 columns, with each rendered column element in its own column in the table. This table is expected to not be changed by the user, and any changes to the layout should be ignored and can potentially break the transformation.
  4. Image with Caption
  - This is a table transformation snippet that renders as an image with an associated caption. The layout of the table editing experience will have the image in the first row and the caption in the second row. Any additional rows added by the user will be ignored.
  5. Blockquote with Citation
  - This is a table transformation snippet that renders a blockquote and associated citation. The layout of the table editing experience will have the blockquote in the first row and the citation in the second row. Any additional rows added by the user will be ignored.
  
  Last Updated: 3/1/2017
-->
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ou="http://omniupdate.com/XSL/Variables"
    xmlns:fn="http://omniupdate.com/XSL/Functions"
    xmlns:ouc="http://omniupdate.com/XSL/Variables"
    exclude-result-prefixes="xs ou fn ouc">
    
    <!-- Identity Matches 
        ***These two template matches should be uncommented and placed in /_resources/xsl/_shared/template-matches.xsl, if not already present.***
    -->
    <!-- The following template matches all items except processing instructions, copies them, then processes any children. -->
    
    <!--<xsl:template match="attribute()|text()|comment()">
        <xsl:copy />
    </xsl:template>
    <xsl:template match="element()">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="attribute()|node()"/>
        </xsl:element>
    </xsl:template>-->
    
    <!-- Accordion -->
    <xsl:template match="table[@class='omni-accordion']">
        <xsl:variable name="uq" select="generate-id(.)" />
        <div id="accordion-{$uq}" class="col-md-12 panel-group">
            <xsl:for-each select="tbody/tr">
                <xsl:variable name="pos" select="position()" />
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a role="button" data-toggle="collapse" data-parent="#accordion-{$uq}" href="#collapse-{$uq}-{$pos}">
                                <xsl:value-of select="td[1]" />
                            </a>
                        </h4>
                    </div>
                    <div id="collapse-{$uq}-{$pos}" class="panel-collapse collapse">
                        <div class="panel-body">
                            <xsl:apply-templates select="td[2]/node()" />
                        </div>
                    </div>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>
    <!-- /Accordion -->
    
    <!-- Tabs -->
    <xsl:template match="table[@class='omni-tabs']">
        <xsl:variable name="uq" select="generate-id(.)" />
        <ul class="nav nav-tabs">
            <xsl:for-each select="tbody/tr">
                <xsl:variable name="pos" select="position()" />
                <li>
                    <xsl:if test="$pos = 1"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
                    <a data-toggle="tab" href="#{$uq}-{$pos}"><xsl:value-of select="td[1]" /></a>
                </li>
            </xsl:for-each>
        </ul>
        <div class="tab-content">
            <xsl:for-each select="tbody/tr">
                <xsl:variable name="pos" select="position()" />
                <div id="{$uq}-{$pos}" class="tab-pane fade">
                    <xsl:if test="$pos = 1"><xsl:attribute name="class">tab-pane fade in active</xsl:attribute></xsl:if>
                    <xsl:apply-templates select="td[2]/node()" />
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>
    <!-- /Tabs -->
    
    <!-- Two Columns -->
    <xsl:template match="table[@class='omni-two-columns']">
        <xsl:variable name="class-name" select="'col-md-6'" />
        <div class="row">
            <div class="{$class-name}">
                <xsl:apply-templates select="tbody/tr[1]/td[1]/node()" />
            </div>
            <div class="{$class-name}">
                <xsl:apply-templates select="tbody/tr[1]/td[2]/node()" />
            </div>
        </div>
    </xsl:template>
    <!-- /Two Columns -->
    
    <!-- Three Columns -->
    <xsl:template match="table[@class='omni-three-columns']">
        <xsl:variable name="class-name" select="'col-md-4'" />
        <div class="row">
            <div class="{$class-name}">
                <xsl:apply-templates select="tbody/tr[1]/td[1]/node()" />
            </div>
            <div class="{$class-name}">
                <xsl:apply-templates select="tbody/tr[1]/td[2]/node()" />
            </div>
            <div class="{$class-name}">
                <xsl:apply-templates select="tbody/tr[1]/td[3]/node()" />
            </div>
        </div>
    </xsl:template>
    <!-- /Three Columns -->
    
    <!-- Image with Caption -->
    <xsl:template match="table[@class='omni-image-caption']">
        <div class="thumbnail">
            <xsl:apply-templates select="tbody/tr[1]/td[1]/descendant::img[1]" />
        </div>
        <div class="caption">
            <xsl:apply-templates select="tbody/tr[2]/td[1]/node()" />
        </div>
    </xsl:template>
    <!-- /Image with Caption -->
    
    <!-- Blockquote -->
    <xsl:template match="table[@class='omni-blockquote']">
        <blockquote>
            <xsl:value-of select="tbody/tr[1]/td[1]" /><br />
            <cite><xsl:value-of select="tbody/tr[2]/td[1]" /></cite>
        </blockquote>
    </xsl:template>
    <!-- /Blockquote -->
    
</xsl:stylesheet>
