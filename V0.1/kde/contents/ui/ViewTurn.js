.pragma library

function seam(direction,progress) {
    const t=Math.max(0,Math.min(1,progress))
    const u=(1-Math.tan((t-.5)*Math.PI*.5))*.5
    return direction==="right" || direction==="down" ? u : 1-u
}

// Project two adjacent walls onto one moving screen edge. Both faces use
// precisely the same seam and depth there, including on the software backend.
function panel(width,height,direction,progress,incoming,strength) {
    const horizontal=direction==="left" || direction==="right"
    const positive=direction==="right" || direction==="down"
    const t=Math.max(0,Math.min(1,progress))
    const span=horizontal ? Math.max(1,width) : Math.max(1,height)
    const edge=positive!==incoming ? 1 : 0
    const at=seam(direction,t)*span
    const depth=(edge ? 1 : -1)*Math.min(.76,.56*strength)*(incoming ? 1-t : t)
    const constant=1-depth*edge
    const k=depth/span
    const mid=(horizontal ? height : width)*.5
    const stretch=1+.15*Math.sin(t*Math.PI)*strength
    const a=at*k+stretch, b=at*constant-edge*span*stretch
    return horizontal ? Qt.matrix4x4(a,0,0,b,mid*k,1,0,mid*(constant-1),0,0,1,0,k,0,0,constant)
        : Qt.matrix4x4(1,mid*k,0,mid*(constant-1),0,a,0,b,0,0,1,0,0,k,0,constant)
}

function identity() { return Qt.matrix4x4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1) }

function descent(height,progress,incoming,returning,strength) {
    const travel=incoming ? 1-progress : progress
    const depth=travel*strength*(incoming ? .27 : .34)
    return {scale:1+depth,y:height*depth*.44*(incoming!==returning ? 1 : -1)}
}
