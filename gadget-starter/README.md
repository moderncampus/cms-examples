# gadget-starter

A skeleton for creating Gadgets for the [OU Campus™ web content management system](http://www.omniupdate.com).

## Creating and Installing Gadgets

Refer to the [OmniUpdate Support documentation](https://support.omniupdate.com/learn-ou-campus/administration/setup/gadgets.html#addingcustomgadgets) for instructions on how to create and install custom Gadgets.

## Resources

Check out the [OU Campus LMS](https://lms.omniupdate.com) for API documentation and an activity guide on how to create Gadgets.

Want to discuss your Gadget idea, get some help with your code, or share your new Gadget with other OU Campus users? Head over to the [Gadgets forum](https://ocn.omniupdate.com/forums/19/gadgets) in the OmniUpdate Community Network to discuss all things Gadget related.

# Table of Contents
- Configuring the Config.xml
      - [Keys](#keys)
      - [Private](#private)
      - [Overwritable](#overwritable)
      - [Type](#type)
- [Gadget Events](#gadget-events)
- [Metadata API](#metadata-api)
      - [Create](#create)
      - [Read](#read)
      - [Update](#update)
      - [Delete](#delete)
      - [Link/Un-link](#link-and-un-link)


## Configuring the Config.xml
The configuration file named config.xml, must be in the root directory of the gadget. The config.xml file contains key/value pairs for various attributes that describe the gadget to OU Campus and, optionally, create persistent variables for the gadget's own use. This file contains a root node named ``<config>`` whose children are ``<entry>`` nodes. Entry nodes can contain several attributes such as ``key``,``type``, ``private``, ``overwritable``, and ``label``.

### Keys
>#### **``title``**
>
>The title that appears in the gadget’s title bar.
>
>
```xml
<entry key="title" label="Title">Gadget Starter</entry>
```

>#### **``icon``**
>
>The URL of an icon image or a class name of a system [icon](http://a.cmsrc.omniupdate.com/resources/icomoon/)
>
>
```xml
<entry key="icon" private="true">http://commons.omniupdate.com/favicon.ico</entry>
```
>
>OR
>
>
```xml
<entry key="icon" private="true">icon-image</entry>
```

>#### **``description``**
>
>The description that appears in the gadget chooser.
>
>
```xml
<entry key="description" private="true">What my gadget does.</entry>
```

>#### **``thumbnail``**
>
>The URL of a thumbnail image to appear in the gadget chooser.
>
>
```xml
<entry key="thumbnail" private="true">http://fakeimg.pl/96/</entry>
```

>#### **``types``**
>
>Current supported types are “dashboard” and “sidebar”. If you want your gadget to appear in both places enter “dashboard, sidebar”.
>
>
```xml
<entry key="types" private="true">dashboard, sidebar</entry>
```

>#### **``sidebar_context``**
>
>For sidebar gadgets only, specifies which view context this gadget should be visible.  Enter one or more view context separated by commas.
>
>
```xml
<entry key="sidebar_context" private="true">edit,page</entry>
```
>
>| Value | Visibility          |
>| ------------- 	 | ----------- |
>| edit      	 	 | legacy wysiwyg, source editor, and JustEdit|
>| justedit      	 | JustEdit     |
>| page     	 	 | Any page view (preview, edit, source, parameters, logs, versions)     |
>| page-params   	 | Page Parameters view   |
>| asset     	     | Any asset view (preview, edit,logs, versions, submissions)     |
>| file     	 	 | Any Asset or Page view     |
>| page-edit-preview | Page Edit preview     |
>| asset-edit        | Asset Edit preview     |
>| page-preview      | Page preview    |
>| legacy-wysiwyg    | Legacy WYSIWYG (not JustEdit)   |
>| source-edit  	 | Source editor   |
>| asset-preview     | Asset preview  |

>#### **``notifications``**
>
>This entry, if present, causes OU Campus to forward notifications of the specified type(s) to the gadget, which allows you to create a Javascript event listener to listen for these events. Enter one or more notification types separated by commas. Refer to the **Gadget Events** section below to see the system defined gadget events that are natively accessible without this entry.
>
>
```xml
<entry key="notifications" private="true">message</entry>
```
>| Event Name 		  | Triggered On          |
>| ------------- 	  | ----------- |
>| message            | Inbox message received, workflow message received|
>| workflow     	  | Workflow request recieved     |
>| activity     	  | Page actions (publish, copy, move, revert), user created, group created,      |
>| linkcheck    	  | Link check finished     |
>| publish      	  | After a page is renamed, after a page is moved     |
>| scan               | After site scan has completed, after directory scan has completed     |
>| revert             | After site revert    |
>| general            | Page recycled  |
>| rename       	  | Page rename  |
>| move               | Page moved   |
>| copy         	  | Page copied |
>| params-save  	  | Page Properties saved |
>| zipimport    	  | Zip uploaded |
>| wysiwyg-selection  | When content selection occurs in the WYSIWYG (Legacy WYSIWYG/ JustEdit) |

>#### **``columns``**
>
>For dashboard gadgets only. Determines the width of the gadget in columns. Can be 1, 2, or 3.
>
>
```xml
<entry key="columns" private="true">1</entry>
```

>#### **``initial_height``**
>
>For sidebar gadgets only. Determines the initial height of the gadget in pixels.
>
>
```xml
<entry key="initial_height" private="true">290</entry>
```

>#### **``admin_only``**
>
>This entry sets the starting access setting of a gadget to be Admin only. The access can be changed subsequently in the Gadget Management screen.
>
>
```xml
<entry key="admin_only" private="true">true</entry>
```

>#### **``auto_enable``**
>
>This defaults the gadget Display Option to “Default On”
>
>
```xml
<entry key="auto_enable" private="true">true</entry>
```

>#### **``force_enable``**
>
>This defaults the gadget Display Option to “Always On”.
>
>
```xml
<entry key="force_enable" private="true">true</entry>
```

>#### **``CUSTOM_VALUE``**
>
>Custom entries are for the gadget’s internal use only, and they allow you to set persistant "global" variables. You can add as many custom entries as you wish. 
>
>
```xml
<entry key="font_size" label="Font Size" overwritable="true">14px</entry>
```


### Private
>#### **``true/false``**
>
>This property will not be exposed in the config object or used in the user-accessible configuration modal. If omitted or set to false, the entry will be accessible in the Gadget Management edit configuration modal.
>
>
```xml
<entry key="notifications" private="true">message</entry>
```


### Overwritable
>#### **``true/false``**
>
>The property will be exposed in the gadgets user-accessible configuration modal. If false, or absent the property will only be exposed in the Gadget Management edit configuration modal. If the private attribute is set to true then this property is ignored.
>
>
```xml
<entry key="font_size" label="Font Size" overwritable="true">14px</entry>
```


### Type
>#### **``radio, checkbox, select``**
>
>This is used to specifiy the element type for the Gadget configuration modal. If the Entry does not contain the private=”true” attribute this will display in the user-accessible configuration modal. The value of the entry must be a JSON object structured as follows:
```javascript
{ 
 "list" : [
       { "key" : "blue", "selected" : "false"},
       { "key" : "green", "selected" : "false"},
       { "key" : "red", "selected" : "true"}
 ]
};
```
>
>
```xml
 <entry key="color_options" type="radio" label="Choose a color." private="false">
      {"list":[{ "key":"blue"},{"key": "red"},{"key": "orange"}]}
 </entry>
```

>#### **``textarea``**
>
>This is used to specifiy the element type for the Gadget configuration modal. If the Entry does not contain the private=”true” attribute this will display in the user-accessible configuration modal. The value of the entry must be a JSON object structured as follows:
>
>
```xml
<entry key="default_text" type="textarea" label="Starting text" private="false">
     This is textarea content
</entry>
```


### Label
>#### **``label="Your label"``**
>
>This specifies the label that should be used for and entry with a “type” attribute.
>
>
```xml
<entry key="default_text" type="textarea" label="Starting text" private="false">
     This is textarea content
</entry>
```

### Misc.

To show help text for modal elements add a key that has the same name with a trailing "__help"

```xml
<entry key="font_size" label="Font Size" overwritable="true">14px</entry>
<entry key="font_size__help">This is the help text for the Font Size element.</entry>
```

If an entry with a ``type`` attribute contains an ``overwritable="true"`` and ``private="false"`` or  no ``private`` attribute or no ``overwritable`` attribute it will show in the configuration modals.

Not specifying the ``private`` attribute defaults to ``false``

## Gadget Events

The events listed below are system events that the gadget library automatically passes on to the gadget without any nessacary setup. To listen for these events, setup a Javascript event listener with the following event names.

>| Event Name | Triggered On          |
>| ------------- | ----------- |
>| expand      | Triggered when the gadget is opened|
>| collapse     | Triggered when the gadget is closed  |
>| configuration     | Triggered when the gadget configuration has been changed in OU Campus.  |
>| view_changed     | Triggered when navigating to different views. |


## Metadata API

The Metadata API library, which comes packaged in the gadgetlib.js, provides a CRUD interface for gadgets to store their own persistant data, as well has share data between gadgets. Data is stored and accessed via a custom Mime Type naming convention, and relationships between specific OU Campus data models (pages, assets, sites, and users) can be created.

### **Create**
**Endpoint** : ``/metadata/new``  
**gadgetlib method** : ``gadget.Metadata.create()``

**Params**: 
- **mime_type** - the unique identifier, think of this as a database name.
- **metadata** - the content you wish to save.
- **scope** - ``private`` or ``public``, if set to private, when this metadata is read again, only the user who created it will have access to it. This parameter is optional and defualts to ``private`` if not specified.
- **groups** - A comma separated list of group names that have access to view this metadata, this parameter is optional and defaults to ``Everyone`` if no groups are specified.
- **success** - The success callback. This is optional, and can be chained after the ``Metadata`` function is called if you wish, as the ``Metadata`` function returns a jQuery jqXHR object. 
- **error** - The error callback. This is optional, and can be chained after the ``Metadata`` function is called if you wish, as the ``Metadata`` function returns a jQuery jqXHR object. 
 
**Example**:
```javascript
    YOUR_MIME_TYPE = 'unique_identifier/json';
    gadget.Metadata.create({
         mime_type : YOUR_MIME_TYPE,
         metadata  : JSON.stringify({}),
         scope     : 'private', //optional defaults to private
         groups    : 'admins', //optional, list of group names
    },{
         success   : successFn,
         error     : errorFn
    });
 ```
 
**Returns**:
 ``id`` of the newly created metadata.
 
 
### **Read**
**Endpoint** : ``/metadata/list``  
**gadgetlib method** : ``gadget.Metadata.list()``

**Params**: 
- **mime_type** - the unique identifier, think of this as a database name.
- **item** - This is an optional alternative to mime_type, and allows you to list the metadata attached to a specific data model (page, asset, directory, site). The value should be either an asset id, page path, directory path, or site name.
- **item_type** - Specify, ``asset``, ``page ``, ``directory``, or ``site``. This is required if the ``item`` param is provided.
- **success** - The success callback. This is optional, and can be chained after the ``Metadata`` function is called if you wish, as the ``Metadata`` function returns a jQuery jqXHR object. 
- **error** - The error callback. This is optional, and can be chained after the ``Metadata`` function is called if you wish, as the ``Metadata`` function returns a jQuery jqXHR object. 
 
**Example**:
```javascript
    YOUR_MIME_TYPE = 'unique_identifier/json';
    gadget.Metadata.list({
         mime_type : YOUR_MIME_TYPE,
         item      : '/index.pcf', //optional alternative to mime_type, 
                                   //name of a site, page / directory path, id of asset
         item_type : 'page' //required if 'item' is provided.
    },{
         success   : successFn,
         error     : errorFn
    });
 ```
 
**Returns**:
 An array of metadata objects structured like this:
 ```javascript
  [{
    id : 1,
    metadata : 'content of metadata',
    account  : OU_Campus_Account,
    user     : {}, //user object who created the metadata
    scope    : 0, //0 for private, 2 for public
    created  : "2015-12-15T19:20:03Z",
    modifed  : "2015-12-15T19:30:01Z", //last save / update date or null
    groups   : {}
    
  },
  ...
  ]
 ```
 
**Endpoint** : ``/metadata/view``  
**gadgetlib method** : ``gadget.Metadata.view()``

**Params**: 
- **mime_type** - the unique identifier, think of this as a database name.
- **id** - The ``id`` of the metadata you would like to retrieve. Generally recieved when creating or listing metadata for a given mime type or after creating a new metadata.
``Metadata`` function returns a jQuery jqXHR object. 
- **error** - The error callback. This is optional, and can be chained after the ``Metadata`` function is called if you wish, as the ``Metadata`` function returns a jQuery jqXHR object. 
 
**Example**:
```javascript
    YOUR_MIME_TYPE = 'unique_identifier/json';
    gadget.Metadata.view({
         mime_type : YOUR_MIME_TYPE,
         id        : 123 //id of the metadata to retrieve
    },{
         success   : successFn,
         error     : errorFn
    });
 ```
 
**Returns**:
 ```javascript
  {
    id : 1,
    metadata : 'content of metadata',
    account  : OU_Campus_Account,
    user     : {}, //user object who created the metadata
    scope    : 0, //0 for private, 2 for public
    created  : "2015-12-15T19:20:03Z",
    modifed  : "2015-12-15T19:30:01Z", //last save / update date or null
    groups   : {},
    //...Additonal details depending on if the metadata has been linked to an OU Campus data model.
  }
 ```
 
 
### **Update**
**Endpoint** : ``/metadata/save``  
**gadgetlib method** : ``gadget.Metadata.update()``

**Params**: 
- **mime_type** - the unique identifier, think of this as a database name.
- **id** - The id of the metadata content you wish to update. Generally recieved when creating or listing metadata for a given mime type or after creating a new metadata.
- **metadata** - the content you wish to save.
- **scope** - ``private`` or ``public``, if set to private, when this metadata is read again, only the user who created it will have access to it. This parameter is optional and defualts to ``private`` if not specified.
- **success** - The success callback. This is optional, and can be chained after the ``Metadata`` function is called if you wish, as the ``Metadata`` function returns a jQuery jqXHR object. 
- **error** - The error callback. This is optional, and can be chained after the ``Metadata`` function is called if you wish, as the ``Metadata`` function returns a jQuery jqXHR object. 
 
**Example**:
```javascript
    YOUR_MIME_TYPE = 'unique_identifier/json';
    gadget.Metadata.update({
         action    : 'update',
         mime_type : YOUR_MIME_TYPE,
         id        : METADATA_ID,
         metadata  : JSON.stringify({}),
         scope     : 'private' //optional defaults to private
    },{
         success   : successFn,
         error     : errorFn
    });
 ```
 
**Returns**:
 ``id`` of the newly updated metadata.
 
### **Delete**
**Endpoint** : ``/metadata/delete``  
**gadgetlib method** : ``gadget.Metadata.delete()``

**Params**: 
- **mime_type** - the unique identifier, think of this as a database name.
- **id** - The id of the metadata content you wish to delete. Generally recieved when creating or listing metadata for a given mime type or after creating a new metadata.
- **success** - The success callback. This is optional, and can be chained after the ``Metadata`` function is called if you wish, as the ``Metadata`` function returns a jQuery jqXHR object. 
- **error** - The error callback. This is optional, and can be chained after the ``Metadata`` function is called if you wish, as the ``Metadata`` function returns a jQuery jqXHR object. 
 
**Example**:
```javascript
    YOUR_MIME_TYPE = 'unique_identifier/json';
    gadget.Metadata.delete({
         mime_type : YOUR_MIME_TYPE,
         id        : METADATA_ID
      },{
         success   : successFn,
         error     : errorFn
    });
 ```
 
**Returns**:
 ``id`` of the successfully deleted metadata.
 
 
### **Link** and **Un-link**

Link creates a relationship between a metadatum and an OU Campus data model (page, asset, directory, or site). Un-link, as you may have guessed removes this relationship. Link should be always be called after the ID is returned from a /new call, or else the metadatum will be "orphaned", and only visible via mime type lookups.

**Endpoint** : ``/metadata/assetlink`` 
**Endpoint** : ``/metadata/pagelink``  
**Endpoint** : ``/metadata/directorylink``  
**Endpoint** : ``/metadata/sitelink``  
**Endpoint** : ``/metadata/assetunlink`` 
**Endpoint** : ``/metadata/pageunlink``  
**Endpoint** : ``/metadata/directoryunlink``  
**Endpoint** : ``/metadata/siteunlink``  
**gadgetlib method** : ``gadget.Metadata.link() or gadget.Metadata.unlink()``

**Params**: 
- **link_type** - This specifies what type of data model we are linking to. The values can be one of the following :
                      - ``page`` if you are linking a metadata to a page. 
                      - ``asset`` if you are linking a metadata to an asset.
                      - ``directory`` if you are linking a metadata to an directory.
                      - ``site`` if you are linking a metadta to a site.
- **mime_type** - the unique identifier, think of this as a database name.
- **id** - The id of the metadata content you wish to delete. Generally recieved when creating or listing metadata for a given mime type or after creating a new metadata.
- **item** - This specifies the path or id of the OU Campus data model you would like the metadata to be 'attached' to. Based on the ``link_type`` used the values are the following:
                    - If the ``page`` link_type is used, provide a page path.
                    - If the ``asset`` link_type is used provide an asset id.
                    - If the ``directory`` link_type is used provide a directory path.
                    - If the ``site`` link_type is used provide a site name.
- **success** - The success callback. This is optional, and can be chained after the ``Metadata`` function is called if you wish, as the ``Metadata`` function returns a jQuery jqXHR object. 
- **error** - The error callback. This is optional, and can be chained after the ``Metadata`` function is called if you wish, as the ``Metadata`` function returns a jQuery jqXHR object. 
 
**Example**:
```javascript
    YOUR_MIME_TYPE = 'unique_identifier/json';
    gadget.Metadata.link({
         link_type : LINK_TYPE, //LINK_TYPE can be 'asset', 'page', 'directory', or 'site'
         mime_type : YOUR_MIME_TYPE,
         id        : METADATA_ID,
         item      : ITEM //ITEM is an asset id, page path, directory path, or site name
      },{
         success   : successFn,
         error     : errorFn
    });
 ```
 
**Returns**:
Sucess or Failure.

 
 
