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

#include "notifications_list.h"
#include "model/app_model.h"

NotificationsList::NotificationsList()
{
    _amgr = AppModel::getInstance().getAssets();
    connect(_amgr.get(), &AssetsManager::assetInfo, this, &NotificationsList::onAssetInfo);
}

QHash<int, QByteArray> NotificationsList::roleNames() const
{
    static const auto roles = QHash<int, QByteArray>
    {
        { static_cast<int>(Roles::TimeCreated), "timeCreated" },
        { static_cast<int>(Roles::TimeCreatedSort), "timeCreatedSort" },
        { static_cast<int>(Roles::Title), "title" },
        { static_cast<int>(Roles::Message), "message" },
        { static_cast<int>(Roles::Amount), "amount" },
        { static_cast<int>(Roles::Fee), "fee" },
        { static_cast<int>(Roles::Coin), "coin" },
        { static_cast<int>(Roles::Wallet), "wallet" },
        { static_cast<int>(Roles::TxID), "txid" },
        { static_cast<int>(Roles::Receiver), "receiver" },
        { static_cast<int>(Roles::Sender), "sender" },
        { static_cast<int>(Roles::Token), "token" },
        { static_cast<int>(Roles::KernelID), "kernelID" },
        { static_cast<int>(Roles::Comment), "comment" },
        { static_cast<int>(Roles::Type), "type" },
        { static_cast<int>(Roles::State), "state" },
        { static_cast<int>(Roles::RawID), "rawID" },
        { static_cast<int>(Roles::DateCreated), "dateCreated" },
        
    };
    return roles;
}

QVariant NotificationsList::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_list.size())
    {
       return QVariant();
    }

    auto& value = m_list[index.row()];
    switch (static_cast<Roles>(role))
    {
        case Roles::TimeCreated:
            return value->timeCreated().time().toString(m_locale.timeFormat(QLocale::ShortFormat));
        case Roles::DateCreated:
            return value->timeCreated().date().toString(m_locale.dateFormat(QLocale::ShortFormat));
        case Roles::TimeCreatedSort:
        {
            auto t = value->getTimestamp();
            if (value->getState() == beam::wallet::Notification::State::Unread)
            {
                t |= (uint64_t(1) << 63);
            }
            return static_cast<qulonglong>(t);
        }
        case Roles::Title:
            return value->title();

        case Roles::Message:
            return value->message(_amgr);

        case Roles::Amount:
            return value->amount(_amgr);

        case Roles::Fee:
            return value->fee(_amgr);

        case Roles::Coin:
            return value->coin(_amgr);

        case Roles::Wallet:
            return value->wallet(_amgr);

        case Roles::TxID:
            return value->txid();

        case Roles::Receiver:
            return value->receiver(_amgr);

        case Roles::Sender:
            return value->sender(_amgr);

        case Roles::Token:
            return value->token(_amgr);

        case Roles::KernelID:
            return value->kernelID(_amgr);

        case Roles::Comment:
            return value->comment(_amgr);

        case Roles::Type:
            return value->type();

        case Roles::State:
            return value->state();

        case Roles::RawID:
            return QVariant::fromValue(value->getID());

        default:
            return QVariant();
    }
}

void NotificationsList::onAssetInfo(beam::Asset::ID assetId)
{
    for (auto it = m_list.begin(); it != m_list.end(); ++it) {
        if ((*it)->assetId() == assetId) {
           const auto idx = it - m_list.begin();
           ListModel::touch(idx);
        }
    }
}
