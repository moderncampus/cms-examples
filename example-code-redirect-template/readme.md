***The included source code, service and information is provided as is, and Modern Campus makes no promises or guarantees about its use or misuse. The source code provided is recommended for advanced users and may not be compatible with all implementations of Omni CMS.***

# Redirect Template

This is an Omni CMS template (TCF, TMPL, Image) that creates a simple meta redirect page. This allows you to create a "page" in a folder named `/rd` that will effectively become a short URL that points to the full page. 

## PHP Redirect

This package includes a `/php-redirect` folder that contains an alternative redirect option, allowing the user to create a page in one location that publishes a PHP redirect pointing to another specified location through the use of the PHP `header` function. This templateuses a PCF page transformed by XSL code to make the redirect location easily editable. The XSL could also be modified by a web developer to output different types of redirects. 