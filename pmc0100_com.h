#ifndef PMC0100_COM_H
#define PMC0100_COM_H

#include <QObject>
#include <QtSerialPort/QSerialPort>
#include <QThread>
#include <QTimer>
#include <QStringList>

class PMC0100_COM : public QObject
{
    Q_OBJECT
public:
    explicit PMC0100_COM(QObject *parent = nullptr);
    ~PMC0100_COM();
    QSerialPort* com;
    QThread* th;
    QTimer* timer;
    bool flag = false;
    void read();
    Q_INVOKABLE bool start(int index);
    Q_INVOKABLE bool stop();
    Q_INVOKABLE QStringList enumDevice();
    Q_INVOKABLE void pause(){timer->stop();};
    Q_INVOKABLE void restartFromPause(){timer->start();};

signals:
    void newValueReady(int value);

};

#endif // PMC0100_COM_H
