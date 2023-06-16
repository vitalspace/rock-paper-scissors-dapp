<script lang="ts">
  //@ts-ignore
  import { Web3 } from "svelte-web3";
  import MetamaskIcon from "./components/metamaskIcon.svelte";
  import Contract from "./lib/contract.json";
  let isLoggedIn: boolean = false;
  let chosenOption: number;
  let gameResult: string = "on hold!";

  class App {
    netWorkId: number = 5777;
    contract_address: string = "0xFE63d267D0B5039609DF2f595939dcDA5ee76698";
    web3;
    constructor() {
      this.isLoggedIn();
    }

    async isLoggedIn() {
      //@ts-ignore
      const account = await window.ethereum.request({
        method: "eth_accounts",
      });
      if (account.length > 0) {
        isLoggedIn = true;
        this.loadweb3();
      } else {
        isLoggedIn = false;
      }
    }

    login = async () => {
      //@ts-ignore
      if (window.ethereum) {
        //@ts-ignore
        window.ethereum
          .request({
            method: "eth_requestAccounts",
          })
          .then((res) => {
            if (res) {
              // isLoggedIn = true;
              this.isLoggedIn();
            }
          })
          .catch((err) => {
            if (err.message == "User rejected the request.") isLoggedIn = false;
          });
      }
    };

    async loadweb3() {
      //@ts-ignore
      if (window.ethereum) {
        //@ts-ignore
        this.web3 = await new Web3(window.ethereum);
        this.loadContract();
      }
    }

    async loadContract() {
      const contract = new this.web3.eth.Contract(
        Contract,
        this.contract_address
      );
      return contract;
    }

    game = async (selection: number) => {
      try {
        const contract = await this.loadContract();
        const method = await contract._methods;
        //@ts-ignore
        const account = await window.ethereum.request({
          method: "eth_accounts",
        });
        chosenOption = selection;
        method
          .jugar(chosenOption)
          .send({
            from: account[0],
            gas: 3000000,
          })
          .on("transactionHash", function (hash) {
            console.log("Transaction sent: " + hash);
          })
          .on("receipt", function (receipt) {
            console.log("Confirmed transaction");
            contract
              .getPastEvents("Juego", {
                fromBlock: receipt.blockNumber,
                toBlock: receipt.blockNumber,
                filter: { jugador: account[0] },
              })
              .then(function (events) {
                if (events.length > 0) {
                  const juegoEvento = events[0].returnValues;

                  const opcionJugador = parseInt(juegoEvento.opcionJugador);
                  const opcionContrato = parseInt(juegoEvento.opcionContrato);
                  const resultado = parseInt(juegoEvento.resultado);

                  if (resultado === 1) {
                    if (
                      (opcionJugador === 1 && opcionContrato === 3) || // Rock vs. Scissors
                      (opcionJugador === 2 && opcionContrato === 1) || // Paper vs. Rock
                      (opcionJugador === 3 && opcionContrato === 2) // Scissors vs. Paper
                    ) {
                      gameResult = "You win!";
                    } else {
                      gameResult = "Draw!";
                    }
                  } else if (resultado === -1) {
                    gameResult = "You lost!";
                  } else {
                    gameResult = "Draw!";
                  }
                } else {
                  console.log(
                    "The Game event was not emitted for your address."
                  );
                }
              })
              .catch(function (error) {
                console.error("Error getting events: ", error);
              });
          })
          .catch((err) => {
            if (err.code == 100) {
              alert("Error you rejected the transaction");
            }
          });
      } catch (error) {
        console.error("Error: ", error);
      }
    };
  }

  const app = new App();
</script>

<div class="flex items-center justify-center h-screen bg-[#084675]">
  <div
    class="flex flex-wrap justify-center w-full text-center py-4 sm:w-4/5 lg:w-1/5 rounded-md bg-[#8d7bea] shadow-md"
  >
    <div class="w-full">
      <h1 class="text-3xl text-white py-2">
        Rock Paper Scissors <span class="text-teal-400">Dapp</span>
      </h1>
    </div>
    {#if !isLoggedIn}
      <div class="py-8 w-4/5 bg-slate-800 my-2 rounded-md">
        <h2 class="text-2xl text-white">Please Sing in to play</h2>
      </div>
      <button
        on:click={app.login}
        class="w-4/5 my-2 bg-teal-300 text-center flex justify-center hover:bg-teal-400 transition-all"
      >
        <MetamaskIcon />
      </button>
    {:else}
      <div class="py-4 w-4/5 my-2 bg-slate-800 rounded-md">
        <div class="my-2">
          <h2 class="text-2xl text-white">Select one option:</h2>
        </div>
        <div class="flex justify-center items-center space-x-4 text-white">
          <button on:click={() => app.game(1)} class="px-4 py-2"
            ><img
              src="rock.gif"
              class="scale-100 hover:scale-125 ease-in duration-200 hover:shadow-md hover:shadow-cyan-300"
              alt=""
            /></button
          >
          <button on:click={() => app.game(2)} class="px-4 py-2"
            ><img
              src="paper.gif"
              class="scale-100 hover:scale-125 ease-in duration-200 hover:shadow-md hover:shadow-cyan-300"
              alt=""
            /></button
          >
          <button on:click={() => app.game(3)} class="px-4 py-2"
            ><img
              src="scissors.gif"
              class="scale-100 hover:scale-125 ease-in duration-200 hover:shadow-md hover:shadow-cyan-300"
              alt=""
            /></button
          >
        </div>
        <div class="my-2">
          <h3 class="text-white">
            Result: <span class="text-teal-400">{gameResult}</span>
          </h3>
        </div>
      </div>
    {/if}
  </div>
</div>
