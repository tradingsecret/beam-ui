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
    connect(&_exchangeRatesManager, SIGNAL(rateUnitChanged()), SIGNAL(secondCurrencyLabelChanged()));
    connect(&_exchangeRatesManager, SIGNAL(activeRateChanged()), SIGNAL(secondCurrencyRateChanged()));
}

UnlinkViewModel::~UnlinkViewModel()
{

}

QString UnlinkViewModel::getTotalToUnlink()
{
    return beamui::AmountToUIString(_unlinkAmountGrothes);
}

QString UnlinkViewModel::getUnlinkAmount()
{
    return beamui::AmountToUIString(_unlinkAmountGrothes);
}

QString UnlinkViewModel::getChange()
{
    return beamui::AmountToUIString(_changeGrothes);
}

unsigned int UnlinkViewModel::getFeeGrothes()
{
    return _feeGrothes;
}

QString UnlinkViewModel::getAvailable()
{
    return beamui::AmountToUIString(_walletModel.getAvailable());
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
