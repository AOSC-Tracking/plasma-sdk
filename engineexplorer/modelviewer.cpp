/*
 *   SPDX-FileCopyrightText: 2008 Aaron Seigo <aseigo@kde.org>
 *   SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "modelviewer.h"

#include <QDebug>
#include <QDialogButtonBox>
#include <KMessageBox>
#include <KStringHandler>
#include <KLocalizedString>

#include <Plasma/DataEngine>
#include <Plasma/Service>
#include <Plasma/ServiceJob>

#include "engineexplorer.h"

Delegate::Delegate(QObject *parent)
    : QAbstractItemDelegate(parent)
{

}

Delegate::~Delegate()
{
}

void Delegate::paint(QPainter *painter, const QStyleOptionViewItem &option,
           const QModelIndex &index) const
{
    if (!index.model()) {
        return;
    }

    QFontMetrics fm(option.font);
    int maxWidth = 0;
    foreach (int role, index.model()->roleNames().keys()) {
        const QString text = index.model()->roleNames().value(role) + QLatin1String(": ");
        maxWidth = qMax(maxWidth, fm.boundingRect(text).width());
    }

    int i = 2;
    foreach (int role, index.model()->roleNames().keys()) {
        const QString text = index.model()->roleNames().value(role) + QLatin1String(": ");
        painter->drawText(option.rect.x() + maxWidth - fm.boundingRect(text).width(), option.rect.y() + i*fm.height(), text);

        if (index.data(role).canConvert<QIcon>()) {
            index.data(role).value<QIcon>().paint(painter, option.rect.x() + maxWidth, option.rect.y() + (i-1)*fm.height(), 16, 16);
        } else if (!index.data(role).isValid()) {
            painter->drawText(option.rect.x() + maxWidth, option.rect.y() + i*fm.height(), "null");
        } else {
            painter->drawText(option.rect.x() + maxWidth, option.rect.y() + i*fm.height(), index.data(role).toString());
        }
        ++i;
    }
}


QSize Delegate::sizeHint(const QStyleOptionViewItem &option,
               const QModelIndex &index) const
{
    if (!index.model()) {
        return QSize();
    }

    QFontMetrics fm(option.font);
    return QSize(fm.boundingRect("M").width() * 50, fm.height() * (index.model()->roleNames().count()+2));
}


ModelViewer::ModelViewer(Plasma::DataEngine *engine, const QString &source, QWidget *parent)
    : QDialog(parent),
      m_engine(engine),
      m_source(source)
{
    setAttribute(Qt::WA_DeleteOnClose);
    m_view = new QTreeView(this);
    m_view->setItemDelegate(new Delegate(m_view));
    QVBoxLayout *layout = new QVBoxLayout();
    layout->addWidget(m_view);
    setLayout(layout);

    QString engineName = i18nc("Plasma engine with unknown name", "Unknown");

    if (m_engine) {
        if (m_engine->pluginInfo().isValid()) {
            engineName = KStringHandler::capwords(m_engine->pluginInfo().name());
        }
        qDebug() << "########### CALLING SERVICE FOR SOURCE: " << m_source;
        m_model = m_engine->modelForSource(m_source);

        if (m_model != nullptr) {
            connect(m_engine, &QObject::destroyed, this, &ModelViewer::engineDestroyed);
            m_view->setModel(m_model);
        } else {
            KMessageBox::sorry(this, i18n("No valid model was returned. Verify that a model is available for this source."));
            close();
        }
    }

    setWindowTitle(i18nc("%1 is a Plasma dataengine name", "%1 Model Explorer", engineName));
}

ModelViewer::~ModelViewer()
{
    m_engine = nullptr;
}


void ModelViewer::engineDestroyed()
{
    m_model = nullptr;
    m_engine = nullptr;
    hide();
    deleteLater();
}


