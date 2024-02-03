import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import TexturedSurfaceGeometry

View3D {
    id: view3d

    property string textureImagePath
    property string depthImagePath

    anchors.left: parent.left
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    environment: SceneEnvironment {
        backgroundMode: SceneEnvironment.Color
        clearColor: "white"
    }

    Node {
        id: originNode
        PerspectiveCamera {
            id: cameraNode
            position: Qt.vector3d(0, -5, 135)

        }

        // onEulerRotationChanged: {console.log(eulerRotation.x + " " + eulerRotation.y)}

        QtObject {
            id: animationParameters
            property real speed: 0.01
            property real angleRange: 40

            property real duration: angleRange / speed
            property real halfAngleRange: angleRange / 2
        }

        ParallelAnimation {
            id: startAnimation
            running: true

            property real duration: animationParameters.duration

            function start() {
                duration = Math.max(
                    Math.abs(originNode.eulerRotation.y),
                    Math.abs(originNode.eulerRotation.x - animationParameters.halfAngleRange)
                ) / animationParameters.speed
                running = true
            }

            NumberAnimation {
                target: originNode
                property: "eulerRotation.x"
                duration: startAnimation.duration
                to: animationParameters.halfAngleRange
            }
            NumberAnimation {
                target: originNode
                property: "eulerRotation.y"
                duration: startAnimation.duration
                to: 0
            }

            onStopped: cyclicAnimation.start()
        }

        ParallelAnimation {
            id: cyclicAnimation

            property real angle
            property real deltaAngle: 1
            property real duration: deltaAngle / (animationParameters.speed * 1.6)

            function start() {
                angle = 0
                goToNextPoint()
            }

            function goToNextPoint() {
                angle += deltaAngle
                running = true
            }

            NumberAnimation {
                target: originNode
                property: "eulerRotation.x"
                duration: cyclicAnimation.duration
                to: Math.sin((cyclicAnimation.angle + 90) * Math.PI / 180) * animationParameters.halfAngleRange
            }
            NumberAnimation {
                target: originNode
                property: "eulerRotation.y"
                duration: cyclicAnimation.duration
                to: Math.cos((cyclicAnimation.angle + 90) * Math.PI / 180) * animationParameters.halfAngleRange
            }

            onFinished: cyclicAnimation.goToNextPoint()
        }
    }

    DirectionalLight {
        id: directionalLight
        color: Qt.rgba(0.4, 0.2, 0.6, 1.0)
        ambientColor: Qt.rgba(1.0, 1.0, 1.0, 1.0)
    }

    Model {
        id: texturedSurfaceModel
        visible: true
        geometry: SurfaceGeometry {
            depthImagePath: view3d.depthImagePath

        }
        materials: [
            DefaultMaterial {
                Texture {
                    id: baseColorMap
                    source: textureImagePath
                }
                cullMode: DefaultMaterial.NoCulling
                diffuseMap: baseColorMap
            }
        ]
    }

    OrbitCameraController {
        origin: originNode
        camera: cameraNode

        MouseArea  {
            anchors.fill: parent
            onWheel: (event)=> {
                if (event.modifiers & Qt.ShiftModifier) {
                    texturedSurfaceModel.scale.z += event.angleDelta.y / 5000.0
                    event.accepted = true
                } else {
                    event.accepted = false
                }
            }
            onMouseXChanged: (event)=> {
                if ((event.button === Qt.LeftButton)) {
                    startAnimation.stop()
                    cyclicAnimation.stop()
                    inactivityTimer.restart()
                    event.accepted = false
                }
            }
        }
    }

    Timer {
        id: inactivityTimer
        interval: 5000
        repeat: false
        running: false
        onTriggered: startAnimation.start()
    }
}
