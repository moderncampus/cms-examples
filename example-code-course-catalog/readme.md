***The included source code, service and information is provided as is, and OmniUpdate makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of OU Campus.***

# Course Catalog

## Initial Setup

The course catalog skeleton is designed to be compatible with the implementation skeleton. It requires a developer familiar with XSL and XSL:FO to implement this package effectively. 

Notes

- Turn OFF BM.
- Use Page Relative Links for all files Except current/_config.pcf and /_resources/*

Instructions

- Download and upload implementation skeleton files.
- Download and upload course catalog skeleton files. 
- Publish current/_data and current/_config.pcf 

Note, if adding a catalog to an existing project that follows closely with the existing implementation skeleton, you can follow these steps:

- Download _resources directory of the current site.
- Create new site in OU Campus.
- Upload _resources directory from the old site.
- Upload course catalog skeleton.
- Publish current/_data and current/_config.pcf 
- Check PCFs for errors - most common will be differences in filenames in imported XSLs.

## Organization

The XSLs directory is split into different sections based on output type.

### Shared (catalog/_shared)

- properties-preview.xsl (friendly display for various file types with no output, only page parameters)
- variables.xsl (global variables for the course catalog)

### Web (catalog/web)

These XSLs import main website XSLs whenever possible. These files should exist one folder above /_resources/xsl/catalog.

- common.xsl  (imports main website XSLs and shared template matches for web output)
- courses-by-subject.xsl (display courses from specific subject based on subject id, eg. 'ACC')
- courses-index.xsl (displays all subjects with link to that subject's page)
- interior.xsl (generic page)

### PDF (catalog/pdf)

For "/pdf/", there are several utility XSL files that: read user input data for PDF content, and define transformations between html and xml to xsl:fo.

-	common.xsl (global xsl:fo templates)
-	courses-by-subject.xsl (display courses from specific subject based on subject id, eg. 'ACC')
-	courses-index.xsl (displays all courses from all subjects)
-	full-pdf.xsl (outer pdf structure for full pdf, table of contents, and transformations for regulatory pages and course pages)
-	full-xml.xsl (creates xml based off of the selected regulatory pages/directories)
-	full-xml-preview.xsl (stylesheet for user to preview generated XML)
-	regulatory.xsl (pdf output for individual regulatory pcfs)

### PDF _shared
-	html-to-xslfo.xsl (transforms html in regulatory pages to xsl:fo)
-	functions.xsl (functions used by pdf utility xsls)
-	style.xsl (font, color, etc. attributes for formatting)
