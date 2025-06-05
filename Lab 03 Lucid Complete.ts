import { Blockfrost, Lucid, Crypto, Data, fromText, Addresses } from "https://deno.land/x/lucid/mod.ts";

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

const address = await lucid.wallet.address("addr_test1qrqdgvkh2vptvfac7prz45dm7x3pw6kpndmnkujk5wammn9jfxpftgmusjmzr5uvmasm5km5ytmtwh6llmf53ye440usnyh6zg"); 
const utxos = await lucid.utxosAt(address);
console.log(address);

// Soạn thảo mintingpolicy :
const { payment } = Addresses.inspect(
  await lucid.wallet.address(),
);
console.log(`Địa chỉ Payment là: ${payment.hash}`);

// ==================MintingPolicy=================================
const mintingPolicy = lucid.newScript(
  {
    type: "All",
    scripts: [
      { type: "Sig", keyHash: payment.hash },
      {
        type: "Before",
        slot: lucid.utils.unixTimeToSlots(Date.now() + 1000000),
      },
    ],
  }, 
);

// ======================================================
const policyId = mintingPolicy.toHash();

const token_name="Lucid";

const unit = policyId + fromText(token_name);

console.log(`PolicyID là: ${policyId}`);

const metadata= {
  [policyId]: {
        [token_name]: {
            "description": "This is NFT minted by Macbook",
            "name": `${token_name}`,
            "id": 1,
            "image": "ipfs://QmcePMCw7xmNYMsofhDg1oZcAQtmwCvyNj7rWbEBWGhCBc"
        }
    }
};

console.log(metadata);

//================tạo giao dịch và ký giao dich====
const tx = await lucid.newTx()
  .mint({ [unit]: 1n })
  .validTo(Date.now() + 200000)
  .attachScript(mintingPolicy)
  .attachMetadata(721, metadata)
  .commit();
const signedTx = await tx.sign().commit();
// =============================================


const txHash = await signedTx.submit();
console.log(signedTx);
console.log(`Bạn có thể kiểm tra giao dịch tại: https://preview.cexplorer.io/tx/${txHash}`);


//-------TẠO CHỨNG CHỈ STAKE VÀ DELEGATE POOL VÀ DREP CÓ KÈM MỘT TRANSACTION ĐƠN GIẢN------

const rewardAddress = await lucid.wallet.rewardAddress();
console.log(rewardAddress);

const tx = await lucid.newTx()
// DelegVariant = "Abstain" | "NoConfidence" | { DRep: string } | { Pool: string };
  .delegateTo(rewardAddress,{DRep: "drep1y2z3wagn2feyeaw25qu9u2kmlwhm3y8vsgkmtaqrgfz9tlgr5efj7"})
  .payTo("addr_test1qz3vhmpcm2t25uyaz0g3tk7hjpswg9ud9am4555yghpm3r770t25gsqu47266lz7lsnl785kcnqqmjxyz96cddrtrhnsdzl228", { lovelace: 31000000n})
  .commit();

const signedTx = await tx.sign().commit();
const txHash = await signedTx.submit();
// await Deno.writeTextFile("./cbor/delegateToPool.log", `cbor code: ${signedTx}` +"\n");
// await Deno.writeTextFile("./cbor/delegateToPool.log", `Bạn có thể kiểm tra giao dịch tại: https://preview.cexplorer.io/tx/${txHash}` + "\n", { append: true });
console.log(`Bạn có thể kiểm tra giao dịch tại: https://preview.cexplorer.io/tx/${txHash}`);








