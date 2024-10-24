import { toNano, Address } from '@ton/core';
import { LotteryV3 } from '../wrappers/LotteryV3';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const seqno: bigint = 465738423n
    const addressLottery: Address = Address.parse('0QBycMxDBYKUsOz_VJzdBmiVMQhkykrzW34p4TjSsq5OpAv9')
    const lottery = provider.open(await LotteryV3.fromInit(seqno, addressLottery));

    await lottery.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(lottery.address);


}

