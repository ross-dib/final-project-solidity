I implemented my (partial) application in two contracts: Marketplace.sol and StoreOwner.sol. the Marketplace contract holds all admins and store owners addresses, as well as the addresses of all StoreOwner contracts.
These StoreOwner contracts are owned and operated by address that own each store, as approved by admins.
This design was implemented so all profits a storeowner makes from a single or multiple stores is held in one contract, mitigating risk. 
If a contract is compromised, there is a circuit breaker that an admin can execute on all storeowner contracts, disallowing any funds to be withdrawn. 
My contracts are split up into necessary functions, and operate just as one would expect they should based on their names.
