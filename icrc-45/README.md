# ICRC-45: Live DEX Data Standard for DeFi Applications on the Internet Computer

## Abstract
The ICRC-45 standard is conceived to standardize interfaces for decentralized finance (DeFi) applications operating on the Internet Computer platform. This standard aims to provide a unified framework for the exchange and representation of live market data, such as current token exchange rates, trading volumes, and market depth.

## Motivation
The current landscape of DeFi applications on the Internet Computer is characterized by a lack of uniformity in data interfaces, as most are independently developed for specific websites or platforms. These interfaces often vary significantly in format and protocol, leading to a highly fragmented ecosystem. This fragmentation not only poses challenges in terms of compatibility and integration but also results in frequent and unpredictable changes that disrupt other DeFi applications relying this data.

## Requirements
* work for all existing DeFi DEXes
* support different systems - Order book, AMM, AMM with ranges
* support different architectures - single canister and multi canister, EVM
* allow the fastest possible refresh rate
* ledger standard agnostic
* compact at the cost of precision
* canisters serve it fast without too much computation
* practical to use
