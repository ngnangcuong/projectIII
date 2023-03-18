// SPDX-License-Identifier: UNLICENSED

// DO NOT MODIFY BELOW THIS
pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract Splitwise {
// DO NOT MODIFY ABOVE THIS

// ADD YOUR CONTRACT CODE BELOW
    mapping (address => mapping (address => uint32)) private Owe;
    mapping (address => address[]) private OweTo;
    
    function lookup(address debtor, address creditor) public view returns (uint32) {
        return Owe[debtor][creditor];    
    }

    function add_IOU(address creditor, uint32 amount) external {
        require(msg.sender != creditor);
        Owe[msg.sender][creditor] += amount; 

        if (Owe[msg.sender][creditor] == amount) {
            OweTo[msg.sender].push(creditor);
            (bool should, address[] memory list) = should_recalculate(msg.sender, creditor);
            if (should) {
                recalculate(list);
            }
        }
    }

    function get_total_owed(address ower) public view returns(uint32 total) {
        address[] memory creditors = OweTo[ower];
        total = 0;
        for(uint i = 0; i < creditors.length; i++) {
            total += Owe[ower][creditors[i]];
        }
    }

    function should_recalculate(address debtor, address creditor) private view returns (bool should, address[] memory list) {
        should = false;
        list = new address[](1);
        (bool found, address[] memory des_list) = find_list(creditor, debtor, 0, list);
        if (found) {
            should = true;
            list = des_list;
        }
    }
    
    function find_list(address start, address end, uint8 index, address[] memory list) private view returns (bool found, address[] memory another_list) {
        another_list = new address[](index + 2);
        for (uint8 i = 0; i < list.length; i++) {
            another_list[i] = list[i];
        }
        another_list[index] = start;
        address[] memory creditors_of_creditor = OweTo[start];
        for (uint8 i = 0; i < creditors_of_creditor.length; i++) {
            if (creditors_of_creditor[i] == end) {
                found = true;
                another_list[index + 1] = end;
                return (found, another_list);
            }

            (bool des_found, address[] memory des_list) = find_list(creditors_of_creditor[i], end, index + 1, another_list);
            if (des_found) {
                found = true;
                another_list = des_list;
                return (found, another_list);
            }
        }
    }

    function recalculate(address[] memory list) private {
        uint32 minIOU = min(list);
        uint len = list.length;
        for (uint8 i = 0; i < len; i++) {
            address debtor = list[i % len];
            address creditor = list[(i + 1) % len];
            Owe[debtor][creditor] -= minIOU;

            if (Owe[debtor][creditor] == 0) {
                address[] storage _list = OweTo[debtor];
                uint _len = _list.length;
                for (uint j = 0; j < _len; j++) {
                    if (_list[j] == creditor) {
                        _list[j] = _list[_len - 1];
                        _list[_len - 1] = creditor;
                        _list.pop();
                    }
                }
            }
        }

    }

    function min(address[] memory list) private view returns (uint32) {
        require(list.length > 0); // throw an exception if the condition is not met
        uint32 minNumber = 1<<31; // default 0, the lowest value of `uint32`
        uint len = list.length;

        for (uint8 i = 0; i < len; i++) {
            address debtor = list[i % len];
            address creditor = list[(i + 1) % len];
            minNumber = minNumber <= Owe[debtor][creditor] ? minNumber : Owe[debtor][creditor];
        }

        return minNumber;
    }

}
