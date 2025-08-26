// {{PROJECT_NAME}} - Main JavaScript
// Created on {{DATE}}

// Wait for DOM to be fully loaded
document.addEventListener('DOMContentLoaded', function() {
    console.log('{{PROJECT_NAME}} loaded successfully!');
    
    // Initialize app
    initializeApp();
});

/**
 * Initialize the application
 */
function initializeApp() {
    // Add smooth scrolling for navigation links
    setupSmoothScrolling();
    
    // Add fade-in animations
    setupAnimations();
    
    // Set up any event listeners
    setupEventListeners();
    
    console.log('App initialized');
}

/**
 * Setup smooth scrolling for navigation links
 */
function setupSmoothScrolling() {
    const navLinks = document.querySelectorAll('.nav-link');
    
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href');
            const targetSection = document.querySelector(targetId);
            
            if (targetSection) {
                const headerHeight = document.querySelector('.header').offsetHeight;
                const targetPosition = targetSection.offsetTop - headerHeight;
                
                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });
}

/**
 * Setup fade-in animations for sections
 */
function setupAnimations() {
    const sections = document.querySelectorAll('.section, .hero');
    
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('fade-in');
            }
        });
    }, observerOptions);
    
    sections.forEach(section => {
        observer.observe(section);
    });
}

/**
 * Setup additional event listeners
 */
function setupEventListeners() {
    // Add active state to navigation
    window.addEventListener('scroll', updateActiveNavigation);
    
    // Add mobile menu toggle if needed
    setupMobileMenu();
}

/**
 * Update active navigation based on scroll position
 */
function updateActiveNavigation() {
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.nav-link');
    const headerHeight = document.querySelector('.header').offsetHeight;
    
    let current = '';
    
    sections.forEach(section => {
        const sectionTop = section.offsetTop - headerHeight - 100;
        const sectionHeight = section.offsetHeight;
        
        if (window.scrollY >= sectionTop && window.scrollY < sectionTop + sectionHeight) {
            current = section.getAttribute('id');
        }
    });
    
    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === `#${current}`) {
            link.classList.add('active');
        }
    });
}

/**
 * Setup mobile menu functionality
 */
function setupMobileMenu() {
    // Add mobile menu toggle button if screen is small
    if (window.innerWidth <= 768) {
        console.log('Mobile menu setup would go here');
        // Implementation would depend on your mobile menu design
    }
}

/**
 * Show a welcome message (example function)
 */
function showMessage() {
    const message = "Welcome to {{PROJECT_NAME}}! This is an example of JavaScript functionality.";
    
    // Create a simple modal or alert
    if (confirm(message + "\n\nWould you like to learn more about this project?")) {
        // Scroll to about section
        const aboutSection = document.querySelector('#about');
        if (aboutSection) {
            const headerHeight = document.querySelector('.header').offsetHeight;
            const targetPosition = aboutSection.offsetTop - headerHeight;
            
            window.scrollTo({
                top: targetPosition,
                behavior: 'smooth'
            });
        }
    }
}

/**
 * Handle contact form submission
 */
function handleFormSubmit(event) {
    event.preventDefault();
    
    // Get form data
    const formData = new FormData(event.target);
    const name = formData.get('name');
    const email = formData.get('email');
    const message = formData.get('message');
    
    // Simple validation
    if (!name || !email || !message) {
        alert('Please fill in all fields.');
        return;
    }
    
    // Here you would typically send the data to a server
    // For now, we'll just show a success message
    alert(`Thank you, ${name}! Your message has been received. 
    
Note: This is a demo form. In a real application, you would integrate with a backend service or form handling service like Formspree, Netlify Forms, or your own server.`);
    
    // Reset the form
    event.target.reset();
}

/**
 * Utility function to create and show notifications
 */
function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    // Style the notification
    Object.assign(notification.style, {
        position: 'fixed',
        top: '20px',
        right: '20px',
        padding: '15px 20px',
        backgroundColor: type === 'success' ? '#28a745' : type === 'error' ? '#dc3545' : '#007bff',
        color: 'white',
        borderRadius: '5px',
        boxShadow: '0 4px 20px rgba(0,0,0,0.1)',
        zIndex: '9999',
        transform: 'translateX(100%)',
        transition: 'transform 0.3s ease'
    });
    
    // Add to page
    document.body.appendChild(notification);
    
    // Animate in
    setTimeout(() => {
        notification.style.transform = 'translateX(0)';
    }, 100);
    
    // Remove after 3 seconds
    setTimeout(() => {
        notification.style.transform = 'translateX(100%)';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 3000);
}

/**
 * Utility function to handle errors gracefully
 */
function handleError(error, userMessage = 'An error occurred') {
    console.error('Error:', error);
    showNotification(userMessage, 'error');
}

// Export functions for use in other scripts if needed
window.AppFunctions = {
    showMessage,
    handleFormSubmit,
    showNotification,
    handleError
};
