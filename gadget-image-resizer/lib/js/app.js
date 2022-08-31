// These are the default presets if nothing has been saved in the Metadata API yet.
var savedPresets = [
	{
		"name": "2 Images",
		"sizes": [
			{"width":1200,"suffix":"-lg"},
			{"width":400,"suffix":"-sm"}
		]
	},
	{
		"name": "3 Images",
		"sizes": [
			{"width":1200,"suffix":"-lg"},
			{"width":600,"suffix":"-md"},
			{"width":400,"suffix":"-sm"}
		]
	},
	{
		"name": "4 Images",
		"sizes": [
			{"width":1600,"suffix":"-xl"},
			{"width":1200,"suffix":"-lg"},
			{"width":600,"suffix":"-md"},
			{"width":400,"suffix":"-sm"}
		]
	}
];

var gadget = gadget || false;
var myGadget = myGadget || false;
var imagesets = [];
var imagesSelected = 0;
var imagesLoaded = 0;
var imagesProcessed = 0;
var existingImages = [];
var metadata_mime_type = 'image-resizer-gadget';
var presets = []; // This is used to store presets while changes are made in the preset manager. When the Save button is clicked they are applied to the savedPresets var.

$(document).ready(function () { // eslint-disable-line no-undef
	$('#user-message .close').on('click', function(){
		hideUserMessage();
	});

	$('#images').change(processImages);
	$('#preset-dropdown').change(processImages);

	function processImages(){
		var files = $('#images')[0].files;

		imagesSelected = files.length;
		imagesets = []; // clear any existing imagesets whenever new files are selected.
		imagesLoaded = 0;
		imagesProcessed = 0;
		$('#output').empty();
		$('#main button[type="submit"]').hide();

		//var sizes = myGadget.getImageSizes();
		var selectedPresetID = $('#preset-dropdown').val();

		if(!imagesSelected || selectedPresetID == '') return; // no files selected or no preset selected.

		var sizes = savedPresets[selectedPresetID].sizes;

		for (var i = 0; i < imagesSelected; i++) {

			(function () {
				var file = files[i];
				// console.log(file);
				var options = {
					name: file.name.replace(/\.[^/.]+$/, ''),
					fullname: file.name,
					elementId: 'output',
					sizes: sizes
				};

				var img = document.createElement('img');
				img.src = window.URL.createObjectURL(file);
				img.onload = function () {
					var imageset = new ImageSet(this, options);
					imageset.resize();
					imageset.printLinks();

					imagesets.push(imageset);
					imagesLoaded++;
					if(imagesSelected == imagesLoaded){ // all images are done loading.
						//console.log(imagesets);
						getExistingImages().done(function(){
							// mark the existing images
							$.each(existingImages, function(i, val){
								$('li[data-filename="' + val + '"]').addClass('disabled');
								$('li[data-filename="' + val + '"] span').removeClass('badge-light').addClass('badge-warning').text('File already exists');
							});

							if($('#output li:not(.disabled)').length){
								// show update button as long as at least one file eligible for upload.
								$('#main button[type="submit"]').prop('disabled', false).show();	
							}
						});

					}
				};
			})();
		}
	}

	$('#main button[type="submit"]').on('click', function(e){
		e.preventDefault();
		if (myGadget) {
			$('#main button[type="submit"]').prop('disabled', true);
			var totalImages = 0;

			for (var x = 0; x < imagesets.length; x++) {
				var imageset = imagesets[x];
				var images = imageset.getImages();
				totalImages += images.length;
			}

			for (var x = 0; x < imagesets.length; x++) {
				var imageset = imagesets[x];
				var images = imageset.getImages();

				for (var i = 0; i < images.length; i++) {
					(function () {
						var image = images[i];
						var fullpath = myGadget.getImageDir() + image.name;
						if($('li[data-filename="' + image.name + '"]').is('.disabled')){
							imagesProcessed++;
							if(imagesProcessed == totalImages) finished();
						}else{
							$('li[data-filename="' + image.name + '"] span').attr('class', 'badge badge-info').text('Uploading...');
							myGadget.uploadImage(fullpath, image.binary).done(function (response) {
								//console.log('done', response);
								//$('li[data-filename="' + image.name + '"]').attr('class', 'uploaded');
								$('li[data-filename="' + image.name + '"] span').attr('class', 'badge badge-primary').text('Publishing...');

								myGadget.publishImage(fullpath).done(function(response){
									//$('li[data-filename="' + image.name + '"]').attr('class', 'published');
									$('li[data-filename="' + image.name + '"] span').attr('class', 'badge badge-success').text('Done');
									imagesProcessed++;
									if(imagesProcessed == totalImages) finished();
								});
							}).fail(function(){
								messageUser('You don\'t have upload permissions. Contact your administrator.');
							});
						}

					})();
				}
			}
		} else {
			//gadget not ready
		}
	});

	if (gadget) {
		document.getElementsByTagName('html')[0].classList.add('gadget');
		gadget.ready().then(gadget.fetch).then(getExistingImages).then(function () {
			// console.log(gadget);

			getSavedPresets();

			var myGadget = {
				settings: {
					site: gadget.site,
					authorization_token: gadget.token
				},
				getImageDir: function() {
					return gadget.getConfig('image_dir').replace(/\/?$/, '/');
				},
				getImageSizes: function() {
					try {
						return JSON.parse(gadget.getConfig('image_sizes'));
					} catch (error) {
						//console.error(error); // TODO: add error handling for SyntaxError
						//window.alert('Your image sizes are not configured properly. This gadget won\'t work properly.');
					}
					return null; // when null is returned the default will be used.
				},
				getOverwrite: function() {
					//return gadget.getConfig('overwrite_upload');
					return false;
				},
				uploadImage: function (path, data, overwrite, output) {
					var url = gadget.apihost + '/files/image_save';
					var params = {
						site: gadget.site,
						authorization_token: gadget.token,
						path: path,
						data: data,
						overwrite: overwrite || this.getOverwrite()
					};

					// console.log({url: url, data: params});
					return $.ajax({
						method: 'post',
						url: url,
						data: params
					});
				},
				publishImage: function (path) {
					var url = gadget.apihost + '/files/publish';
					var params = {
						site: gadget.site,
						authorization_token: gadget.token,
						path: path
					};

					// console.log({url: url, data: params});
					return $.ajax({
						method: 'post',
						url: url,
						data: params
					});
				}
			};

			window.myGadget = myGadget;
		});

		$(gadget).on({
			'expanded': function (evt) {
				// This event is triggered when the user expands (makes visible) a sidebar gadget.
				// console.log('Gadget expanded.', evt);
			},
			'collapsed': function (evt) {
				// This event is triggered when the user collapses (hides) a sidebar gadget.
				// console.log('Gadget collapsed.', evt);
			},
			'configuration': function (evt, config) {
				// If the user changes the gadget's configuration through the configuration modal,
				// the gadget will hear about it and get the new config in the data argument here.
				// console.log('New config:', config);
				//$('#main').css({ 'font-size': config.font_size });
			},
			'notification': function (evt, notification) {
				// If the gadget's config.xml contains a "notification" entry, any notifications
				// of the specified type(s) generated by Omni CMS will trigger 'notification'
				// events that can be handled here.
				// console.log('Notification received:', notification);
			}
		});
	}

	function getExistingImages(){
		var url = gadget.apihost + '/files/list';
		var params = {
			site: gadget.site,
			authorization_token: gadget.token,
			path: gadget.getConfig('image_dir').replace(/\/?$/, '/') // get path and add trailing slash if missing.
		};
		return $.ajax({
			type    : 'GET',
			url     : url, 
			data    : params, 
			success : function (data) {
				existingImages = [];
				//console.log(data);
				if(data.staging_path != params.path.replace(/\/$/, '')){
					$('#input-form').hide();
					messageUser(params.path + ' does not exist. Update the gadget setting or create the folder first.');
					return;
				}else{
					$('#input-form').show();
				}

				var entries = data.entries;
				for(var i=0; i<entries.length; i++){
					if(!entries[i].is_directory){
						existingImages.push(entries[i].file_name);
						//existingImages[entries[i].file_name] = 1;
					}
				}
				//console.log(data);
			},
			error : function (xhr, status, error) {
				//console.log('Error:', status, error);
				messageUser('You don\'t have access to the upload folder! Contact your administrator.');
			}
		});
	}

	function getSavedPresets(){

		var settings = {mime_type: metadata_mime_type};

		gadget.Metadata.list(settings, {
			success: function(data){
				if(data.length){
					savedPresets = $.parseJSON(data[0].metadata); // overwrite default settings metadata value.
				}

				if(gadget.admin){
					$('#input-form .input-group-append').show();
				}else{
					$('#input-form .input-group-append').remove();	
				}

				renderPresetDropdown();

				//console.log(savedPresets);
			}
		});

	}

});

function messageUser(msg, alertType, autoHideDelay){
	if (typeof(alertType)==='undefined') alertType = 'warning'; // default alertType to 'warning' when not passed in
	if (typeof(autoHideDelay)==='undefined') autoHideDelay = 0; // default autoHideDelay to 0 when not passed in

	if(alertType == 'success'){
		$('#user-message').removeClass('alert-warning').addClass('alert-success');
		$('#user-message span.glyphicon').removeClass('glyphicon-exclamation-sign').addClass('glyphicon-ok');
	}else{
		$('#user-message').removeClass('alert-success').addClass('alert-warning');
		$('#user-message span.glyphicon').removeClass('glyphicon-ok').addClass('glyphicon-exclamation-sign');
	}

	$('#user-message .message').text(msg);
	$('#user-message').addClass('slide-up');

	if(autoHideDelay > 0){
		setTimeout(hideUserMessage, autoHideDelay);
	}
}

function hideUserMessage(){
	$('#user-message').removeClass('slide-up');
}

function finished(){
	messageUser('All images have been processed.', 'success', 5000);
}

function renderPresetList(){

	$('#list-card ul li').remove();
	var presetLength = presets.length;
	for (var i = 0; i < presetLength; i++) {
		var data = { name: presets[i].name, id: i}
		$('#list-card ul').append(compileTemplate($('#list-preset-template').html(), data));
	}

	switchDisplay('list-card');
}

function savePresets(){

	var callback = function(){
		savedPresets = presets;
		renderPresetDropdown();
		$('#preset-dropdown').trigger('change');
		switchDisplay('main');
	}

	gadget.Metadata.list({mime_type:metadata_mime_type}, {
		success: function(data){
			if(data.length){
				var metadata_id = data[0].id;
				gadget.Metadata.update({mime_type:metadata_mime_type, id: metadata_id, action: 'update', scope: 'public', metadata: JSON.stringify(presets)}, {
					success: function(){
						messageUser('Presets Saved!', 'success', 3000);
						callback();
					}
				});
			}else{
				gadget.Metadata.create({mime_type:metadata_mime_type, scope: 'public', metadata: JSON.stringify(presets)}, {
					success: function(){
						messageUser('Presets Saved!', 'success', 3000);
						callback();
					}
				});
			}
		}
	});
}

Array.prototype.clone = function() {
	return this.slice(0);
};

function switchDisplay(activeDisplay){
	$('.screen').hide();
	$('#' + activeDisplay).show();
	window.scrollTo(0,0);
}

function loadPreset(id){
	clearPresetForm();

	switchDisplay('form-card');

	if(id !== undefined){
		var preset = presets[id];
		$('#form-card .card-header').text('Edit Preset');
		$('#presetName').val(preset.name);
		$('[name="presetID"]').val(id);
		// populate preset
		$.each(preset.sizes, function (i, val){
			addPresetRow(val.width, val.suffix);
		});
	}
	addPresetRow();
}

function deletePreset(id){
	if(presets.length > 1){
		presets.splice(id, 1);
		renderPresetList();
	}else{
		messageUser('You must keep at least one preset!', 'warning', 3000);
	}
}

$(function(){

	$('body').on('keyup', '#manage-presets .form-group.row:last input', function(){
		if(!$(this).closest('.form-group.row').find('input').filter(function(){ return $(this).val() == '' }).length){
			addPresetRow(); // add another empty row
		}
	});

	$('body').on('change', '#manage-presets :input', function(){
		$(this).valid();
	});

	$('body').on('click', '#manage-presets button.clear-row', function(){
		if($(this).closest('.form-group').is(':last-of-type')){
			if($('#manage-presets .input-group').length == 1){
				messageUser('You must keep at least one size!', 'warning', 3000);
			}else if($(this).closest('.input-group').children(':text').filter(function(){return $(this).val() != ''}).length){
				messageUser('Cleared row. Empty rows will be ignored.', 'warning', 3000);
			}else{
				messageUser('Empty rows will be ignored.', 'warning', 3000);
			}
			$(this).closest('.input-group').children(':text').removeClass('invalid').val('');
		}else{
			$(this).closest('.form-group').remove();
		}
	});

	$('body').on('click', '#list-card .list-group-item[data-preset-id]', function(e){
		var id = $(this).closest('[data-preset-id]').data('preset-id');
		loadPreset(id);
		e.preventDefault();
	});

	$('body').on('click', '#list-card a.delete', function(e){
		var id = $(this).closest('[data-preset-id]').data('preset-id');
		deletePreset(id);
		e.preventDefault();
		e.stopPropagation();
	});

	$('#list-card a.add-preset').on('click', function(e){
		loadPreset();
		e.preventDefault();
	});

	$('#manage-presets button.cancel').on('click', function(){
		switchDisplay('list-card');
	});

	$('#list-card button.cancel').on('click', function(){
		switchDisplay('main');
	});

	$('#manage-presets-btn').on('click', function(){
		presets = savedPresets.clone();
		renderPresetList();
	});

	$('#list-card button.save').on('click', savePresets);

	$('#manage-presets').on('submit', function(e){
		e.preventDefault();
		var sizes = [];
		var sizeMap = {};
		var suffixMap = {};
		var presetName = trim($('#presetName').val());
		var presetID = trim($('#manage-presets [name="presetID"]').val());
		var presetNameMap = {};
		var formValid = true;

		$.each(presets, function(i, val){
			presetNameMap[val.name] = i.toString();
		});

		if(presetName === '' || (presetName in presetNameMap) && presetNameMap[presetName] !== presetID){
			$('#presetName').invalid();
			formValid = false;
		}else{
			$('#presetName').valid();
		}

		$('#manage-presets .form-group.row').each(function(){
			var $size = $(this).find('.preset-width');
			var $suffix = $(this).find('.preset-suffix');
			var size = $size.val();
			var suffix = trim($suffix.val());

			var sizeValid = (isInteger(size) && !(size in sizeMap));
			sizeMap[size] = 1;
			var suffixValid = (suffix != '' && !(suffix.toLowerCase() in suffixMap) && !(/[!#$%^&*()[\]\\/?’”|<>{};:,+=]/.test(suffix)));
			suffixMap[suffix.toLowerCase()] = 1;

			if(sizeValid && suffixValid){
				$size.valid();
				$suffix.valid();

				sizes.push({
					width: size,
					suffix: suffix
				});
			}else if(size != '' || suffix != ''){
				formValid = false;

				if(sizeValid){
					$size.valid();
				}else{
					$size.invalid();
				}

				if(suffixValid){
					$suffix.valid();
				}else{
					$suffix.invalid();
				}
			}
		});

		if(!sizes.length){
			var $width = $('#manage-presets .preset-width:first');
			var $suffix = $('#manage-presets .preset-suffix:first');

			if(!isInteger($width.val())) $width.invalid();
			if(trim($suffix.val()) == '') $suffix.invalid();

			formValid = false;
		}

		// console.log('formValid: ' + formValid);
		if(formValid){
			if(presetID === ''){
				presets.push({
					name: presetName,
					sizes: sizes
				});
			}else{
				presets[presetID] = {
					name: presetName,
					sizes: sizes
				}
			}
			renderPresetList();
		}else{
			$('input.invalid:first').focus(); // focus first element.
			scrollToMiddle($('input.invalid:first')); // scroll to first invalid element.
		}

		// console.log(presets);
	});

});

function renderPresetDropdown(){
	$('#preset-dropdown option:not(:first)').remove();
	var presetLength = savedPresets.length;
	for (var i = 0; i < presetLength; i++) {
		$('#preset-dropdown').append('<option value="' + i + '">' + savedPresets[i].name + '</option>');
	}
}

function addPresetRow(width, suffix){
	var data = {
		width: width || '',
		suffix: suffix || ''
	};

	$('#manage-presets button[type="submit"]').before(compileTemplate($('#preset-row-template').html(), data));
}

function compileTemplate(template, data){
	for(var key in data){
		template = template.replace(new RegExp('{{' + key + '}}', 'g'), data[key]);
	}
	return template;
}

function clearPresetForm(){
	$('.form-group.row').remove(); // remove all preset rows
	$('.invalid').valid(); // reset any existing invalid rows
	$('#form-card .card-header').text('Add Preset');
	$('#manage-presets [name="presetID"]').val('');
	$('#presetName').val('');
}

function trim(string){
	return string.replace(/^\s+|\s+$/g, '');
}

function isInteger(s){
	return /^[1-9]\d*$/.test(s);
}

$.fn.invalid = function(){

	if(this.val() == ''){
		var msg = 'This field is required!';
	}else{
		if(this.is('.preset-width') && !isInteger(this.val())){
			var msg = 'Must be a positive integer!';
		}else{
			if(/[!#$%^&*()[\]\\/?’”|<>{};:,+=]/.test(this.val())){
				var msg = 'Cannot contain:\n!#$%^&*()[]\/?’”|<>{};:,+=';
			}else{
				var msg = 'Must be unique!';
			}
		}
	}

	$(this).addClass('invalid').tooltip({
		title: msg
	});

	return this;
}

$.fn.valid = function(){
	$(this).removeClass('invalid').tooltip('dispose');

	return this;
}

function scrollToMiddle($elem){
	var top = $elem.offset().top;
	var speed = 700;
	var elOffset = $elem.offset().top;
	var elHeight = $elem.height();
	var winHeight = $(window).height();
	var offset;

	if (elHeight < winHeight) {
		offset = elOffset - ((winHeight / 2) - (elHeight / 2));
	}else{
		offset = elOffset;
	}

	$('html, body').animate({scrollTop:offset}, speed);
};


function ImageSet(source, options) {

    var extensionMap = { 'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp'};

    /* private functions */
    var randomString = function(length) {
        if (typeof length !== 'number' || length < 1) {
            length = 10;
        }
        var chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        var output = '';

        for (var i = 0; i < length; i++) {
            var pos = Math.floor(Math.random() * chars.length);
            output += chars[pos];
        }

        return output;
    };

    // A resize algorithm that resizes images by steps.
    var simpleResize = function(maxScaleStep) {
        if (typeof(maxScaleStep) !== 'number') {
            maxScaleStep = .667; // Set the default maximum scale step to 33.3% size reduction for maximum quality. When this number is higher, the image can be over-smoothed.
        }
        //console.info('simpleResize');
        var canvas = document.createElement('canvas'), context = canvas.getContext('2d');
        var tempCanvas = document.createElement('canvas'), tempContext = tempCanvas.getContext('2d');
        context.msImageSmoothingEnabled  = true;
        context.imageSmoothingEnabled = true;
        tempContext.msImageSmoothingEnabled  = true;
        tempContext.imageSmoothingEnabled = true;

        canvas.width = self.source.width;
        canvas.height = self.source.height;
        context.drawImage(self.source.image, 0, 0);

        self.output.original = canvas.toDataURL(self.output.type);

        for (var i = 0; i < self.sizes.length; i++) {
            tempCanvas.width = canvas.width;
            tempCanvas.height = canvas.height;
            tempContext.drawImage(canvas, 0, 0);
            var w0 = tempCanvas.width;
            var w1 = self.sizes[i].width;
            var scale = Math.round((w1 / w0) * 1000) / 1000;
            var h0 = tempCanvas.height;
            var h1 = Math.round(h0 * scale);
            if (w1 > w0) {
                self.output[w1] = null;
                continue; // only scale down
            }

            // non-outputting image scaling for increasing output image quality
            while (scale <= maxScaleStep) {
                var w1Temp = Math.round(w0 * maxScaleStep);
                var h1Temp = Math.round(h0 * maxScaleStep);

                canvas.width = w1Temp;
                canvas.height = h1Temp;
                context.drawImage(tempCanvas, 0, 0, w1Temp, h1Temp);

                w0 = w1Temp; // update the new starting width, height, and image
                h0 = h1Temp;
                tempCanvas.width = canvas.width;
                tempCanvas.height = canvas.height;
                tempContext.drawImage(canvas, 0, 0);

                scale = Math.round((w1 / w0) * 1000) / 1000; // check for new scale value based on final desired output width and new starting width
            }

            canvas.width = w1;
            canvas.height = h1;

            context.drawImage(tempCanvas, 0, 0, w1, h1);
            self.output[w1] = {};
            self.output[w1].data = canvas.toDataURL(self.output.type);
            self.output[w1].binary = self.output[w1].data.split(',')[1];
        }
    };

    // eslint-disable-next-line no-unused-vars
    var bicubicResize = function() { console.log('bicubicResize'); };

    if (!(source instanceof HTMLImageElement)) {
        throw 'The source must be an HTMLImageElement.';
    }
    else if(!source.complete) {
        throw 'Please call the ImageSet constructor after the image has been loaded.';
    }

    var defaultOptions = {
        elementId: 'main',
        name: randomString(12),
		fullname: randomString(12),
        sizes: [
            { width: 1920, suffix: '-xl' },
            { width: 1280, suffix: '-lg' },
            { width: 800, suffix: '-md' },
            { width: 600, suffix: '-sm' },
            { width: 480, suffix: '-xs' }
        ]
    };

    if (options == null || typeof options != 'object') {
        options = defaultOptions;
    }

    var self = this;

    this.output = {
        elementId: options.elementId || defaultOptions.elementId,
        type: 'image/jpeg',
        name: options.name || defaultOptions.name,
		fullname: options.fullname || defaultOptions.fullname
    };
    this.source = {
        image: source,
        width: source.naturalWidth,
        height: source.naturalHeight
    };
    this.sizes = options.sizes || defaultOptions.sizes;
    this.sizes.sort(function(a, b) { return b.width - a.width;}); // largest to smallest, so we can scale down efficiently

    this.resize = function(element) {
        simpleResize();
    };

    this.getFilename = function(suffix) {
        return this.output.name + suffix + '.' + extensionMap[this.output.type];
    };

    this.printLinks = function(element) {
        if (!(element instanceof HTMLElement)) {
            element = document.getElementById(this.output.elementId);
            if (!(element instanceof HTMLElement)) {
                throw 'The argument must be an HTMLElement.';
            }
        }
		// console.log(this);
		var card = document.createElement('div');
		$(card).addClass('card').html('<div class="card-header">' + this.output.fullname + '</div>');
        var ul = document.createElement('ul');

		$(ul).addClass('list-group');
        for(var i = 0; i < this.sizes.length; i++) {
            var key = this.sizes[i].width;
            var suffix = this.sizes[i].suffix || '-x' + key;

            var li = document.createElement('li');

			if (this.output[key] === null) {
				// when output is null source image is too small to scale to this width.
                $(li)
					.attr('data-filename', this.getFilename(suffix))
					.addClass('list-group-item')
					.addClass('disabled')
					.html(this.getFilename(suffix) + '<span class="badge badge-warning">Source too small to scale to ' + key + 'px</span>');
            }else{
				$(li)
					.attr('data-filename', this.getFilename(suffix))
					.addClass('list-group-item')
					.html(this.getFilename(suffix) + '<span class="badge badge-light">Reduce width to ' + key + 'px</span>');
			}
			
            ul.appendChild(li);
        }
		card.appendChild(ul);
        element.appendChild(card);
    };

    this.getImages = function() {
        var output = [];
        for(var i = 0; i < this.sizes.length; i++) {
            var key = this.sizes[i].width;
            var suffix = this.sizes[i].suffix || '-x' + key;
            if (this.output[key] === null) {
                continue;
            }
            var image = {};
            image.name = this.getFilename(suffix);
            image.data = this.output[key].data;
            image.binary = this.output[key].binary;

            output.push(image);
        }

        return output;
    };
}