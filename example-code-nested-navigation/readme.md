***The included source code, service and information is provided as is, and OmniUpdate makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of OU Campus.***

# Nested Navigation

## Planning Your Navigation

Navigation is easy to visualize, but much harder to really define when it comes down to creating a standard to work across all pages in a site, particularly when it comes to a nested navigation. There are many questions that need answering before a navigation can be implemented. Some of these important questions to address before beginning are:

- What will the navigation look like when I am 3 levels down on an interior page? At an interior page at the top level? On a section's index page? 
- Will the navigation only nest the navigation for the section a page is in and those pages above?
- Will all children pages be nested at all levels and use a mechanism like accordions or fly-outs to give more of a mega-menu view for the sidebar? 
- How many levels of nesting should be allowed? 
- At what level will the nesting begin at? Will the navigation always nest starting at the root level? Will it nest from a major section of the site? Will it always nest a certain number of levels from the current page? 
- Will the nesting behave differently when on an index page? 

## Contents

This package contains multiple scripts that allow for different types of nested navigation. There are two server side scripts using C# and PHP that were developed with a "top-down" approach, meaning that all possible nestings occur for all navigations from a given directory, with an option to set the maximum number of levels that will display. The other version, using XSL + JS, uses a "bottom-up" approach, where the current directory and its ancestors are nested only, ignoring other directories. This is typically the simplest type of nesting, as it only nests those directories that are relevant to the location any given page is located in, but as such it also loses some of the flexibility of the server side scripts, which can also be modified to simulate the same output. 

To begin, identify which version of the nested navigation you will use and begin by uploading only the contents of the appropriate folder. 
