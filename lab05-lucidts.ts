import { Blockfrost, Lucid, Crypto } from "https://deno.land/x/lucid/mod.ts";

const lucid = new Lucid({
    provider: new Blockfrost(
        "https://cardano-preview.blockfrost.io/api/v0", 
        "nhap vao id tren blockfrost",
    ),
});

const seed = " 24 ky tu"
lucid.selectWalletFromSeed(seed, { addressType: "Base", index: 0});
console.log(lucid); 

const address = await lucid.wallet.address(); 
const utxos = await lucid.utxosAt(address);

console.log(address);
console.log(utxos);
console.log('lovelace: '+utxos[4].assets.lovelace);
const assets = utxos[6].assets
console.log('assests: ', assets)

// //hien thi datum
// const [scriptUtxo] = await lucid.utxosAt("addr_test1wrv8xtfuwyfsq2zhur8es0aw4pq6uz73um8a4507dj6wkqc4yccnh");
// // console.log(scriptUtxo)

// const datum = await lucid.datumOf(scriptUtxo);
// // console.log('datum: ', datum)


//lấy thông tin prococol
// const protocolParams = await lucid.provider.getProtocolParameters();
// console.log(protocolParams);

// tạo giao dịch bằng lucid
// const tx = await lucid.newTx()
//     .payTo("addr_test1qzhmts2nhr3fpag0wl0ns4puqlseg5ey4hfa3n8w95x9ym0mgx64n2gpvmhy8ru6m08307wwv7q25hmtxafd5end5eusk8c8vd", { lovelace: 10000000n})
//     .commit();
//     console.log('tx: ${tx}')
// Sign transaction

// const signedTx = await tx.sign().commit();
// console.log(`signedTx: ${signedTx}`)
// const txHash = await signedTx.submit();



const receiver = "addr_test1qz3vhmpcm2t25uyaz0g3tk7hjpswg9ud9am4555yghpm3r770t25gsqu47266lz7lsnl785kcnqqmjxyz96cddrtrhnsdzl228";
const tien = 31000000;
const metadata = { msg: ["VuNam_31. metadata 674"] };

const tx = await lucid.newTx()
    .payTo(receiver, { lovelace: tien })
    .attachMetadata(674, metadata)
.commit();

const signedTx = await tx.sign().commit();
const txHash = await signedTx.submit();

console.log(`signedtx: ${signedTx}`)
console.log(`txhash: ${txHash}`)

Deno.exit(0);
