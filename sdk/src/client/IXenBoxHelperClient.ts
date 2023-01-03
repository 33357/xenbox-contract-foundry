import { CallOverrides, BigNumber, BigNumberish } from 'ethers';

export interface IXenBoxHelperClient {
  getOwnedTokenIdList(
    target: string,
    owner: string,
    start: BigNumberish,
    end: BigNumberish,
    config?: CallOverrides
  ): Promise<BigNumber[]>;

  calculateMintReward(user: string, config?: CallOverrides): Promise<BigNumber>;

  calculateMintRewardNew(
    addRank: BigNumberish,
    term: BigNumberish,
    config?: CallOverrides
  ): Promise<BigNumber>;

  /* ================ TRANSACTION FUNCTIONS ================ */
}
