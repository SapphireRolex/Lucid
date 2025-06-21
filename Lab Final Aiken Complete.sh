----------Tạo validator với cấu trúc mint và burn NFT-----------------

use aiken/collection/dict
use aiken/collection/list
use aiken/primitive/bytearray
use cardano/address.{Address}
use cardano/assets.{PolicyId}
use cardano/transaction.{Output, Transaction} as tx

pub type Action {
  Minting_NFT
  Burning_NFT
}

validator mint_send_nft(prifix_token_name: ByteArray) {
  // redeemer, policy_id, transaction đều được lấy từ transaction thực
  mint(rdmr: Action, policy_id: PolicyId, transaction: Transaction) {
    let Transaction { mint, outputs, .. } = transaction
    let four_outputs = list.length(outputs) == 4
    //The payment credential of addr_test1qz3vhmpcm2t25uyaz0g3tk7hjpswg9ud9am4555yghpm3r770t25gsqu47266lz7lsnl785kcnqqmjxyz96cddrtrhnsdzl228 is a2cbec38da96aa709d13d115dbd79060e4178d2f775a528445c3b88f
    let c2vn_addr =
      address.from_verification_key(
        #"a2cbec38da96aa709d13d115dbd79060e4178d2f775a528445c3b88f",
      )
    expect [Pair(asset_name, amount)] =
      mint
        |> assets.tokens(policy_id)
        |> dict.to_pairs()
    let sent_nft_to_c2vn = find_output(outputs, asset_name, c2vn_addr)
    when rdmr is {
      Minting_NFT -> amount == 1 && sent_nft_to_c2vn && four_outputs
      Burning_NFT -> amount == -1 && sent_nft_to_c2vn && four_outputs
    }
  }

  else(_) {
    fail
  }
}

fn find_output(outputs: List<Output>, asset_name: ByteArray, addr_cred: Address) {
  list.any(
    outputs,
    fn(output) {
      bytearray.slice(asset_name, start: 0, end: 3) == prifix_token_name && output.address.payment_credential == addr_cred.payment_credential
    },
  )
}


----------Lucid--------------


import {  Blockfrost, Lucid, Addresses,fromHex,toHex,applyParamsToScript, Data, Constr,fromText } from "https://deno.land/x/lucid@0.20.9/mod.ts";
import * as cbor from "https://deno.land/x/cbor@v1.4.1/index.js";


const lucid = new Lucid({
  provider: new Blockfrost(
    "https://cardano-preview.blockfrost.io/api/v0",
    "previewTN8UXKGlPYoZF3fPyqhtaK4H3jNoGIQc"
  ),
});

// Chọn ví từ bộ seed phrase:
const seed = "december fantasy news diary valve valley lawn bachelor video degree success shy essay mushroom kidney lab melody happy limit lounge chest club have outside";
lucid.selectWalletFromSeed(seed);

const wallet_address = await lucid.wallet.address();
console.log(`dia chi vi la: ${wallet_address}`);

const payment_hash = Addresses.inspect(wallet_address).payment?.hash;
if (!payment_hash) {
  throw new Error("Failed to extract payment hash from address");
}

//===============Đặt tên token và setting phí trả về platform==================
const ma_khoa_hoc = fromText("BK02");


//------Kê khai thông tin địa chỉ nhận fee của platform---------
const payment_credential = Addresses.inspect(
  "addr_test1qz3vhmpcm2t25uyaz0g3tk7hjpswg9ud9am4555yghpm3r770t25gsqu47266lz7lsnl785kcnqqmjxyz96cddrtrhnsdzl228"
).payment?.hash;
console.log(payment_credential);


//-------Gọi và truyền thông tin định dạng của biến multiparams-----------
const validator = await readValidator();
const Params = [Data.Bytes()];
const parameterized_script = lucid.newScript(
  {
    type: "PlutusV3",
    script: validator.script,
  },
  [ma_khoa_hoc],
  Params
);

//------Tạo các thông tin về địa chỉ script và tạo policy cùng tên cho NFT----------
const scriptAddress = parameterized_script.toAddress();
console.log(`Địa chỉ Parameterized script là: ${scriptAddress}`);
const policyId = parameterized_script.toHash();
const unit = policyId + fromText("BK02_VU_VAN_NAM");

const mintRedeemer = Data.to(new Constr(0, []));
// const mintRedeemer = Data.void()
const recipient = "addr_test1qz3vhmpcm2t25uyaz0g3tk7hjpswg9ud9am4555yghpm3r770t25gsqu47266lz7lsnl785kcnqqmjxyz96cddrtrhnsdzl228";
const tx = await lucid
  .newTx()
  .mint({ [unit]: 1n }, mintRedeemer)
  .payTo(
    "addr_test1qz22wkszyt9kgqhk24670xz7ehs9tvlhq079rzy5vyekn5p5x065mhvs0z9p2gymxgguy3w0v5qnk39klvaapeqla97qsdltfy",
    { lovelace: 10000000n }
  )
    .payTo(
    "addr_test1qrqdgvkh2vptvfac7prz45dm7x3pw6kpndmnkujk5wammn9jfxpftgmusjmzr5uvmasm5km5ytmtwh6llmf53ye440usnyh6zg",
    { lovelace: 10000000n }
  )
  .payTo(recipient, {
    [unit]: 1n,
    lovelace: 10000000n      
  })
  .attachScript(parameterized_script)
  .commit();

const signedTx = await tx.sign().commit();
await Deno.writeTextFile("Mint-signedTx.cbor", signedTx);
const txHash = await signedTx.submit();
console.log(`A NFT was mint at tx:    https://preview.cexplorer.io/tx/${txHash} `);

//===============Đọc mã CBOR của SC  ============================
async function readValidator(): Promise<SpendingValidator> {
  const validator = JSON.parse(await Deno.readTextFile("plutus.json")).validators[0];
  return {
    type: "PlutusV3",
    script: toHex(cbor.encode(fromHex(validator.compiledCode))),
  };
}


