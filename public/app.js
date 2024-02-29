document.addEventListener("DOMContentLoaded", function() {
  const dropdownButtons = document.querySelectorAll(".btn");

  dropdownButtons.forEach(function(dropdownButton) {
      dropdownButton.addEventListener("click", function(event) {
          const dropdownContent = this.nextElementSibling;
          const isActive = dropdownContent.classList.contains("active");

          // Toggle the "active" class to open or close the dropdown
          dropdownContent.classList.toggle("active", !isActive);

          event.stopPropagation(); // Prevent event bubbling
      });

      // Close the dropdown when clicking outside of it
      document.addEventListener("click", function(event) {
          const dropdownContent = dropdownButton.nextElementSibling;
          if (!dropdownButton.contains(event.target) && !dropdownContent.contains(event.target)) {
              dropdownContent.classList.remove("active");
          }
      });
  });
});
