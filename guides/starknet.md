# Setting up development environment

In a `cairo_venv` virtual environment, run:

    pip install ecdsa fastecdsa sympy

If the above gives errors, then first run

    brew install gmp
    CFLAGS=-I/opt/homebrew/opt/gmp/include LDFLAGS=-L/opt/homebrew/opt/gmp/lib pip install fastecdsa

Then install:

    pip3 install cairo-lang

# Setting up an account for development

## Environment variables

Instruct CLI to use the StarkNet testnet

    export STARKNET_NETWORK=alpha-goerli

Choose wallet provider which defines account contract to deploy (a modified version of OpenZeppelin's account standard in this case)

    export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount

This instructs the Starknet CLI to use the account in the `starknet invoke` and `starknet call` commands. To do a contract call without passing the account contract, the `--no_wallet` can be passed with the command in the CLI.

## Creating an account

Creating an account by running:

    starknet deploy_account

## Acquiring test ETH

Acquire Goerli ETH by:

1. Faucet - https://faucet.goerli.starknet.io/
2. StarkGate (bridging L1 Goerli ETH to L2) - https://testnet.layerswap.io/?destNetwork=starknet_goerli

## Compiling a contract

    starknet-compile contract.cairo \
    --output contract_compiled.json \
    --abi contract_abi.json

## Deploying a contract

StarkNet contracts distinguish between a contract class and a contract instance. `starknet declare` is used to declare the contract class, which is then deployed using a deploy system call.

However, this is not necessary to do, as `starknet deploy` both declares (creates the class for) and deploys (creates a new instance for that class) the new contract.

The contract can be deployed by running:

    starknet deploy --contract contract_compiled.json

The contract address can be saved as an environment variable:

    export CONTRACT_ADDRESS=<address>

## Interacting with a contract

To call a function within a contract, use `starknet invoke` as follows:

    starknet invoke \
    --address ${CONTRACT_ADDRESS} \
    --abi contract_abi.json \
    --function increase_balance \
    --inputs 1234

This must be done using an account.

The transaction status can be queryed using `starknet tx_status` and the hash of the transaction returned from `starknet invoke`:

    starknet tx_status --hash TRANSACTION_HASH

Functions can be called without modifying their state using `starknet call`. This will return the result of the function without applying it to the current state (allows for dry run before committing to an update).

    starknet invoke \
    --address ${CONTRACT_ADDRESS} \
    --abi contract_abi.json \
    --functiong get_balance

## CLI commands

Explanation of CLI commands: https://starknet.io/docs/hello_starknet/cli.html

# Smart contract functions

## Storage maps

Map from `user`, a `felt` containing the account contract address, to `res`, the call response containing the queried account balance.

    @storage_var
    func balance(user : felt) -> (res : felt):
    end

## Getting caller address

    from starkware.starknet.common.syscalls import get_caller_address

    let (caller_address) = get_caller_address()

## Try/catch or assert

To use assert (in this case to verify that an amount is non-negative) and, we can use `assert_nn` (assert non-negative) in combination with the `with_attr error_message()` wrapper.

    with_attr error_message(
            "Amount must be positive. Got: {amount}."):
        assert_nn(amount)
    end
