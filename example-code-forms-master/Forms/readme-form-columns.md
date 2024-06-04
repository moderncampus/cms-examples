# Forms with Columns Documentation
---
## XSL Changes
- This replaces the match of `element` in the ou-forms.xsl
- You will need to change what classes are applied to the column widths.

## Custom Settings
- supports 1 column (default behavior) 2 columns, 3 columns, or 4 columns, anything column count bigger will give unexpected results.
- There is no configuration needed for 1 column since that is the default behavior.
- ***IMPORTANT*** - if this is not configured correctly, the output will not be correct and not look as expected. 
- When creating the LDP form, the elements that you want to display side by side have exist together. They can not be spaced out. 
- Each form element in LDP forms has an `Advanced` field and we will be utilizing that field to create the column layouts. 
- On the first element that you would like to be in the first column of the row you have to defined `row_start=true;` This opens the row. ***Important to have the semi-colon at the end***
- On the last element of the row you will need to define `row_end=true;` This closes the row. ***Important to have the semi-colon at the end***
- On each element of the row even the first element and last element you need to define `row_col_count=(number of elements for the row);` *Replace Number of elements for the row* with a value of 2, 3 or 4. ***Important to have the semi-colon at the end***

### Example case for 2 column layout
- First Element has `row_start=true;row_col_count=2;`
- Second Element `row_end=true;row_col_count=2;`

### Example Case for 3 column layout
- First Element has `row_start=true;row_col_count=3;`
- Second Element `row_col_count=3;`
- Third Element `row_end=true;row_col_count=3;`

### Example Case for 4 column layout
- First Element has `row_start=true;row_col_count=4;`
- Second Element `row_col_count=4;`
- Third Element `row_col_count=4;`
- Fourth Element `row_end=true;row_col_count=4;`
- 
