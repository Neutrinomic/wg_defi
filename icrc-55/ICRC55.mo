

module {

    public type LocalNodeId = Nat32;
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
    public type LedgerIdx = Nat;
    public type LedgerLabel = Text;
    public type EndpointsDescription = [(LedgerIdx, LedgerLabel)];
    public type Version = {#release:[Nat16]; #beta:[Nat16]; #alpha:[Nat16]}; // Always 3 items. Ex: [0,1,23]
    public type ModuleMeta = {
        id : Text;
        name : Text;
        description : Text;
        author : Text;
        supported_ledgers : [SupportedLedger]; // SPEC: If it's empty, this means it supports all pylon ledgers
        billing : Billing;
        version: Version;
        create_allowed: Bool;
        ledger_slots : [Text];
        sources: EndpointsDescription;
        destinations: EndpointsDescription;
        author_account: Account;
    };

    public type SupportedLedger = {
        #ic : Principal;
        #other : {
            platform : Nat64;
            ledger : Blob;
        };
    };

    public type GetNode = {
        #id : LocalNodeId;
        #endpoint : Endpoint;
    };

    public type Account = {
        owner : Principal;
        subaccount : ?Blob;
    };

    public type SourceEndpointResp = {
        endpoint : Endpoint;
        balance : Nat;
        name : Text;
    };

    public type DestinationEndpointResp = {
        endpoint : EndpointOpt;
        name : Text;
    };

    public module Endpoint {
        public module IC {
            public type Ledger = {
                ledger : Principal;
            };
            public type WithAccount = {
                account : Account;
            };
            public type OptAccount = {
                account : ?Account;
            }
        };
        public module Other {
            public type Ledger = {
                platform : Nat64;
                ledger : Blob;
            };
            public type WithAccount = {
                account : Blob;
            };
            public type OptAccount = {
                account : ?Blob;
            };
        }
    };

    //--
    public type EndpointOpt = {
        #ic : EndpointOptIC;
        #other : EndpointOptOther;
    };

    public type EndpointOptIC = Endpoint.IC.Ledger and Endpoint.IC.OptAccount;
    public type EndpointOptOther = Endpoint.Other.Ledger and Endpoint.Other.OptAccount;
    


    //--
    public type Endpoint = {
        #ic : EndpointIC;
        #other : EndpointOther;
    };

    public type EndpointIC = Endpoint.IC.Ledger and Endpoint.IC.WithAccount;
 
    public type EndpointOther = Endpoint.Other.Ledger and Endpoint.Other.WithAccount;
  

    //-- 

    public type InputAddress = {
        #ic : Account;
        #other : Blob;
        #temp : {id: Nat32; source_idx: EndpointIdx}
    };

    public type BillingPylon = {
        ledger : Principal;
        min_create_balance : Nat; // Min balance required to create a node
        freezing_threshold_days: Nat; // Min days left to freeze the node if it has insufficient balance. Frozen nodes can't do transactions, but can be modified or deleted
        operation_cost: Nat; // Cost incurred per operation (Ex: modify, withdraw). Has to be at least 4 * ledger fee. Paid to the pylon only since the costs are incurred by the pylon
        split: BillingFeeSplit;
    };

    public type BillingFeeSplit = { /// Ratios, their sum has to be 1000
        platform : Nat;
        pylon : Nat; 
        author : Nat; 
        affiliate: Nat; 
    };

    public type Billing = { // The billing parameters need to make sure author, pylon and affiliate get paid.
        cost_per_day: Nat; // Split to all

        // Transaction fees apply only to transactions sent to destination addresses
        // These are split to all
        transaction_fee: BillingTransactionFee;
    };

    public type BillingTransactionFee = { 
        #none;
        #flat_fee_multiplier: Nat; // On top of that the pylon always gets 1 fee for virtual transfers and 4 fees for external transfers to cover its costs
        #transaction_percentage_fee: Nat // 8 decimal places
    };

    public type BillingInternal = {
        frozen: Bool;
        current_balance: Nat;
        account : Account;
        expires : ?Nat64;
    }; 

    public type Controller = Account;
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

    public type GetControllerNodesRequest = {
        id : Controller;
        start : LocalNodeId;
        length : Nat32;
    };
    
    public type GetControllerNodes<A> = [GetNodeResponse<A>];

    public type CreateNodeResponse<A> = {
        #ok : GetNodeResponse<A>;
        #err : Text;
    };


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

    public type CommonModifyRequest = {
        sources: ?[?InputAddress];
        destinations : ?[?InputAddress];
        extractors : ?[LocalNodeId];
        refund: ?Account;
        controllers : ?[Controller];
        active: ?Bool;
    };

    public type DeleteNodeResp = {
        #ok : ();
        #err : Text;
    };

    public type CreateNodeRequest<A> = (CommonCreateRequest, A);
    public type ModifyNodeRequest<A> = (LocalNodeId, ?CommonModifyRequest, ?A);
    public type ModifyNodeResponse<A> = {
        #ok : GetNodeResponse<A>;
        #err : Text;
    };

    public type EndpointIdx = Nat8;


    public type TransferRequest = {
        ledger: SupportedLedger;
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

    public type TransferResponse = {
        #ok : Nat64;
        #err : Text;
    };


    public type Command<C,M> = {
        #create_node : CreateNodeRequest<C>;
        #delete_node : LocalNodeId;
        #modify_node : ModifyNodeRequest<M>;
        #transfer: TransferRequest;
    };

    public type CommandResponse<A> = {
        #create_node : CreateNodeResponse<A>;
        #delete_node : DeleteNodeResp;
        #modify_node : ModifyNodeResponse<A>;
        #transfer: TransferResponse;
    };

    public type BatchCommandRequest<C,M> = {
        expire_at : ?Nat64;
        request_id : ?Nat32;
        controller: Controller;
        signature : ?Blob;
        commands: [Command<C,M>]
    };

    public type BatchCommandResponse<A> = {
        #err : {
            #duplicate: Nat;
            #expired;
            #invalid_signature;
            #access_denied;
            #other: Text;
        };
        #ok : {
            id: Nat;
            commands: [CommandResponse<A>]
        };
    };

    public type VirtualBalancesRequest = Account;
    public type VirtualBalancesResponse = [(SupportedLedger, Nat)];
    public type ValidationResult = {
        #Ok : Text;
        #Err : Text;
    };

    public type Self = actor {
        icrc55_get_controller_nodes : shared query GetControllerNodesRequest -> async GetControllerNodes<Any>;
        
        icrc55_command : shared BatchCommandRequest<Any, Any> -> async BatchCommandResponse<Any>;
        icrc55_command_validate : shared query BatchCommandRequest<Any, Any> -> async ValidationResult;

        icrc55_get_nodes : shared query [GetNode] -> async [?GetNodeResponse<Any>];
        icrc55_get_pylon_meta : shared query () -> async PylonMetaResp;

        icrc55_virtual_balances : shared query (VirtualBalancesRequest) -> async VirtualBalancesResponse;
    };
};
