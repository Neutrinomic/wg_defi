import ICRC45 "./ICRC45";
import Principal "mo:base/Principal";

// Examples

let ed: ICRC45.PairData = {
    id = {
        base = {platform = 1; path = Principal.fromText("ryjl3-tyaaa-aaaaa-aaaba-cai")};
        quote = {platform = 1; path = Principal.fromText("mxzaz-hqaaa-aaaar-qaada-cai")};
    };
    base = {
        decimals = 8;
        volume24 = 1232123;
        volume_total = 23423423424;
    };
    quote = {
        decimals = 8;
        volume24 = 332123;
        volume_total = 23423423424;
    };
    // volume24_USD = ?2342342342342342;
    // volume_total_USD = ?3947539475797294;
    last_trade = 48121.1231;
    bids = [(48121.3123, 3123123123), (48120.3123, 31231233), (48115.3123, 631231233)];
    asks = [(48122.3123, 23123123), (48124.4223, 31231233), (48125.323, 6312313)];
    timestamp = 1723232932398239283298;

}
