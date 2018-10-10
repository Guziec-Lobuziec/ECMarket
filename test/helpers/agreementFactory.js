module.exports = {
  async createManyAgreements(manager, setupData) {

          var transactions = [];
          var i;
          setupData.forEach((accountData) => {
            for(i = 0; i < accountData.count; i++) {
              transactions.push(manager.create(
                accountData.name, accountData.description,
                (function(){
                  if(accountData.hasOwnProperty('expirationTime')){
                    return accountData.expirationTime;
                  } else {
                    return 100;
                  }
                })(),
                (function(){
                  if(accountData.hasOwnProperty('price')){
                    return accountData.price;
                  } else {
                    return 0;
                  }
                })(),
                (function(){
                  if(accountData.hasOwnProperty('extra')){
                    return encodeCreateParams(accountData.extra);
                  } else {
                    return '';
                  }
                })(),
                {from: accountData.address}
              ));
            }
          });
          return Promise.all(transactions);
  },
}

function encodeCreateParams(dataArray) {
  var builderABI = [
  	{
  		"constant": true,
  		"inputs": [
  			{
  				"name": "advancePaymen",
  				"type": "uint256"
  			},
  			{
  				"name": "blocksToFallback",
  				"type": "uint256"
  			}
  		],
  		"name": "setAdvancePayment",
  		"outputs": [],
  		"payable": false,
  		"stateMutability": "pure",
  		"type": "function"
  	}
  ]

  var builder = web3.eth.contract(abi);
  var payload = '';

  dataArray.forEach(call => {
      payload += builder[call.name].getData.apply(call.args).slice(2);
  })

  return '0x'+payload;
}
