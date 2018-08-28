pragma solidity ^0.4.24;
import "../contracts/Marketplace.sol";
import "truffle/DeployedAddresses.sol"; 


contract TestMarketplace {

    function testAddAdmin() public {
        Marketplace mp = Marketplace(DeployedAddresses.Marketplace());

        mp.addAdmin(this);

        Assert.equal(mp.admins[this], true, "Address should be found in admins mapping and return true");
    } 

    function testAddStoreOwner() public {
        Marketplace mp = Marketplace(DeployedAddresses.Marketplace());

        mp.addStoreOwner(this);

        Assert.equal(mp.storeOwnerMap[this], this, "Address should be found in admins mapping and equal this contract address");
    } 

    function testLockStoreOwner() public {
        Marketplace mp = Marketplace(DeployedAddresses.Marketplace());

        mp.addStoreOwner(this);
        mp.lockStoreOwners();

        Assert.equal(mp.storeOwnerMap[this].lockdown, true, "Lockdown should be true");
    }

    function testUnlockStoreOwner() public {
        Marketplace mp = Marketplace(DeployedAddresses.Marketplace());

        mp.addStoreOwner(this);
        mp.unlockStoreOwners();

        Assert.equal(mp.storeOwnerMap[this].lockdown, false, "Lockdown should be false");
    } 

    function testGetStore() public{
        Marketplace mp = Marketplace(DeployedAddresses.Marketplace());

        mp.addStoreOwner(this);

        Assert.equal(mp.storeOwnerMap[this], storeOwnerArray[0], "Checks Storeowner address in both places it should be stored");
    } 

}