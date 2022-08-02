import sys
import json

from web3 import Web3, HTTPProvider

OWNER_ACCOUNT = '0xded98e256d2C56a801FAa6a26e37F7b0E1c77008'
OWNER_PRIVATE_KEY = 'adf3ee811fb2e27947232b39f6bbbada559c75ab09f694ad567fc18142341784'

CONTRACT_ABI = json.load(open('docker/contracts/sc-management/smart-contract-abi.json'))
CONTRACT_BYTECODE = json.load(open('docker/contracts/sc-management/smart-contract-bytecode.json'))

def check_contract(web3, CONTRACT_ADDRESS):
	address = CONTRACT_ADDRESS
	abi = CONTRACT_ABI
	contract = web3.eth.contract(address=address, abi=abi)
	if contract:
		return (contract)
	else:
		return False

def deploy_contract(web3):
    try:
        account_from = {
            'private_key': OWNER_PRIVATE_KEY,
            'address': OWNER_ACCOUNT,
        }
        contract = web3.eth.contract(abi=CONTRACT_ABI, bytecode=CONTRACT_BYTECODE)
        construct_txn = contract.constructor().buildTransaction(
            {
                'from': account_from['address'],
                'nonce': web3.eth.get_transaction_count(account_from['address']),
                'gasPrice' : web3.toWei('10', 'gwei')
            }
        )
        tx_create = web3.eth.account.sign_transaction(construct_txn, account_from['private_key'])
        tx_hash = web3.eth.send_raw_transaction(tx_create.rawTransaction)
        tx_receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
        #print(f"Contract deployed at address: { tx_receipt.contractAddress }")
        
        return tx_receipt.contractAddress
    except:
        #print("Error to create SC")
        return False


def usage():
    sys.stdout = sys.stderr
    #print('Usage: diotappet rpc')
    sys.exit(2)

def main():
    if len(sys.argv) != 2:
        #print(sys.argv)
        usage()
    else:
        RPC_URL = sys.argv[1]

        web3 = Web3(HTTPProvider(RPC_URL))

        if(not web3.isConnected()):
            #print(RPC_URL, "Connection error. Exiting...")
            return -1

        CONTRACT_ADDRESS = False
        trying=0
        while (not CONTRACT_ADDRESS) and (trying < 5):
            trying += 1
            #print("Contract creation problem. Trying again...", trying)
            CONTRACT_ADDRESS = deploy_contract(web3)
        
        if trying >= 5:
            #print("Contract creation problem. Exiting...")
            return -1

        contract = check_contract(web3,CONTRACT_ADDRESS)

        if not contract:
            #print("Contract problem. Exiting...")
            return -1
        
        print(contract.address)
        return 1

if __name__ == '__main__':
    sys.exit(main())