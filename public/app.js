document.addEventListener("DOMContentLoaded", function() {
  const toggleDropdown = function(dropdownButton) {
    const dropdownContent = dropdownButton.nextElementSibling;
    const isActive = dropdownContent.classList.contains("active");
    dropdownContent.classList.toggle("active", !isActive);
  };

  const dropdownButtons = document.querySelectorAll(".btn");
  dropdownButtons.forEach(function(dropdownButton) {
    dropdownButton.addEventListener("click", function(event) {
      toggleDropdown(this);
      event.stopPropagation();
    });
  });
  document.addEventListener("click", function(event) {
    dropdownButtons.forEach(function(dropdownButton) {
      const dropdownContent = dropdownButton.nextElementSibling;
      if (!dropdownButton.contains(event.target) && !dropdownContent.contains(event.target)) {
        dropdownContent.classList.remove("active");
      }
    });
  });

 
});

function toggleDropdown() {
  var dropdown = document.getElementById("myDropdown");
  dropdown.classList.toggle("open");
}  