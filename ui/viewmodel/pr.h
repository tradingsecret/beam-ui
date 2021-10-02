#ifndef PR_H
#define PR_H

#include <QObject>
#include <QVariant>
#include "start_view.h"

class pr : public QObject
{
    Q_OBJECT

public:
    pr();

public:
    Q_INVOKABLE void print(QList<RecoveryPhraseItem *> data);
};

#endif // PR_H