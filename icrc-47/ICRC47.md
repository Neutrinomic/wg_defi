
**Exchange Block Schema**
the `btype` field MUST be "47exchange" 
the `ts` field MUST contain a timestamp
`tx` MUST contain `xfer` field - Array of transfers (2 or more)
Each `xfer` MUST contain `from`, `to`, `ledger` and amount fields
Each `xfer` CAN contain `from_owner` and `to_owner` fields
`from_owner`, `to_owner`, `ledger` are of type `Address`
`from` and to are `PlatformPaths` with `PlatformId` taken from the address of the `ledger`
each `Address` MUST contain `PlatformPath` as first element 
each `Address` CAN contain `PlatformId` as second element 
if `PlatformId` is the InternetComputer - 1, it doesn't have to be included

**Token addresses and Owner addresses**
`from_owner` is the identity of the sender
`from` is the address tokens get trasferred from
`to_owner` is the identity of the receiver
`to` is the address tokens get trasferred to
`from_owner` is optional when `from` == `from_owner`
`to_owner` is optional when `to` == `to_owner`

Note: Usually IC contracts hold user funds in subaccounts controlled by them and these have different addresses than the user ownining these tokens. 

```
variant { Map = vec {
    record { "btype"; "variant" { Text = "47exchange" }};
    record { "ts"; variant { Nat = 1_675_241_149_669_614_928 : nat } };
    record { "tx"; variant { Map = vec {
        record { "xfer"; variant { Array = vec {
                variant { Map = vec {
                    record { "ledger"; variant { Map = vec {
                        variant { Blob = blob "\16c\e1\91v\eb\e5)\84:\b2\80\13\cc\09\02\01\a8\03[X\a5\a0\d3\1f\e4\c3{\02" } ;
                        variant { Nat = 1 : nat } ;
                    }}};
                    record { "amount"; variant { Nat = 1_000_000_000_000_000_000 : nat }};
                    record { "from"; variant { Map = Blob = blob "\16c\e1\91v\eb\e5)\84:\b2\80\13\cc\09\02\01\a8\03[X\a5\a0\d3\1f\e4\c3{\02" }};
                    record { "to"; variant { Map = Blob = blob "\16c\e1\91v\eb\e5)\84:\b2\80\13\cc\09\02\01\a8\03[X\a5\a0\d3\1f\e4\c3{\02" }};
                    record { "from_owner"; variant { Array = vec {
                        variant { Blob = blob "\16c\e1\91v\eb\e5)\84:\b2\80\13\cc\09\02\01\a8\03[X\a5\a0\d3\1f\e4\c3{\02" } ;
                        variant { Nat = 1 : nat } ;
                    }}};
                    record { "to_owner"; variant { Map = vec {
                        variant { Blob = blob "\16c\e1\91v\eb\e5)\84:\b2\80\13\cc\09\02\01\a8\03[X\a5\a0\d3\1f\e4\c3{\02" } ;
                        variant { Nat = 2 : nat } ;
                    }}};

                    
                }};
        }}};
    }}};
}};
```