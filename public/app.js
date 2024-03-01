document.addEventListener("DOMContentLoaded", function() {
  const dropdownButtons = document.querySelectorAll(".btn");

  dropdownButtons.forEach(function(dropdownButton) {
      dropdownButton.addEventListener("click", function(event) {
          const dropdownContent = this.nextElementSibling;
          const isActive = dropdownContent.classList.contains("active");

          dropdownContent.classList.toggle("active", !isActive);

          event.stopPropagation(); 
      });

      document.addEventListener("click", function(event) {
          const dropdownContent = dropdownButton.nextElementSibling;
          if (!dropdownButton.contains(event.target) && !dropdownContent.contains(event.target)) {
              dropdownContent.classList.remove("active");
          }
      });
  });
});
