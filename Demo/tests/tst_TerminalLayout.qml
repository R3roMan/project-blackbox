import QtQuick
import QtTest
import "../../Desktop/runtime/TerminalLayout.js" as Layout

TestCase {
    name:"PureCodeLayout"

    function test_mixedSplitsAndResizingKeepTheWallpaperTiled() {
        let node={divider:6,across:true,ratio:.5,first:{pane:1},
            second:{divider:7,across:false,ratio:.5,first:{pane:2},second:{pane:3}}}
        node=Layout.changeRatio(node,6,.27)
        const zones=Layout.arrange(node,1280,720)
        compare(zones.panes[1].x,0)
        compare(zones.panes[1].h,720)
        compare(zones.panes[1].w,zones.dividers[6].x)
        compare(zones.dividers[6].x+zones.dividers[6].w,zones.panes[2].x)
        compare(zones.panes[3].x+zones.panes[3].w,1280)
        compare(zones.panes[3].y+zones.panes[3].h,720)
        compare(zones.panes[2].y+zones.panes[2].h,zones.dividers[7].y)
        const narrow=Layout.arrange(node,170,120)
        verify(narrow.panes[1].w>0 && narrow.panes[2].h>0 && narrow.panes[3].h>0)
        fuzzyCompare(narrow.panes[3].x+narrow.panes[3].w,170,.01)
    }

    function test_closingAViewLetsItsNeighbourFillTheSpace() {
        const node={divider:4,across:false,ratio:.5,first:{pane:1},second:{pane:2}}
        const result=Layout.arrange(Layout.replacePane(node,1,null),920,700)
        compare(Object.keys(result.dividers).length,0)
        compare(result.panes[2].w,920)
        compare(result.panes[2].h,700)
    }
}
