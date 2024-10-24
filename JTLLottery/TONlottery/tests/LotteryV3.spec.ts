import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { LotteryV3 } from '../wrappers/LotteryV3';
import '@ton/test-utils';

describe('LotteryV3', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let lotteryV3: SandboxContract<LotteryV3>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        lotteryV3 = blockchain.openContract(await LotteryV3.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await lotteryV3.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: lotteryV3.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and lotteryV3 are ready to use
    });
});
