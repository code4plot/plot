//This script is to update your google form dropdown choices based on a spreadsheet column

function updateForm(){
  // call your form and connect to the drop-down item
  var form = FormApp.openById("<Form-id>"); 
  //Form-id can be found in the url (docs.google.com/forms/d/<Form-id>/edit)
  
  var namesList = form.getItemById(<itemId>).asListItem(); 
  //inspect the dropdown html code. look for "data-item-id" element. You should find a 9-digit code corresponding to the dropdown.

  // identify the sheet where the data resides needed to populate the drop-down
  var ss = SpreadsheetApp.getActive();
  var names = ss.getSheetByName(<sheetName>);

  var rowStart = 2; //use 1 if no header
  var colStart = 1; //populate drop-down from first column
  var numRows = names.getMaxRows() - 1 // (- 1) to account for header
  // grab the values in the first column of the sheet
  var namesValues = names.getRange(rowStart, colStart, numRows).getValues();
  
  //initiate new vector
  var itemList = [];

  // convert the array ignoring empty cells
  for(var i = 0; i < namesValues.length; i++)   
    if(namesValues[i][0] != ""){
      itemList[i] = namesValues[i][0];
    }
  // populate the drop-down with the array data
  namesList.setChoiceValues(itemList); //.setChoiceValues is specific to drop-downs
 
}