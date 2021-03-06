// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract HipHopGya is ERC721, Pausable, Ownable {
    // URI需要/結尾以銜接檔名
    string public baseURI;
    string public unrevealedURI =
        "ipfs://QmQskJtsyFp6mczsHmSyBPyCrhNJKvY5qpWghM7u4bh3PJ/";

    bool public revealed = false;

    uint256 public MAX_SUPPLY = 20;
    uint256 public MINT_PRICE = 0.01 ether;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("HipHopGya", "HHG") {
        // baseURI若為空則無法獲取tokenURI
        // setBaseURI("");
        _tokenIdCounter.increment();
    }

    // constructor() ERC721PresetMinterPauserAutoId("HipHopGya", "HHG", "") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setUnrevealedURI(string memory _newUnrevealedURI)
        public
        onlyOwner
    {
        unrevealedURI = _newUnrevealedURI;
    }

    // ERC721.sol內的tokenURI()會去獲取_baseURI()
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        // 以下為ERC721內的tokenURI()內容
        // require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        // string memory baseURI = _baseURI();
        // return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";

        if (!revealed) {
            return string(abi.encodePacked(unrevealedURI, "hidden.json"));
        }

        return string(abi.encodePacked(super.tokenURI(tokenId), ".json"));
    }

    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "Balance is 0");
        payable(owner()).transfer(address(this).balance);
    }

    function safeMint(address to) public payable {
        require(totalSupply() < MAX_SUPPLY, "Can't mint more");
        require(msg.value >= MINT_PRICE, "Not enough ether sent");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    // ERC721 _mint()會呼叫_beforeTokenTransfer()，這邊override加上了whenNotPaused因此若pause則無法safeMint()
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // Function to return the total supply
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter.current() - 1;
    }

    function setRevealed(bool flag) public onlyOwner {
        revealed = flag;
    }
}
