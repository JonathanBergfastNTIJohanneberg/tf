document.addEventListener("DOMContentLoaded", function() {
  // Function to toggle dropdown content
  const toggleDropdown = function(dropdownButton) {
    const dropdownContent = dropdownButton.nextElementSibling;
    const isActive = dropdownContent.classList.contains("active");
    dropdownContent.classList.toggle("active", !isActive);
  };

  // Event listener for dropdown buttons
  const dropdownButtons = document.querySelectorAll(".btn");
  dropdownButtons.forEach(function(dropdownButton) {
    dropdownButton.addEventListener("click", function(event) {
      toggleDropdown(this);
      event.stopPropagation(); // Prevent event from bubbling up to document
    });
  });

  // Event listener to close dropdowns when clicking outside
  document.addEventListener("click", function(event) {
    dropdownButtons.forEach(function(dropdownButton) {
      const dropdownContent = dropdownButton.nextElementSibling;
      if (!dropdownButton.contains(event.target) && !dropdownContent.contains(event.target)) {
        dropdownContent.classList.remove("active");
      }
    });
  });

  // Event listener for password confirmation
  const passwordInput = document.querySelector('input[name="password"]');
  const confirmPasswordInput = document.querySelector('input[name="password_confirm"]');
  const errorMessage = document.querySelector('.error-message');
  const signUpButton = document.getElementById('signup_button');

  confirmPasswordInput.addEventListener('input', function() {
    if (passwordInput.value !== confirmPasswordInput.value) {
      errorMessage.style.display = 'block';
      signUpButton.disabled = true;
    } else {
      errorMessage.style.display = 'none';
      signUpButton.disabled = false;
    }
  });
});

function toggleDropdown() {
  var dropdown = document.getElementById("myDropdown");
  dropdown.classList.toggle("open");
}  