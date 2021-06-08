const Web3 = require("web3");
const web3 = new Web3("HTTP://127.0.0.1:7545");
const token = require("./build/contracts/MAP.json")
const contract = new web3.eth.Contract(
  token.abi,
  "0x2f47E0511AbB8120a44980799629823A466A71CE"
);
var accounts;

// console.log(token.abi)
const init = async () =>{
    accounts = await web3.eth.getAccounts();

    // console.log(await contract.methods.totalSupply().call());
    // ("0xf2E4Dc360553923c17d63C6E96acd29a0AB2e9C0",100000000);
    // events()
    // deposit(1000000000);
    const data = await contract.methods.data(1).call();
    console.log(data.interest);


}

const deposit = async (val) =>{
    console.log("depositing tokens");
    await contract.methods.deposit(val).send({from:accounts[0],gas:1000000});
    console.log("done");
}

const transfer = async (ad,val) =>{
    console.log('trasfering tokens from '+accounts[0]+' to '+ad);
    await contract.methods.transfer(ad,val).send({from:accounts[0]})
    console.log("successful transaction")
}

const withdraw = async (val) => {
  console.log("withdrawing tokens");
  await contract.methods.withdraw(val).send({ from: accounts[0] });
  console.log("done");
};

function events(){
    contract.getPastEvents(
      "Deposit",
      {
        filter: {
          _owner: "0x22004c203d5548E0C9FF7B3705911D7BA908D7Fc",
        },
        fromBlock: 0,
        toBlock: "latest",
      },
      (err, events) => {
        for (let i = 0; i < events.length; i++) {
          console.log(events[i].returnValues._tokenId);;
        }
      }
    );
}

init()