Bài 1: Hàm chuyển function nhiều địa chỉ:  async function createMultipleRecipients(payments: { address: string, amount: bigint }[]) {
  let tx = lucid.newTx();
  for (const payment of payments) {
  tx = tx.payTo(payment.address, { lovelace: payment.amount });
  }
  tx = await tx.commit();
  return tx;
  }



//1. Multiple recipients
const tx = await createMultipleRecipients([
  { address: "addr_test1qq9mrj6gxeny2cl99thrd6wvv3vr8n3tvtxa78jgdxegjp3p4neh4ew5j446xthascrs6t6k3x48jqum62yq06gf8wkslw2scz", amount: 1000000n },
  { address: "addr_test1qq9mrj6gxeny2cl99thrd6wvv3vr8n3tvtxa78jgdxegjp3p4neh4ew5j446xthascrs6t6k3x48jqum62yq06gf8wkslw2scz", amount: 2000000n },
  { address: "addr_test1qq9mrj6gxeny2cl99thrd6wvv3vr8n3tvtxa78jgdxegjp3p4neh4ew5j446xthascrs6t6k3x48jqum62yq06gf8wkslw2scz", amount: 3000000n }
  ]);

console.log(`tx: ${tx}`);


let signedTx = await tx.sign().commit();
let txHash = await signedTx.submit();
  
console.log(`Transaction hash: https://preview.cexplorer.io/tx/${txHash}`);



Bài 2: Hàm gửi token :  async function createSendNativeTokens(toAddress: string, policyId: string, assetName: string, amount: bigint) {
  const tx = await lucid.newTx()
  .payTo(toAddress, { [policyId + fromText(assetName)]: amount })
  //.payTo(toAddress, { lovelace: 10_000_000n, [policyId + fromText(assetName)]: amount })
  .commit();
  return tx;
  }

  const toAddress = "addr_test1qq9mrj6gxeny2cl99thrd6wvv3vr8n3tvtxa78jgdxegjp3p4neh4ew5j446xthascrs6t6k3x48jqum62yq06gf8wkslw2scz";
  const amount = 30n;

  //3. Send native tokens
const tx = await createSendNativeTokens(toAddress, "804fd2ddbd0ed3de8ca4dff96afb0af79a76e52ec901a977a09c0cf1", "KHBK02", 30n);

console.log(`tx: ${tx}`);


let signedTx = await tx.sign().commit();
let txHash = await signedTx.submit();
  
console.log(`Transaction hash: https://preview.cexplorer.io/tx/${txHash}`);  Lưu ý: Phải để biến assetname dưới dạng Text và thêm fromtext ở trên thư viên import lệnh đầu tiên.



Bài 3: Tạo giao dịch và gửi đi cùng datumn được tạo:  async function createSendAdaWithDatum(toAddress: string, datum: any, amount: bigint) {
  const tx = await lucid.newTx()
  .payToWithData(toAddress, datum , { lovelace: amount })
  .commit();
  return tx;
  }

//---------------------------------------------------
const VestingSchema = Data.Object({
  lock_until: Data.Integer(),
  beneficiary: Data.Bytes(),
  });
  
  type VestingSchema = typeof VestingSchema;
  
  
  // Set the vesting deadline
  const deadlineDate: Date = new Date("2026-06-09T00:00:00Z")
  const deadlinePosIx = BigInt(deadlineDate.getTime());
  
  
  const { payment } = Addresses.inspect(
  "addr_test1qzjzr7f3yj3k4jky7schc55qjclaw6fhc3zfnrarma9l3579hwurrx9w7uhz99zdc3fmmzwel6hac404zyywjl5jhnls09rtm6",
  );
  
  //---------------------------------------------------
  const d = {
  lock_until: deadlinePosIx,
  beneficiary: payment?.hash,
  };
  const datum = await Data.to<VestingSchema>(d, VestingSchema);
  
  console.log("Datum:", datum);

  const tx = await createSendAdaWithDatum(
    "addr_test1qzjzr7f3yj3k4jky7schc55qjclaw6fhc3zfnrarma9l3579hwurrx9w7uhz99zdc3fmmzwel6hac404zyywjl5jhnls09rtm6",
    datum,
    5000000n, // 5 ADA (đơn vị: lovelace)
  );


  console.log(`tx: ${tx}`);
  
  let signedTx = await tx.sign().commit();
  let txHash = await signedTx.submit();
    
  console.log(`Transaction hash: https://preview.cexplorer.io/tx/${txHash}`);   Lưu ý: thêm biến Addreses, Data ở trên import thư viện của Deno.



Bài 4 : Tạo giao dịch đi kèm datum có lệnh lock và unlock UTXO.  //scripts alwaysSucceed 
const alwaysSucceed_scripts1 = lucid.newScript({
  type: "PlutusV2",
  script: "49480100002221200101",
  });
  const alwaysSucceed_scripts = lucid.newScript({
  type: "PlutusV3",
  script: "588501010029800aba2aba1aab9faab9eaab9dab9a48888896600264653001300700198039804000cc01c0092225980099b8748008c01cdd500144c8cc896600266e1d2000300a375400d132325980098080014528c5900e1bae300e001300b375400d16402460160026016601800260106ea800a2c8030600e00260066ea801e29344d9590011",
  });
  
const alwaysSucceedAddress = alwaysSucceed_scripts.toAddress();
console.log(`Always succeed address: ${alwaysSucceedAddress}`);



const Datum = () => Data.void();
// const Redeemer = () => Data.void();
// Định nghĩa cấu trúc Redeemer
const RedeemerSchema = Data.Object({
msg: Data.Bytes, // msg là một ByteArray
});

// Tạo một Redeemer với giá trị cụ thể
const Redeemer = () => Data.to({ msg: fromText("Vu Nam!") }, RedeemerSchema); 
const lovelace_lock=500_999_999n

// Lock UTxO
export async function lockUtxo(lovelace: bigint,): Promise<string> {
  const tx = await lucid
  .newTx()
  .payToContract(alwaysSucceedAddress, { Inline: Datum() }, { lovelace })
  .commit();
  
  const signedTx = await tx.sign().commit();
  console.log(signedTx);
  
  const txHash = await signedTx.submit();
  
  return txHash;
  }

// ----------check tình trạng lock UTXO và log ra Lock TxHash -------------
const txHash = await lockUtxo(lovelace_lock);
console.log(`Lock TxHash: ${txHash}`);




// Mở khóa UTxO
export async function unlockUtxo(lovelace: bigint ): Promise<string> {

  const utxo = (await lucid.utxosAt(alwaysSucceedAddress)).find((utxo) => 
  utxo.assets.lovelace == lovelace && utxo.datum === Datum() && !utxo.scriptRef 
  );
  console.log(utxo);
  if (!utxo) throw new Error("No UTxO with lovelace > 1000 found");

const recipientAddress = "addr_test1qz3vhmpcm2t25uyaz0g3tk7hjpswg9ud9am4555yghpm3r770t25gsqu47266lz7lsnl785kcnqqmjxyz96cddrtrhnsdzl228";
const myAddress = "addr_test1qzhx5h84aqv3sjl9ylup5636amed0w43c3h7znml4ehf27654vw2tfl2679u642fuctay47kqsyr7dre3p68tnt4nnmqv0rhen";

  const tx = await lucid
  .newTx()
  .collectFrom([utxo], Redeemer())
  .attachScript(alwaysSucceed_scripts)
  .payTo(recipientAddress, { lovelace: 31_000_000n }) // 43 tADA
  .payTo(myAddress, { lovelace: utxo.assets.lovelace - 31_000_000n }) // Số còn lại
  .commit();
  
  const signedTx = await tx.sign().commit();
  
  const txHash = await signedTx.submit();
  
  return txHash;
  }

async function main() {
      try {
      // const txHash = await lockUtxo(lovelace_lock); // Khóa 2 ADA (2_000_000 lovelace)
      // console.log(`Transaction hash: ${txHash}`);
      
      
      // Gọi hàm redeemUtxo để mở khóa UTxO
      const redeemTxHash = await unlockUtxo(lovelace_lock);
      console.log(`Transaction hash: ${redeemTxHash}`);
      
      
      } catch (error) {
      console.error("Error locking UTxO:", error);
      }
      }
      
      main();

