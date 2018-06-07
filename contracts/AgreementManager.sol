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

    event AgreementCreation(address created);

    constructor(address _wallet) public {
        wallet = _wallet;
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

    function create(uint price) public returns (address) {
        address newAgreement = new Agreement(msg.sender, wallet, price);
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

    function checkReg(address agreementAddress) public returns (bool)
    {
        uint current = HEAD;
        uint i = 0;

        for(i = 0; i < 64 ; i++)
        {
            if(agreementAddress == list[current].data)
            {
                return true;
            }
            current = list[current].pointers[NEXT];
            
        }
        return false;
    }


}
