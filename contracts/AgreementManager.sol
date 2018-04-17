pragma solidity 0.4.21;

import "./Agreement.sol";


contract AgreementManager {

    address[] private agreements;

    function search() public view returns (address[64]) {
        address[64] memory page;
        for (uint i = 0; i < 64 && i < agreements.length; i++) {
            page[i] = agreements[i];
        }
        return page;
    }

    function create() public returns (address) {
        address newAgreement = new Agreement(msg.sender);
        agreements.push(newAgreement);
        return newAgreement;
    }

}
