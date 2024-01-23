#include "surfacegeometry.h"
#include <QRandomGenerator>
#include <QVector3D>
#include <QList>
#include <QDataStream>
#include <QIODevice>
#include <QImage>
#include <QDir>

SurfaceGeometry::SurfaceGeometry()
{
}

void SurfaceGeometry::setDepthImagePath(QString depthImagePath)
{
    const QUrl url(depthImagePath);
    if (url.isLocalFile()) {
        m_depthImagePath = QDir::toNativeSeparators(url.toLocalFile());
    }
    updateData();
    update();
}

void SurfaceGeometry::updateData()
{
    clear();

    size_t stride = (3 + 3 + 2) * sizeof(float);
    setStride(stride);

    QImage depthMap;

    if (!depthMap.load(m_depthImagePath)) {
        return; // TODO implement better error handling
    }

    // let QT make sure that pixel format is always RGB888
    depthMap.convertTo(QImage::Format_RGB888);

    const uchar *imageBits = depthMap.constBits();

    size_t imageHeight = depthMap.height();
    size_t imageWidth = depthMap.width();

    size_t widthBits = imageWidth * 3;

    QByteArray vertexData(imageHeight * imageWidth * stride, Qt::Initialization::Uninitialized);
    QDataStream vertexDataStream(&vertexData, QIODevice::OpenModeFlag::WriteOnly);
    vertexDataStream.setByteOrder(QDataStream::LittleEndian);
    vertexDataStream.setFloatingPointPrecision(QDataStream::SinglePrecision);

    for (size_t i = 0; i < imageHeight; i++) {
        size_t p = i * widthBits;
        for (size_t j = 0; j < imageWidth; j++) {
            uchar r = imageBits[p];
            uchar g = imageBits[p + 1];
            uchar b = imageBits[p + 2];

            int grayscale = (int) (0.299 * r + 0.587 * g + 0.114 * b);

            // vertex (x, y, z)
            vertexDataStream << (j - imageWidth / 2.0f) * m_gridSize << (i * -1.0f + imageHeight / 2.0f) * m_gridSize <<  grayscale * 0.1f;

            // fake normal (x, y, z)
            vertexDataStream <<  0.0f <<  0.0f <<  1.0f;

            // texture uv (x, y)
            vertexDataStream <<  j / static_cast<float>(imageWidth - 1) <<  (imageHeight - i) / static_cast<float>(imageHeight - 1);

            p += 3;
        }
    }

    QByteArray indexData(6 * sizeof(uint32_t), Qt::Initialization::Uninitialized);
    QDataStream indexDataStream(&indexData, QIODevice::OpenModeFlag::WriteOnly);
    indexDataStream.setByteOrder(QDataStream::LittleEndian);

    // simple triangulation
    for (size_t j = 0; j < imageHeight - 1; ++j) {
        for (size_t i = 0; i < imageWidth - 1; ++i) {
            uint32_t a = j * imageWidth + i;
            uint32_t b = a + 1;
            uint32_t c = a + imageWidth;
            uint32_t d = c + 1;

            indexDataStream << a << b << d; // first triangle ccw
            indexDataStream << a << d << c; // second triangle ccw
        }
    }

    setPrimitiveType(QQuick3DGeometry::PrimitiveType::Triangles);

    addAttribute(QQuick3DGeometry::Attribute::PositionSemantic, 0, QQuick3DGeometry::Attribute::F32Type);
    addAttribute(QQuick3DGeometry::Attribute::NormalSemantic, 3 * sizeof(float), QQuick3DGeometry::Attribute::F32Type);
    addAttribute(QQuick3DGeometry::Attribute::TexCoordSemantic, 6 * sizeof(float), QQuick3DGeometry::Attribute::F32Type);
    setVertexData(vertexData);

    addAttribute(Attribute::IndexSemantic, 0, Attribute::U32Type);
    setIndexData(indexData);
}
