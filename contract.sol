// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Marketplace {
    struct Item {
        string name;
        address seller;
        uint256 price;
        address buyer;
    }

    mapping(uint256 => Item) public items;
    uint256 private _itemCount;

    // Function to list an item for sale with a name
    function listItem(string calldata name, uint256 price) external {
        require(price > 0, "Price must be greater than zero");
        require(bytes(name).length > 0, "Item name is required");

        items[_itemCount] = Item({
            name: name,
            seller: msg.sender,
            price: price,
            buyer: address(0)
        });

        _itemCount++; 
    }

    // Function to buy an item
    function buyItem(uint256 itemId) external payable {
        Item storage item = items[itemId];

        require(item.seller != address(0), "Item does not exist");
        require(item.buyer == address(0), "Item already sold");
        require(msg.value == item.price, "Incorrect payment amount");

        item.buyer = msg.sender;

        // Transfer payment to the seller
        payable(item.seller).transfer(msg.value);
    }

    // Function to get the name and address of the owner (seller or buyer) of an item
    function getOwner(uint256 itemId) external view returns (string memory, address) {
        Item storage item = items[itemId];
        require(item.seller != address(0), "Item does not exist");

        // If the item is unsold, the seller is the owner
        if (item.buyer == address(0)) {
            if (item.seller == msg.sender) {
                return ("You (Seller)", item.seller); 
            }
            return ("Seller", item.seller);
        }

        // If the item is sold, the buyer is the owner
        if (item.buyer == msg.sender) {
            return ("You (Buyer)", item.buyer);
        }

        return ("Buyer", item.buyer); 
    }

    // Function to get all items with their IDs and names
    function getAllItems() external view returns (uint256[] memory, string[] memory) {
        uint256[] memory ids = new uint256[](_itemCount);
        string[] memory names = new string[](_itemCount);

        // Loop through all the items and store their IDs and names
        for (uint256 i = 0; i < _itemCount; i++) {
            ids[i] = i;
            names[i] = items[i].name;
        }

        return (ids, names);
    }
}
