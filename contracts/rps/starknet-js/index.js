import { Account, RpcProvider, json, Contract } from "starknet";
import fs from "fs";
import * as dotenv from "dotenv";
dotenv.config();

const provider = new RpcProvider({
    nodeUrl: "https://free-rpc.nethermind.io/sepolia-juno",
  });
const accountAddress = 0x0612997Ce52B1f6276B11A3E31D2E932F0B88ade3a3B091E3BD47829661f83a0;

const privateKey = process.env.PRIVATE_KEY;
// "1" is added to show that our account is deployed using Cairo 1.0.
const account = new Account(provider, accountAddress, privateKey, "1");

const compiledContractAbi = json.parse(
    fs.readFileSync("./abi.json").toString("ascii")
  );
  const storageContract = new Contract(
    compiledContractAbi.abi,
    contractAddress,
    provider
  );

let get_winner = await storageContract.get();
console.log("Stored_data:", get_winner.toString());