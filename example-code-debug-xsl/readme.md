***The included source code, service and information is provided as is, and Modern Campus makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of Omni CMS.***

# Debug XSL

The `debug.xsl` code here provides for variable reference, testing, & debugging. It is not intended for all end users but rather source editors and xsl developers. By referencing this XSL as an alternate stylesheet, you can have easy access to Directory Variable values and other common variables for a given page. 

## Example

Add the following pcf-stylesheet declaration to any PCF you would like to have this capability on:

```
<?pcf-stylesheet path="/_resources/xsl/debug.xsl" title="Variable Debug" extension=".debug.html" publish="no" alternate="yes"?>
```

Once added, simply click `Preview` on the PCF and then click the dropdown to select the "Variable Debug" output. You should then see a page full of the globally available variables that have been specified in `debug.xsl` and their specific values for the given page. 

### Dependencies

This code references `common.xsl`, which is assumed to call the required file `variables.xsl`. These XSLs are typically included for an implementation and a sample of `variables.xsl` is also included in this package. 
