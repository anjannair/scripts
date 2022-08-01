var write = document.getElementById("lists");
var final = "";
fetch(
  "https://api.github.com/repos/anjannair/scripts/git/trees/main?recursive=1"
)
  .then(function (response) {
    // The API call was successful!
    response.forEach((element) => {
      if (element.path.startsWith("src/")) {
        final += `<li><a href="${element.path}">${element.path}</a></li>`;
      }
    });
  })
  .catch(function (err) {
    // There was an error
    console.warn("Something went wrong.", err);
  });

write.innerHTML = final;
