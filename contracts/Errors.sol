// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.7;

error NotAuthorized(address needed, address found);
error CallReverted(address target, bool delegate, bytes data, bytes errorData);
error ProfileValid();
