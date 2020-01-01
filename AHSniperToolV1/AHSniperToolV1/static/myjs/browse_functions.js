//function to create the URL of and go to the new page
function goToPage() {
    page = document.getElementById("pageNumber").value; 
    newUrl = window.location.href.split('?')[0] + "?page=" + page;
    console.log("New URL:" + newUrl);
    window.location.replace(newUrl);
}

//function for creating an AJAX request to the server so the item is added to the user's wishlist
//user is identified by the cookie in the request
function addToWishList(itemID) {
    console.log("S-a apelat functia addToWishList cu id-ul de item: " + itemID);
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = function () {
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
            console.log("Response:" + xmlHttp.responseText);
            alert(xmlHttp.responseText);
        }
    }
    xmlHttp.open("POST", '/addToWishList', true); // true for asynchronous 
    xmlHttp.setRequestHeader("itemID", itemID);
    xmlHttp.send(null);
}

function addToReserved(aucID) {
    console.log("S-a apelat functia addToReserved cu auction id-ul: " + aucID);
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = function () {
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
            console.log("Response:" + xmlHttp.responseText);
            alert(xmlHttp.responseText);
        }
    }
    xmlHttp.open("POST", '/addToReserved', true); // true for asynchronous 
    xmlHttp.setRequestHeader("aucID", aucID);
    xmlHttp.send(null);
}