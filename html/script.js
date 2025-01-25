// Change path here for image folder
const imagePath = "nui://vorp_inventory/html/img/items/";
const placeholderImage = "nui://vorp_inventory/html/img/items/placeholder.png";

let items = [];
let openFirst = true;
let players = [];
let selectedItems = {};

const itemsPerPage = 150; // Limit items per page for performance
let currentPage = 1;
let filteredItems = [];

const nextButton = document.getElementById('next-button');
const deselectAll = document.getElementById('deselect-all-button');
const modal = document.getElementById('preview-modal');
const previewList = document.getElementById('preview-list');
const playerList = document.getElementById('player-list');
const spawnButton = document.getElementById('spawn-button');
const closeModal = document.getElementById('close-modal');
const searchInput = document.getElementById('search');
const grid = document.getElementById('item-grid');
const paginationContainer = document.getElementById('pagination');

window.addEventListener('message', function(event) {
    if (event.data.type === 'show') {
        if (openFirst) {
            selectedItems = {};
            items = event.data.items;
            sortItems(); // Sort items alphabetically before rendering
            filteredItems = [...items]; // Copy sorted items for filtering
            openFirst = false;
            initializeGrid();
        }
        players = event.data.players;
        updatePlayerList(players);
        document.body.style.display = 'block';
    }
});

// Function to sort items alphabetically
function sortItems() {
    items.sort((a, b) => a.label.localeCompare(b.label)); // Sort by label
}

function updatePlayerList(players) {
    playerList.innerHTML = '<option value="self" selected>Yourself</option>';
    players.forEach(player => {
        const option = document.createElement('option');
        option.value = player.id;
        option.textContent = player.name;
        playerList.appendChild(option);
    });
}

function initializeGrid() {
    grid.innerHTML = ''; 
    currentPage = 1;
    renderPage();
}

// Render a specific page with a limited number of items
function renderPage() {
    grid.innerHTML = '';
    const start = (currentPage - 1) * itemsPerPage;
    const end = start + itemsPerPage;
    const pageItems = filteredItems.slice(start, end);
    
    pageItems.forEach(item => {
        grid.appendChild(createItemCard(item));
    });

    updatePaginationControls();
}

// Create an Item Card
function createItemCard(item) {
    const itemCard = document.createElement('div');
    itemCard.classList.add('item-card');
    itemCard.dataset.label = item.label;

    if (selectedItems[item.item]) {
        itemCard.classList.add('selected');
    }

    const imageUrl = `${imagePath}${item.item}.png`;
    
    itemCard.innerHTML = `
        <img src="${imageUrl}" alt="${item.item}" onerror="this.onerror=null; this.src='${placeholderImage}'">
        <div class="item-name">${item.label}</div>
        <input type="number" class="quantity-selector" min="1" value="${selectedItems[item.item] ? selectedItems[item.item].quantity || 1 : 1}" 
                data-item-id="${item.item}" oninput="updateQuantity('${item.item}', this.value)">
    `;

    if (item.limit) {
        const quantityInput = itemCard.querySelector('.quantity-selector');
        quantityInput.addEventListener('change', () => {
            const quantity = parseInt(quantityInput.value, 10);
            if (quantity > item.limit) {
                quantityInput.value = item.limit;
                updateQuantity(item.item, item.limit);
            }
        });
    }

    itemCard.addEventListener('click', (e) => {
        if (e.target.tagName !== 'INPUT') {
            toggleSelection(itemCard, item);
        }
    });

    return itemCard;
}

// Toggle Item Selection
function toggleSelection(itemCard, item) {
    const quantityInput = itemCard.querySelector('.quantity-selector');
    const quantity = parseInt(quantityInput.value, 10);

    if (itemCard.classList.contains('selected')) {
        itemCard.classList.remove('selected');
        delete selectedItems[item.item];
    } else {
        itemCard.classList.add('selected');
        selectedItems[item.item] = { quantity, item: item.item, label: item.label, type: item.type };
    }
}

// Update Quantity of Selected Items
function updateQuantity(itemId, newQuantity) {
    const quantity = parseInt(newQuantity, 10);
    if (selectedItems[itemId] !== undefined) {
        if (quantity > 0) {
            selectedItems[itemId].quantity = quantity;
        } else {
            delete selectedItems[itemId];
        }
    }
}

// Handle Search
function filterItems() {
    const query = searchInput.value.toLowerCase();
    filteredItems = items.filter(item => item.label.toLowerCase().includes(query));
    currentPage = 1;
    renderPage();
}

searchInput.addEventListener('input', filterItems);

// Pagination Controls (Navigation Bar at Bottom)
function updatePaginationControls() {
    paginationContainer.innerHTML = `
        <button onclick="prevPage()" ${currentPage === 1 ? 'disabled' : ''}>Previous</button>
        <span>Page ${currentPage} of ${Math.ceil(filteredItems.length / itemsPerPage)}</span>
        <button onclick="nextPage()" ${currentPage * itemsPerPage >= filteredItems.length ? 'disabled' : ''}>Next</button>
    `;
}

function nextPage() {
    if (currentPage * itemsPerPage < filteredItems.length) {
        currentPage++;
        renderPage();
    }
}

function prevPage() {
    if (currentPage > 1) {
        currentPage--;
        renderPage();
    }
}

// Handle Next Button Click
nextButton.addEventListener('click', () => {
    if (Object.keys(selectedItems).length === 0) return;

    previewList.innerHTML = '';
    Object.values(selectedItems).forEach(item => {
        const itemPreview = document.createElement('div');
        itemPreview.textContent = `${item.label} x${item.quantity}`;
        previewList.appendChild(itemPreview);
    });

    modal.classList.remove('hidden');
});

// Handle Deselect All Button Click
deselectAll.addEventListener('click', () => {
    selectedItems = {};
    document.querySelectorAll('.selected').forEach(itemCard => {
        itemCard.classList.remove('selected');
    });
});

// Close Modal
closeModal.addEventListener('click', () => {
    modal.classList.add('hidden');
});

// Handle Spawn Items
spawnButton.addEventListener('click', () => {
    const selectedPlayerId = playerList.value;
    fetch(`https://${GetParentResourceName()}/spawnItems`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ items: selectedItems, player: selectedPlayerId })
    });

    modal.classList.add('hidden');
});

// Press Escape to Hide UI
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        document.body.style.display = 'none';
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});

// Initialize on Load
document.addEventListener('DOMContentLoaded', initializeGrid);
