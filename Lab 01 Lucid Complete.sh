apt install curl

apt-get updateapt-get install unzip -ycurl -fsSL https://deno.land/install.sh | sh

export PATH="$HOME/.deno/bin:$PATH"

deno -v

mkdir lucid

import { Blockfrost, Lucid, Crypto } from "https://deno.land/x/lucid/mod.ts";// Provider selection// There are multiple builtin providers you can choose from in Lucid.// Blockfrost : previewbjWeyokguJArwoYZFioqk4hn8Pr5wcxU
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

// Lấy address của ví đã login ra:

const address = await lucid.wallet.address(); // Bech32 address
console.log (`Đ/c ví gửi: ${address}`) //Hiện thị địa chỉ ví

// Query UTXO trong address:

const utxos = await lucid.utxosAt(address);
console.log (utxos) //Hiện thị toàn bộ UTxOs

// Lấy thông tin cụ thể một UTXO được chỉ định:

const utxo=utxos[0];
console.log(utxo)
console.log (`lovelace: ${utxo.assets.lovelace}`)

//Lấy thông tin assets có trong utxo đã khai ở bước trên:

// Lấy thông tin assets từ UTxO
const assets = utxo.assets;

// Hiển thị thông tin assets
console.log("Assets:", assets);


// Hiển thị toàn bộ tài sản và giá trị của chúng
for (const assetname in assets) {
console.log(`Assetname: ${assetname}, Value: ${assets[assetname]}`);
}

// Query scriptUtxo
const [scriptUtxo] = await lucid.utxosAt("addr_test1wrv8xtfuwyfsq2zhur8es0aw4pq6uz73um8a4507dj6wkqc4yccnh");
console.log(scriptUtxo)

const datum = await lucid.datumOf(scriptUtxo);
console.log('datum: ', datum)

//đọc datum từ hash 
const datumcbor = await lucid.provider.getDatum("602ca110fe0b1874444086afb8e9e98ecf4372ff7cf44268531249bf793c9065");
console.log (`datum: ${datumcbor}`)

//Đọc thông số của giao thức mạng lưới blockchain Cardano
const protocolParameters = await lucid.provider.getProtocolParameters();
console.log(protocolParameters)

// Tạo giao dịch bằng lucid
const tx = await lucid.newTx()
   .payTo("addr_test1qzhmts2nhr3fpag0wl0ns4puqlseg5ey4hfa3n8w95x9ym0mgx64n2gpvmhy8ru6m08307wwv7q25hmtxafd5end5eusk8c8vd", { lovelace: 10000000n})
.commit();
console.log('tx: ${tx}')
// Sign transaction

const signedTx = await tx.sign().commit();
console.log(`signedTx: ${signedTx}`)
const txHash = await signedTx.submit();

//Tạo giao dịch gửi tới nhiều địa chỉ trong một giao dịch:
const receiver = "addr_test1qz3vhmpcm2t25uyaz0g3tk7hjpswg9ud9am4555yghpm3r770t25gsqu47266lz7lsnl785kcnqqmjxyz96cddrtrhnsdzl228";
const receiver2 = "addr_test1qrqdgvkh2vptvfac7prz45dm7x3pw6kpndmnkujk5wammn9jfxpftgmusjmzr5uvmasm5km5ytmtwh6llmf53ye440usnyh6zg";
const receiver3 = "addr_test1qzhx5h84aqv3sjl9ylup5636amed0w43c3h7znml4ehf27654vw2tfl2679u642fuctay47kqsyr7dre3p68tnt4nnmqv0rhen";
const tien = 5000000;
const metadata = { msg: ["VuNam_31. metadata 674"] };

const tx = await lucid.newTx()
    .payTo(receiver, { lovelace: tien })
    .payTo(receiver2, { lovelace: tien })
    .payTo(receiver3, { lovelace: tien })
    .attachMetadata(674, metadata)
.commit();

const signedTx = await tx.sign().commit();
const txHash = await signedTx.submit();

console.log(`signedtx: ${signedTx}`)
console.log(`txhash: ${txHash}`)