// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ERC721 {

    // Token name
    string private _name;
    mapping(uint => address) private _owners;
    mapping(address => uint) private _balances;
    mapping(uint => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name) {
        _name = name;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "ERC721: Address 0 is not a valid address.");
        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return _owners[_tokenId];
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        return _tokenApprovals[_tokenId];
    }

    function _isApprovedForAll(address _owner, address _operator) internal view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return _isApprovedForAll(_owner, _operator);
    }

    function approve(address _approved, uint256 _tokenId) external payable {
        require(msg.sender == _owners[_tokenId] || _isApprovedForAll(_owners[_tokenId], msg.sender), "ERC721: Only token's owner can make this operation or the token is approved for all.");
        require(_approved != address(0), "ERC721: Invalid approved address.");
        _tokenApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        address _owner = address(msg.sender);
        require(_owner != _operator, "ERC721: Approval to caller.");
        _operatorApprovals[_owner][_operator] = _approved;
        emit ApprovalForAll(_owner, _operator, _approved);
    }

    function _tranfer(address _from, address _to, uint256 _tokenId) internal {
        require(_owners[_tokenId] == _from, "ERC721: This address does not own this token");
        require(_tokenApprovals[_tokenId] == _to, "ERC721: Receiver is not approved to this token.");
        _owners[_tokenId] = _to;
        _balances[_from]--;
        _balances[_to]++;
        delete _tokenApprovals[_tokenId];
        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable {
        _tranfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        _tranfer(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        _tranfer(_from, _to, _tokenId);
    }
}