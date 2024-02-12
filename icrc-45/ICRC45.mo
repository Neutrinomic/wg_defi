actor {

    type Amount = Nat;

    type PlatformId = Nat64; // IC = 1, Bitfinity=2, Ethereum = 3, Ordinals=4, ICPI=5, Binance CEX = 6, etc.
    // Can be anything, a principal, a symbol like BTC, ethereum address, text, etc.
    // Max 50 bytes

    type PlatformPath = Blob; // For the IC that is a Principal

    type TokenId = {platform: PlatformId; path:PlatformPath}; // for the IC -> Blob = Principal

    type Decimals = Nat8;

    type DataSource = Principal; // Location from which we can get icrc_38_pair_data. Not necessarily the PairLocation
    
    type PairId = {base:TokenId; quote:TokenId}; // base token, quote token

    type Rate = Float; // IEEE 754 floating point numbers 

    type TokenData = {
        decimals: Decimals;
        volume24: Float;
        volume_total: Amount; // Floats can't be used here
    };

    type PairData = {
        id: PairId;
        base: TokenData;
        quote: TokenData;
        volume24_USD : ?Float; // (optional) 
        volume_total_USD : ?Amount; // (optional) Always 4 decimals
        last: Rate; // Last trade rate
        bids: [(Rate, Amount)]; 
        asks: [(Rate, Amount)]; 
        timestamp: Nat64; // last updated - nanoseconds
    };
    
    type PairInfo = {
        data : DataSource;
        id: PairId;
    };

    type Level = Nat8;
    // Levels are numbered starting from 1, with 1 being the most aggregated or coarsest level
    // of data, and increasing levels offering finer detail.

    type ListPairsResponse = [PairInfo];

    // Can point to different canisters
    public query func icrc_45_list_pairs() : async ListPairsResponse {
        []
    };


    type PairRequest = {pairs: [PairId]; depth:{limit:Nat32; level:Level}}; 

    type PairResponse = [PairData];

    // Doesn't have to be in the same canister where icrc_45_list_exchanges is
    public query func icrc_45_get_pair(req: PairRequest) : async PairResponse {
        [];
    };


}
