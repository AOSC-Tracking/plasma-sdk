/***************************************************************************
 *                                                                         *
 *   Copyright 2014-2015 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 *                                                                         *
 ***************************************************************************/

#ifndef CUTTLEFISHICONMODEL_H
#define CUTTLEFISHICONMODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <QJsonObject>
#include <QFileInfo>
#include <QVariantMap>
#include <QVariantList>

class KColorSchemeManager;

namespace CuttleFish {


class IconModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)
    Q_PROPERTY(QString category READ category WRITE setCategory NOTIFY categoryChanged)
    Q_PROPERTY(QStringList categories READ categories NOTIFY categoriesChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged);

public:
    enum Roles {
        FileName = Qt::UserRole + 1,
        IconName,
        Icon,
        FullPath,
        Category,
        Scalable,
        Sizes,
        Type,
        Theme
    };

    explicit IconModel(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList inOtherThemes(const QString& iconName, int size);

    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;

    QString key(int role) const;

    bool matchIcons(const QFileInfo &info);
    void add(const QFileInfo &info, const QString &cat);
    void remove(const QString &iconFile);

    void setCategory(const QString &cat);
    QString category() const;

    void setFilter(const QString &filter);
    QString filter() const;

    QStringList categories() const;
    QAbstractItemModel* colorschemes() const;

    bool loading();

    void load();

    Q_INVOKABLE void output(const QString &text);
    Q_INVOKABLE void sort();


Q_SIGNALS:
    void filterChanged();
    void categoryChanged();
    void categoriesChanged();
    void loadingChanged();

private:
    QHash<int, QByteArray> m_roleNames;

    QStringList m_icons;
    QString m_category;
    QStringList m_categories;
    QString m_filter;
    QHash<QString, QVariantMap> m_data;
    QHash<QString, QString> m_categoryTranslations;

    bool m_loading;
    QString categoryFromPath(const QString &path);
};

} // namespace

#endif // CUTTLEFISHICONMODEL_H
