// Copyright 2020 The Beam Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
#include "unlink_view.h"

#include "model/app_model.h"
#include "ui_helpers.h"
#include "qml_globals.h"
#include "wallet/transactions/lelantus/unlink_transaction.h"

#include <qdebug.h>

UnlinkViewModel::UnlinkViewModel() :
    _walletModel(*AppModel::getInstance().getWallet()),
    _walletID(beam::Zero)
{
    connect(&_walletModel, SIGNAL(changeCalculated(beam::Amount)), SLOT(onChangeCalculated(beam::Amount)));
    connect(&_walletModel,
            SIGNAL(generatedNewAddress(const beam::wallet::WalletAddress&)),
            SLOT(onGeneratedNewAddress(const beam::wallet::WalletAddress&)));
    connect(&_walletModel, SIGNAL(sendMoneyVerified()), SIGNAL(unlinkVerified()));
    connect(&_exchangeRatesManager, SIGNAL(rateUnitChanged()), SIGNAL(secondCurrencyLabelChanged()));
    connect(&_exchangeRatesManager, SIGNAL(activeRateChanged()), SIGNAL(secondCurrencyRateChanged()));

    _walletModel.getAsync()->generateNewAddress();
    _unlinkAmountTotal = _walletModel.getLinked();
}

UnlinkViewModel::~UnlinkViewModel()
{

}

QString UnlinkViewModel::getTotalToUnlink() const
{
    return beamui::AmountToUIString(_unlinkAmountTotal);
}

QString UnlinkViewModel::getUnlinkAmount() const
{
    return beamui::AmountToUIString(_unlinkAmount);
}

void UnlinkViewModel::setUnlinkAmount(QString value)
{
    beam::Amount amount = beamui::UIStringToAmount(value);
    if (amount != _unlinkAmount)
    {
        _unlinkAmount = amount;
        LOG_DEBUG() << "Send amount: " << _unlinkAmount << " Coins: " << (long double)_unlinkAmount / beam::Rules::Coin;
        _walletModel.getAsync()->calcChange(_unlinkAmount + _feeGrothes);
        emit unlinkAmountChanged();
        emit canUnlinkChanged();
    }
}

QString UnlinkViewModel::getChange() const
{
    return beamui::AmountToUIString(_changeGrothes);
}

unsigned int UnlinkViewModel::getFeeGrothes() const
{
    return _feeGrothes;
}

void UnlinkViewModel::setFeeGrothes(unsigned int value)
{
    if (value != _feeGrothes)
    {
        _feeGrothes = value;
        _walletModel.getAsync()->calcChange(_unlinkAmount + _feeGrothes);
        emit feeGrothesChanged();
        emit canUnlinkChanged();
    }
}

QString UnlinkViewModel::getRemaining()
{
    return beamui::AmountToUIString(isEnough() ? _unlinkAmountTotal - _unlinkAmount - _feeGrothes : 0);
}

QString UnlinkViewModel::getSecondCurrencyLabel()
{
    return beamui::getCurrencyLabel(_exchangeRatesManager.getRateUnitRaw());
}

QString UnlinkViewModel::getSecondCurrencyRateValue()
{
    auto rate = _exchangeRatesManager.getRate(beam::wallet::ExchangeRate::Currency::Beam);
    return beamui::AmountToUIString(rate);
}

QString UnlinkViewModel::getMissing() const
{
    return beamui::AmountToUIString(_unlinkAmount + _feeGrothes - _unlinkAmountTotal);
}

bool UnlinkViewModel::isZeroBalance() const
{
    return _unlinkAmountTotal == 0;
}

bool UnlinkViewModel::isEnough() const
{
    return _unlinkAmountTotal >= _unlinkAmount + _feeGrothes + _changeGrothes;
}

bool UnlinkViewModel::canUnlink() const
{
    return _walletID != beam::Zero && _unlinkAmount > 0 && isEnough() && QMLGlobals::isLelantusFeeOK(_feeGrothes);
}

void UnlinkViewModel::setMaxAvailableAmount()
{
    setUnlinkAmount(getMaxToUnlink());
}

void UnlinkViewModel::unlink()
{
    if (!canUnlink()) return;

    auto parameters = beam::wallet::lelantus::CreateUnlinkFundsTransactionParameters(_walletID)
        .SetParameter(beam::wallet::TxParameterID::Amount, _unlinkAmount)
        .SetParameter(beam::wallet::TxParameterID::Fee, _feeGrothes);

    _walletModel.getAsync()->startTransaction(std::move(parameters));

    _unlinkAmount = 0;
    _unlinkAmountTotal = _walletModel.getLinked();
    emit remainingChanged();
}

QString UnlinkViewModel::getMaxToUnlink() const
{
    return beamui::AmountToUIString(_unlinkAmountTotal - _feeGrothes);
}

void UnlinkViewModel::onChangeCalculated(beam::Amount change)
{
    _changeGrothes = change;
    emit remainingChanged();
    emit isEnoughChanged();
    emit canUnlinkChanged();
}

void UnlinkViewModel::onGeneratedNewAddress(const beam::wallet::WalletAddress& walletAddr)
{
    _walletID = walletAddr.m_walletID;
    emit canUnlinkChanged();
}
