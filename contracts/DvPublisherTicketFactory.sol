// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

// Importing the DvFactory contract as the base for this factory contract.
import "@devest/contracts/DvFactory.sol";
// Importing the DvPublisherTicket contract which defines the tickets to be managed by this factory.
import "./DvPublisherTicket.sol";

/**
 * @title DvPublisherTicketFactory
 * @dev Contract to create and manage DvPublisherTicket. Inherits from DvFactory for common factory functionality.
 */
contract DvPublisherTicketFactory is DvFactory {

    /**
     * @dev Detaches a DvPublisherTicket ticket from this factory's control, making it independent.
     * Can only be called by the owner of the factory.
     * @param _ticketAddress Address of the DvPublisherTicket ticket to be detached.
     */
    function detach(address payable _ticketAddress) external payable onlyOwner {
        DvPublisherTicket ticket = DvPublisherTicket(_ticketAddress);
        ticket.detach();
    }

    /**
     * @dev Creates a new DvPublisherTicket ticket with specified attributes and registers it with the factory.
     * Charges an issue fee if applicable.
     * @param name Name of the new ticket.
     * @param symbol Symbol of the new ticket.
     * @param rootId An identifier for the root ticket, if applicable.
     * @param rootUri URI for the root metadata.
     * @return The address of the newly created DvPublisherTicket ticket.
     */
    function issue(string memory name, string memory symbol, uint256 rootId, string memory rootUri) public payable isActive returns (address) {
        // Verifies the transaction includes enough ETH to cover the issue fee.
        require(msg.value >= _issueFee, "Please provide enough fee");
        
        // If there's an issue fee defined, transfers it to the fee recipient.
        if (_issueFee > 0)
            payable(_feeRecipient).transfer(_issueFee);

        // Creates a new DvPublisherTicket ticket with the provided parameters, setting the issuer (msg.sender) and this factory as its manager.
        DvPublisherTicket ticket = new DvPublisherTicket(name, symbol, rootId, rootUri, _msgSender(), address(this));

        // Emits an event indicating a new ticket has been deployed.
        emit deployed(_msgSender(), address(ticket));

        // Returns the address of the newly created ticket.
        return address(ticket);
    }
}
