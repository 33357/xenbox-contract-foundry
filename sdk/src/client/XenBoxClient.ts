import { Provider } from '@ethersproject/providers';
import {
  BigNumber,
  BigNumberish,
  CallOverrides,
  ContractTransaction,
  PayableOverrides,
  Signer,
  utils
} from 'ethers';
import { IXenBoxClient, XenBoxModel } from '..';
import { XenBox, XenBox__factory } from '../typechain';

export class XenBoxClient implements IXenBoxClient {
  protected _contract: XenBox;
  protected _provider: Provider | Signer;
  protected _waitConfirmations = 1;
  protected _errorTitle = 'XenBoxClient';
  private _codeHash: string | undefined;

  constructor(
    provider: Provider | Signer,
    address: string,
    waitConfirmations?: number
  ) {
    if (waitConfirmations) {
      this._waitConfirmations = waitConfirmations;
    }
    this._provider = provider;
    this._contract = XenBox__factory.connect(address, provider);
  }

  public address(): string {
    return this._contract.address;
  }

  /* ================ UTILS FUNCTIONS ================ */

  private _beforeTransaction() {
    if (this._provider instanceof Provider) {
      throw `${this._errorTitle}: no singer`;
    }
  }

  private async _afterTransaction(
    transaction: ContractTransaction,
    callback?: Function
  ): Promise<any> {
    if (callback) {
      callback(transaction);
    }
    const receipt = await transaction.wait(this._waitConfirmations);
    if (callback) {
      callback(receipt);
    }
  }

  public async getProxyAddress(index: BigNumber): Promise<string> {
    if (!this._codeHash) {
      this._codeHash = await this.codehash();
    }
    let salt = index.toHexString().replace('0x', '');
    while (salt.length < 64) {
      salt = '0' + salt;
    }
    return (
      '0x' +
      utils
        .keccak256(
          `0xff${this._contract.address.replace(
            '0x',
            ''
          )}${salt}${this._codeHash.replace('0x', '')}`
        )
        .substring(26)
    );
  }

  /* ================ VIEW FUNCTIONS ================ */

  public async codehash(config?: CallOverrides): Promise<string> {
    return this._contract.codehash({ ...config });
  }

  public async totalProxy(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.totalProxy({ ...config });
  }

  public async totalToken(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.totalToken({ ...config });
  }

  public async fee(config?: CallOverrides): Promise<BigNumber> {
    return this._contract.fee({ ...config });
  }

  public async baseURI(config?: CallOverrides): Promise<string> {
    return this._contract.baseURI({ ...config });
  }

  public async contractURI(config?: CallOverrides): Promise<string> {
    return this._contract.contractURI({ ...config });
  }

  public async tokenMap(
    tokenId: BigNumberish,
    config?: CallOverrides
  ): Promise<XenBoxModel.Token> {
    return this._contract.tokenMap(tokenId, { ...config });
  }

  public async name(config?: CallOverrides): Promise<string> {
    return this._contract.name({ ...config });
  }

  public async symbol(config?: CallOverrides): Promise<string> {
    return this._contract.symbol({ ...config });
  }

  public async balanceOf(
    owner: string,
    config?: CallOverrides
  ): Promise<BigNumber> {
    return this._contract.balanceOf(owner, { ...config });
  }

  public async ownerOf(
    tokenId: BigNumberish,
    config?: CallOverrides
  ): Promise<string> {
    return this._contract.ownerOf(tokenId, { ...config });
  }

  public async tokenURI(
    tokenId: BigNumberish,
    config?: CallOverrides
  ): Promise<string> {
    return this._contract.tokenURI(tokenId, { ...config });
  }

  public async getApproved(
    tokenId: BigNumberish,
    config?: CallOverrides
  ): Promise<string> {
    return this._contract.getApproved(tokenId, { ...config });
  }

  public async isApprovedForAll(
    owner: string,
    operator: string,
    config?: CallOverrides
  ): Promise<boolean> {
    return this._contract.isApprovedForAll(owner, operator, { ...config });
  }

  /* ================ TRANSACTION FUNCTIONS ================ */

  public async mint(
    amount: BigNumberish,
    term: BigNumberish,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this._contract.mint(amount, term, {
      ...config
    });
    this._afterTransaction(transaction, callback);
  }

  public async claim(
    tokenId: BigNumberish,
    term: BigNumberish,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this._contract.claim(tokenId, term, {
      ...config
    });
    this._afterTransaction(transaction, callback);
  }

  public async setApprovalForAll(
    operator: string,
    approved: boolean,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this._contract.setApprovalForAll(
      operator,
      approved,
      {
        ...config
      }
    );
    this._afterTransaction(transaction, callback);
  }

  public async approve(
    to: string,
    tokenId: BigNumber,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this._contract.approve(to, tokenId, {
      ...config
    });
    this._afterTransaction(transaction, callback);
  }

  public async transferFrom(
    from: string,
    to: string,
    tokenId: BigNumber,
    config?: PayableOverrides,
    callback?: Function
  ): Promise<void> {
    this._beforeTransaction();
    const transaction = await this._contract.transferFrom(from, to, tokenId, {
      ...config
    });
    this._afterTransaction(transaction, callback);
  }
}
