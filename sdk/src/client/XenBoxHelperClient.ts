import { Provider } from '@ethersproject/providers';
import { BigNumber, BigNumberish, CallOverrides, Signer } from 'ethers';
import { IXenBoxHelperClient } from '..';
import { XenBoxHelper, XenBoxHelper__factory } from '../typechain';

export class XenBoxHelperClient implements IXenBoxHelperClient {
  protected _contract: XenBoxHelper;
  protected _provider: Provider | Signer;
  protected _waitConfirmations = 1;
  protected _errorTitle = 'XenBoxHelperClient';

  constructor(
    provider: Provider | Signer,
    address: string,
    waitConfirmations?: number
  ) {
    if (waitConfirmations) {
      this._waitConfirmations = waitConfirmations;
    }
    this._provider = provider;
    this._contract = XenBoxHelper__factory.connect(address, provider);
  }

  public address(): string {
    return this._contract.address;
  }

  /* ================ UTILS FUNCTIONS ================ */

  /* ================ VIEW FUNCTIONS ================ */

  public async getOwnedTokenIdList(
    target: string,
    owner: string,
    start: BigNumberish,
    end: BigNumberish,
    config?: CallOverrides
  ): Promise<BigNumber[]> {
    return this._contract.getOwnedTokenIdList(target, owner, start, end, {
      ...config
    });
  }

  public async calculateMintReward(
    user: string,
    config?: CallOverrides
  ): Promise<BigNumber> {
    return this._contract.calculateMintReward(user, {
      ...config
    });
  }

  public async calculateMintRewardNew(
    addRank: BigNumberish,
    term: BigNumberish,
    config?: CallOverrides
  ): Promise<BigNumber> {
    return this._contract.calculateMintRewardNew(addRank, term, {
      ...config
    });
  }

  /* ================ TRANSACTION FUNCTIONS ================ */
}
