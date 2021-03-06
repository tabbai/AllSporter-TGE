pragma solidity ^0.4.19;
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Minter.sol";

/* TgeMock is used for unit testing */

contract TgeMock is Minter {
    using SafeMath for uint;

    /* --- CONSTANTS --- */

    uint public firstStateMultiplier = 2;
    uint public secondStateMultiplier = 3;
    bool public secondState = false;
    uint public secondStateAfter = 10 * 1e18;
    uint public minimumContributionAmount = 10;

    /* --- FIELDS --- */

    address public firstStateMinter;
    address public secondStateMinter;
    mapping(address => bool) public allStateMinters;

    /* --- CONSTRUCTOR --- */

    function TgeMock(
        CrowdfundableToken _token,
        uint _saleEtherCap,
        address _firstStateMinter,
        address _secondStateMinter
    ) public Minter(_token, _saleEtherCap) {
        firstStateMinter = _firstStateMinter;
        secondStateMinter = _secondStateMinter;
    }

    /* --- PUBLIC / EXTERNAL METHODS --- */

    function addAllStateMinter(address account) public {
        allStateMinters[account] = true;
    }

    // override
    function getMinimumContribution() public view returns(uint) {
        return minimumContributionAmount;
    }

    // override
    function updateState() public {
        if (confirmedSaleEther.add(reservedSaleEther) >= secondStateAfter) {
            secondState = true;
        }
    }

    // override
    function canMint(address sender) public view returns(bool) {
        bool result = false;
        if (secondState) {
            result = sender == secondStateMinter;
        }
        else result = sender == firstStateMinter;

        return result || allStateMinters[sender];
    }

    // override
    function getTokensForEther(uint etherAmount) public view returns(uint) {
        if (secondState) {
            return etherAmount.mul(secondStateMultiplier);
        }
        return etherAmount.mul(firstStateMultiplier);
    }
}
