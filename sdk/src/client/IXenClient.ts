import { BigNumber, CallOverrides } from 'ethers';
import { XenModel } from '..';

export interface IXenClient {
  userMints(user: string, config?: CallOverrides): Promise<XenModel.MintInfo>;

  globalRank(config?: CallOverrides): Promise<BigNumber>;

  /* ================ TRANSACTION FUNCTIONS ================ */
}
