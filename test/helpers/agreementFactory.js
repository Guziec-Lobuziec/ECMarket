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
                  if(accountData.hasOwnProperty('extra')){
                    return encodeCreateParams(accountData.extra);
                  } else {
                    return [];
                  }
                })(),
                {from: accountData.address}
              ));
            }
          });
          return Promise.all(transactions);
  },
}

function encodeCreateParams(dataObject) {
  const encodingDef = [
    {key: 'price', code: 1, submarks:[]},
    {key: 'contractOut', code: 2, submarks:[
      {key: 'advancePayment', code: 1, submarks:[]},
      {key: 'timeToFallback', code: 2, submarks:[]}
    ]}
  ];

  function encode(obj,def = encodingDef) {
    var encoded = [];
    var index = 0;
    Object.keys(obj).forEach(function (key) {
      if(def[index].key === key) {
        encoded.push(def[index].code);
        if (typeof obj[key] === 'object') {
            encoded = encoded.concat(encode(obj[key],def[index].submarks));
        }
        else {
          encoded.push(obj[key]);
        }
        encoded.push(def[index].code);
        index++;
      }
    });
    return encoded;
  }

  return encode(dataObject);
}
