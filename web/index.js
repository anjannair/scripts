var write = document.getElementById("lists");
var final = "";
fetch(
  "https://api.github.com/repos/anjannair/scripts/git/trees/main?recursive=1"
)
  .then(function (response) {
    if (response.ok) {
      return response.json();
    } else {
      return Promise.reject(response);
    }
  })
  .then(function (data) {
    data.tree.forEach((element) => {
      if (element.path.startsWith("src/")) {
        final += `<li><a href="${element.path}">${element.path}</a></li>` + "\n";
      }
    });
    write.innerHTML = final;
  })
  .catch(function (err) {
    console.warn("Something went wrong.", err);
  });
