CONTRACT_ADDRESS=0x859645652E027acd3F4f08A2e00539bb1741652c

forge verify-contract \
  --show-standard-json-input $CONTRACT_ADDRESS \
src/YokiVLS.sol:YokiVLS > yoki-flatten.json