<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp   "&#160;">
]>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ou="http://omniupdate.com/XSL/Variables"
    xmlns:ouc="http://omniupdate.com/XSL/Variables"
    exclude-result-prefixes="xs ou ouc">

    <xsl:template match="ouc:*[$ou:action != 'edt']">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="ouc:div">
        <xsl:copy>
            <xsl:attribute name="wysiwyg-class"><xsl:value-of select="$body-class" /></xsl:attribute>
            <xsl:apply-templates select="attribute()|node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="ouc:div" mode="edit-button">
        <xsl:if test="$ou:action = 'edt'">
            <xsl:copy>
                <xsl:attribute name="wysiwyg-class" select="$body-class" />
                <xsl:apply-templates select="attribute()|ouc:editor" />
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ouc:div" mode="snippets">
        <xsl:apply-templates select=".//table[starts-with(@class, 'ou-')]" />
    </xsl:template>

    <!-- The following template matches all items except processing instructions, copies them, then processes any children. -->
    <xsl:template match="attribute()|text()|comment()">
        <xsl:copy />
    </xsl:template>

    <xsl:template match="element()">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="attribute()|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="processing-instruction('csharp')">
        <xsl:text disable-output-escaping="yes">&lt;%</xsl:text>
            <xsl:value-of select="." disable-output-escaping="yes" />
        <xsl:text disable-output-escaping="yes">%&gt;</xsl:text>
    </xsl:template>

    <xsl:template match="text()" mode="normalize-space">
        <xsl:value-of select="normalize-space()"/>
    </xsl:template>

    <xsl:template match="gcse">
        <xsl:text disable-output-escaping="yes">&lt;gcse:search&gt;&lt;/gcse:search&gt;</xsl:text>
    </xsl:template>

    <!-- blog asset with specific structure <blog type="tags" limit="3" dir="/posts"/> -->
    <xsl:template match="blog">
        <xsl:variable name="tags" select="if (@tags) then @tags else ''"/>
        <xsl:variable name="type" select="@type"/>
        <xsl:variable name="dir" select="if (@dir) then @dir else $dirname"/>
        <xsl:variable name="limit" select="if (@limit != '') then @limit else if ($type = 'tags') then 3 else 0"/>

        <xsl:variable name="current-post-link" select="concat( substring( $ou:httproot, 1, string-length($ou:httproot)-1 ), replace( $ou:path, '\.xml', '.aspx') )" />

        <div id="{if ($type = 'featured') then 'featured-posts' else if ($type = 'tags') then 'post-tags' else if ($type = 'related') then 'related-posts' else 'recent-posts'}">
            <xsl:choose>
                <xsl:when test="not($ou:action='pub')">
                    <div class="panel">
                        <p>Posts displayed on production.</p>
                        <p style="color:red">type: <xsl:value-of select="$type"/>
                        <br/>dir: <xsl:value-of select="$dir" />

                        <xsl:if test="not(@type = 'tags')">
                            <br/>limit: <xsl:value-of select="$limit"/>
                        </xsl:if>

                        <xsl:if test="$type='related'">
                            <br/>tag(s): <xsl:value-of select="$tags"/>
                            <br/>links to this page excluded.
                            <!-- <br/>link: <xsl:value-of select="$current-post-link" /> -->
                        </xsl:if>

                    </p>

                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="@type = 'featured'">
                        <p>Featured Posts:</p>
                    </xsl:when>
                    <xsl:when test="@type = 'tags'">
                        <p>Available Tags:</p>
                    </xsl:when>
                    <xsl:when test="@type = 'related'">
                        <p>Related Posts:</p>
                    </xsl:when>
                    <xsl:otherwise>
                        <p>Recent Posts:</p>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text disable-output-escaping="yes">&lt;%</xsl:text>
                <xsl:choose>
                    <xsl:when test="@type = 'featured'">
                        Response.Write(OUC.Blog.DisplayFeaturedPosts("<xsl:value-of select="$dir" />", "<xsl:value-of select="$limit" />"));
                    </xsl:when>
                    <xsl:when test="@type = 'tags'">
                        Response.Write(OUC.Blog.DisplayAvailableTags("<xsl:value-of select="$dir" />"));
                    </xsl:when>
                    <xsl:when test="@type = 'related'">
                        Response.Write(OUC.Blog.DisplayRelatedPosts("<xsl:value-of select="$dir" />", "<xsl:value-of select="$current-post-link" />", "<xsl:value-of select="$tags" />", "<xsl:value-of select="$limit" />"));
                    </xsl:when>
                    <xsl:otherwise>
                        Response.Write(OUC.Blog.DisplayRecentPosts("<xsl:value-of select="$dir" />", "<xsl:value-of select="$limit" />"));
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text disable-output-escaping="yes">%&gt;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </div>
</xsl:template>

</xsl:stylesheet>
