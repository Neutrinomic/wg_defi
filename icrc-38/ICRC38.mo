actor {

    type Rate = Float; // IEEE 754 floating point numbers 

    type Amount = Float; // Doesn't mean you have to store amounts as floats inside the canister

    type TokenId = Text; // Can be anything, a principal, a symbol like BTC, ethereum address, etc.

    type PairId = (TokenId, TokenId); // base token, quote token

    type PairsRequest = {pairs: [PairId], limit:Nat, level:Nat}; 

    type Volume = (Amount, Amount); // in both tokens

    type Depth = {
        bids: [(Rate, Amount)]; 
        asks: [(Rate, Amount)]; 
        highest_bid: Amount;
        lowest_ask: Amount;
    };

    type PairData = {
        pair_id: PairId;
        last_trade_rate: Rate;
        volume24: Volume; // rolling 24h volume in each token
        volume_total: Volume;
        depth : Depth;
    };
    
    type PairsResponse = [PairData];

    type PairAddress = (Principal, PairId);

    public query func icrc_38_list_pairs() : async [PairAddress] {
        []
    };

    public query func icrc_38_pair_data(req: PairsRequest) : async PairsResponse {
        [];
    };



}
