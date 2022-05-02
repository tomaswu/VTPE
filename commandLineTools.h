#ifndef COMMANDLINETOOLS_H
#define COMMANDLINETOOLS_H

#include <QObject>
#include <QProcess>
#include <QString>

class commandLineTools : public QObject
{
    Q_OBJECT
public:
    explicit commandLineTools(QObject *parent = nullptr);
    ~commandLineTools();
    QProcess *p;
    Q_INVOKABLE void system(QString s);
    Q_INVOKABLE QString getSaveFileName(QString title,QString dir,QString filter);
    Q_INVOKABLE QString getOpenFileName(QString title,QString dir,QString filter);

signals:

};

#endif // COMMANDLINETOOLS_H
