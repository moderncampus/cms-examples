# Cookie Consent

This repository shows how you can use the Osano cookie consent library to implement a cookie consent message on your site. View the [index.html](index.html) for a working example along with some short instructions.

## Osano's cookie consent library

The sample page makes use of Osano's cookie consent javascript library. It's an MIT licensed, easy to use code with some nice configuration options.

You can visit their [download page](https://www.osano.com/cookieconsent/download/) and click "Start Coding" to open up their configuration form.

If you are interested in the cookie consent code, you can find their GitHub repository here: [Osano Cookie Consent GitHub](https://github.com/osano/cookieconsent/).

## Sample Code

### CSS

```html
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/cookieconsent@3/build/cookieconsent.min.css" />
```

### JavaScript

```html
<script src="https://cdn.jsdelivr.net/npm/cookieconsent@3/build/cookieconsent.min.js" data-cfasync="false"></script>
<script>
    window.cookieconsent.initialise({
        "palette": {
            "popup": {
                "background": "#64386b",
                "text": "#ffcdfd"
            },
            "button": {
                "background": "#f8a8ff",
                "text": "#3f0045"
            }
        },
        "theme": "edgeless"
    });
</script>
```