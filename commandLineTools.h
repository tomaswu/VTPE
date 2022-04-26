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

signals:

};

#endif // COMMANDLINETOOLS_H
