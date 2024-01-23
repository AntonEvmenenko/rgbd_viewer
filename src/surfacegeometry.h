#ifndef SURFACEGEOMETRY_H
#define SURFACEGEOMETRY_H

#include <QQuick3DGeometry>

class SurfaceGeometry : public QQuick3DGeometry
{
    Q_OBJECT
    QML_NAMED_ELEMENT(SurfaceGeometry)
    Q_PROPERTY(QString depthImagePath READ depthImagePath WRITE setDepthImagePath NOTIFY depthImagePathChanged)

public:
    SurfaceGeometry();

    QString depthImagePath() const { return m_depthImagePath; }
    void setDepthImagePath(QString depthImagePath);

signals:
    void depthImagePathChanged();

private:
    void updateData();

    QString m_depthImagePath;
    float m_gridSize = 0.1f;
};

#endif
