***The included source code, service and information is provided as is, and OmniUpdate makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of OU Campus.***

# LDP Galleries

> LDP Galleries Version: 1.0.1
> 
> Library Requirements: jQuery 1.7+

When a user adds an LDP gallery to a page, the page is populated with XML information beginning with a node titled `gallery`. This node will contain all the information about the pictures within the gallery, which includes, URL, Caption, Title, Description, Thumbnail URL, Thumbnail Size (width and height).
In version 10, 'link' is also introduced, which is used to make an image in a slider link to another web page. In previous implementations, the 'caption'  was used for this instead.

Some gallery types may not support certain fields, and that is okay. However, the usage of title, description, caption, and link must stay consistent across all gallery types when the fields are used.

- **title**: The `title` attribute in the `img` tag.
- **description** The `alt` attribute in the `img` tag.
- **caption**: A caption for galleries that support captions.
- **link**: A link for galleries that support links.

Shown below is an example of the XML that is output to the page, with extra information omitted.

```
<gallery asset_id="4800" ... >

    ...
    
    <images>
       
        <image ... url="http://cspooner.oudemo.com/v10/ldpgalleries/.private_ldp/a4800/staging/master/01ffeac5-3c93-4935-a847-f29f83836fb7.jpg" ...>
            ... 
            <thumbnail ... url="http://cspooner.oudemo.com/v10/ldpgalleries/.private_ldp/a4800/staging/thumb/01ffeac5-3c93-4935-a847-f29f83836fb7.jpg">
                <width>100</width>
                <height>100</height>
            </thumbnail>
            <title>test</title>
            <description>test</description>
            <caption>test</caption>
            <link>http://www.google.com</link>
        </image>
        
        <image ... url="http://cspooner.oudemo.com/v10/ldpgalleries/.private_ldp/a4800/staging/master/6d9a48b0-347d-4fd1-95d0-fc4d077418c9.jpg" ...>
            ...
            <thumbnail ... url="http://cspooner.oudemo.com/v10/ldpgalleries/.private_ldp/a4800/staging/thumb/6d9a48b0-347d-4fd1-95d0-fc4d077418c9.jpg">
                <width>100</width>
                <height>100</height>
            </thumbnail>
            <title>test2</title>
            <description>test2</description>
            <caption>test2</caption>
            <link>http://www.google.com</link>
        </image>

    </images>

</gallery>
```

## PCF and TMPL Files

For most implementations, the user will be able to select a gallery type in Page Properties. This gallery type will apply for all gallery assets on the page. However, a user could add the same asset on another page with a different type selected.

```
<parameter section="LDP Gallery" name="gallery-type" type="select" group="Everyone" prompt="Gallery Type" alt="Select the output type for gallery assets on this page.">
    <option value="slick" selected="true">Carousel Gallery</option>
    <option value="fancybox" selected="false">Popup Gallery</option>
</parameter>
```

## galleries.xsl

> DO NOT MODIFY THIS FILE
> 
> This file may be overwritten with updates and bug fixes in the future.

The template matches in galleries.xsl will then match the gallery node and, depending on the type selected by the user, apply a different transformation. Note that the parameter `gallery-type` is the value of the selected page property. If you do not have the `ou:pcf-params` function, simply redefine this parameter to the xpath of the selected option. There are two gallery types defined by default: fancybox and slick. To create additional gallery types, modify another XSL file.

```
<xsl:param name="gallery-type" select="if (normalize-space(ou:pcf-param('gallery-type'))) then ou:pcf-param('gallery-type') else 'fancybox'" />
<xsl:template match="gallery[$gallery-type = 'fancybox']"> ... </xsl:template>
<xsl:template match="gallery[$gallery-type = 'slick']"> ... </xsl:template>
```


Additionally the `gallery-headcode` and `gallery-footcode` templates are used by common.xsl to copy any needed resource files. If an implementation has a custom gallery type, it is not usually necessary to add it to this function as the resource scripts are usually already part of the design templates.

Note the use of {$domain}. This can be used to define the url if the staging root is different than the production.

```
<xsl:template name="gallery-headcode">
    <xsl:param name="gallery-type" select="$gallery-type"/>
    <xsl:param name="domain" select="$domain"/>
    ...
</xsl:template>
```

```
<xsl:template name="gallery-footcode">
    <xsl:param name="gallery-type" select="$gallery-type"/>
    <xsl:param name="domain" select="$domain"/>
    ...
</xsl:template>
```

## common.xsl

In common.xsl, you will want to import the gallery.xsl and call the gallery headcode and footcode templates. This is usually done within the common-headcode and common-footcode templates. Ensure that the footcode is called after jquery is loaded on the page. Include them as follows:

```
<xsl:import href="_shared/galleries.xsl"/>
```

```
<xsl:call-template name="gallery-headcode"/>
```

```
<xsl:call-template name="gallery-footcode"/>
```

## Uploading the Resource Files

Simply upload the `active.zip` file via the Import Zip File function in OU Campus. All css, js, and xsl files will be uploaded into the standard locations.

## Troubleshooting

### Undefined jQuery Function

Sometimes when newer versions of jQuery are introduced, the functions used by the gallery javaScript no longer exist. If that is the case, then jQuery migrate can be added, which will contain the missing functions.

    <script src="http://code.jquery.com/jquery-migrate-1.1.0.min.js"></script>

### Conflicts with jQuery and other JavaScript libraries

If there is a conflict between jQuery and another library, noConflict mode can be used. See http://learn.jquery.com/using-jquery-core/avoid-conflicts-other-libraries/ for more information.

