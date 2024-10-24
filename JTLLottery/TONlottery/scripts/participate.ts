import { Address, toNano } from '@ton/core';
import { NetworkProvider } from '@ton/blueprint';
import { LotteryV3 } from '../wrappers/LotteryV3';

export async function run(provider: NetworkProvider) {
    const contractAddress = 'EQAXNm6bpuxYAFZBSedIxEVeEzMynyr2t6AVExK2vw7nqiKV'; 
    const lottery = provider.open(LotteryV3.fromAddress(Address.parse(contractAddress)));

    await lottery.send(
        provider.sender(),
        {
            value: toNano('1.1'),
        },
        'Buying a tickets'
    );

   
}



