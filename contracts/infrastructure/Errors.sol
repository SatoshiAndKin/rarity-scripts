// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.7;

error CallReverted(address target, bool delegate, bytes data, bytes errorData);
error NotApprovedOrOwner(address who, uint summoner);
error NotAuthorized(address needed, address found);
error ProfileValid();
