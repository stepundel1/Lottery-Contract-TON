import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/lottery_v3.tact',
    options: {
        debug: true,
    },
};
