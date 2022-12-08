pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/blob/main/contracts/payment/ERC20/SafeERC20.sol";
import "https://github.com/kybernetwork/smart-contracts/blob/main/contracts/KyberNetwork.sol";
import "https://github.com/trailofbits/etsc/blob/master/contracts/http/Http.sol";


contract MyContract {
  string public coinbaseApiKey;
  ERC20 public token;
  KyberNetwork public kyber;
  Http public http;

  constructor(string _coinbaseApiKey, address _tokenAddress, address _kyberAddress, address _httpAddress) public {
    coinbaseApiKey = _coinbaseApiKey;
    token = ERC20(_tokenAddress);
    kyber = KyberNetwork(_kyberAddress);
    http = Http(_httpAddress);
  }
  
  function onrampDollars(address _to, uint256 _amount) public {
    // Set the API endpoint and the amount to convert
    string memory endpoint = "https://api.coinbase.com/v2/prices/<token>/spot";
    string memory amount = _amount.toString();

    // Set the request headers
    string memory headers = '{"Content-Type": "application/json", "Authorization": "Bearer ' + coinbaseApiKey + '"}';

    // Set the request data
    string memory data = '{"amount": ' + amount + ', "currency": "USD", "to": "' + _to + '"}';

    // Call the Coinbase API
    (bool success, string memory response) = http.post(endpoint, headers, data);

    // Parse the response
    if (success) {
      // Parse the response data
      string memory responseData = response.substr(response.indexOf('{'), response.lastIndexOf('}') + 1);
      TokenResponse memory tokenResponse = TokenResponse(responseData);

      // Transfer the tokens to the contract
      // Use a safe version of the ERC20 contract to ensure that the tokens are transferred securely
      token.safeTransfer(_to, tokenResponse.amount);
    } else {
      // Handle errors
    }
  }

  function swapTokens(address _from, address _tokenA, address _tokenB, uint256 _amount) public {
    // Call the swap function on the Kyber contract
    kyber.swap(_from, _tokenA, _tokenB, _amount, 0, 0);
  }

  struct TokenResponse {
    uint256 amount;
  }
}
