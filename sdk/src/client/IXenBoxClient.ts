import {
  CallOverrides,
  PayableOverrides,
  BigNumber,
  BigNumberish
} from 'ethers';
import { XenBoxModel } from '..';

export interface IXenBoxClient {
  codehash(config?: CallOverrides): Promise<string>;

  totalProxy(config?: CallOverrides): Promise<BigNumber>;

  totalToken(config?: CallOverrides): Promise<BigNumber>;

  fee(config?: CallOverrides): Promise<BigNumber>;

  baseURI(config?: CallOverrides): Promise<string>;

  contractURI(config?: CallOverrides): Promise<string>;

  tokenMap(
    tokenId: BigNumberish,
    config?: CallOverrides
  ): Promise<XenBoxModel.Token>;

  name(config?: CallOverrides): Promise<string>;

  symbol(config?: CallOverrides): Promise<string>;

  balanceOf(owner: string, config?: CallOverrides): Promise<BigNumber>;

  ownerOf(tokenId: BigNumberish, config?: CallOverrides): Promise<string>;

  tokenURI(tokenId: BigNumberish, config?: CallOverrides): Promise<string>;

  getApproved(tokenId: BigNumberish, config?: CallOverrides): Promise<string>;

  isApprovedForAll(
    owner: string,
    operator: string,
    config?: CallOverrides
  ): Promise<boolean>;

  /* ================ TRANSACTION FUNCTIONS ================ */

  mint(
    amount: BigNumberish,
    term: BigNumberish,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void>;

  claim(
    tokenId: BigNumberish,
    term: BigNumberish,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void>;

  setApprovalForAll(
    operator: string,
    approved: boolean,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void>;

  approve(
    to: string,
    tokenId: BigNumber,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void>;

  transferFrom(
    from: string,
    to: string,
    tokenId: BigNumber,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void>;

  /* ================ UTIL FUNCTIONS ================ */

  getProxyAddress(index: BigNumber): Promise<string>;
}
