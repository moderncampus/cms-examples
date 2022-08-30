<!-- ouc:editor wysiwyg="no" -->
<script>
	/* automatically pulls the direct edit button from the publishes pages without the need to define Button Code */
	function directedit() {
		if(document.getElementById("de") != null && document.getElementById("directedit")) {
			var link = document.getElementById("de").children[0].href;
			document.getElementById("de").innerHTML = "";
			document.getElementById("directedit").href = link;
		}
	}
	window.onload = function() { directedit() };
</script>