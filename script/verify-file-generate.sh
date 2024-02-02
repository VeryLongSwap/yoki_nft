CONTRACT_ADDRESS=0x194aD41398552E61D5C9a825Ae86112E94d7c6D1

forge verify-contract \
  --show-standard-json-input $CONTRACT_ADDRESS \
src/YokiVLS.sol:YokiVLS > yoki-flatten.json