# ICRC-45: Live DEX Data Standard for DeFi Applications on the Internet Computer

## Abstract
The ICRC-45 standard is conceived to standardize interfaces for decentralized finance (DeFi) applications operating on the Internet Computer platform. This standard aims to provide a unified framework for the exchange and representation of live market data, such as current token exchange rates, trading volumes, and market depth.

## Motivation
The current landscape of DeFi applications on the Internet Computer is characterized by a lack of uniformity in data interfaces, as most are independently developed for specific websites or platforms. These interfaces often vary significantly in format and protocol, leading to a highly fragmented ecosystem. This fragmentation not only poses challenges in terms of compatibility and integration but also results in frequent and unpredictable changes that disrupt other DeFi applications relying this data.

## Key Components

### Data Types

- `Amount` (Nat): Represents a numerical value without decimals.
- `PlatformId` (Nat64): A numeric identifier for blockchain platforms, ensuring cross-platform compatibility.
- `PlatformPath` (Blob): A flexible identifier for assets across platforms, accommodating various formats like principals, addresses, or symbols.
- `TokenId` (Struct): Uniquely identifies a token by its platform and specific path. Contains `PlatformId` (Nat64) and `PlatformPath` (Blob).
- `Decimals` (Nat8): Indicates the precision of a token's value.
- `DataSource` (Principal): Points to the source of data for a token pair.
- `PairId` (Struct): Identifies a token pair consisting of a base and a quote token. Contains two `TokenId` structs.
- `Rate` (Float): Represents exchange rates using floating-point numbers.
- `TokenData` (Struct): Stores detailed information about a token. Contains `Decimals` (Nat8), `volume24` (Nat), `volume_total` (Nat).
- `PairData` (Struct): Structures for storing detailed information about token pairs. Contains `PairId` (Struct), `TokenData` for base and quote, optional `volume24_USD` (Nat), optional `volume_total_USD` (Nat), `last` (Rate), `bids` and `asks` (List of tuples with `Rate` and `Amount`), and `timestamp` (Nat64 in nanoseconds).
- `PairInfo` (Struct): Describes a token pair and its data source. Contains `DataSource` (Principal) and `PairId` (Struct).
- `Level` (Nat8): Used to specify the aggregation level of data.
```candid
type Amount = nat;
type Rate = f64;
type Level = u8;
type DataSource = Principal;
type PlatformPath = blob;
type PlatformId = u64;
type TokenId = record { path : PlatformPath; platform : PlatformId };
type PairId = record { base : TokenId; quote : TokenId };
type PairInfo = record { id : PairId; data : DataSource };
type ListPairsResponse = vec PairInfo;
type DepthRequest = record { level : Level; limit : nat32 };
type PairRequest = record { pairs : vec PairId; depth : opt DepthRequest };
type TokenData = record { decimals : u8; volume24 : Amount; volume_total : Amount };
type PairData = record {
  id : PairId;
  volume_total_USD : opt Amount;
  asks : vec record { Rate; Amount };
  base : TokenData;
  bids : vec record { Rate; Amount };
  last : Rate;
  quote : TokenData;
  last_timestamp : nat64;
  volume24_USD : opt Amount;
  updated_timestamp : nat64;
};
type PairResponseErr = variant {
  NotFound : PairId;
  InvalidDepthLevel : Level;
  InvalidDepthLimit : nat32;
};
type PairResponse = variant { Ok : vec PairData; Err : PairResponseErr };
```

### Public Actor Methods

#### `icrc_45_list_pairs`

```motoko
public query func icrc_45_list_pairs() : async ListPairsResponse
```
```candid
icrc_45_list_pairs : () -> (ListPairsResponse) query;
```

- **Purpose**: Retrieves a list of all token pairs available for querying. This function serves as an entry point for clients to discover which token pairs are supported by the DEX.
- **Returns**: An asynchronous response containing an array of `PairInfo`, each describing a token pair and its data source.

#### `icrc_45_get_pairs`

```motoko
public query func icrc_45_get_pairs(req: PairRequest) : async PairResponse
```
```candid
icrc_45_get_pairs : (PairRequest) -> (PairResponse) query;
```

- **Purpose**: Fetches live data for a specified set of token pairs, including details like trading volumes, last traded rate, and order book depth.
- **Parameters**:
  - `PairRequest`: A request structure specifying the token pairs to query and optional depth information.
- **Returns**: An asynchronous response that can be either `PairResponseOk` with the requested pair data or `PairResponseErr` indicating an error such as pair not found or invalid request parameters.

## Error Handling

Errors are explicitly handled via the `PairResponseErr` type, allowing clients to gracefully handle issues like missing data or invalid requests.


### Depth Information in Pair Requests

#### Depth Limit

Specifies the number of depth entries (bids and asks) to return. The API should predefine acceptable limit values (e.g., 5, 10, 20, 50, 100, 500, 1000). If the requested limit is not one of the predefined values, the API should default to the nearest lower valid limit. Default - 100

#### Depth Level

The `DepthRequest` structure includes a `level` field of type `Level` (Nat8), which specifies the aggregation level of order book data. This field allows clients to adjust the granularity of the data they receive.

- **Level 1**: Represents the most aggregated or coarsest level of data. It typically includes only the best bid and ask prices.
- **Higher Levels**: Increasing the level number provides more detailed data, with each subsequent level offering finer granularity. 

**Levels of Detail (LOD)**
Level 1 **(default)**: Offers a high-level snapshot of the market, focusing primarily on the current market price. This level typically returns the best bid and the best ask, providing a quick overview of market conditions without extensive detail.

Level 1 data is suitable for applications or services requiring a quick market overview, such as displaying the current price or basic market sentiment.

Level 2: Represents the most common level of data aggregation, where order volumes at the same price point are grouped together. This aggregation results in a clearer view of market depth, showing how buy and sell orders are distributed across different price levels. L2 data is particularly useful for most analytical and trading purposes, offering a balance between detail and readability.

For most trading and analytical needs, Level 2 aggregation is recommended. It provides a comprehensive view of market depth and liquidity, facilitating effective trading strategies without overwhelming clients with excessive detail.


Level 3 and above: These are DEX specific. The higher the level the finer the granularity.



### Volume 24 Calculation

Each pair has 24 slots for every hour over the past 24 hours.
Each slot contains two values: the volume of each token in the pair.
When a trade occurs, the system updates the volume window based on the elapsed time:
If the trade falls within the same hour as the last recorded slot, the volume of the new trade is added to the current hour's volume.
If more time has passed, the system adjusts the volume data to fit the new trade into the correct hour slot, potentially removing the oldest data if it falls outside the 24-hour window.
Then Volume24 is the sum of all slots for each token.

For reference https://github.com/infu/sonic_contrib_volume (however it tracks only one token)


### PairData

```motoko

type PairData = {
    id: PairId;
    base: TokenData;
    quote: TokenData;
    volume24_USD : ?Amount; // (optional) Always 6 decimals
    volume_total_USD : ?Amount; // (optional) Always 6 decimals
    last: Rate; // Last trade rate
    last_timestamp: Nat64;
    bids: [(Rate, Amount)]; // Bids are listed in descending order by rate
    asks: [(Rate, Amount)]; // Asks are listed in ascending order by rate
    updated_timestamp: Nat64; // Last updated timestamp in nanoseconds
};
```
#### Volume

The `volume24_USD` and `volume_total_USD` fields are optional, as not every decentralized exchange (DEX) necessarily retrieves USD values from oracles and converts prices through multiple pairs.

#### Bids and asks
The bids array contains tuples of (Rate, Amount), representing bid orders, and is sorted in descending order by rate.

The asks array contains tuples of (Rate, Amount), representing ask orders, and is sorted in ascending order by rate.

#### TokenData

Each base and quote contains volume data:

```motoko
type TokenData = {
    decimals: Decimals;
    volume24: Amount; // 24-hour volume for the token
    volume_total: Amount; // Total volume for the token
};
```

`volume_total` could be periodically recorded by aggregators if they need finer volume detail.


#### Stale pair data

Stale data is indicated by the PairData.updated_timestamp, which represents the time of the last data update.

## PairId

To ensure compatibility with various blockchains beyond the Internet Computer, we refrain from using a Principal for pair identification. Doing so would restrict us to only a subset of IC DEXes.

```motoko
type PairId = {base:TokenId; quote:TokenId}; 
type TokenId = {platform: PlatformId; path: PlatformPath};
type PlatformId = Nat64; 
type PlatformPath = Blob; // For the IC that is a Principal
```


### Platform ID Specification

Additionally, the `platform.md` document outlines the numeric identifiers assigned to various blockchain platforms, ensuring consistent cross-platform references.

- **Internet Computer**: 1
- **Bitcoin**: 2
- **Ethereum**: 3

This setup facilitates the inclusion of tokens from different blockchains within the Internet Computer's DeFi ecosystem.


### Example

Note: Bigints are converted to strings

```js

[
  {
    "id": {
      "base": {
        "path": [0, 0, 0, 0, 0, 0, 0, 2, 1, 1 ],
        "platform": "1"
      },
      "quote": {
        "path": [0, 0, 0, 0, 2, 0, 0, 136, 1, 1],
        "platform": "1"
      }
    },
    "volume_total_USD": "3918279453",
    "asks": [
      [
        1.9598386967305617,
        "29849999"
      ],
      [
        2.029114064593758,
        "57499575"
      ],
      [
        2.206508558796901,
        "57499575"
      ]
    ],
    "bids": [
      [
        1.5499390744885575,
        "112092988"
      ],
      [
        0.9658805915985059,
        "112092988"
      ]
    ],
    "base": {
      "volume24": "34151305618",
      "volume_total": "44180684408"
    },
    "last": 0.5124375981022963,
    "quote": {
      "volume24": "66972742724",
      "volume_total": "87103922590"
    },
    "last_timestamp": "1722516962237527731",
    "volume24_USD": "3014944945",
    "updated_timestamp": "1722516962237527731"
  }
]


```
