***The included source code, service, and the information is provided as is, and Modern Campus makes no promises or guarantees about its use or misuse. The source code provided is recommended for all users and may not be compatible with all implementations of Omni CMS.***
# Single PDF output
This repository provides XSL containing how to make a PCF file have a secondary output of PDF. This all exists in the folder `single-pdf-output`.
## single-pdf.pcf
- Contains the page parameters for adding meta data to the PDF, changing the column count and other options.
## xsl folder
- Contains an example web output, along with an example of a single PDF output
- The PDF xsl exists in the pdf folder
## PDF xsl
- `html-to-xslfo.xsl`: contains the template matches to convert WYSIWYG content into XSL-FO
- `pdf-output.xsl`: contains the structure of the PDF including the header/footer and the document root `<fo:root>`
- `style.xsl`: contains the PDF styling xsl:attribute-sets for color, margin, font-sizes, etc..
## How to use the code
1. Zip and upload the `single-pdf-output` folder into a test location in your site to see how everything functions, as this package is stand-alone from any other code in your implementation.
2. After you are comfortable understanding the code, copy the PDF xsl to a pdf folder where your current XSL exists. You might need some of the variables inside of`/single-pdf-output/xsl/_shared/variables.xsl` depending on your implementation.
3. Copy a current PCF file from your implementation you would like to have PDF output on. Add the following two alternate outputs in the source code of the page and adjust the outputs:
	```
	<?pcf-stylesheet path="/_resources/xsl/pdf/pdf-output.xsl" title="PDF" extension="pdf" alternate="yes" publish="yes" ?>
	<?pcf-stylesheet path="/_resources/xsl/pdf/pdf-output.xsl" title="FO XML" extension=".fo.xml" alternate="yes" publish="no" ?>
	```
4. Adjust the `pdf-output.xsl`, `style.xsl` and `html-to-xslfo.xsl` to match your desired styling/structure for the PDF
5. To allow the user to specify content to be excluded from the PDF output but appear on the web version, add `.ou-exclude-from-pdf Exclude from PDF block` to the styles dropdown file.
## Helpful Tips
- XSL-FO has a very strict syntax. Even though it looks like regular XML, certain nodes have to exist as children or parents of other nodes. Errors will occur if you do not follow the XSL-FO syntax.
- When working with XSL-FO, you must only use the fo namespace nodes. You can also create custom fo nodes if needed.
- To debug the XSL-FO structure, you can use the `.fo.xml` output in your pcf-stylesheet declaration to see the structure of the XSL-FO of what is being sent to Omni CMS to create the actual PDF output.