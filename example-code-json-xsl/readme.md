***The included source code, service, and the information is provided as is, and OmniUpdate makes no promises or guarantees about its use or misuse. The source code provided is recommended for all users and may not be compatible with all implementations of OU Campus.***

# Outputting PCF as JSON with XSL

This repository provides an XSL file containing a list of catch-all template matches for converting a PCF file into JSON.

## Sample PCF

1. Zip up the `xsl` folder and `sample.pcf` file.
2. Import into OU Campus root. *It is recommended that you do this in an empty sandbox site*
3. View the `sample.pcf` in Preview
4. Toggle the output dropdown option to JSON to view the JSON view.
5. Publish the page to see the JSON output of the PCF document.

## How to Use in Your Code

1. Upload the `xsl-map-templates.xsl` file to where your xsl files are stored.
2. Modify the template to meet your needs (or use as is).
3. Upload the provided `sample-json.xsl` file or create a new xsl file similar to the sample file.
4. Add a new pcf-stylesheet line in the desired PCF file under your default web output. See example below.
```
<?xml version="1.0" encoding="UTF-8"?>
<?pcf-stylesheet path="/xsl/sample-web.xsl" title="Web Page Output" extension="html"?>
<?pcf-stylesheet path="/xsl/sample-json.xsl" title="JSON Output" extension="json" alternate="yes"?>
```
5. Preview and publish.
