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
#pragma once

#include <QObject>
#include "model/wallet_model.h"
#include "notifications/exchange_rates_manager.h"

class UnlinkViewModel: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString  totalToUnlink           READ getTotalToUnlink                                 NOTIFY availableChanged)
    Q_PROPERTY(QString  unlinkAmount            READ getUnlinkAmount            /*WRITE setUnlinkAmount*/ NOTIFY unlinkAmountChanged)
    Q_PROPERTY(QString  change                  READ getChange                                        NOTIFY availableChanged)
    Q_PROPERTY(unsigned int  feeGrothes         READ getFeeGrothes              /*WRITE setFeeGrothes*/   NOTIFY feeGrothesChanged)
    Q_PROPERTY(QString  available               READ getAvailable                                     NOTIFY availableChanged)
    Q_PROPERTY(QString  secondCurrencyLabel     READ getSecondCurrencyLabel                           NOTIFY secondCurrencyLabelChanged)
    Q_PROPERTY(QString  secondCurrencyRateValue READ getSecondCurrencyRateValue                       NOTIFY secondCurrencyRateChanged)

public:
    UnlinkViewModel();
    ~UnlinkViewModel();
    QString getTotalToUnlink();
    QString getUnlinkAmount();
    QString getChange();
    unsigned int getFeeGrothes();
    QString getAvailable();
    QString getSecondCurrencyLabel();
    QString getSecondCurrencyRateValue();

signals:
    void availableChanged();
    void unlinkAmountChanged();
    void feeGrothesChanged();
    void secondCurrencyLabelChanged();
    void secondCurrencyRateChanged();

private:
    beam::Amount _unlinkAmountGrothes = 100000000;
    beam::Amount _feeGrothes = 100000000;
    beam::Amount _changeGrothes = 100000000;

    WalletModel& _walletModel;
    ExchangeRatesManager _exchangeRatesManager;
};
