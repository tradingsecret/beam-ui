#include "pr.h"
#include "start_view.h"
#include <QPrinter>
#include <QPainter>
#include <QPrintDialog>
#include <QStaticText>
#include <QPixmap>
#include <QImage>
#include <qDebug>

pr::pr()
{
}

void pr::print(QList<RecoveryPhraseItem *> items)
{
    QPrinter printer;
    printer.setFullPage(true);
    QPrintDialog *dlg = new QPrintDialog(&printer,0);
    if(dlg->exec() == QDialog::Accepted) {
          QPainter painter(&printer);
          int id = 0;
          QString text = "<center><table width='4000' align='center'><tr><td colspan='4'><br/><br/><br/><br/><br/><font size='250'><b align='center'><center>Seed phrase</center></b></font><br/><br/><br/><br/><br/></td></tr><tr>";


          for (RecoveryPhraseItem * item : items) {
              id++;

              text = text + "<td width='300'><font size='250'>"+ QString::number(item->getIndex()+1) + ".&nbsp;" + item->getPhrase() +"</b></td>";

              if (id % 4 == 0) {
                  text = text + "</tr><tr>";
              }
          }

          text = text + "</tr></table></center>";
             
          QStaticText staticText;
          staticText.setText(text);
          staticText.setTextFormat(Qt::RichText);
          painter.drawStaticText(250, 0, staticText);
    }
}
