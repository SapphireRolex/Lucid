

-------------Setting Aiken & install extension Aiken-------------

curl --proto '=https' --tlsv1.2 -LsSf https://install.aiken-lang.org | sh 
source $HOME/.aiken/bin/env
apt install git (option)
aikup

aiken new aiken-lang/hello-world
cd hello-world

use aiken/primitive/string
use cardano/transaction.{OutputReference, Transaction}

pub type Redeemer {
msg: ByteArray,
}

// The validator is a function that takes the following arguments:
// - datum: the datum of the UTXO being spent
// - redeemer: the redeemer of the UTXO being spent
// - utxo: the UTXO Reference 
// - self: the transaction being created
// - ctx: the script context
// The validator returns a boolean value indicating whether the transaction is valid or not

validator alwayssuccess {
spend(
_datum: Option<Data>,
redeemer: Redeemer,
_utxo: OutputReference,
_self: Transaction,
) {
// The redeemer is a custom type that contains a message
trace @"redeemer": string.from_bytearray(redeemer.msg)
let a = True
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


----Chạy aiken check và aiken build để lấy mã CBOR Rồi paste qua Script để lấy mã CBOR đã tạo qua aiken và chạy các lệnh lock&unlock UTXO------

const alwaysSucceed_scripts = lucid.newScript({
  type: "PlutusV3",
  script: "Mã CBOR",
  });

END...






