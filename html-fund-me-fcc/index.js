import { ethers } from "./ethers-5.6.esm.min.js";
import { abi, contractAddress } from "./constants.js";

const connectButton = document.getElementById("connectButton");
const withdrawButton = document.getElementById("withdrawButton");
const fundButton = document.getElementById("fundButton");
const balanceButton = document.getElementById("balanceButton");
connectButton.onclick = connect;
withdrawButton.onclick = withdraw;
fundButton.onclick = fund;
balanceButton.onclick = getBalance;

async function connect() {
  if (typeof window.ethereum !== "undefined") {
    try {
      // Request metamask accounts
      await ethereum.request({ method: "eth_requestAccounts" });
    } catch (error) {
      console.log(error);
    }
    connectButton.innerHTML = "Connected";
    // Get connected accounts
    const accounts = await ethereum.request({ method: "eth_accounts" });
    console.log(accounts);
  } else {
    connectButton.innerHTML = "Please install MetaMask";
  }
}

async function withdraw() {
  console.log(`Withdrawing...`);
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(contractAddress, abi, signer);
    try {
      // Call the withdraw function
      const transactionResponse = await contract.withdraw();
      await listenForTransactionMine(transactionResponse, provider);
      // await transactionResponse.wait(1)
    } catch (error) {
      console.log(error);
    }
  } else {
    withdrawButton.innerHTML = "Please install MetaMask";
  }
}

async function fund() {
  const ethAmount = document.getElementById("ethAmount").value;
  console.log(`Funding with ${ethAmount}...`);
  if (typeof window.ethereum !== "undefined") {
    // To send a transaction we always need a provider (connection) to the blockchain and we need a signer (wallet, someone with some has)
    // We also need a smart contract that we want to interact with, for which we need its ABI and address

    // Web3Provider is an object in ethers that allows us to wrap around Metamask it takes the http endpoint from our connected Metamask and sticks it into ethers for us
    // This line of code looks at the http endpoint inside of Metamask, which is what will be used as provider
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    // Since provider is connected to Metamask we can easily get the signer
    const signer = provider.getSigner();
    // Connect to the contract
    const contract = new ethers.Contract(contractAddress, abi, signer);

    try {
      const transactionResponse = await contract.fund({
        value: ethers.utils.parseEther(ethAmount),
      });
      // Wait for tx to finish
      await listenForTransactionMine(transactionResponse, provider);
    } catch (error) {
      console.log(error);
    }
  } else {
    fundButton.innerHTML = "Please install MetaMask";
  }
}

async function getBalance() {
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    try {
      // Get the balance
      const balance = await provider.getBalance(contractAddress);
      console.log(ethers.utils.formatEther(balance));
    } catch (error) {
      console.log(error);
    }
  } else {
    balanceButton.innerHTML = "Please install MetaMask";
  }
}

function listenForTransactionMine(transactionResponse, provider) {
  // Show hash of response
  console.log(`Mining ${transactionResponse.hash}`);
  // We are returning a promise, because we need to create a listener for the blockchain
  // Without this promise the listenForTransactionMine function would finish without waiting for the provider.once() function to finish its execution
  // We need the promise so the code runs in our desired order and doesn't skip ahead
  return new Promise((resolve, reject) => {
    try {
      // once listens for an event one time
      provider.once(transactionResponse.hash, (transactionReceipt) => {
        console.log(
          `Completed with ${transactionReceipt.confirmations} confirmations. `
        );
        // Resolve the promise
        resolve();
      });
    } catch (error) {
      // Reject the promise
      reject(error);
    }
  });
}
