import QtQuick
import QtTextToSpeech

Item {
    id:voice
    property real pitch:.38
    function speak(line) {speech.stop();speech.say(line)}
    function stopSpeech() {speech.stop()}
    TextToSpeech {id:speech;pitch:voice.pitch;rate:.14;volume:.65}
}
