// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

// unit
// intergrations
// forked tests
// staging

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "src/Raffle.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract InteractionsTest is Test {
    Raffle raffle;
    HelperConfig helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint32 callbackGasLimit;
    uint256 subscriptionId;
    address link;

    address PLAYER = makeAddr("player");
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        callbackGasLimit = config.callbackGasLimit;
        subscriptionId = config.subscriptionId;
        link = config.link;
    }

    function testUserCanCreateAndFundSubscriptionAndAddConsumer() public {
        CreateSubscription createSubscription = new CreateSubscription();
        (uint256 subId, address vrfCoord) = createSubscription
            .createSubscription(vrfCoordinator, PLAYER);

        FundSubscription fundSubscription = new FundSubscription();
        fundSubscription.fundSubscription(vrfCoord, subId, link, PLAYER);

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(address(raffle), vrfCoord, subId, PLAYER);

        assert(subId != 0);
        assert(vrfCoord != address(0));
    }
}
