-----Add thêm trường dữ liệu của aiken toml-------------
[[dependencies]]
name = "sidan-lab/vodka"
version = "0.1.1-beta"
source = "github"


=> Chạy aiken check


-----Tạo Validator SC với điều kiện thụ hưởng theo bài giảng---------
use aiken/crypto.{VerificationKeyHash}
use cardano/transaction.{OutputReference, Transaction}

use vodka_extra_signatories.{key_signed}
use vodka_validity_range.{valid_after}

pub type VestingDatum {
/// POSIX time in milliseconds, e.g. 1672843961000
lock_until: Int,
/// Owner's credentials
owner: VerificationKeyHash,
/// Beneficiary's credentials
beneficiary: VerificationKeyHash,
}


validator vesting {
// In principle, scripts can be used for different purpose (e.g. minting
// assets). Here we make sure it's only used when 'spending' from a eUTxO
spend(
datum_opt: Option<VestingDatum>,
_redeemer: Data,
_input: OutputReference,
tx: Transaction,
) {
expect Some(datum) = datum_opt
or {
key_signed(tx.extra_signatories, datum.owner),
and {
key_signed(tx.extra_signatories, datum.beneficiary),
valid_after(tx.validity_range, datum.lock_until),
},
}
}

else(_) {
fail
}
}

------Lấy mã CBOR trong file JSON qua LUCID-------
import { Blockfrost, Lucid, Crypto, Data, fromText, Addresses, String, Integer } from "https://deno.land/x/lucid/mod.ts";

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
lucid.selectWalletFromSeed(seed, { addressType: "Base", index: 1});
console.log(lucid);

const address = await lucid.wallet.address("addr_test1qzhx5h84aqv3sjl9ylup5636amed0w43c3h7znml4ehf27654vw2tfl2679u642fuctay47kqsyr7dre3p68tnt4nnmqv0rhen"); 
console.log(address);


// Khai biến địa chỉ chủ sở hữu hợp đồng.
const { payment: paymentOwner  } = Addresses.inspect(address);
console.log(`paymentOwner.hash: ${paymentOwner.hash}`);

// Khai biến địa chỉ thụ hưởng hợp đồng.
const { payment: paymentBeneficiary } = Addresses.inspect(
  "addr_test1qpzsx7wl2ta9l9gayrh2l25y6jn5zdc3e6eq55tfeq4jgm6ln7cayuvdl767wfq3y6z99h9lnal927rnjweahlqlkn0qfth9z8",
);
console.log(`paymentBeneficiary.hash: ${paymentBeneficiary.hash}`);


//Tạo ra script từ CBOR của validator 
const vesting_scripts = lucid.newScript({
  type: "PlutusV3",
  script: "59018d01010029800aba2aba1aba0aab9faab9eaab9dab9a488888896600264653001300800198041804800cdc3a400530080024888966002600460106ea800e2646644b30013370e900018059baa0018cc004c03cc030dd5000c8c040c044c044c044c044c044c044c044c04400644646600200200644b30010018a508acc004cdc79bae30130010038a51899801001180a000a01c40449112cc004cc004dd6180118079baa007375c60246026601e6ea800e29462b30013300137586004601e6ea801cdd718091809980998079baa003899191919912cc004c034c04cdd50014566002601a60266ea8c05cc06000e266e20004dd6980b980a1baa002899b89001375a602e60286ea8009012452820243015001375a602a60246ea8018cc04cc050004cc04e6002601460206ea8c050c05400698103d87a8000a60103d8798000403c97ae030103754602660206ea8004c048c04cc04cc04cc04cc04cc04cc04cc03cdd5003c528201a40348b2014300d001300d300e0013009375400716401c300800130033754011149a26cac8009",
  });
//Tạo SC address từ script đã tạo
const signerbyAddress = vesting_scripts.toAddress();
console.log(`vesting address: ${signerbyAddress}`);

//Định dạng biến cho Vestingdatum
const Vestingdatum = Data.Object({
  lock_until: Data.Integer(),
  owner: Data.Bytes,
  beneficiary: Data.Bytes(), //VerificationKeyHash
});
type Vestingdatum = typeof Vestingdatum;

// Khai biến thời gian cho vesting deadline
const deadlineDate1: Date = new Date("2025-04-01T10:00:00Z");
const deadlineDate: Date = Date.now(); 
const offset = 5 * 60 * 1000; // 5 phút
const deadlinePosIx =BigInt((deadlineDate+offset))
console.log("deadlinePosIx: ", deadlinePosIx);

// Định nghĩa cấu trúc cho datum
const d = {
    lock_until: deadlinePosIx,
    owner: paymentOwner?.hash,
    beneficiary: paymentBeneficiary?.hash,
};
const datum = await Data.to<Vestingdatum>(d, Vestingdatum);

// Định nghĩa cấu trúc Redeemer
const RedeemerSchema = Data.Object({
  value: Data.Bytes, // msg là một ByteArray
});
type RedeemerSchema = typeof RedeemerSchema;

// Tạo một Redeemer với giá trị cụ thể
const Redeemer = () => Data.to({ value: fromText("Hello world!") }, RedeemerSchema); // "48656c6c6f20576f726c64" là chuỗi "Hello World" được mã hóa dưới dạng hex
const lovelace_lock=50_100_123n

// Lock UTxO (Khi lock cần phải để ý địa chỉ đúng index của owner)  

export async function lockUtxo(lovelace: bigint,): Promise<string> {
  console.log("=====Lock UTxO===========================================================")
  console.log("")
  console.log("Datum lock_until: ", Number(d.lock_until));

  const tx = await lucid
    .newTx()
    .payToContract(signerbyAddress, { Inline: datum }, { lovelace })
    .validTo(Date.now() + 100000)
    .commit();

  const signedTx = await tx.sign().commit();
  // console.log(signedTx);

  const txHash = await signedTx.submit();

  return txHash;
}

// Mở khóa UTxO (Khi unlock cần phải để ý địa chỉ đúng index của beneficiary)  

export async function unlockUtxo(redeemer: RedeemerSchema, find_vest: Data.Bytes): Promise<string> {
  // Tìm UTxO tại địa chỉ signerbyAddress
  console.log("====Unlock UTxO============================================================")
  console.log("")
  const utxo = (await lucid.utxosAt(signerbyAddress)).find((utxo) => {
    if (!utxo.scriptRef && utxo.datum) {
      // Giải mã utxo.datum thành đối tượng Vestingdatum
      const decodedDatum = Data.from<Vestingdatum>(utxo.datum, Vestingdatum);

      // So sánh trường owner với expectedOwner
      return decodedDatum.owner === find_vest || decodedDatum.beneficiary === find_vest;
    }
    return false;
  });

  if (!utxo) {
    throw new Error("No matching UTxO found");   
  }

  console.log(`Unlock UTxO.txhash: ${utxo.txHash}`); // Hiển thị Datum của UTxO

  const decodedDatum1 = Data.from<Vestingdatum>(utxo.datum, Vestingdatum);
  // console.log("Now:              ", BigInt(lucid.utils.unixTimeToSlots(Date.now()) ));
  // console.log("Now:              ", Date.now()) ;
  console.log("Datum lock_until: ", Number(decodedDatum1.lock_until));
  console.log("Time offset:      ", -Number(decodedDatum1.lock_until) + Date.now());
  console.log(`Datum owner: ${decodedDatum1.owner}`);
  console.log(`Datum beneficiary: ${decodedDatum1.beneficiary}`);

  console.log(`Redeemer: ${redeemer}`); 
 
  const offsetvalid= 1 * 60 * 1000; // 1 phút

  // Tiếp tục thực hiện giao dịch
  const tx = await lucid
    .newTx()
    .collectFrom([utxo], redeemer)
    .attachScript(vesting_scripts)
    .addSigner(paymentOwner?.hash)
    .validTo(Date.now() + offsetvalid)
    .validFrom(Date.now() - offsetvalid)
    .commit();
  
  const signedTx = await tx.sign().commit();
  // console.log("tx: ", tx);
  const txHash = await signedTx.submit();

  return txHash;
}

async function main() {
  try {
    // Gọi hàm lockUtxo để khóa UTxO
    // const txHash = await lockUtxo(lovelace_lock);


    // Gọi hàm unlockUtxo để mở khóa UTxO
    const txHash = await unlockUtxo(Redeemer(), d.owner);

  console.log(`Transaction hash: https://preview.cexplorer.io/tx/${txHash}`);
  } catch (error) {
    console.error("Error main :", error);
  }
}

main();