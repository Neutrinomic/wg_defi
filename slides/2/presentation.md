---
marp: true
theme: default
class:
  - lead
  - invert
---

# DeFi

## Technical Working Group

---

# Goals

- Simplify the creation of DeFi services

- Enhance interoperability and collaboration. Setting ICRC standards and offering libraries that are easy to use, secure, and reliable.

- Increase awareness of DeFi on ICP. Bringing ICP DeFi projects to relevant platforms like Dexscreener.

---

## WG repo GitHub

https://github.com/neutrinomic/wg_defi

https://forum.dfinity.org/t/defi-working-group/27350/5

---

## ICRC-45 [Live DEX Data]

The ICRC-45 standard is conceived to standardize interfaces for decentralized finance (DeFi) applications operating on the Internet Computer. This standard aims to provide a unified framework for the exchange and representation of live market data, such as current token exchange rates, trading volumes, and market depth.

https://forum.dfinity.org/t/icrc-38-live-dex-data/26417

---

## ICRC-47 [DEX History]

The goal is to establish uniform interfaces for accessing DEX exchange history. This standardization will facilitate third-party developers in creating applications and canisters for decentralized finance (DeFi) purposes. This will help the IC DeFi ecosystem to grow and increase its networking effect.

https://forum.dfinity.org/t/icrc-40-dex-history/26477

---

Without standards and libraries, these will be a lot harder or impossible:

- Making an accounting app that reports all - swaps and generates tax reports
- Canisters swapping safely
- Canisters getting reliable prices they can use to make other DeFi contracts like, arbitrage bots, trading bots, etc.
- Someone creating swapping libraries
- Analytics sites like ICPCoins to have reliable data
- Someone making a service that provides CoinMarketcap, DeFi lama, DEX Screener listing as a service to dexes.
- Devs will find it hard to do DeFi that connects to other services rn.
- Library module for ccxt and similar - will allow all the off-chain apps to work with dexes like cexes (if we want that) there are probably a lot of apps using this lib
