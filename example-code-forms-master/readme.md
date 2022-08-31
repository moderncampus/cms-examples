***The included source code, service and information is provided as is, and Modern Campus makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of Omni CMS.***

# LDP Installation

## Configuring PHP LDP Forms
The LDP Forms consist of two parts the connector scripts (specific to a language) and the SSM. 
The connector scripts can be found in the `/SSM Connectors` folder within this package. Other necessary files are located under the `/Forms` folder. 
Before uploading the forms, the following files must be configured.

### Before Installing
Note: If you're installing PHP LDP Forms, please ensure that the production server has both json_encode and xmlrpc_encode enabled/configured for their PHP installation. Note that PHP v5.1.6 and below do not have
json_encode on by default when they are compiled (this was added in v5.2.0+). To save yourself some time (and headache), make sure that these are setup before you begin installation.

### config.php

Within config.php find the following line of code: 

`$_ENV['ldp_config']['site_uuid']`

Set this array field equal to the site's UUID. The UUID can be found within a Site's Setup, under the following menus `Setup->Site->Edit Site`

`/utils/config_default.php`

Within the /utils/config_default.php file find the following line of code:

  `$_ENV['ldp_config']['ssm_host'] = ' ';`

If the SSM is installed on the same machine, you should, for the most part, be okay setting this equal to `http://127.0.0.1`
The final line should be:

`$_ENV['ldp_config']['ssm_host'] = 'http://127.0.0.1';`

After configuring the files, upload them to `/_resources/php/ldp`


## Configuring ASP LDP Forms
Before editing any files, determine if the production server is using .NET 3.5 or .NET 4.0. Please note that if the server is using VB as the Codebehind language, adding in C# files will actually cause the server to crash. Please ensure that the server is in fact using C# and not VB. The setup for both connectors is identical and rather simple.

Retrieve the  correct .NET Connector from the `SSM Connectors` subfolder of this package.

Find the Site's UUID from within Omni CMS under Setup->Sites. Open the `web.config` file and find line 14.

`<add key="siteuuid" value="6f01b824-70f9-4f5d-9202-3b4ac4f79e10"/>`

Edit the value attribute of this node so that it contains the Site's UUID.

After editing the Site's UUID, upload the files to their appropriate folders. Realize that certain .NET setups may have existing Bin and App_Code folders, so you may have to place these files in the corresponding folders.
 
## Implementing Forms into the XSL
Implementing LDP forms into the XSL will require you to edit an XSL file for a corresponding template as well as the site's common.xsl

### Modifying Specific XSL Files

A good place to start would be to edit the XSL file for the page(s) forms will be placed on, since the amount of stuff you are editing is minimal. The first step is modifying the header. You will have to determine if you will be using Bootstrap's CSS for forms or a custom CSS. Simply include the CSS files that you'll be using within the header. Also, please ensure that you are using jQuery. If not, [here's a handy link](http://docs.jquery.com/Downloading_jQuery).
After including the necessary CSS files and jQuery, find the `copy-of` statement for the area that the forms will be placed in, if present. 

Modify the copy-of statement so that it appears similar to this:

`<xsl:apply-templates select="document/content/node()" />`

What we are doing is changing the `copy-of` statement to use a recursive copy template. This way the template can call appropriate templates depending on the type of nodes that it matches.

### Modifying common.xsl

Within the common.xsl you will be placing the templates for LDP Forms as well as several other functions. The first function will be the recursive copy template, which typically resides in `_shared/template-matches.xsl`. If XSL 3.0 is being used, this simply looks like the following:

```
<!-- Identity Matches -->
    <!-- The following mode will match all items except processing instructions, copies them, then processes any children. -->
    <xsl:mode on-no-match="shallow-copy" />
    <!-- match the pcf-sheet to make the editable region function -->
    <xsl:template match="processing-instruction('pcf-stylesheet')" mode="#all" />
```

If an earlier version of XSL is being used, this match can be used to accomplish the same thing: 
  
    <xsl:template match="attribute()|element()|text()|comment()">
      <xsl:copy>
        <xsl:apply-templates select="attribute()|node()"/>
      </xsl:copy>
    </xsl:template>


The recursive copy template will output nodes depending on the templates that it matches. In our case, it will match the ouforms template which is found later on within the `forms.xsl`. The ouforms template will appropriately handle the nodes for the LDP form. The ouforms template is what renders the form input elements. It uses a set of `xsl:if` statements to output the correct elements. 

Within the ouform template is an include to a javascript file, `ouforms.js` It is included using the following statement:
    
    <script type="text/javascript" src="/_resources/ldp/forms/js/ou-forms.js"></script>

Please make sure that the source attribute for this script tag is pointing to the correct location. Often times, a folder titled 'scripts' is used rather than 'js' for Javascript files.

Within the `ou-forms.js` JavaScript file, you may have to modify the following line:

    url: "/_resources/ldp/forms/php/forms.php",

So that it is pointing to your correct LDP form file. PHP LDP forms will be similar to the above line, ASP forms will usually submit to `form-submit.aspx`.

Please note the comments made on the add and remove classes commands. Make sure that you enable/disable the correct lines based on the type of forms you're using (Bootstrap vs Normal)
        
## Using Bootstrap's CSS (Optional)
First retrieve the `ou-forms.bootstrap.css` file along with the appropriate OU Forms bootstrap xsl file. Simply include the CSS file as you would any other CSS file.

### Modify Element Focus Color
A nice feature about Bootstrap's CSS for forms is the outer-glow focus that your elements receive when a user clicks on an element. The default Boostrap color is a light blue. Since this does not fit all website design colors, you will probably want to modify this so that it fits nicely with the website color scheme. To do so, do a perform a find within the `ou-forms.bootstrap.css` file and search for: 

`rgba(102, 175, 233, 0.6);`

This CSS allows you to select an RGB color and specify an opacity for the outer glow. Select a color that will match your color scheme and simply perform a find and replace.  Another nice feature of Boostrap's CSS is their buttons and alert. You can use these alert and buttons so that the form fits in nicely with the design's color scheme.

### Boostrap Error/Success Messages
Within the `ou-forms.js` file, please follow the instructions within the comments on what lines to enable/disable so that you receive the appropriate error messages. 
If you would like to customize the color of the messages you can use the different classes found within [Bootstrap's Documentation](http://twitter.github.com/bootstrap/components.html#alerts).

### Boostrap Labels

Similar to Error/Success Messages, please follow the instructions within the comments on enabling/disabling lines within the `ou-forms.js` file.
To use different label colors, you can use the classes found within [Bootstrap's Documentation](http://twitter.github.com/bootstrap/components.html#labels).

### Bootstrap Buttons
Along with colorful messages and labels, Bootstrap comes with a small set of different colored buttons, which you can find in [there documentation](http://twitter.github.com/bootstrap/base-css.html#buttons).
If these buttons do not fit your implementation (or they're just not your style), you can always [create your own](http://charliepark.org/bootstrap_buttons/).

Once you've decided on the styling of your submit button, modify the `class` attribute in the following line within the `ouform` template match:

  `<input type="submit" name="button" id="Submit" alt="Submit" class="btn btn-info" value="Submit" />`

To use the class that you have defined in your CSS. If for example, you wanted to use Bootsrap's orange button, your class would be `btn btn-warning` and your whole submit button would be:

  `<input type="submit" name="button" id="Submit" alt="Submit" class="btn btn-warning" value="Submit" />`

## Testing and Debugging LDP Forms

### Error: No success/failure messages

If you're not receiving a success/failure message, that is because the XSL for the LDP forms is missing a div with the id of 'status'. Add the following code to your XSL:

`<div id="status"></div>`

You can create and style the status div however you like. Remember that if you hide the div using  style="display: none;" you will need to remove this styling by using the jQuery command `$('#status').show();`

### Error: Multiple validation field messages
You may be experiencing an issue with multiple validation error messages. This is because the Javascript is not clearing out old messages. To fix this issue, locate the following line within the Javascript of the XSL that you're using:

`$("#status").removeClass("main-formsuccess");`

After this line, add:

`$(".formerror").remove();`

This should fix the problem with multiple error messages.

###Error: Multiple select/input fields are only showing the latest result in the database (PHP ONLY)

Within the XSL for the LDP Forms you'll see that every type of input option has an xsl:variable declaration. The select field for the field-name variable should concat the attribute name with opening and closing square brackets.  

`<xsl:variable name="field_name" select="concat(./@name, '[]')" />`

### Error: ASP Forms Cannot Find Jayrock Class

If you're having an issue where your ASP forms cannot find Jayrock class, then the supplied DLLs are not in the correct Bin folder. Placing the DLLs in the correct Bin folder will correct this error

### Error: ASP Forms Textarea is breaking database results

If you're having problems with retrieving results from the database with forms that contain textareas, it is most likely an issue to do the workaround to stop textareas from self closing. 
The way to fix this is by adding: 

`<xsl:value-of select="' '"/>` 

within the textarea nodes. This is a database safe work around.

### Error: Undefined function json_encode() (PHP ONLY)

If you're PHP forms are having an issue and are throwing out an error that json_encode is an undefined function then the production server is most likely running a version of PHP that is older than 5.2.0. JSON was not bundeled and compiled by default before PHP 5.2.0, so you will either have to enable JSON, re-compile PHP with JSON, or update to PHP 5.2.0+.

### Error: Call to undefined function xmlrpc_encode_request() (PHP ONLY)

If you're receiving this error using PHP forms it means that the production server does not have the XMLRPC extension installed/enabled. Your best bet is to have your IT team reconfigure PHP so that the XMLRPC extension is installed/enabled.

### Error: Multiple select/input fields are not showing any results in the database (ASP)

If you're having problems with multiple select and input fields, ensure that these fields do not contain square brackets within their names in your ouforms template. Unlike PHP, ASP does not like square brackets in names of elements to group them as an array.


### Advanced Styling
Predefined Attributes:

 * Legends To create a placeholder text inside a form. `legend=true;`
 * Adding Classes: `addclass=[CLASS NAME];` - Adds class to an element block
 * Fieldsets
    * `fieldset_start_true=true;` - defines the starting block for a fieldset
    * `fieldset_end_true=true;` - defines the ending block for a field set
    * `fieldset_label=FIELDSET LABEL;` - defines the label for a field set

* Rules
    * Every declaration in the advanced field must be terminated with a semicolon. Eg. `legend=true;addclass=form_legend;`
    * Attributes are always lowercase.


### CAPTCHA Configuration
LDP forms feature Google reCAPTCHA functionality.

##### Steps to configure:
1. Generate Google reCAPTCHA credentials by visiting https://www.google.com/recaptcha and copy the "Site Key" and "Secret Key".
2. Set the param "captcha-site-key" at the top of forms.xsl to the provided "Site Key".
3. Set the "Secret Key" 
   - PHP - Set "captcha_secret" at the top of forms.php to the provided "Secret Key".
   - C# - Set "captchaSecret" at the top of ldp-forms.ashx to the provided "Secret Key".

Now when the CAPTCHA checkbox is checked in the form asset properties it will be included with the form.
