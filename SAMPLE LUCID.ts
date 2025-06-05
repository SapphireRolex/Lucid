import { Blockfrost, Lucid } from "https://deno.land/x/lucid/mod.ts";
import "jsr:@std/dotenv/load";

// Lấy các biến từ env
const MNEMONIC = Deno.env.get("MNEMONIC");
const BLOCKFROST_ID = Deno.env.get("BLOCKFROST_ID");
const BLOCKFROST_NETWORK = Deno.env.get("BLOCKFROST_NETWORK")
const addr = "addr_test1qprfh5jl5zfklakhcmeezksvrx0ylp6haa24pk5mt4tdw2f48nlr7dmpqgg3vf0626q43cfalep9s8knl03wrxnll6dslr7wfj";
const tx_Hash= "aa83fefa422c73e2a7a5698a4e55108c74b2f6a625765bd3a547d2b482cbb327";
const lucid = new Lucid({
    provider: new Blockfrost(
      BLOCKFROST_NETWORK,
      BLOCKFROST_ID,
    ),
  });

lucid.selectReadOnlyWallet({address: addr, });
// lucid.selectWalletFromSeed(MNEMONIC)
// console.log (await lucid.wallet.address())
const utxos = await lucid.wallet.getUtxos()
for (let i = 0; i < utxos.length; i++) {
  if (utxos[i].txHash === tx_Hash) {
    console.log(utxos[i]);
    break; // Thoát sau khi tìm thấy
  }
}
