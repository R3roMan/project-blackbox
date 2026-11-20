.pragma library

function replacePane(node,pane,replacement) {
    if (!node) return null
    if (node.pane!==undefined) return node.pane===pane ? replacement : node
    const first=replacePane(node.first,pane,replacement)
    const second=replacePane(node.second,pane,replacement)
    return first && second ? Object.assign({},node,{first,second}) : first || second
}

function changeRatio(node,divider,ratio) {
    if (node.pane!==undefined) return node
    if (node.divider===divider) return Object.assign({},node,{ratio})
    return Object.assign({},node,{first:changeRatio(node.first,divider,ratio),second:changeRatio(node.second,divider,ratio)})
}

function minimum(node) {
    if (node.pane!==undefined) return {w:126,h:86}
    const first=minimum(node.first),second=minimum(node.second)
    return node.across ? {w:first.w+second.w+6,h:Math.max(first.h,second.h)}
        : {w:Math.max(first.w,second.w),h:first.h+second.h+6}
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
        const first=minimum(branch.first),second=minimum(branch.second)
        const a=across ? first.w : first.h,b=across ? second.w : second.h
        const left=usable>=a+b ? Math.max(a,Math.min(usable-b,usable*branch.ratio)) : usable*a/(a+b)
        dividers[branch.divider]={x:x+(across ? left : 0),y:y+(across ? 0 : left),
            w:across ? grip : w,h:across ? h : grip,usable,across,ratio:usable>0 ? left/usable : .5}
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
