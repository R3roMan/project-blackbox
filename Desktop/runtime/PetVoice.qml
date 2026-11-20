import QtQuick
import QtTextToSpeech

Item {
    function speak(line) {speech.stop();speech.say(line)}
    function stopSpeech() {speech.stop()}
    TextToSpeech {id:speech;pitch:.38;rate:.14;volume:.65}
}
