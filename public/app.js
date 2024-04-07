document.addEventListener("DOMContentLoaded", function() {
  const body = document.querySelector('body');
  const loggedIn = body.dataset.loggedIn === "true"; // Convert the attribute value to a boolean
  
  // If user is not logged in and tries to access certain pages, show a pop-up message and redirect
  const restrictedPages = ['/plans', '/diets', '/exercises'];
  if (!loggedIn && restrictedPages.includes(window.location.pathname)) {
    alert("You need to register or log in to access this feature.");
    window.location.href = '/register'; // Redirect unregistered users to the register page
  }
  
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

  // Event listener for heart icon toggling
  const hearts = document.querySelectorAll('.icon-heart');
  hearts.forEach(heart => {
    heart.addEventListener('click', function () {
      const planId = this.dataset.planId; // Get the plan ID from data attribute
      fetch(`/toggle_favorite?plan_id=${planId}`) // Send request to backend
        .then(response => {
          if (!response.ok) {
            throw new Error('Network response was not ok');
          }
          return response.json();
        })
        .then(data => {
          if (data.success) {
            heart.classList.toggle('clicked'); // Toggle the 'clicked' class if request is successful
          } else {
            alert(data.error); // Display error message if request fails
          }
        })
        .catch(error => {
          console.error('There was a problem with the fetch operation:', error);
        });
    });
  });

  // Event listener for search functionality
  const searchInput = document.querySelector('input[name="item"]');
  const articles = document.querySelectorAll('.diet_layout');
  searchInput.addEventListener('input', function() {
    const searchTerm = this.value.trim().toLowerCase();
    
    articles.forEach(article => {
      const title = article.querySelector('h3').textContent.trim().toLowerCase();
      const isVisible = title.includes(searchTerm); // Check if title includes the search term
      article.style.display = isVisible ? 'block' : 'none'; // Show or hide the article based on visibility
    });
  });
});