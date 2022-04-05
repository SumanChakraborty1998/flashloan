// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IFlashloanUser.sol";

contract FlashloanProvider is ReentrancyGuard {
    mapping(address => IERC20) public tokens;

    constructor(address[] memory _tokens) {
        for (uint256 i = 0; i < _tokens.length; i++) {
            tokens[_tokens[i]] = IERC20(_tokens[i]);
        }
    }

    function executeFlashloan(
        address callback,
        uint256 amount,
        address _token,
        bytes memory data
    ) external nonReentrant {
        IERC20 token = tokens[_token];
        uint256 originalBalance = token.balanceOf(address(this));

        require(address(token) != address(0), "Token is not supported");
        require(originalBalance >= amount, "Insufficient balance");

        token.transfer(callback, amount);
        IFlashloanUser(callback).flashloanCallback(amount, _token, data);
        require(
            token.balanceOf(address(this)) == originalBalance,
            "Flashloan not reembursed"
        );
    }
}
