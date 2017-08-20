#!/bin/bash
lllc -x contract.lll > contract.lll.bin
DATA=$(cat contract.lll.bin)
cat <<REQUEST_BODY |      
  {
    "jsonrpc": "2.0", 
    "method": "eth_sendTransaction",
    "params": [{ 
        "gas": "0xb8a90", 
        "from": "0x302c7121ad7194d52450c7a6bfad5141ee596269",
        "data": "$DATA"   }], 
    "id": 1 
}
REQUEST_BODY
curl http://library.internal.fode.io:32768 -d @- | tee rx.json | jq

ID=$(jq '.result' rx.json)
cat <<REQUEST_BODY |
  {
    "jsonrpc": "2.0", 
    "method": "eth_getTransactionReceipt",
    "params": [$ID], 
    "id": 1 
  }
REQUEST_BODY
curl http://library.internal.fode.io:32768 -d @- | tee contract.json | jq

CONTRACT=$(jq '.result.contractAddress' contract.json)
cat <<REQUEST_BODY |
  {
    "jsonrpc": "2.0", 
    "method": "eth_sendTransaction",
    "params": [{
        "gas": "0xfffff", 
        "to": $CONTRACT,
        "from": "0x302c7121ad7194d52450c7a6bfad5141ee596269",
        "data":"0x0"}],
    "id": 1 
  }
REQUEST_BODY
curl http://library.internal.fode.io:32768   -d @-  | tee test_trans.json | jq


ID=$(jq '.result' test_trans.json)
cat <<REQUEST_BODY |
  {
    "jsonrpc": "2.0", 
    "method": "eth_getTransactionReceipt",
    "params": [$ID], 
    "id": 1 
  }
REQUEST_BODY
curl http://library.internal.fode.io:32768 -d @- | tee contract.json | jq

