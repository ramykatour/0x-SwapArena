// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IERC20.sol";
import "./interfaces/IPancakeRouter.sol";

contract SwapArena {
    address public owner;
    address public feeWallet;
    uint256 public feePercent;

    IPancakeRouter public pancakeRouter;

    mapping(address => uint256) public xp;

    event Swapped(address indexed user, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut, uint256 xpEarned);

    constructor(address _router, address _feeWallet, uint256 _feePercent) {
        owner = msg.sender;
        pancakeRouter = IPancakeRouter(_router);
        feeWallet = _feeWallet;
        feePercent = _feePercent;
    }

    function swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOutMin) external {
        require(amountIn > 0, "Invalid amount");

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        uint256 fee = (amountIn * feePercent) / 10000;
        uint256 amountToSwap = amountIn - fee;

        if (fee > 0) {
            IERC20(tokenIn).transfer(feeWallet, fee);
        }

        IERC20(tokenIn).approve(address(pancakeRouter), amountToSwap);

        address ;
        path[0] = tokenIn;
        path[1] = tokenOut;

        uint[] memory amounts = pancakeRouter.swapExactTokensForTokens(
            amountToSwap,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );

        uint256 earnedXP = amountIn / 1e18;
        xp[msg.sender] += earnedXP;

        emit Swapped(msg.sender, tokenIn, tokenOut, amountIn, amounts[1], earnedXP);
    }

    function setFee(uint256 _feePercent) external {
        require(msg.sender == owner, "Not owner");
        feePercent = _feePercent;
    }

    function setFeeWallet(address _feeWallet) external {
        require(msg.sender == owner, "Not owner");
        feeWallet = _feeWallet;
    }
}
