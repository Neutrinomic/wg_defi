#### ICRC-47 is ICRC-3 compliant Block


**Exchange Block Schema**

- the `btype` field MUST be "47exchange"
- the `ts` field MUST contain a timestamp
- `phash` is REQUIRED
- MUST contain `xfers` field - Array of transfers (2 or more)
- Each transfer MUST contain `amount`
- Each transfer MUST contain `from`, `to`, `ledger` and amount fields
- Each transfer CAN contain `from_owner` and `to_owner` fields
- `from_owner`, `to_owner`, `ledger` MUST be valid Address (sub schema)
- `to` and `from` MUST be valid PlatformPath (sub schema)


**Token addresses and Owner addresses**

- `from_owner` is the identity of the sender
- `from` is the address tokens get trasferred from
- `to_owner` is the identity of the receiver
- `to` is the address tokens get trasferred to
- `from_owner` is optional when `from` == `from_owner`
- `to_owner` is optional when `to` == `to_owner`


Note: Usually IC contracts hold user funds in subaccounts controlled by them and these have different addresses than the users ownining these tokens. 


**Design**

This specification allows logging of fungible and non-fungible exchanges between two or more participants on the same or different platforms.

**Schema** 

```js
variant { Map = vec {
    record { "btype"; variant { Text = "47exchange" }};
    record { "ts"; variant { Nat = 1_675_241_149_669_614_928 : nat } };
    record { "xfers"; variant { Array = vec {
            variant { Map = vec {
                record { "ledger"; Address};
                record { "amount"; variant { Nat = 1_000_000_000_000_000_000 : nat }};
                record { "from"; PlatformPath};
                record { "to"; PlatformPath};
                record { "from_owner"; Address };
                record { "to_owner"; Address };
            }};
            //...
    }}};
}};


```

**Address**

- First element MUST be PlatformPath
- Second element CAN be PlatformId if it is different from 1 (IC fungible tokens)

```js
variant { Array = vec {
        PlatformPath; // First element PlatformPath
        variant { Nat = 1 : nat }; // Second element PlatformId
    }}
```

**PlatformPath**
- Array of Platform specific Blobs (1 or more)
- If ICRC Accounts then first element is `owner` and second element is `subaccount` (optional)
- If used inside `ledger` for NFTs then first element is canister id and second element is NFT id

```js
variant { Array = vec {
        variant { Blob = blob "\00\00\00\00\020\00\07\01\01" };
        variant { Blob = blob "&\99\c0H\7f\a4\a5Q\af\c7\f4;\d9\e9\ca\e5 \e3\94\84\b5c\b6\97/\00\e6\a0\e9\d3p\1a" };
    }};
```

**PlatformId** 

Check ../ICRC45/platforms.md

- IC fungible - 1
- IC NFT - 2


**Example** 

Doesn't have PlatformID's since everything is pointing to the IC


```js

Map = vec {
    record { "phash"; variant {Blob = blob "\e9\c6\36\57\f0\f6\da\de\e3\a1\40\05\1e\f6\f0\7e\87\73\43\1b\5e\1f\2a\be\4b\2a\b8\6f\fb\66\4e\c4" }; };
    record { "ts"; variant { Nat = 1_722_515_422_309_834_566 : nat } };
    record { "btype"; variant { Text = "47exchange" } };
    record { "xfers"; variant { Array = vec {
            variant { Map = vec { 
                record { "ledger"; variant { Array = vec { variant { Array = vec { variant { Blob = blob "\00\00\00\00\00\00\00\02\01\01" };} };} };};
                record { "amount"; variant { Nat = 34_022_675 : nat };};
                record { "from"; variant { Array = vec { 
                    variant { Blob = blob "\00\00\00\00\01\70\48\e3\01\01" };
                    variant { Blob = blob "\01\00\00\00\04\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" };} };};
                record { "to"; variant { Array = vec { 
                    variant { Blob = blob "\00\00\00\00\01\70\48\e3\01\01" };
                    variant { Blob = blob "\01\00\00\00\04\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" };} };};
                record { "from_owner"; variant { Array = vec { variant { Blob = blob "\56\64\f8\fa\86\71\92\f3\5d\09\79\c3\7f\3d\4b\f4\f8\c7\7b\79\cf\ca\bc\ab\d6\bd\4d\16\02" };} };};
                record { "to_owner"; variant { Array = vec { variant { Blob = blob "\56\64\f8\fa\86\71\92\f3\5d\09\79\c3\7f\3d\4b\f4\f8\c7\7b\79\cf\ca\bc\ab\d6\bd\4d\16\02" };} };};}
            };
            variant { Map = vec { 
                record { "ledger"; variant { Array = vec { variant { Array = vec { variant { Blob = blob "\00\00\00\00\02\00\00\88\01\01" };} };} };}; 
                record { "amount"; variant { Nat = 66_399_224 : nat };};
                record { "from"; variant { Array = vec { 
                    variant { Blob = blob "\00\00\00\00\01\70\48\e3\01\01" }; 
                    variant { Blob = blob "\01\00\00\00\05\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" };} };}; 
                record { "to"; variant { Array = vec { 
                    variant { Blob = blob "\00\00\00\00\01\70\48\e3\01\01" }; 
                    variant { Blob = blob "\01\00\00\00\05\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" };} };}; 
                record { "from_owner"; variant { Array = vec { variant { Array = vec { variant { Blob = blob "\56\64\f8\fa\86\71\92\f3\5d\09\79\c3\7f\3d\4b\f4\f8\c7\7b\79\cf\ca\bc\ab\d6\bd\4d\16\02" };}}} };}; 
                record { "to_owner"; variant { Array = vec { variant { Array = vec { variant { Blob = blob "\56\64\f8\fa\86\71\92\f3\5d\09\79\c3\7f\3d\4b\f4\f8\c7\7b\79\cf\ca\bc\ab\d6\bd\4d\16\02" };}}} };};}
            };
    }}}}
```