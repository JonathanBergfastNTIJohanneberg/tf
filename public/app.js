document.addEventListener("DOMContentLoaded", function() {
  const body = document.querySelector('body');
  const loggedIn = body.dataset.loggedIn === "true"; // Convert the attribute value to a boolean
  
  // If user is not logged in and tries to access the plans page, show a pop-up message
  if (!loggedIn && window.location.pathname === '/plans') {
    alert("You need to register or log in to access this feature.");
    window.location.href = '/home'; // Redirect unregistered users to the home page
  }
  
  // Rest of your JavaScript code...

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

  const searchInput = document.querySelector('input[name="item"]');
  const articles = document.querySelectorAll('.diet_layout');

  searchInput.addEventListener('input', function() {
    const searchTerm = this.value.trim().toLowerCase();
    
    articles.forEach(article => {
      const title = article.querySelector('h3').textContent.trim().toLowerCase();
      if (title.includes(searchTerm)) {
        article.style.display = 'block';
      } else {
        article.style.display = 'none';
      }
    });
  });
});
