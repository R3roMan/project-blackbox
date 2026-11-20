.pragma library

function replacePane(node,pane,replacement) {
    if (!node) return null
    if (node.pane!==undefined) return node.pane===pane ? replacement : node
    const first=replacePane(node.first,pane,replacement)
    const second=replacePane(node.second,pane,replacement)
    return first && second ? {...node,first,second} : first || second
}

function changeRatio(node,divider,ratio) {
    if (node.pane!==undefined) return node
    if (node.divider===divider) return {...node,ratio}
    return {...node,first:changeRatio(node.first,divider,ratio),second:changeRatio(node.second,divider,ratio)}
}

function arrange(node,width,height) {
    const panes={}
    const dividers={}
    function walk(branch,x,y,w,h) {
        if (branch.pane!==undefined) {
            panes[branch.pane]={x,y,w,h}
            return
        }
        const across=branch.across
        const length=across ? w : h
        const grip=Math.min(6,length*.1)
        const usable=length-grip
        const left=usable*branch.ratio
        dividers[branch.divider]={x:x+(across ? left : 0),y:y+(across ? 0 : left),
            w:across ? grip : w,h:across ? h : grip,usable,across,ratio:branch.ratio}
        if (across) {
            walk(branch.first,x,y,left,h)
            walk(branch.second,x+left+grip,y,usable-left,h)
        } else {
            walk(branch.first,x,y,w,left)
            walk(branch.second,x,y+left+grip,w,usable-left)
        }
    }
    if (node) walk(node,0,0,Math.max(0,width),Math.max(0,height))
    return {panes,dividers}
}
