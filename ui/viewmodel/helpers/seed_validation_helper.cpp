// Copyright 2021 The Beam Team
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

#include "seed_validation_helper.h"

#include "model/app_model.h"

SeedValidationHelper::SeedValidationHelper()
{
    auto model = AppModel::getInstance().getWalletModel();
    if (model)
    {
        model->getAsync()->readRawSeedPhrase([this] (const std::string& seed)
        {
            m_seed = seed;
            emit isSeedValidatedChanged();
        });
    }
};
SeedValidationHelper::~SeedValidationHelper(){};

bool SeedValidationHelper::getIsSeedValidatiomMode() const
{
    return AppModel::getInstance().isSeedValidationMode();
}

void SeedValidationHelper::setIsSeedValidationMode(bool value)
{
    AppModel::getInstance().setSeedValidationMode(value);
}

bool SeedValidationHelper::getIsTriggeredFromSettings() const
{
    return AppModel::getInstance().isSeedValidationTriggeredFromSetting();
}

void SeedValidationHelper::setIsTriggeredFromSettings(bool value)
{
    AppModel::getInstance().setSeedValidationTriggeredFromSetting(value);
}

void SeedValidationHelper::validate()
{
    auto model = AppModel::getInstance().getWalletModel();
    if (model)
        model->getAsync()->removeRawSeedPhrase();
}

bool SeedValidationHelper::getIsSeedValidated() const
{
    return m_seed.empty();
}
