import  {ethers } from 'hardhat';
import { expect } from "chai";
import { Contract } from 'ethers';
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { time } from "@openzeppelin/test-helpers";

describe("Horizon Pool", () => {
    
    let owner: SignerWithAddress;
    let alice: SignerWithAddress;
    let bob: SignerWithAddress;
    let res: any;
    let horizonStake: Contract;
    let horizon: Contract;
    let exDao: Contract;

    let daiAmount: any = 10000;
  
    beforeEach(async() => {
        const HorizonStake = await ethers.getContractFactory("HorizonStake");
        const HorizonToken = await ethers.getContractFactory("HorizonToken");
        const ExDao = await  ethers.getContractFactory("MockERC20");
        exDao = await ExDao.deploy("MockDai", "mDAI");
        [owner, alice, bob] = await  ethers.getSigners();
        await Promise.all([
            exDao.mint(owner.address, daiAmount),
            exDao.mint(alice.address, daiAmount),
            exDao.mint(bob.address, daiAmount)
        ]);
        horizon = await HorizonToken.deploy(owner.address, daiAmount + daiAmount);
        horizonStake = await HorizonStake.deploy(exDao.address, horizon.address);
    })

    describe("Init", async() => {
        it("should initialize", async() => {
            expect(horizon).to.be.ok
            expect(horizonStake).to.be.ok
            expect(exDao).to.be.ok
        })

        it("Should show MockDai balance", async() => {
            let balance = await exDao.balanceOf(owner.address);
            expect(balance.toString()).to.eq(daiAmount.toString());
        })
    })

    describe("Stake", async() => {
        it("Should accept ExDao and update mapping", async() => {
            let toTransfer = 50;
            await exDao.connect(alice).approve(horizonStake.address, toTransfer);
            expect(await horizonStake.isStaking(alice.address))
                .to.eq(false);

            expect(await horizonStake.connect(alice).stake(toTransfer))
                .to.be.ok

            expect(await horizonStake.isStaking(alice.address))
                .to.eq(true);
            
            expect(await horizonStake.stakingBalance(alice.address))
                .to.eq(toTransfer)
        })
    })
});

