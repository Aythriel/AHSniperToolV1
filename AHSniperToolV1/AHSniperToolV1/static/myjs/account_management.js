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