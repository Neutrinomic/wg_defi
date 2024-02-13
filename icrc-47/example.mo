
// One transfer
let tr : Transfer = {
    from_owner : (1, "werwaz-hqaaa-aaaar-qaada-cai-werwe-werwer"),
    from: (1, "fezaz-hqaaa-aaaar-qaada-cai.101201021000"),
    to_owner : (3, "af4oiwfhwieoihwoihwwewe"),
    to : (1, "fwew-hqaaa-aaaar-qaada-cai.101201021000"),
    ledger : (1, "mxzaz-hqaaa-aaaar-qaada-cai"),
    amount: 12031023012,
    }


// Simple Exchange with 2 transfers
{ 
    transfers = [
    {
    from_owner : (1, "werwaz-hqaaa-aaaar-qaada-cai-werwe-werwer"),
    from = (1, {owner="aaaaa-aa", subaccount=null}:blob);
    to = (1, {owner="aaaaa-aa", subaccount=null}:blob);
    ledger = "ryjl3-tyaaa-aaaaa-aaaba-cai";
    amount= 1_0000_000;
    },
    {
    from = (1, {owner="aaaaa-aa", subaccount=null}:blob);
    to = (1, {owner="aaaaa-aa", subaccount=null}:blob);
    ledger = "ryjl3-tyaaa-aaaaa-aaaba-cai";
    amount= 1_0000_000;
    }
    ]
    timestamp = 17321263812
    phash = d9d9f7a3647472656583018301830183024863616e6973746572
}

// We can also cover more complicated scenarios where three or more different parties exchange A → B | B → C | C → A across multiple blockchains. All are facilitated by a DEX on the IC using chain-key crypto.

{ 
transfers = [
    {
    from = (1, {owner="aaaaa-aa", subaccount=null}:blob);
    to = (1, {owner="aaaaa-aa", subaccount=null}:blob);
    ledger = "ryjl3-tyaaa-aaaaa-aaaba-cai";
    amount= 1_0000_000;
    },
    {
    from = (2,  d9d9f7a3647472656583018301830 );
    to = (2, faf9f7a3647472656583018301830);
    ledger = "wwerwerwrwrwerwerwerwer";
    amount= 4_0000_000;
    },
    {
    from = (3,  d9d9f7a3647472656583018301830 );
    to = (3, faf9f7a3647472656583018301830);
    ledger = "3ff9f7a36474726565830183";
    amount = 22_0000_000;
    }
]
timestamp = 17321263812
phash = d9d9f7a3647472656583018301830183024863616e6973746572
}