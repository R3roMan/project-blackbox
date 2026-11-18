import QtQuick

ShaderEffect {
    required property Item battlefield
    required property real phase
    required property real strength
    property bool hypnotised: false

    property variant source: ShaderEffectSource {
        sourceItem: parentEffect.battlefield
        hideSource: true
        live: true
        textureSize: Qt.size(Math.min(1280, parentEffect.width), Math.min(720, parentEffect.height))
    }
    id: parentEffect
    fragmentShader: Qt.resolvedUrl(hypnotised ? "shaders/hypnosis.frag.qsb" : "shaders/distortion.frag.qsb")
}
