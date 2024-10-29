# ICRC-55: DeFi Vectors Protocol Specification


## Introduction


ICRC55 is a protocol designed for building advanced DeFi systems out of interoperable components on the Internet Computer. It is a product of the IC DeFi Working Group, with the Neutrinomic Foundation serving as the primary contributor. The protocol's development is sponsored by Neutrinite DAO.


## Core Technology

The foundational element of ICRC55 is the concept of a DeFi Vector, characterized by a source address and a destination address.


### Source Address
Controlled by a canister on the Internet Computer, we call "Pylon" in the context of this protocol.
### Destination Address
Not confined by control from the pylon and can reside anywhere, including pointing to another component on the same pylon.
### Vector
Source address that accepts tokens and based on certain conditions sends tokens to a destination address.
Vectors are activated by sending tokens to their designated source address. Subsequent token movement to occurs without further interaction.
Vectors can be created without ICRC55 or any ICRC endpoints, while still working with other vectors from other standards, because they communicate through simple transfers.
What ICRC55 is about is creating, billing, organizing, displaying and controlling nodes. Other vector ICRCs can also be developed around vectors that do things differently.
Vectors particularly suit developers and DAOs aiming for efficient dApp tokenization, requiring only a single ledger transfer.
### Vector node
Deployed thought ICRC-55 single node governed by controllers and has multiple sources, destinations and vectors.
### Vector module
These provide different protocols like throttle, exchange, lending and allow clients to create multiple vector nodes using these modules.
Vector modules can be developed by third parties and deployed by pylons.

### Pylon
Canisters without a central coordinating DAO, aside from the Network Nervous System (NNS) that governs the IC Protocol. Each DAO autonomously determines which vector modules it installs and which ledgers they work with.
Pylons communicate securely, ensuring no adversarial behavior can occur between pylons, as their interactions are mediated through cryptocurrency ledger transactions. A transaction either completes successfully or does not, ensuring reliability and security. This requires ledgers to be trusted.


## Virtualization
If a transfer occurs between two Accounts and both of them are in custody of the same canister, the transaction doesn't need to be registered inside the main ledger and can be executed synchronously inside the pylon's ledger.
Virtual accounts are ICRC Accounts which have access to tokens inside the pylon ledger. If a client has access to {owner: principal, subaccount: any} in ledgers, they have access to the same virtual account inside the pylon. This allows pylons to distribute nano fees without doing any main ledger transfers until virtual accounts withdraw tokens.
Clients can also have virtual accounts used for billing. Paid vectors are created only by billing these virtual accounts and pylons don't support async icrc ledger calls during payment, which is a mechanism that can't be made DoS resistant. The billing virtual account is {owner:principal, subaccount:null}
In case of pylon deletion, all virtual account tokens will be sent to their actual accounts.
Virtual transactions still cost one ledger fee and go to the `pylon` to cover cycle costs.


### Comparison with Existing DeFi Architectures
Current DeFi architectures combine instructions and tokens, with instructions passed after every token transfer to dictate actions to the canister. In contrast, the ICRC55 protocol first passes the instructions, creating a contract that determines what to do with incoming tokens and where to send them next. Once established, multiple tokens can be sent without additional instructions.

This approach enhances composability, as each component does not need to understand the language of the next; they are simply passing tokens. Each component can have multiple sources and destinations, executing more complex operations internally. These components are termed **Vector Nodes** or simply **Nodes**.


### Role of Timers and Chain-Key Cryptography

Two critical Internet Computer functions—Timers and chain-key cryptography—play a pivotal role in the operation of Pylons:


- **Timers** enable Pylons to monitor ledger logs and detect when their source addresses receive tokens, even without explicit client calls.
- **Chain-key Cryptography** allows Pylons to interface with other ledgers, such as those on EVM blockchains and Bitcoin. This can be done using Chain-fusion ck tokens like ckBTC, ckETH, and ckUNI, which have ledgers on the Internet Computer. Alternatively, pylons can directly read native ledgers and send transactions using HTTP out requests.

These Vectors can serve as foundational elements in decentralized application development, expediting development and providing robust tokenization mechanisms.


## Vectorizing Services

Any DeFi service can be vectorized by creating a vector module. Both on-chain services (e.g., NNS neurons, swaps) and off-chain services (e.g., Uniswap, Aave) can be vectorized. Vectorization brings external chain services into conformance with the ICRC55 protocol, enabling seamless integration, interoperability, and the chaining of complex DeFi functionalities.


## User Interfaces (UIs)

UIs interact with ICRC55 and help users deploy vector nodes in pylons. These applications allow users to connect nodes and modify parameters. All such UIs can work directly with pylons without additional backends.

UIs can offer verbose, user-friendly interfaces where users can drag and drop components, similar to NodeRED. Alternatively, they can provide streamlined, simplified interfaces that deploy multiple components and chain them under the hood, ensuring ease of use for a broader audience.


## Commanding Pylons

Commands come from a controller in an IC call and are cryptographically signed. 

### Controllers
**Controller** is defined as an `Account`, allowing for flexibility. Using an `Account` rather than just a `Principal` ensures that one client canister can have multiple controllers, which is particularly useful when serving multiple users.

### Command

Commands are given using the only update function `icrc55_command`, which contains a list of commands

```
icrc55_command : shared BatchCommandRequest<Any, Any> -> async BatchCommandResponse<Any>;
```


```
public type BatchCommandRequest<C,M> = {
   expire_at : ?Nat64;
   request_id : ?Nat32;
   controller: Controller;
   signature : ?Blob;
   commands: [Command<C,M>]
};
```


`request_id` and `expire_at` facilitate best-effort messaging. Request_id provides deduplication for every controller command call and expires in `expire_at` timestamp, which can be up to 10 minutes. `expire_at` can be used without `request_id`.
There is no deduplication if the request didn't result in fees charged.


### Authentication
The `signature` field can be used for additional security of the controller. A subset of the subaccounts will require a signature. In this case the public key is contained within the subaccount. 

This allows various controller authentication methods:
- A canister to be the controller, vector management canisters or DAO governance canisters
- A canister on behalf of a user, using subaccounts
- Self authenticating principal and its subaccounts
- Self authenticating principal + hardware wallet for dual protection. Ex: Internet Identity + Trezor device
- Anonymous principal with hardware wallet device


```
public type Command<C,M> = {
   #create_node : CreateNodeRequest<C>;
   #delete_node : LocalNodeId;
   #modify_node : ModifyNodeRequest<M>;
   #source_transfer: SourceTransferRequest;
   #virtual_transfer: VirtualTransferRequest;
   #top_up_node : TopUpNodeRequest;
};
```


The `Command` type defines the possible operations that can be executed within the ICRC55 protocol:


- `#create_node`: Requests the creation of a new node.
- `#delete_node`: Deletes an existing node using its local identifier.
- `#modify_node`: Modifies an existing node with the given parameters.
- `#source_transfer`: Transfers tokens out of a source address.
- `#virtual_transfer`: Transfers tokens out of a virtual address.
- `#top_up_node`: Tops up an existing node with additional resources.



### Create Node


```
public type CreateNodeRequest<A> = (CommonCreateRequest, A);

public type CommonCreateRequest = {
   sources:[?Address];
   extractors: [LocalNodeId];
   destinations: [?Address];
   ledgers: [SupportedLedger];
   refund: Account;
   controllers : [Controller];
   affiliate: ?Account;
   temporary: Bool;
   temp_id: Nat32;
};
```

```
public type Address = {
   #ic : Account;
   #other : Blob;
   #temp : {id: Nat32; source_idx: EndpointIdx}
};
```

#temp is used in case one of our command creates a node and subsequent commands want to point to the node source. This allows one call to icrc55_command to create multiple interconnected nodes in one call.
`id` points is the `temp_id` of the node. `endpoint_idx` is the index of the source endpoint in sources.

If a source endpoint has null in account, it will automatically be assigned an account.
If a destination endpoint has null in account, it will be set to null and disconnected.
A node can be created without setting any of its destinations.

`temporary` If set to `true` and the pylon allows temporary vectors, they will be created without initial charges, but will expire, unless paid later. Once they expire they will be deleted and their tokens send to the `refund` address. Temporary nodes shouldn't be allowed by the vector module developers if tokens can't be refunded.


**Sources** and **destination accounts** can be ICRC Accounts or remote chain accounts. These can be left as empty arrays when creating the node. Sources will be automatically assigned based on the vector ID and the pylon canister principal. Sources can only be Accounts with the owner being the canister principal, and the `subaccount` is generated based on the node ID.


One node can use another node's source address, which is why they can be specified at all. The other node must have the node ID in **extractors**, otherwise it will not be allowed to extract.

`ledgers` corresponds to `node.metadata.ledger_slots` and gets mapped using `node.metadata.sources` and `node.metadata.destinations`, which are of type `EndpointsDescription`
```
public type EndpointsDescription = [(LedgerIdx, LedgerLabel)];
```
Clients pick which `ledgers` the vector module will use in which slot, while module authors map them to source and destination endpoints. `sources` and `destinations` are addresses which are used in these endpoints.

The custom types in ICRC55 serves to relay type definitions to its vector modules. The custom type is implemented as a variant, where each module's unique identifier is an option. It's preferred if node module authors pick a prefix, so their module id won't collide with other modules. For example:


```
{
 #bbb_throttle: ThrottleSpecificCreate;
 #abc_exchange: ExchangeSpecificCreate;
}
```


This structure allows for distinct and extendable definitions, ensuring that each node can be uniquely and explicitly defined within the pylon. Once deployed, the schema for these nodes can be found in the canister Candid IDL in metadata.

General Candid endpoint design principles apply to these custom node requests, so older clients still work as expected after a node gets released:
- Nodes must not be removed or renamed.
- Modifying field names and types is prohibited.
- New record fields can only be added if they are optional.
- Old record fields can be removed if they are unnecessary for cases when old clients send calls.
- New options can be added to variants.


For responses:
- New variant options can only be added if the variant is optional. This ensures that when a client retrieves node information without the latest schema, only the variant will be null rather than the entire node response.
- New fields will be ignored by old clients
- Always make variants optional if there is a chance you will be adding options.


Releasing a brand-new node module with a different id is an upgrade option as well, but should be done only as last resort.


### Modify Node


Modification similar to creation requires custom interface for each node module.


icrc55_command #modify_node takes `LocalNodeId`, `?CommondModifyRequest` and `?A` (custom type)
```
public type ModifyNodeRequest<A> = (LocalNodeId, ?CommondModifyRequest, ?A);
```
If `CommondModifyRequest` or `A` is `null` these parts won't be modified.


```
public type CommondModifyRequest = {
   sources: ?[Endpoint];
   destinations : ?[EndpointOpt];
   extractors : ?[LocalNodeId];
   refund: ?Account;
   controllers : ?[Controller];
   active: ?Bool;
};
```


If a field in this record is null, the field won't be modified.

`sources`, `destinations` and `extractors` can be empty arrays.

`controllers` if empty will black hole the vector node.

`active` - allows clients to start and stop a node.

`refund` - contains a virtual account that receives every token inside the vector node on expiration.

The custom modify type defined by the node module acts same as the custom create type.

### Delete Node

Takes `LocalNodeId` and deletes the node permanently. Its history remains inside the ICRC3 backlog.
During deletion all transferable tokens are returned to the `refund` Account.


## Endpoints


Sources & Destinations of vector nodes contain endpoints.
Endpoints contain platform id, ledger address and account address.


```
public type Endpoint = {
   #ic : EndpointIC;
   #other : EndpointOther;
   #temp : Nat;
};
```


For ease of use within the IC endpoints can be #ic which means ledgers are Principals and accounts are ICRC1 Accounts.
```
#ic {
   ledger:Principal;
   account:?Account;
}
```
#other endpoints can be on different chains. Platform Ids get registered inside ICRC-55 spec repo.

```
#other {
   platform:Nat;
   ledger:Blob;
   account:?Blob;
}
```
ICRC55 should cover all possible cryptocurrency endpoints.

There is a variation of the Endpoint type where the `account` is not optional. In responses source endpoint accounts are always required.




A vector node always has source accounts in all endpoints, but may not have destination accounts set. A node without all destination accounts set, will be inactive.




## Billing

To fully support the protocol, a clear billing model is essential for vector nodes. This enables end-user interfaces to facilitate payments for vector usage seamlessly.

Four distinct roles receive fees:

- **Vector Module Authors**  
  Third-party developers who create diverse protocol modules. They do not manage deployments but focus on publishing modules for deployment in pylons and use by clients.

- **Pylon Operators**  
  Primarily envisioned as DAOs, operators handle all cycle fees and govern the pylon canisters. Their responsibilities include verifying the security of authors code, integrating vector modules, performing upgrades, compiling canisters, and selecting ledgers. Pylons also pay for storing the log generated by module activities.

- **Platform Maintainers**  
  The platform responsible for maintaining the framework that underpins this protocol.

- **Affiliates**  
  Creators of user interfaces, including both sophisticated IDEs and streamlined, task-specific applications.


### Pylon billing parameters
```
public type BillingPylon = {
   ledger : Principal;
   min_create_balance : Nat; // Min balance required to create a node
   freezing_threshold_days: Nat; // Min days left to freeze the node if it has insufficient balance. Frozen nodes can't do transactions, but can be modified or deleted
   exempt_daily_cost_balance: ?Nat; // Balance threshold that exempts from cost per day deduction
   operation_cost: Nat; // Cost incurred per operation (Ex: modify, withdraw). Has to be at least 4 * ledger fee. Paid to the pylon only since the costs are incurred by the pylon
   split: BillingFeeSplit;
};

public type BillingFeeSplit = { /// Ratios, their sum has to be 1000
   platform : Nat;
   pylon : Nat; 
   author : Nat; 
   affiliate: Nat; 
};
```
Pylons define the `ledger` used for creation, operational fees and daily costs.

`operation_cost` occurs on `modify` and `source_transfer` commands
`min_create_balance` is required to pay a temporary vector or create a new paid vector.

`affiliate` cut goes to the `affiliate` set during node creation. The affiliate can't be changed.
`author` cut goes to the vector module author in account defined by them, visible in `node.metadata.author_account`
`pylon` cut goes to `pylon.metadata.pylon_account`
`platform` cut goes to `pylon.metadata.platform_account`

If `source_balance` is above `exempt_daily_cost_balance`, then no daily costs are deducted.

### Vector module billing parameters

```
public type Billing = {
   cost_per_day: Nat;
   transaction_fee: BillingTransactionFee;
};

public type BillingTransactionFee = { 
   #none;
   #flat_fee_multiplier: Nat; 
   #transaction_percentage_fee: Nat // 8 decimal places
};
```
Each vector node has a billing account `node.billing.account` from which daily costs are deducted. Every vector module defines its `cost_per_day`.
If the node's billing balance drops bellow `freezing_threshold_days * cost_per_day` the node gets frozen.
Frozen nodes are inactive and require their billing accounts to be topped up.
`cost_per_day` is shared between `split`.


### Querying nodes

#### Get node
```
icrc55_get_nodes : shared query [GetNode] -> async [?GetNodeResponse<Any>];
```
Array of `GetNode` is requested and array of `Opt GetNodeResponse<Any>` is returned.

```
public type GetNode = {
   #id : LocalNodeId;
   #endpoint : Endpoint;
};
```

The request can query by node id or source endpoint. Endpoint requests can be used to find nodes of destination accounts and this way discover the graph of interconnected nodes starting from any node.

```
public type GetNodeResponse<A> = {
   id : LocalNodeId;
   sources : [SourceEndpointResp];
   destinations : [DestinationEndpointResp];
   extractors: [LocalNodeId];
   refund: Account;
   controllers : [Controller];
   created : Nat64;
   modified : Nat64;
   billing : Billing and BillingInternal;
   active : Bool;
   custom : ?A;
};
```

`custom` contains vector module ids as variant options and their own custom get response type.
In case the custom type is unsupported by the client, custom will be `null`

```
public type BillingInternal = {
   frozen: Bool;
   current_balance: Nat;
   account : Account;
   expires : ?Nat64;
}; 
```

If `current_balance` goes to zero, `expires` will be set to a timestamp using `pylon.metadata.temporary_nodes.expire_sec`. Once the node expires, it gets deleted and tokens sent to the `refund` account.
`active` is set by the client in order to stop/start nodes internal operations. `cost_per_day` is still taking fees even if inactive.

#### Endpoint responses

```
public type SourceEndpointResp = {
   endpoint : Endpoint;
   balance : Nat;
   name : Text;
};

public type DestinationEndpointResp = {
   endpoint : EndpointOpt;
   name : Text;
};
```

`balance` of the `endpoint`
`name` is assigned by vector modules


#### Get controller nodes 

To quickly retrieve all nodes of a controller, we can use the API endpoint

```
icrc55_get_controller_nodes : shared query GetControllerNodesRequest -> async GetControllerNodes<Any>;
```

```
public type GetControllerNodesRequest = {
   id : Controller;
   start : Nat;
   length : Nat;
};

public type GetControllerNodes<A> = [GetNodeResponse<A>];
```

It returns the same response type as when querying a single node, but allows pagination in case there are more nodes than one response can return.

#### Source transfer

In many cases tokens will not match conditions and stay in their source address. They can be retrieved back by using `#source_transfer` command.

```
    public type SourceTransferRequest = {
        id : LocalNodeId;
        source_idx : EndpointIdx;
        to: Address;
        amount: Nat;
    };
```

These tokens can be multichain. The platform and ledger are taken from the source endpoint. The address from `to`.

#### Virtual transfer

To transfer tokens out of virtual accounts we use the command `#virtual_transfer`

```
    public type VirtualTransferRequest = {
        account : Account;
        to: Endpoint;
        amount: Nat;
    };
```    

The platform, ledger and address come from the endpoint `to`