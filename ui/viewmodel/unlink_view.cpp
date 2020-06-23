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

UnlinkViewModel::UnlinkViewModel() :
    _walletModel(*AppModel::getInstance().getWallet())
{
    connect(&_walletModel, SIGNAL(changeCalculated(beam::Amount)), SLOT(onChangeCalculated(beam::Amount)));
    connect(&_exchangeRatesManager, SIGNAL(rateUnitChanged()), SIGNAL(secondCurrencyLabelChanged()));
    connect(&_exchangeRatesManager, SIGNAL(activeRateChanged()), SIGNAL(secondCurrencyRateChanged()));
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
        // emit canSendChanged();
    }
}

QString UnlinkViewModel::getRemaining()
{
    return beamui::AmountToUIString(_unlinkAmountTotal - _unlinkAmount - _feeGrothes);
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

void UnlinkViewModel::setMaxAvailableAmount()
{
    setUnlinkAmount(getMaxToUnlink());
}

void UnlinkViewModel::onChangeCalculated(beam::Amount change)
{
    _changeGrothes = change;
    emit remainingChanged();
}

QString UnlinkViewModel::getMaxToUnlink() const
{
    return beamui::AmountToUIString(_unlinkAmountTotal - _feeGrothes);
}
