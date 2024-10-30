# ICRC-55: DeFi Vectors Protocol Specification


## Introduction


ICRC55 is a protocol designed for building advanced DeFi systems out of interoperable components on the Internet Computer. It is authored by Neutrinomic Foundation, funded by Neutrinite DAO and discussed inside the IC DeFi Working Group.

## Core Technology

ICRC55 is built around the __DeFi Vector__ concept, a "push" model that transfers tokens from a source to a destination address based on preset conditions. Unlike traditional "pull" models, where recipients initiate transfers, this approach enables direct token movements without constant requests from the destination. 

In asynchronous, multi-canister execution environments, a "pull" model cannot achieve atomicity, whereas a "push" model can. With a "push" model, tokens remain under the custody of a single canister, granting it exclusive authority to manage those tokens and maintain an internal ledger, thereby offloading work from the main ledger. In contrast, a "pull" model involves shared custody of tokens, preventing any single canister from independently maintaining such a ledger.

Additionally, ICRC55 separates the conditions guiding these transfers from the token transfer itself. This allows conditions to be defined once, before sending tokens, and reused for subsequent transfers.

This setup enhances efficiency and security, particularly in high-frequency or complex multi-contract systems, enabling streamlined, reliable token flows across decentralized finance applications on the Internet Computer.

Clients using ICRC55 can assemble lean, streamlined modules to build a graph of interconnected nodes. This design enables precise configurations, transforming simple elements into advanced systems tailored to meet specific business requirements.

## Core Elements

### Source Endpoint
Endpoints have platform ID, ledger address and account address. Sources are controlled by a canister on the Internet Computer, we call __Pylon__ in the context of this protocol.
### Destination Endpoint
Not confined by control from the _Pylon_ and can reside anywhere, including pointing to another component on the same _Pylon_.

### Vector
A Vector is a source address that receives tokens and, under specified conditions, forwards those tokens to a designated destination address. Once activated by an initial token transfer to its source address, the _Vector_ automatically manages subsequent token movements without requiring further intervention. Importantly, _Vectors_ can operate independently of ICRC55 or any specific ICRC endpoints, allowing them to interact seamlessly with other _Vectors_ across different standards through straightforward token transfers. The role of ICRC55, in this context, is to handle the creation, billing, organization, display, and control of these nodes. Other ICRC-based _Vector_ implementations can be developed to extend functionality in unique ways.

### Vector Node
A Vector Node is an instance governed by designated controllers and comprises multiple sources, destinations, and abstract _Vectors_. These internal _Vectors_ function as conceptual pathways that connect addresses without requiring explicit definitions within the node itself; instead, the node’s code operates in a way that creates the appearance of _Vectors_. In effect, Vector Nodes act as modular units, managing complex token flows between multiple sources and destinations according to programmable conditions, even though the internal _Vector_ connections are implicitly represented rather than explicitly defined.


### Vector Module
These provide different protocols like throttle, exchange, lending and allow clients to create multiple _Vector Nodes_ using these modules.
_Vector Modules_ can be developed by third parties and deployed by _Pylons_.

### Pylon
Canisters without a central coordinating DAO, aside from the Network Nervous System (NNS) that governs the IC Protocol. Each DAO independently decides which _Vector Modules_ to install and which ledgers they will utilize.
_Pylons_ communicate securely, ensuring no adversarial behavior can occur between _Pylons_, as their interactions are mediated through cryptocurrency ledger transactions. A transaction either completes successfully or does not, ensuring reliability and security.
 

### Virtualization
If a transfer occurs between two Accounts and both of them are in custody of the same canister, the transaction doesn't need to be registered inside the main ledger and can be executed synchronously inside the _Pylon_'s virtual ledger.
_Virtual Accounts_ are ICRC Accounts which have access to tokens inside the _Pylon_ ledger. If a client has access to `{owner: client-principal, subaccount: any}` in main ledgers, they have access to the same virtual account inside the _Pylon's_ virtual ledgers. This allows _Pylons_ to distribute nano fees without doing any main ledger transfers until virtual accounts withdraw tokens.
Clients can also have virtual accounts used for billing. Paid _Vectors_ are created only by billing these virtual accounts and _Pylons_ don't support async ICRC ledger calls during payment requests, which is a mechanism that can't be made DoS resistant. The virtual account used for billing is `{owner:user-principal, subaccount:null}`
In case of _Pylon_ deletion, all virtual account tokens will be sent to their main ledger accounts.
Virtual transactions still cost one ledger fee and go to the _Pylon_ to cover cycle costs.
Virtualization is optional in ICRC55 implementations.


### Transaction Events
Timers enable _Pylons_ to autonomously monitor ledger logs, detecting incoming tokens without requiring explicit client calls. By utilizing inter-canister calls instead of client notifications, this approach provides the only DoS-resistant solution that can scale to millions of addresses without the need for additional tokens to provide the protection. This mechanism is especially well-suited to the IC's reverse-gas model.


### Multichain
Canisters can interface with other ledgers, such as those on EVM blockchains and Bitcoin. This can be done using Chain Fusion tokens like ckBTC, ckETH, and ckUNI, which have ledgers on the Internet Computer. Alternatively, canisters can directly read native ledgers and send transactions using HTTP out requests and IC's Chain-key cryptography. For this reason ICRC55 allows source and destination endpoints to be on different blockchains.

## Vectorizing Services

Any DeFi service can be Vectorized by creating a _Vector Module_. Both on-chain services (e.g., NNS neurons, swaps) and off-chain services (e.g., Uniswap, Aave) can be Vectorized. Vectorization brings services into conformance with the ICRC55 protocol.


## User Interfaces (UIs)

UIs interact with ICRC55 directly and help users deploy _Vector Nodes_ in _Pylons_. These applications allow users to create, connect, modify parameters. 

UIs can offer verbose, user-friendly interfaces where power users can drag and drop nodes. Alternatively, they can provide streamlined, simplified interfaces that deploy multiple nodes and create graphs under the hood, ensuring ease of use for a broader audience.


## Commanding Pylons

Commands are issued exclusively through the `icrc55_command` update function, which includes a list of commands, authentication, and request idempotency controls.

### Controllers
**Controller** is defined as `Account`, allowing for flexibility. Using `Account` rather than just a `Principal` ensures that one client canister can have multiple controllers, which is particularly useful when it is serving multiple users.

### Command


```js
icrc55_command : shared BatchCommandRequest<Any, Any> -> async BatchCommandResponse<Any>;

```

```js
public type BatchCommandRequest<C,M> = {
   expire_at : ?Nat64;
   request_id : ?Nat32;
   controller: Controller;
   signature : ?Blob;
   commands: [Command<C,M>]
};
```


`request_id` and `expire_at` facilitate best-effort messaging. `request_id` provides deduplication for every controller command call and expires in `expire_at` timestamp, which can be up to `pylon.metadata.request_max_expire_sec`. `expire_at` can be used without `request_id`.
There is no deduplication if the request didn't result in fees charged.

```js
icrc55_command_validate : shared query BatchCommandRequest<Any, Any> -> async ValidationResult;
```

`icrc55_command_validate` takes the same input and returns rendered text, useful for SNS DAOs and signing calls.

### Authentication
The `signature` field can be used for additional security of the controller. A subset of the subaccounts will require a signature. In this case the public key is contained within the subaccount. 

This allows various controller authentication methods:
- A canister to be the controller, _Vector_ management canisters or DAO governance canisters
- A canister on behalf of a user, using subaccounts
- Self authenticating principal and its subaccounts
- Self authenticating principal + hardware wallet for dual protection. Ex: Internet Identity + hardware wallet
- Anonymous principal with hardware wallet device


```js
public type Command<C,M> = {
   #create_node : CreateNodeRequest<C>;
   #delete_node : LocalNodeId;
   #modify_node : ModifyNodeRequest<M>;
   #transfer: TransferRequest;
};
```


The `Command` type defines the possible operations that can be executed within the ICRC55 protocol:


- `#create_node`: Requests the creation of a new node.
- `#delete_node`: Deletes an existing node using its local identifier.
- `#modify_node`: Modifies an existing node with the given parameters.
- `#transfer`: Transfers tokens.



### Create Node


```js
public type CreateNodeRequest<A> = (CommonCreateRequest, A);

public type CommonCreateRequest = {
   sources:[?InputAddress];
   extractors: [LocalNodeId];
   destinations: [?InputAddress];
   ledgers: [SupportedLedger];
   refund: Account;
   controllers : [Controller];
   affiliate: ?Account;
   temporary: Bool;
   temp_id: Nat32;
};
```

```js
public type InputAddress = {
   #ic : Account;
   #other : Blob;
   #temp : {id: Nat32; source_idx: EndpointIdx}
};
```

`#temp` is used in case one of our command creates a node and subsequent commands want to point to the node source. This allows one call to icrc55_command to create a whole interconnected node graph and send tokens to these nodes.
`id` points is the `temp_id` of the node. `endpoint_idx` is the index of the source endpoint in sources.

If a source endpoint has null in account, it will automatically be assigned an account.
If a destination endpoint has null in account, it will be set to null and disconnected.
A node can be created without setting any of its destinations.

`temporary` If set to `true` and the _Pylon_ allows temporary _Vectors_, they will be created without initial charges, but will expire, unless paid later. Once they expire they will be deleted and their tokens send to the `refund` address. Temporary nodes shouldn't be allowed by the _Vector Module_ developers if tokens can't be refunded.


**Sources** and **destination accounts** can be ICRC Accounts or remote chain accounts. These can be left as empty arrays when creating the node. Sources will be automatically assigned based on the _Vector_ ID and the _Pylon_ canister principal. Sources can only be Accounts with the owner being the canister principal, and the `subaccount` is generated based on the node ID.


One node can use another node's source address, which is why they can be specified at all. The other node must have the node ID in **extractors**, otherwise it will not be allowed to extract.

`ledgers` corresponds to `node.metadata.ledger_slots` and gets mapped using `node.metadata.sources` and `node.metadata.destinations`, which are of type `EndpointsDescription`
```js
public type EndpointsDescription = [(LedgerIdx, LedgerLabel)];
```
Clients pick which `ledgers` the _Vector Module_ will use in which slot, while module authors map them to source and destination endpoints. `sources` and `destinations` are addresses which are used in these endpoints.

The custom types in ICRC55 serves to relay type definitions to its _Vector Modules_. The custom type is implemented as a variant, where each module's unique identifier is an option. It's preferred if node module authors pick a prefix, so their module ID won't collide with other modules. For example:


```js
{
 #bbb_throttle: ThrottleSpecificCreate;
 #abc_exchange: ExchangeSpecificCreate;
}
```


This structure allows for distinct and extendable definitions, ensuring that each module can be uniquely and explicitly defined within the _Pylon_. Once deployed, the schema for these modules can be found in the canister Candid interface in metadata.

Standard Candid endpoint design principles apply to these custom _Vector Module_ types, ensuring backward compatibility for older clients after a module is released.

For requests:
- _Vector Module_ IDs must not be removed or renamed.
- Modifying field names and types is prohibited.
- New record fields can only be added if they are optional.
- Old record fields can be removed if they are unnecessary for cases when old clients send calls.
- New options can be added to variants.


For responses:
- New variant options can only be added if the variant is optional. This ensures that when a client retrieves node information without the latest schema, only the variant will be null rather than the entire node response.
- New fields will be ignored by old clients
- Always make variants optional if there is a chance you will be adding options.


Releasing a brand-new node module with a different ID is an upgrade option as well, but should be done only as last resort.


## Modify Node


Modification similar to creation requires custom interface for each node module.


`icrc55_command` `#modify_node` takes `LocalNodeId`, `?CommonModifyRequest` and `?A` (custom type)
```js
public type ModifyNodeRequest<A> = (LocalNodeId, ?CommonModifyRequest, ?A);
```
If `CommonModifyRequest` or `A` is `null` these parts will remain unmodified.


```js
public type CommonModifyRequest = {
   sources: ?[?InputAddress];
   destinations : ?[?InputAddress];
   extractors : ?[LocalNodeId];
   refund: ?Account;
   controllers : ?[Controller];
   active: ?Bool;
};
```


If a field in this record is null, it will remain unmodified.

`sources`, `destinations` and `extractors` can be empty arrays.

`controllers` if empty will black hole the _Vector Node_.

`active` - allows controllers to start and stop a node.

`refund` - contains a virtual account that receives every token inside the _Vector Node_ on expiration or other errors.

The custom modify type defined by the node module acts same as the custom create type - _Vector Module_ IDs are options in a variant.

### Delete Node

Takes `LocalNodeId` and deletes the node permanently. Its history remains inside the ICRC3 backlog.
During deletion all transferable tokens are returned to the `refund` virtual account.


#### Transfer

To transfer tokens inside of _Pylons_ or in between virtual accounts we use the command `#transfer`.

```js
public type TransferRequest = {
   ledger: SupportedLedger; // IC or remote blockchain ledger
   account : Account;
   from: {
      #node: {
            node_id : LocalNodeId;
            endpoint_idx : EndpointIdx;
      };
      #account : Account;
   };
   to: {
      #external_account: {
            #ic : Account;
            #other: Blob;
      };
      #account: Account;
      #node_billing: LocalNodeId;
      #node: {
            node_id : LocalNodeId;
            endpoint_idx : EndpointIdx;
      };
   };
   amount: Nat;
};
```    

Sending to `#external_account` withdraws tokens to the main ledger.
`#account` both in to and from is used when making virtual transfers.
To `#node_billing` is the billing address of the node.
Similarly, we can transfer from and to `#node` source addresses.

## Token Endpoints


`sources` & `destinations` of _Vector Nodes_ contain endpoints.
Endpoints contain platform ID, ledger address and account address.


```js
public type Endpoint = {
   #ic : EndpointIC;
   #other : EndpointOther;
};
```


For ease of use within the IC endpoints can be `#ic` which means ledgers are Principals and accounts are ICRC1 Accounts.
```js
#ic {
   ledger:Principal;
   account:?Account;
}
```
#other endpoints can be on different chains. Platform IDs get registered inside ICRC-55 spec repo.

```js
#other {
   platform:Nat;
   ledger:Blob;
   account:?Blob;
}
```
ICRC55 should cover all possible cryptocurrency endpoints.

There is a variation of the Endpoint type where the `account` is not optional. In responses source endpoint accounts are always required.




A _Vector Node_ always has source accounts in all endpoints, but may not have destination accounts set. A node without all destination accounts set, will be inactive.




## Billing

To fully support the protocol, a clear billing model is essential for _Vector Nodes_. This enables end-user interfaces to facilitate payments for _Vector_ usage seamlessly.

Four distinct roles receive platform fees:

- **Vector Module Authors**  
  Third-party developers who create diverse protocol modules. They do not manage deployments but focus on publishing modules for deployment in _Pylons_ and use by clients.

- **_Pylon_ Operators**  
  Primarily envisioned as DAOs, operators handle all cycle fees and govern the _Pylon_ canisters. Their responsibilities include verifying the security of authors code, integrating _Vector Modules_, performing upgrades, compiling canisters, and selecting ledgers. _Pylons_ also pay for storing the log generated by module activities.

- **Platform Maintainers**  
  The platform responsible for maintaining the framework that underpins this protocol.

- **Affiliates**  
  Creators of user interfaces, including both sophisticated IDEs and streamlined, task-specific applications.


### Pylon Billing Parameters
```js
public type Billing_Pylon_ = {
   ledger : Principal;
   min_create_balance : Nat; // Min balance required to create a node
   freezing_threshold_days: Nat; // Min days left to freeze the node if it has insufficient balance. Frozen nodes can't do transactions, but can be modified or deleted
   operation_cost: Nat; // Cost incurred per operation (Ex: modify, withdraw). Has to be at least 4 * ledger fee. Paid to the Pylon only since the costs are incurred by the Pylon
   split: BillingFeeSplit;
};

public type BillingFeeSplit = { /// Ratios, their sum has to be 1000
   platform : Nat;
   pylon : Nat; 
   author : Nat; 
   affiliate: Nat; 
};
```
_Pylons_ define the `ledger` used for creation, operational fees and daily costs.

`operation_cost` occurs on `modify` and `source_transfer` commands
`min_create_balance` is required to pay a temporary _Vector_ or create a new paid one.

`affiliate` cut goes to the `affiliate` set during node creation. The affiliate can't be changed.
`author` cut goes to the _Vector Module_ author in account defined by them, visible in `node.metadata.author_account`
`pylon` cut goes to `pylon.metadata.pylon_account`
`platform` cut goes to `pylon.metadata.platform_account`


### Vector Module Billing Parameters

```js
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
Each _Vector Node_ has a billing account `node.billing.account` from which daily costs are deducted. Every _Vector Module_ defines its `cost_per_day`.
If the node's billing balance drops bellow `freezing_threshold_days * cost_per_day` the node gets frozen.
Frozen nodes are inactive and require their billing accounts to be topped up.
`cost_per_day` is shared between `split`.


### Querying Nodes

#### Get node
```js
icrc55_get_nodes : shared query [GetNode] -> async [?GetNodeResponse<Any>];
```
Array of `GetNode` is requested and array of `Opt GetNodeResponse<Any>` is returned.

```js
public type GetNode = {
   #id : LocalNodeId;
   #endpoint : Endpoint;
};
```

The request can query by node ID or source endpoint. Endpoint requests can be used to find nodes of destination accounts and this way discover the graph of interconnected nodes starting from root nodes.

```js
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

`custom` contains _Vector Module_ IDs as variant options and their own custom get response type.
In case the custom type is unsupported by the client, custom will be `null`

```js
public type BillingInternal = {
   frozen: Bool;
   current_balance: Nat;
   account : Account;
   expires : ?Nat64;
}; 
```

If `current_balance` goes to zero, `expires` will be set to a timestamp using `pylon.metadata.temporary_nodes.expire_sec`. Once the node expires, it gets deleted and tokens sent to the `refund` virtual account.
`active` is set by the client in order to stop/start nodes internal operations. `cost_per_day` is still taking fees even if inactive.

#### Endpoint Responses

```js
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
`name` is assigned by _Vector Modules_


#### Get controller nodes 

To quickly retrieve all nodes of a controller, we can use the API endpoint

```js
icrc55_get_controller_nodes : shared query GetControllerNodesRequest -> async GetControllerNodes<Any>;
```

```js
public type GetControllerNodesRequest = {
   id : Controller;
   start : LocalNodeId;
   length : Nat32;
};

public type GetControllerNodes<A> = [GetNodeResponse<A>];
```

It returns the same response type as when querying a single node, but allows pagination in case there are more nodes than one response can return.

### Get Virtual Balances

```
   icrc55_virtual_balances : shared query (VirtualBalancesRequest) -> async VirtualBalancesResponse;
```

```
   public type VirtualBalancesRequest = Account;
   public type VirtualBalancesResponse = [(SupportedLedger, Nat)];
```    

Returns virtual account balances for every non-empty supported ledger inside the _Pylon_

### Pylon meta

```js
icrc55_get_pylon_meta : shared query () -> async PylonMetaResp;
```

```js
    public type PylonMetaResp = {
        name: Text;
        governed_by : Text;
        modules: [ModuleMeta];
        temporary_nodes: {
            allowed : Bool;
            expire_sec: Nat64;
        };
        supported_ledgers : [SupportedLedger];
        billing: BillingPylon;
        platform_account : Account;
        pylon_account: Account;
        request_max_expire_sec: Nat64;
    };
```    

`supported_ledgers` contains a list of ledgers nodes can use.
`modules` contains metadata for all _Vector Modules_ inside the _Pylon_
`temporary_nodes.allowed` specifies if the _Pylon_ accepts _Vector Nodes_ without initial fee. `expire_sec` specifies how long temporary nodes will be kept before deletion.


```js
    public type ModuleMeta = {
        id : Text;
        name : Text;
        description : Text;
        author : Text;
        supported_ledgers : [SupportedLedger]; // If it's empty, this means it supports all pylon ledgers
        billing : Billing;
        version: Version;
        create_allowed: Bool;
        ledger_slots : [Text];
        sources: EndpointsDescription;
        destinations: EndpointsDescription;
        author_account: Account;
    };
```
If `supported_ledgers` is empty, the module supports all _Pylon_ ledgers.
A client will usually start by requesting the _Pylon_ metadata and then use it when making `icrc55_command` calls.
`id` has to be the same as the variant option inside the module's custom types.

Full interface description is available in ICRC55.mo