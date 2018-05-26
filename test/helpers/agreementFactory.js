module.exports = {
  async createManyAgreements(manager, setupData) {

          var transactions = [];
          var i;
          setupData.forEach((accountData) => {
            for(i = 0; i < accountData.count; i++) {
              transactions.push(manager.create(
                (function(){
                  if(accountData.hasOwnProperty('price')){
                    return accountData.price;
                  } else {
                    return 0;
                  }
                })(),
                {from: accountData.address}
              ));
            }
          });
          return Promise.all(transactions);
  },
}
