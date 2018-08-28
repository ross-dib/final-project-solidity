pragma solidity ^0.4.24;
import "./StoreOwner.sol";

/**
    @title Marketplace contract
 */
contract Marketplace {
    /** @dev to check if an address is an admin    
     */
    mapping(address => bool) admins;

    //------MAPPINGS------

    /**@dev just to check to see if someone is a store owner
    */
    mapping(address => StoreOwner) storeOwnerMap;

    /** @dev keep track of StoreOwner contracts created (this is an Alias to Stores created)
     */
    StoreOwner[] storeOwnerArray;

    //------MODIFIERS------

    /** @dev keep track of StoreOwner contracts created (this is an Alias to Stores created)
     */
    modifier callerIsAdmin () {
        require (admins[msg.sender] );
        _;
    }  

    //-------ADMIN FUNCTIONS------// 
    /**
    @dev add new administrator, reserved as administrator function
    @param _address address of new adminstrator
    */ 
    function addAdmin(address _address) public callerIsAdmin(){
        admins[_address] = true;
    }
    /**
    @dev creates new storeowner contract, sending address of storeowner and address of this contract as constructor params
    @param _address address of new storeowner
    */ 
    function addStoreOwner(address ownerAddress) public callerIsAdmin(){
        storeOwnerMap[ownerAddress] = new StoreOwner(ownerAddress, this);
        storeOwnerArray.push(storeOwnerMap[ownerAddress]);

    }

    /**
    @dev circuit breaker lock, only callable by adminstrators,calls lock function in Storeowner contract
     */
    function lockStoreOwners() public callerIsAdmin(){
        for(uint i = 0; i < storeOwnerArray.length; i++){
            storeOwnerArray[i].setLockdown(true);
        }
    }

    /**
    @dev circuit breaker unlock, only callable by adminstrator, calls unlock fucntion in Storeowner Contract 
     */
    function unlockStoreOwners() public callerIsAdmin(){
        for(uint i = 0; i < storeOwnerArray.length; i++){
            storeOwnerArray[i].setLockdown(false);
        }
    }

}