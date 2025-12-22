// API Configuration
const API_BASE_URL = window.location.hostname === 'localhost' 
    ? 'http://localhost:5001/api'  // Development
    : 'http://localhost:5000/api'; // Production

// DOM Elements
const addItemForm = document.getElementById('addItemForm');
const itemsContainer = document.getElementById('itemsContainer');
const statusIndicator = document.getElementById('apiStatus');
const statusText = document.getElementById('statusText');
const environmentSpan = document.getElementById('environment');

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    checkAPIHealth();
    loadItems();
    
    // Form submission
    addItemForm.addEventListener('submit', handleAddItem);
});

// Check API health
async function checkAPIHealth() {
    try {
        const response = await fetch(`${API_BASE_URL.replace('/api', '')}/api/health`);
        const data = await response.json();
        
        if (data.status === 'healthy') {
            statusIndicator.classList.add('healthy');
            statusText.textContent = 'API Connected';
            environmentSpan.textContent = data.database === 'connected' ? 'Connected' : 'Disconnected';
        } else {
            throw new Error('API unhealthy');
        }
    } catch (error) {
        statusIndicator.classList.add('error');
        statusText.textContent = 'API Connection Failed';
        console.error('Health check failed:', error);
    }
}

// Load all items
async function loadItems() {
    try {
        const response = await fetch(`${API_BASE_URL}/items`);
        const data = await response.json();
        
        if (data.success) {
            displayItems(data.data);
        } else {
            throw new Error(data.error);
        }
    } catch (error) {
        itemsContainer.innerHTML = `<p class="error">Failed to load items: ${error.message}</p>`;
        console.error('Load items error:', error);
    }
}

// Display items
function displayItems(items) {
    if (items.length === 0) {
        itemsContainer.innerHTML = '<p class="loading">No items yet. Add one above!</p>';
        return;
    }
    
    itemsContainer.innerHTML = items.map(item => `
        <div class="item-card" data-id="${item.id}">
            <div class="item-content">
                <h3>${escapeHtml(item.name)}</h3>
                ${item.description ? `<p>${escapeHtml(item.description)}</p>` : ''}
                <p class="item-date">Created: ${formatDate(item.created_at)}</p>
            </div>
            <button class="btn btn-danger" onclick="deleteItem(${item.id})">Delete</button>
        </div>
    `).join('');
}

// Handle add item form submission
async function handleAddItem(e) {
    e.preventDefault();
    
    const formData = new FormData(addItemForm);
    const data = {
        name: formData.get('name'),
        description: formData.get('description')
    };
    
    try {
        const response = await fetch(`${API_BASE_URL}/items`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });
        
        const result = await response.json();
        
        if (result.success) {
            addItemForm.reset();
            loadItems();
            showMessage('Item added successfully!', 'success');
        } else {
            throw new Error(result.error);
        }
    } catch (error) {
        showMessage(`Failed to add item: ${error.message}`, 'error');
        console.error('Add item error:', error);
    }
}

// Delete item
async function deleteItem(id) {
    if (!confirm('Are you sure you want to delete this item?')) {
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/items/${id}`, {
            method: 'DELETE'
        });
        
        const data = await response.json();
        
        if (data.success) {
            loadItems();
            showMessage('Item deleted successfully!', 'success');
        } else {
            throw new Error(data.error);
        }
    } catch (error) {
        showMessage(`Failed to delete item: ${error.message}`, 'error');
        console.error('Delete item error:', error);
    }
}

// Utility: Show message
function showMessage(message, type) {
    const messageDiv = document.createElement('div');
    messageDiv.className = type;
    messageDiv.textContent = message;
    
    const main = document.querySelector('main');
    main.insertBefore(messageDiv, main.firstChild);
    
    setTimeout(() => {
        messageDiv.remove();
    }, 3000);
}

// Utility: Escape HTML
function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, m => map[m]);
}

// Utility: Format date
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
}
