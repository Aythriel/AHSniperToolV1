//function to delete all cookies; TODO: delete only loggedUser
function logout() { 
    alert('s-a apelat functia de logout.');
    var cookies = document.cookie.split(";");
    console.log(cookies)
    for (var i = 0; i < cookies.length; i++) {
        var cookie = cookies[i];
        var eqPos = cookie.indexOf("=");
        var name = eqPos > -1 ? cookie.substr(0, eqPos) : cookie;
        document.cookie = name + "=;expires=Thu, 01 Jan 1970 00:00:00 GMT";
    }
    location.reload();
}

function validate() {
    var form = document.forms["createUserForm"];
    var pw = form["pw"];
    var cpw = form["cpw"];
    if (pw == cpw)
        return true;
    else
        return false;
}

function removeFromWishList(itemID) {
    console.log("S-a apelat functia removeFromWishList cu id-ul de item: " + itemID);
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = function () {
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
            console.log("Response:" + xmlHttp.responseText);
            alert(xmlHttp.responseText);
            if (xmlHttp.responseText.includes("Ok")) {
                document.getElementById("item" + itemID).hidden = true; // hides table row if the item was successfully removed
            }
        }
    }
    xmlHttp.open("DELETE", '/removeFromWishList', true); // true for asynchronous 
    xmlHttp.setRequestHeader("itemID", itemID);
    xmlHttp.send(null);
}

function removeReservation(aucID) {
    console.log("S-a apelat functia removeReservation cu id-ul de licitatie: " + aucID);
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = function () {
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
            console.log("Response:" + xmlHttp.responseText);
            alert(xmlHttp.responseText);
            if (xmlHttp.responseText.includes("Ok")) {
                document.getElementById("auc" + aucID).hidden = true; // hides table row if the reservation was successfully removed
            }
        }
    }
    xmlHttp.open("DELETE", '/removeReservation', true); // true for asynchronous 
    xmlHttp.setRequestHeader("aucID", aucID);
    xmlHttp.send(null);
}

<<<<<<< Updated upstream
=======
function updatePassword() {
    var newPW = document.getElementById("newPW").value;
    var confirmPW = document.getElementById("confirmPW").value;
    var oldPW = document.getElementById("oldPW").value;
    console.log("newPW:" + newPW + "; oldPW:" + oldPW + "; confirmPW:" + confirmPW);
    if (newPW == confirmPW) {
        var ajaxReq = new XMLHttpRequest();
        ajaxReq.onreadystatechange = function () {
            if (ajaxReq.readyState == 4 && ajaxReq.status == 200) {
                console.log("Response:" + ajaxReq.responseText);
                if (ajaxReq.responseText.includes("Ok") ) {
                    alert("Password changed successfully. Logging you out.");
                    logout();
                }
            }
        }
        ajaxReq.open("PUT","/updatePassword", true);
        ajaxReq.setRequestHeader("oldPW", oldPW);
        ajaxReq.setRequestHeader("newPW", newPW);
        ajaxReq.send(null);
    }
    else {
        alert("New password doesn't match with confirmation.")
        return;
    }
       
}

function updateParam(param, oldVal) {
    var val = document.getElementById(param).value;
    if (val == oldVal) {
        alert("Change " + param + " before trying to update.");
        return;
    }

    
    console.log("Parameter to update:" + param +"; OldValue:"+ oldVal+"; New Value:"+val);
    
    var ajaxReq = new XMLHttpRequest();
    ajaxReq.onreadystatechange = function () {
        if (ajaxReq.readyState == 4 && ajaxReq.status == 200) {
            console.log("Response:" + ajaxReq.responseText);
            if (ajaxReq.responseText.includes("Ok")) {
                alert(param + " changed successfully.");
            }
            else {
                console.log("Response:" + ajaxReq.responseText);
                alert("Failed. See console for more detailed explanation.");
            }
        }
    }
    ajaxReq.open("PUT", "/updateUserParam", true);
    ajaxReq.setRequestHeader("param", param);
    ajaxReq.setRequestHeader("value", val);
    ajaxReq.send(null);
    
}

function sendEmails(userEmail) {
    var ajaxReq = new XMLHttpRequest();
    ajaxReq.onreadystatechange = function () {
        if (ajaxReq.readyState == 4 && ajaxReq.status == 200) {
            console.log("Response:" + ajaxReq.responseText);
            if (ajaxReq.responseText.includes("Ok")) {
                alert("Emails sent successfully.");
            }
            else {
                console.log("Response:" + ajaxReq.responseText);
                alert("Failed. See console for more detailed explanation.");
            }
        }
    }
    ajaxReq.open("GET", "/sendEmails", true);
    ajaxReq.setRequestHeader("userEmail", userEmail);
    ajaxReq.send(null);

}
>>>>>>> Stashed changes
