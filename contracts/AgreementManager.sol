pragma solidity 0.4.23;

import "./Agreement.sol";


contract AgreementManager {

    uint constant private HEAD = 0;
    bool constant private NEXT = true;
    bool constant private PREV = false;

    struct AddressList {
        address data;
        mapping(bool => uint) pointers;
    }

    mapping (uint => AddressList) private list;
    address private wallet;
    uint private lowerExpirationLimit;
    uint private upperExpirationLimit;

    event AgreementCreation(address created);

    constructor(address _wallet, uint _lowerExpirationLimit, uint _upperExpirationLimit) public {
        wallet = _wallet;
        lowerExpirationLimit = _lowerExpirationLimit;
        upperExpirationLimit = _upperExpirationLimit;
    }

    function search() public view returns (address[64]) {
        address[64] memory page;
        uint current = HEAD;
        uint i = 0;
        while ((list[current].pointers[NEXT] != HEAD) && (i < 64)) {
            current = list[current].pointers[NEXT];
            page[i] = list[current].data;
            i++;
        }
        return page;
    }

    function create(
      bytes32[2] name,
      bytes32[8] description,
      uint price,
      uint blocksToExpiration
    ) public returns (address) {

        if(blocksToExpiration < lowerExpirationLimit)
          blocksToExpiration = lowerExpirationLimit;
        
        if(blocksToExpiration >= upperExpirationLimit)
          blocksToExpiration = upperExpirationLimit-1;

        address newAgreement = new Agreement(
          msg.sender,
          wallet,
          price,
          blocksToExpiration,
          name,
          description
        );
        uint previous = list[HEAD].pointers[PREV];
        uint newNode = uint(keccak256(previous, block.number));

        list[previous].pointers[NEXT] = newNode;
        list[HEAD].pointers[PREV] = newNode;
        list[newNode].data = newAgreement;
        list[newNode].pointers[NEXT] = HEAD;
        list[newNode].pointers[PREV] = previous;

        emit AgreementCreation(newAgreement);
        return newAgreement;
    }

    function remove() public {
        address toBeRemoved = msg.sender;
        uint current = HEAD;
        while ((list[current].pointers[NEXT] != HEAD)) {
            current = list[current].pointers[NEXT];
            if (list[current].data == toBeRemoved) {

                list[list[current].pointers[PREV]].pointers[NEXT]
                = list[current].pointers[NEXT];

                list[list[current].pointers[NEXT]].pointers[PREV]
                = list[current].pointers[PREV];

                delete list[current].pointers[NEXT];
                delete list[current].pointers[PREV];
                delete list[current];

                break;
            }
        }
    }

    function checkReg(address agreementAddress) public view returns (bool)
    {
        uint current = HEAD;

        while(list[current].pointers[NEXT] != HEAD)
        {
            current = list[current].pointers[NEXT];
            if(agreementAddress == list[current].data)
            {
                return true;
            }
        }
        return false;
    }


}
