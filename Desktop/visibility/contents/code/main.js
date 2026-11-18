// No window properties are changed. Only desktop exposure is reported.
function reportBlackbox() {
    var window=workspace.activeWindow;
    if(window && window.dock)return; // Panel interaction keeps the preceding state.
    var home=!window || window.desktopWindow;
    callDBus("org.projectblackbox.Desktop","/Blackbox","org.projectblackbox.Desktop","Visibility",Boolean(home));
}
workspace.windowActivated.connect(reportBlackbox);
workspace.windowAdded.connect(reportBlackbox);
workspace.windowRemoved.connect(reportBlackbox);
workspace.currentDesktopChanged.connect(reportBlackbox);
workspace.currentActivityChanged.connect(reportBlackbox);
reportBlackbox();
