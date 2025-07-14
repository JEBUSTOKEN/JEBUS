// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract JEBUSToken is ERC20, ERC20Burnable, ERC20Pausable, Ownable {
    uint256 public maxSupply;
    mapping(address => bool) private blacklist;

    constructor() ERC20("JEBUS Token", "JBS") Ownable(msg.sender) {
        maxSupply = 100_000_000 * 10 ** decimals();
        _mint(msg.sender, 33_000_000 * 10 ** decimals());
    }

    modifier notBlacklisted(address account) {
        require(!blacklist[account], "JEBUS: wallet bloqueada");
        _;
    }

    function mint(address to, uint256 amount)
        public
        onlyOwner
        whenNotPaused
        notBlacklisted(to)
    {
        require(totalSupply() + amount <= maxSupply, "JEBUS: supply excedido");
        _mint(to, amount);
    }

    function burn(uint256 amount)
        public
        override
        whenNotPaused
        notBlacklisted(msg.sender)
    {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount)
        public
        override
        whenNotPaused
        notBlacklisted(account)
    {
        super.burnFrom(account, amount);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function blockWallet(address wallet) public onlyOwner {
        blacklist[wallet] = true;
    }

    function unblockWallet(address wallet) public onlyOwner {
        blacklist[wallet] = false;
    }

    function isBlacklisted(address wallet) public view returns (bool) {
        return blacklist[wallet];
    }

    // 🔁 Override obligatorio de _update para resolver conflicto de herencia
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
        require(!blacklist[from] && !blacklist[to], "JEBUS: transferencia bloqueada");
    }
}

