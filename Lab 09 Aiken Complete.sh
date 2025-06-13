----Tạo Validator bao gồm datum và redeemer Plutus V3 để lấy mã CBOR------

use aiken/primitive/string
use cardano/transaction.{OutputReference, Transaction}

pub type Redeemer {
msg: ByteArray,
}

pub type Datum {
msg: ByteArray,
}

// The validator is a function that takes the following arguments:
// - datum: the datum of the UTXO being spent
// - redeemer: the redeemer of the UTXO being spent
// - utxo: the UTXO Reference 
// - self: the transaction being created
// - ctx: the script context
// The validator returns a boolean value indicating whether the transaction is valid or not

validator datum_redeemer {
spend(
datum: Option<Datum>,
redeemer: Redeemer,
_utxo: OutputReference,
_self: Transaction,
) {
// The redeemer is a custom type that contains a message
expect Some(datum_input) = datum
let d: Datum = datum_input
// The datum is a custom type that contains a message

let a = d.msg == redeemer.msg
a?
}

else(_) {
fail
}
}

  // // If needs be, remove any of unneeded handlers above, and use:
  //
  // else(_ctx: ScriptContext) {
  //   todo @"fallback logic if none of the other purposes match"
  // }
  //
  // // You will also need an additional import:
  // //
  // // use cardano/script_context.{ScriptContext}



-------Từ Script được tạo từ validator(Aiken) sẽ tạo ra address của SC----------

import { Blockfrost, Lucid, Crypto, Data, fromText, Addresses, String } from "https://deno.land/x/lucid/mod.ts";

// Provider selection
// There are multiple builtin providers you can choose from in Lucid.

// Blockfrost : previewbjWeyokguJArwoYZFioqk4hn8Pr5wcxU


const lucid = new Lucid({
  provider: new Blockfrost(
    "https://cardano-preview.blockfrost.io/api/v0",
    "previewbjWeyokguJArwoYZFioqk4hn8Pr5wcxU",
  ),
});

console.log(lucid);

// Chọn ví từ bộ seed phare:

const seed = "december fantasy news diary valve valley lawn bachelor video degree success shy essay mushroom kidney lab melody happy limit lounge chest club have outside"
lucid.selectWalletFromSeed(seed, { addressType: "Base", index: 0});
console.log(lucid);

const address = await lucid.wallet.address("addr_test1qzhx5h84aqv3sjl9ylup5636amed0w43c3h7znml4ehf27654vw2tfl2679u642fuctay47kqsyr7dre3p68tnt4nnmqv0rhen"); 
console.log(address);

//scripts datum==redeemer 
const datum_redeemer_scripts = lucid.newScript({
  type: "PlutusV3",
  script: "58af01010029800aba2aba1aab9faab9eaab9dab9a48888896600264653001300700198039804000cc01c0092225980099b8748008c01cdd500144c8cc896600266e1d2000300a375400d13232598009808001456600266e1d2000300c375400713371e6eb8c03cc034dd5180798069baa003375c601e601a6ea80222c805a2c8070dd7180700098059baa0068b2012300b001300b300c0013008375400516401830070013003375400f149a26cac80081",
  });

const datum_redeemerAddress = datum_redeemer_scripts.toAddress();
console.log(`datum_redeemer address: ${datum_redeemerAddress}`);


// Định nghĩa cấu trúc Datum
  const DatumSchema = Data.Object({
  msg: Data.Bytes, // msg là một ByteArray
  });
// Định nghĩa cấu trúc Redeemer
  const RedeemerSchema = Data.Object({
  msg: Data.Bytes, // msg là một ByteArray
  });


const Datum = () => Data.to({ msg: fromText("Vu Nam") }, DatumSchema);
console.log("Datum: ", Datum());
const Redeemer = () => Data.to({ msg: fromText("Vu Tai") }, RedeemerSchema);
const lovelace_lock=100_000_789n

 // Lock UTxO
  // export async function lockUtxo(lovelace: bigint,): Promise<string> {
  // const tx = await lucid
  // .newTx()
  // .payToContract(datum_redeemerAddress, { Inline: Datum() }, { lovelace })
  // .commit();
  
  // const signedTx = await tx.sign().commit();
  // console.log(signedTx);
  
  // const txHash = await signedTx.submit();
  
  // return txHash;
  // } 
  
 
  
  // Mở khóa UTxO
  export async function unlockUtxo(redeemer: RedeemerSchema ): Promise<string> {
  
      const utxo = (await lucid.utxosAt(datum_redeemerAddress)).find((utxo) =>
         !utxo.scriptRef && utxo.datum === redeemer
      );
      console.log(`redeemer: ${redeemer}`);
      console.log(`UTxO unlock: ${utxo}`);

      if (!utxo) throw new Error("No UTxO found");
      const tx = await lucid
      .newTx()
      .collectFrom([utxo], redeemer)
      .attachScript(datum_redeemer_scripts)
      .commit();
      
      const signedTx = await tx.sign().commit();
      
      const txHash = await signedTx.submit();
      
      return txHash;
      }
  
  async function main() {
          try {

          //Gọi hàm TxHash để lock UTXO
          // const txHash = await lockUtxo(lovelace_lock); 
          // console.log(`Transaction hash: ${txHash}`);
          
          
          // //Gọi hàm redeemUtxo để mở khóa UTxO
          const txHash = await unlockUtxo(Redeemer());

          console.log(`Transaction hash: ${txHash}`);
          
         } catch (error) {
          console.error("Error :", error);
          }
          }
          
          main();

