
function goToPage() {
    page = document.getElementById("pageNumber").value; 
    newUrl = window.location.href.split('?')[0] + "?page=" + page;
    console.log("New URL:" + newUrl);
    window.location.replace(newUrl);
}