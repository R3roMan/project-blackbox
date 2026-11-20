import QtQuick
import QtTest
import ".." as Demo
TestCase {
    name:"ApplicationShell"
    Component {id:shell;Demo.Demo {visible:false}}
    function test_demoAndItsPagesCompile() {
        const window=shell.createObject(null)
        verify(window!==null)
        compare(window.page,"home")
        window.destroy()
    }
}
