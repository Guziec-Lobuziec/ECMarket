pragma solidity 0.4.21;

import "./Agreement.sol";


contract AgreementManager {

    Agreement private agreements;

    function search() public view returns (address) {
        return agreements;
    }

    function create() public returns (address) {
        agreements = new Agreement();
        return agreements;
    }

}
