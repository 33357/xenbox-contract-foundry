import {
    CallOverrides,
    PayableOverrides,
    BigNumber,
    BigNumberish
} from 'ethers';
import { XenBox2Model } from '..';

export interface IXenBox2Client {
    codehash(config?: CallOverrides): Promise<string>;

    totalProxy(config?: CallOverrides): Promise<BigNumber>;

    totalToken(config?: CallOverrides): Promise<BigNumber>;

    totalFee(config?: CallOverrides): Promise<BigNumber>;

    baseURI(config?: CallOverrides): Promise<string>;

    fee100(config?: CallOverrides): Promise<BigNumber>;

    fee50(config?: CallOverrides): Promise<BigNumber>;

    fee20(config?: CallOverrides): Promise<BigNumber>;

    fee10(config?: CallOverrides): Promise<BigNumber>;

    referFeePercent(config?: CallOverrides): Promise<BigNumber>;

    forceDay(config?: CallOverrides): Promise<BigNumber>;

    forceFee(config?: CallOverrides): Promise<BigNumber>;

    tokenMap(
        tokenId: BigNumberish,
        config?: CallOverrides
    ): Promise<XenBox2Model.Token>;

    isRefer(
        user: string,
        config?: CallOverrides
    ): Promise<boolean>;

    rewardMap(
        user: string,
        config?: CallOverrides
    ): Promise<BigNumber>;

    maturityTs(
        tokenId: BigNumberish,
        config?: CallOverrides
    ): Promise<BigNumber>;

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
        refer: string,
        config?: PayableOverrides,
        callback?: Function
    ): Promise<void>;

    claim(
        tokenId: BigNumberish,
        term: BigNumberish,
        config?: PayableOverrides,
        callback?: Function
    ): Promise<void>;

    force(
        tokenId: BigNumberish,
        term: BigNumberish,
        config?: PayableOverrides,
        callback?: Function
    ): Promise<void>;

    batchClaim(
        tokenIdList: BigNumberish[],
        term: BigNumberish,
        config?: PayableOverrides,
        callback?: Function
    ): Promise<void>;

    getReward(
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
