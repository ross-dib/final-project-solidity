pragma solidity ^0.4.24;
import "../string-utils/src/strings.sol";

/**
    @title StoreOwner contract
 */
contract StoreOwner {
    address public owner;
    address public marketplace;
    mapping(string => StoreFront) storeMap;
    string[] storeNames;
    uint public balance;
    bool public lockdown;

    /** @dev keep track of StoreOwner contracts created (this is an Alias to Stores created)
    -set lockdown to false as default
    -store marketplace contract's address for reference in lockdown modifier
    @param ownerAddress address of the account that will operate this contract
    @param marketplaceAddress address of contract that created this address
     */
    constructor (address ownerAddress, address marketplaceAddress) public {
        owner = ownerAddress;
        balance = 0;
        lockdown = false;
        marketplace = marketplaceAddress;
    }

    /**
    @dev StoreFront struct contains:
    item array to hold inventory
    revenue for accounting purposes
    name
     */
    struct StoreFront {
        Item[20] inventory;
        uint revenue;
        string storeName;
    }

    /**
    @dev Item struct contains:
    quantity: to keep track of number of Item
    price
    name
    itemNumber: unique id of item, to be used as index in StoreFront's inventory Item[]
     */
    struct Item {
        uint quantity;
        uint price;
        string name;
        uint itemNumber;
    }

/**
    @dev verifies that the calle rof this contract is the owner
     */
    modifier isOwner(){
        require(msg.sender == owner);
        _;
    }

    /**
    @dev suspends functionality when state variable "lockdown" is true 
     */
    modifier circuitBreak(){
        require(!lockdown);
        _;
    }

    /**
    @dev verifies that caller's address is equivalent to the marketplace address
     */
    modifier isMarketplace(){
        require(msg.sender == marketplace);
        _;
    }
    /**
    @dev if caller is the marketplace contract to which this contract belongs, set lockdown state variable to argument
    @param lockValue boolean value, either sets lockdown to true or false
    */
    function setLockdown(bool lockValue) public isMarketplace(){
        lockdown = lockValue;
    }

    /**
    @dev create new StoreFront struct
    @param _storeName must set store name to be easily distniguishable from other stores
     */
    function addStoreFront(string _storeName) public  isOwner(){
        StoreFront storage st = storeMap[_storeName];
        st.storeName = _storeName;
        storeNames.push(_storeName);
    }

    /**
    @dev withdraw a specified amount from this contract, must be owner, susceptible to being shutdown by marketplace admin if contract is compromised
    @param withdrawAmount amount to withdraw from contract, must be less than or equal to balance
     */
    function withdraw(uint withdrawAmount) private isOwner() circuitBreak(){
        if(balance >= withdrawAmount){
            if(msg.sender.send(withdrawAmount)){
                balance -= withdrawAmount;
            }
        }
    }

     /**
    @dev add item to storefront
    @param _storeName name of store
    @param itemName name of item added
    @param _quantity number of item 
    @param _price price of item
    @param _itemName name of item
     */
    function addItem(string _storeName,string itemName, uint _quantity, uint _price, string _itemName ) private isOwner(){
        StoreFront store = storeMap[_storeName];
        uint _itemNumber = store.inventory.length + 1;
        require (_itemNumber < store.inventory.length);
        store.inventory[_itemNumber] = Item({quantity: _quantity, price: _price, name: _itemName, itemNumber: _itemNumber });        

    }
    /**
    @dev increase inventory of a given item
    @param _storeName name of store
    @param _itemNumber unique id displayed next to item on store
    @param _quantity number of items to increase 
     */
    function increaseInventory(string _storeName, uint _itemNumber, uint _quantity) private isOwner(){
        StoreFront store = storeMap[_storeName];
        store.inventory[_itemNumber].quantity += _quantity;
    }

    /**
    @dev change price of a given item
    @param _storeName name of store
    @param _itemNumber unique id displayed by the item
    @param newPrice new price of item
     */
    function changePrice(string _storeName, uint _itemNumber, uint newPrice ) private isOwner(){
        StoreFront store = storeMap[_storeName];
        store.inventory[_itemNumber].price = newPrice;
    }

    /**
    @dev buy an item
    @param _storeName name of store
    @param _itemNumber unique id displayed by the item
    @param quantity number wanted to buy
     */
    function buyItem(string _storeName, uint _itemNumber, uint quantity) public payable {        
        //get store from which item is bought
        StoreFront store = storeMap[_storeName];
        
        //calculate total price
        uint unitPrice = store.inventory[_itemNumber].price;
        uint totalPrice = unitPrice * quantity;
        
        //verify buyer (caller of contract) has enough ether to qualify buying
        require(msg.value >= totalPrice);
        
        //if transaction completes, decrement quantity and increment revenue
        if(msg.sender.send(totalPrice)){
            store.inventory[_itemNumber].quantity -= quantity;
            store.revenue += totalPrice;
            balance += totalPrice;

        }
        
    }
    /**
    @dev return revenue of specific store
    @param _storeName name of store
     */
    function getRevenue(string _storeName) public returns (uint){
        StoreFront store = storeMap[_storeName];
        return store.revenue;
    }

    /**
    @dev get items in a given store (does this by concatenating items from array into a string), goal: store on IPFS
    @param _storeName name of store
     */
    function getItems(string _storeName) public returns(string) {
        StoreFront storage store = storeMap[_storeName];
        string storage items;
        for(uint i = 0; i < store.inventory.length - 1; i++){
            string memory str = (store.inventory[i].name).toSlice().concat(", ".toSlice());
            items = items.toSlice().concat(str.toSlice());  
        }
        items = items.toSlice().concat((store.inventory[store.inventory.length - 1]).toSlice());
        return items;
    }

    /**
    @dev get items in a given store, same functionality as above
    @param _storeName name of store
     */
    function getStores(string _storeName) public returns(string) {
        
        string names;
        for(int i = 0; i < storeNames.length - 1; i++){
            string str = (storeNames[i]).toSlice().concat(", ".toSlice());
            names = names.toSlice().concat(str.toSlice());  
        }
        names = names.toSlice().concat(storeNames[storeNames.length - 1]);
        return names;
    }


}