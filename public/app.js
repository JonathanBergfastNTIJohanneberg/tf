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

document.addEventListener('DOMContentLoaded', function() {
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

document.addEventListener('DOMContentLoaded', function () {
    const hearts = document.querySelectorAll('.icon-heart');
  
    hearts.forEach(heart => {
      heart.addEventListener('click', function () {
        if (heart.classList.contains('clicked')) {
          heart.classList.remove('clicked');
        } else {
          heart.classList.add('clicked');
        }
      });
    });
});
  
