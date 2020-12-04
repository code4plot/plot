/**
 * Sends emails with data from the current spreadsheet.
 */
// trigger this function on new form submit
function sendEmails() {
  var ss = SpreadsheetApp.getActive();
  var sheet = ss.getSheetByName(<sheetname>);
  // Fetch the range of cells containing new order information
  // suppose column1 = email
  // column2 = message
  var lastRow = ss.getLastRow(); // latest row of data to process (latest form submit)
  var colStart = 1;
  var numRows = 1; // send 1 email at a time
  var numCols = 2; // email and message
  var infoRange = sheet.getRange(lastRow,colStart,numRows,numCols);
  // Fetch values for each row in the Range.
  var data = infoRange.getValues();
  for (var i in data) {
    var row = data[i];
    var emailAddress = row[1]; // First column
    var message = row[2]; // second column
    var subject = 'a test message';
    MailApp.sendEmail(emailAddress, subject, message);
  }
  // mark as sent
  var colStart = colStart + numCols;
  var mark = sheet.getRange(lastRow, colStart);
  mark.setValue('sent');
}
