/*
 * GlobalThemeModel
 * SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 * SPDX-FileCopyrightText: 2002 Karol Szwed <gallium@kde.org>
 * SPDX-FileCopyrightText: 2002 Daniel Molkentin <molkentin@kde.org>
 * SPDX-FileCopyrightText: 2007 Urs Wolfer <uwolfer @ kde.org>
 * SPDX-FileCopyrightText: 2009 Davide Bettio <davide.bettio@kdemail.net>
 * SPDX-FileCopyrightText: 2007 Paolo Capriotti <p.capriotti@gmail.com>
 * SPDX-FileCopyrightText: 2007 Ivan Cukic <ivan.cukic+kde@gmail.com>
 * SPDX-FileCopyrightText: 2008 Petri Damsten <damu@iki.fi>
 * SPDX-FileCopyrightText: 2000 TrollTech AS.
 *
 * SPDX-License-Identifier: GPL-2.0-only
 */

#ifndef LNFLISTMODEL_H
#define LNFLISTMODEL_H

#include <QAbstractItemView>

//Theme selector code by Andre Duffeck (modified to add package description)
class ThemeInfo
{
public:
    QString name;
    QString package;
    QString description;
    QString author;
    QString version;
    QString themeRoot;
};

class GlobalThemeModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
public:
    enum { PackageNameRole = Qt::UserRole,
           PackageDescriptionRole = Qt::UserRole + 1,
           PackageAuthorRole = Qt::UserRole + 2,
           PackageVersionRole = Qt::UserRole + 3
         };

    explicit GlobalThemeModel(QObject *parent = nullptr);
    ~GlobalThemeModel() override;

    QHash<int, QByteArray> roleNames() const override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QModelIndex indexOf(const QString &path) const;
    void reload();
    void clearThemeList();
    int count() const
    {
        return rowCount();
    }

    Q_INVOKABLE QVariantMap get(int index) const;

Q_SIGNALS:
    void countChanged();

private:
    QHash<int, QByteArray> m_roleNames;

    QList<ThemeInfo> m_themes;
};


#endif
