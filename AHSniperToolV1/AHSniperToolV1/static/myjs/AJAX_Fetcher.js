function fetchItems() {
    var url = "/fetch";
	//url = 'https://cors-anywhere.herokuapp.com/' // pentru a folosi un proxy, dar se pare ca a mers si fara; e important de specificat http:// in URL
	var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        console.log("\nRequest status:" + this.status);
  if (this.readyState == 4 && this.status == 200) {
      console.log(this.responseText);
      document.getElementById("resultFetch").innerHTML = this.responseText;
  }
};
xhttp.open("GET",url, true);
//xhttp.setRequestHeader("Accept", 'text/json');
xhttp.send();
}

function fetchDump() {
    var url = "/fetchDump";
    //url = 'https://cors-anywhere.herokuapp.com/' // pentru a folosi un proxy, dar se pare ca a mers si fara; e important de specificat http:// in URL
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        console.log("\nRequest status:" + this.status);
        if (this.readyState == 4 && this.status == 200) {
            //var jsonOBJ = JSON.parse(this.responseText);
            console.log(this.responseText);
            document.getElementById("resultDump").innerHTML = this.responseText;
        }
    };
    xhttp.open("GET", url, true);
    //xhttp.setRequestHeader("Accept", 'text/json');
    xhttp.send();
}