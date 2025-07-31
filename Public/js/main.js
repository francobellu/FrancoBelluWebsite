/**
 * Main JavaScript module for Franco Bellu's personal website
 * Handles scroll animations, contact form submission, and interactive effects
 */

document.addEventListener('DOMContentLoaded', function() {
    initializeScrollAnimations();
    initializeContactForm();
    initializeInteractiveEffects();
    initializeSmoothScrolling();
});

/**
 * Sets up intersection observer for scroll-based animations
 */
function initializeScrollAnimations() {
    const animationObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                animateElementIntoView(entry.target);
            }
        });
    }, {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    });

    document.querySelectorAll('.section').forEach(section => {
        prepareElementForAnimation(section);
        animationObserver.observe(section);
    });
}

/**
 * Prepares an element for scroll animation
 * @param {HTMLElement} element - Element to prepare for animation
 */
function prepareElementForAnimation(element) {
    element.style.opacity = '0';
    element.style.transform = 'translateY(30px)';
    element.style.transition = 'all 0.8s ease-out';
}

/**
 * Animates an element into view
 * @param {HTMLElement} element - Element to animate
 */
function animateElementIntoView(element) {
    element.style.opacity = '1';
    element.style.transform = 'translateY(0)';
}

/**
 * Sets up contact form submission handling with validation and API communication
 */
function initializeContactForm() {
    const contactForm = document.getElementById('contactForm');
    const contactResponse = document.getElementById('contactResponse');

    if (!contactForm || !contactResponse) {
        console.warn('Contact form elements not found');
        return;
    }

    contactForm.addEventListener('submit', async function(event) {
        event.preventDefault();
        
        try {
            const contactData = extractContactFormData(contactForm);
            
            if (!validateContactFormData(contactData)) {
                displayContactResponse(contactResponse, 'Please fill in all fields correctly.', false);
                return;
            }

            await submitContactForm(contactData, contactResponse, contactForm);
            
        } catch (error) {
            console.error('Contact form submission error:', error);
            displayContactResponse(
                contactResponse, 
                'Sorry, there was an error sending your message. Please try again.', 
                false
            );
        }
    });
}

/**
 * Extracts form data from contact form
 * @param {HTMLFormElement} form - The contact form element
 * @returns {Object} Form data object matching Swift ContactForm structure
 */
function extractContactFormData(form) {
    const formData = new FormData(form);
    return {
        senderName: formData.get('senderName'),
        senderEmail: formData.get('senderEmail'),
        messageContent: formData.get('messageContent')
    };
}

/**
 * Validates contact form data
 * @param {Object} contactData - Form data to validate
 * @returns {boolean} True if data is valid
 */
function validateContactFormData(contactData) {
    const { senderName, senderEmail, messageContent } = contactData;
    
    return senderName?.trim().length > 0 &&
           senderEmail?.trim().length > 0 &&
           messageContent?.trim().length > 0 &&
           isValidEmailFormat(senderEmail);
}

/**
 * Validates email format using basic regex
 * @param {string} email - Email to validate
 * @returns {boolean} True if email format appears valid
 */
function isValidEmailFormat(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

/**
 * Submits contact form data to the API
 * @param {Object} contactData - Form data to submit
 * @param {HTMLElement} responseElement - Element to display response
 * @param {HTMLFormElement} formElement - Form element to reset on success
 */
async function submitContactForm(contactData, responseElement, formElement) {
    const response = await fetch('/api/contact', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(contactData)
    });

    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }

    const result = await response.json();
    
    displayContactResponse(responseElement, result.responseMessage, result.isSuccessful);
    
    if (result.isSuccessful) {
        formElement.reset();
    }
}

/**
 * Displays contact form response message
 * @param {HTMLElement} element - Element to display message in
 * @param {string} message - Message to display
 * @param {boolean} isSuccess - Whether the operation was successful
 */
function displayContactResponse(element, message, isSuccess) {
    element.style.display = 'block';
    element.textContent = message;
    element.className = `contact-response ${isSuccess ? 'success' : 'error'}`;
}

/**
 * Sets up interactive hover effects for skill items
 */
function initializeInteractiveEffects() {
    document.querySelectorAll('.skill-item').forEach(skillItem => {
        skillItem.addEventListener('mouseenter', function() {
            applyHoverEffect(this);
        });
        
        skillItem.addEventListener('mouseleave', function() {
            removeHoverEffect(this);
        });
    });
}

/**
 * Applies hover effect to an element
 * @param {HTMLElement} element - Element to apply effect to
 */
function applyHoverEffect(element) {
    element.style.transform = 'translateY(-5px) scale(1.02)';
}

/**
 * Removes hover effect from an element
 * @param {HTMLElement} element - Element to remove effect from
 */
function removeHoverEffect(element) {
    element.style.transform = 'translateY(0) scale(1)';
}

/**
 * Sets up smooth scrolling for internal anchor links
 */
function initializeSmoothScrolling() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(event) {
            event.preventDefault();
            
            const targetId = this.getAttribute('href');
            const targetElement = document.querySelector(targetId);
            
            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}
