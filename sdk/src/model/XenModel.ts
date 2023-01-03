import { BigNumber } from 'ethers';

export interface MintInfo {
  user: string;
  term: BigNumber;
  maturityTs: BigNumber;
  rank: BigNumber;
  amplifier: BigNumber;
  eaaRate: BigNumber;
}
