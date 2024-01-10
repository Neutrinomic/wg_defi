actor {

    type Rate = Float; // IEEE 754 floating point numbers 

    type Amount = Float; // Doesn't mean you have to store amounts as floats inside the canister

    type TokenId = Text; // Can be anything, a principal, a symbol like BTC, ethereum address, etc.

    type PairId = (TokenId, TokenId); // base token, quote token

    type PairsRequest = [PairId];

    type Volume = (Amount, Amount); 

    // Define the structure for representing market depth.
    // The market depth is described in terms of bids and asks arrays,
    // each containing a series of 'Amount' values. These values correspond to
    // cumulative order volumes within specified percentage ranges from the current market price.
    // The ranges are set to provide detailed granularity close to the market price,
    // becoming progressively less granular as the price range widens.
    // This approach helps in understanding immediate trading pressures and potential support/resistance levels.
    type Depth = {
        bids: [Amount]; // 0.1%, 0.5%, 1%, 2%, 5%, 10%, 15%, 20%, 25%, 30%, 50%, 75%, 100%
        asks: [Amount]; // 0.1%, 0.5%, 1%, 2%, 5%, 10%, 15%, 20%, 25%, 30%, 50%, 100%, 200%, 300%, 500%, 1000%, +Infinity
    };

    type PairData = {
        pair_id: PairId;
        rate: Rate;
        volume24: Volume; // rolling 24h volume in each token
        volume_total: Volume;
        depth : Depth;
    };
    
    type PairsResponse = [PairData];

    public query func icrc_38_list_pairs() : async [PairId] {
        []
    };

    public query func icrc_38_pair_data(req: PairsRequest) : async PairsResponse {
        [];
    };



}