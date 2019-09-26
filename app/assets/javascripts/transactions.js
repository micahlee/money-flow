function addTransactionField() {
 
    //create Date object
    var date = new Date();
 
    //get number of milliseconds since midnight Jan 1, 1970 
    //and use it for address key
    var mSec = date.getTime(); 
 
    //Replace 0 with milliseconds
    idAttributeAmount =  
          "split_transactions_0_amount".replace("0", mSec);
    nameAttributeAmount =  
          "split[transactions][0][amount]".replace("0", mSec);

    //create <li> tag
    var li = document.createElement("li");
 
    //create label for Kind, set it's for attribute, 
    //and append it to <li> element
    var labelAmount = document.createElement("label");
    labelAmount.setAttribute("for", idAttributeAmount);
    var amountLabelText = document.createTextNode("Amount");
    labelAmount.appendChild(amountLabelText);
    li.appendChild(labelAmount);
 
    //create input for Kind, set it's type, id and name attribute, 
    //and append it to <li> element
    var inputAmount = document.createElement("INPUT");
    inputAmount.setAttribute("type", "text");
    inputAmount.setAttribute("id", idAttributeAmount);
    inputAmount.setAttribute("name", nameAttributeAmount);
    li.appendChild(inputAmount);
 
 
    //add created <li> element with its child elements 
    //(label and input) to myList (<ul>) element
    document.getElementById("myList").appendChild(li);
 
    //show address header
    $("#transactionHeader").show(); 
  }