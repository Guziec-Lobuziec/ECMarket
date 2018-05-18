module.exports = {
  async createManyAgreements(manager, setupData) {

          var transactions = [];
          var i;
          setupData.forEach((accountData) => {
            for(i = 0; i < accountData.count; i++) {
              transactions.push(manager.create(accountData.name, accountData.description, {from: accountData.address}));
            }
          });
          return Promise.all(transactions);
  },
}
