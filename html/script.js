// Change path here for image folder
const imagePath = "nui://vorp_inventory/html/img/items/";
const placeholderImage = "nui://vorp_inventory/html/img/items/placeholder.png";

let items = [
];
let openFirst = true
let players = [
];

const nextButton = document.getElementById('next-button');
const deselectAll = document.getElementById('deselect-all-button');
const modal = document.getElementById('preview-modal');
const previewList = document.getElementById('preview-list');
const playerList = document.getElementById('player-list');
const spawnButton = document.getElementById('spawn-button');
const closeModal = document.getElementById('close-modal');
// Track Selected Items
let selectedItems = {};

window.addEventListener('message', function(event) {
    if (event.data.type === 'show') {
        // The message type is 'loadItems', process the data
        if (openFirst) {
            selectedItems = {};
            items = event.data.items;
            openFirst = false;
            initializeGrid();
        }
        players = event.data.players;
        playerList.innerHTML = '<option value="self" selected>Yourself</option>'; // Clear previous players
        players.forEach(player => {
            const option = document.createElement('option');
            option.value = player.id;
            option.textContent = player.name;
            playerList.appendChild(option);
        });
        document.body.style.display = 'block'; // Show the body
    }
})

// Initialize Grid
function initializeGrid() {
    const grid = document.getElementById('item-grid');
    grid.innerHTML = ''; // Clear previous items

    items.forEach(item => {
        const itemCard = createItemCard(item);
        grid.appendChild(itemCard);
    });
}

// Create an Item Card
function createItemCard(item) {
    const itemCard = document.createElement('div');
    itemCard.classList.add('item-card');
    // add item.label to item card dataset
    itemCard.dataset.label = item.label;

    // Mark as selected if it exists in selectedItems
    if (selectedItems[item.item]) {
        itemCard.classList.add('selected');
    }
    itemCard.innerHTML = `
        <img src="${imagePath+item.item+".png"}" alt="${item.item}" onerror="this.src='${placeholderImage}'; this.onerror=null;">
        <div class="item-name">${item.label}</div>
        <input type="number" class="quantity-selector" min="1" value="${selectedItems[item.item] ? selectedItems[item.item].quantity || 1 : 1}" 
                data-item-id="${item.item}" oninput="updateQuantity('${item.item}', this.value)">
    `;
    // Check quantity input on change for limit
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

    // Add click event to toggle selection
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
        // Deselect item
        itemCard.classList.remove('selected');
        delete selectedItems[item.item];
    } else {
        // Select item
        itemCard.classList.add('selected');
        selectedItems[item.item] = {quantity : quantity, item : item.item, label : item.label, type : item.type};
    }
}

// Update Quantity of Selected Items
function updateQuantity(itemId, newQuantity) {
    const quantity = parseInt(newQuantity, 10);

    if (selectedItems[itemId] !== undefined) {
        if (quantity > 0) {
            selectedItems[itemId].quantity = quantity; // Update quantity
        } else {
            delete selectedItems[itemId]; // Remove if quantity is invalid
        }
    }
}

// Filter Items by Search
function filterItems() {
    const query = document.getElementById('search').value.toLowerCase();
    const items = document.querySelectorAll('.item-card');
    items.forEach(itemCard => {
        const label = itemCard.dataset.label.toLowerCase();
        if (label.includes(query)) {
            itemCard.classList.remove('hidden');
        } else {
            itemCard.classList.add('hidden');
        }
    });
}

// Handle Next Button Click
nextButton.addEventListener('click', () => {
    // Check if any items are selected
    if (Object.keys(selectedItems).length === 0) {
        return;
    }
    previewList.innerHTML = ''; // Clear previous items
    Object.keys(selectedItems).forEach(itemId => {
        const item = selectedItems[itemId];
        if (item) {
            const itemPreview = document.createElement('div');
            itemPreview.textContent = `${item.label} x${item.quantity}`;
            previewList.appendChild(itemPreview);
        }
    });

    modal.classList.remove('hidden'); // Show the modal
});

// Handle Deselect All Button Click
deselectAll.addEventListener('click', () => {
    selectedItems = {}; // Clear selected items
    // search through all selected
    const selected = document.querySelectorAll('.selected');
    selected.forEach(itemCard => {
        itemCard.classList.remove('selected');
    });
});

// Close Modal
closeModal.addEventListener('click', () => {
    modal.classList.add('hidden'); // Hide the modal
});

// Handle Spawn Items
spawnButton.addEventListener('click', () => {
    const selectedPlayerId = playerList.value; // Selected player (or "self")

    // Send data to server via trigger
    fetch(`https://${GetParentResourceName()}/spawnItems`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            items: selectedItems,
            player: selectedPlayerId
        })
    });

    modal.classList.add('hidden'); // Hide the modal
});

// press escape to hide body
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        document.body.style.display = 'none'; 
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
            })
        });
    }
});

// Initialize on Load
document.addEventListener('DOMContentLoaded', initializeGrid);
