pragma solidity ^0.5.0;


contract ContractUtils {
    function isContract(address _addr) external view returns (bool isContract) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}
