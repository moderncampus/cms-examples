<variable section="General Page Setup" name="title" type="text" prompt="Page Title" alt="Required Field. Enter the page title. This will also be displayed by search engines as well as the web browser window.">Page Title</variable>
<variable name="keywords" type="text" rows="3" prompt="Keywords" alt="Add keywords to describe key topics on your page. (For limited SEO purposes.)"></variable>
<variable name="description" type="text" rows="3" prompt="Description" alt="Important. Enter a short description of the page, to be displayed by search engines."></variable>
<variable section="File Configuration" name="autonavigation" prompt="Add Navigation Item" type="select" alt="Specify if this page should be added to the navigation file automatically. Note that both files need to be published after creation.">
	<option value="true">Yes</option>
	<option value="false">No</option>
</variable>
<variable name="layout" type="select" prompt="Layout" alt="Choose between a two column and single column layout." output="xml" >
	<option value="one" selected="false">Single Column</option>
	<option value="two" selected="true">Two Column</option>
</variable>