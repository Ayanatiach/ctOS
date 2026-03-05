import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: container
    width: 1920
    height: 1080
    color: "#050505"

    // ===========================================================================================
    // PHASE 1: BOTTOM LEFT BOOT LOGS and RIGHT INTERFACE THINGY(not present in the current ver.)
    // ===========================================================================================
    ListView {
        id: bootLogs
        width: 600; height: 200
        anchors { bottom: parent.bottom; left: parent.left; margins: 40 }
        model: ListModel { id: logModel }
        delegate: Text { 
            text: "> " + display
            color: "#00ffff"; font.pixelSize: 12; font.family: "Monospace"; opacity: 0.6 
        }
        
        Timer {
            id: logTimer
            interval: 80; repeat: true; running: true
            property var lines: ["REGION_LINK_ESTABLISHED", "KERNEL_ESTABLISHED", "BYPASSING_FIREWALLS...", "HANDSHAKE_COMPLETE"]
            property int index: 0
            onTriggered: {
                if (index < lines.length) {
                    logModel.append({"display": lines[index]})
                    index++
                } else {
                    stop(); centerBoot.opacity = 1; centerBootTimer.start()
                }
            }
        }
    }

	// --- PHASE 1.5: SIDE DECORATIONS (to be revised in future) ---
    Image {
        id: sideGraphic
        source: ""
        width: 400
        height: 800
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 40
        }
        
        // Match the boot logs visibility
        opacity: logTimer.running ? 0.4 : 0 
        fillMode: Image.PreserveAspectFit
        
        // Smooth fade in as logs start
        Behavior on opacity { NumberAnimation { duration: 1000 } }
    }

    // ========================================================
    // PHASE 2: ROTATING STRUCTURAL LOGO MORPH (the cool shi-)
    // ========================================================
    Item {
        id: centerBoot
        anchors.centerIn: parent
        width: 600; height: 200
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 500 } }

        // --LOADING BAR--
        
	Column {
            id: loadingColumn
            anchors.centerIn: parent; spacing: 20
            Text {
                text: "ESTABLISHING_SECURE_CONNECTION..."
                color: "white"; font.pixelSize: 18; font.family: "Monospace"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Rectangle {
                id: barContainer
                width: 500; height: 4; color: "transparent"
                border.color: "white"; border.width: 1
                Rectangle {
                    id: progressBar
                    height: parent.height - 2; width: 0; color: "white"
                    anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 1
                }
            }
        }

        // CANVAS OUTLINE
        
	Canvas {
            id: logoOutline
            anchors.centerIn: parent
            width: 140; height: 140
            opacity: 0; rotation: 0
            property real strokeEnd: 0
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.strokeStyle = "#00ffff"
                ctx.lineWidth = 3
                ctx.beginPath()
                ctx.arc(70, 70, 60, -Math.PI/2, (-Math.PI/2) + (Math.PI * 2 * strokeEnd))
                ctx.stroke()
            }
            onStrokeEndChanged: requestPaint()
        }

        // MAIN LOGO between the circle loader
        	
	Image {
            id: internalLogo
            source: "ctos_logo_main.png"
            anchors.centerIn: parent
            width: 100; height: 100
            opacity: 0; scale: 0.7
        }

        // Animation Sequence to morph BAR -> LOGO
        SequentialAnimation {
            id: morphSequence
            NumberAnimation { target: loadingColumn; property: "opacity"; to: 0; duration: 200 }
            
            ParallelAnimation {
                NumberAnimation { target: logoOutline; property: "opacity"; to: 1; duration: 100 }
                NumberAnimation { target: logoOutline; property: "strokeEnd"; to: 1; duration: 800; easing.type: Easing.InOutCubic }
                NumberAnimation { target: logoOutline; property: "rotation"; from: -90; to: 0; duration: 800; easing.type: Easing.OutCubic }
            }

            ParallelAnimation {
                NumberAnimation { target: internalLogo; property: "opacity"; to: 1; duration: 500 }
                NumberAnimation { target: internalLogo; property: "scale"; to: 1; duration: 500; easing.type: Easing.OutBack }
            }
            
            PauseAnimation { duration: 1200 }
            NumberAnimation { target: centerBoot; property: "opacity"; to: 0; duration: 400 }
            onFinished: { loginUI.visible = true; uiLoadAnim.start() }
        }

        // TIME TO FILL THE PROGRESS BAR
        
	Timer {
            id: centerBootTimer
            interval: 20; repeat: true
            onTriggered: {
                if (progressBar.width < 498) {
                    progressBar.width += Math.random() * 35 
                } else {
                    stop(); morphSequence.start()
                }
            }
        }
    }

    // =======================================================================
    // PHASE 3: MAIN LOGIN INTERFACE (The watch dogs style yet to be revamped)
    // =======================================================================
    Item {
        id: loginUI
        anchors.fill: parent; visible: false

        // Top Left: Logo + Clock
        Row {
            id: topLeftUI
            anchors { top: parent.top; left: parent.left; margins: 30 }
            spacing: 20; opacity: 0
            Image { source: "ctos_logo_main.png"; width: 60; height: 60; fillMode: Image.PreserveAspectFit }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                Text { text: Qt.formatDateTime(new Date(), "hh:mm"); color: "white"; font.pixelSize: 28; font.family: "Monospace" }
                Text { text: Qt.formatDateTime(new Date(), "dddd d MMMM"); color: "white"; font.pixelSize: 20; font.family: "Monospace"; opacity: 0.8 }
            }
        }

        // Password entry to login ofc ;)
        Column {
            id: loginCenter
            anchors.centerIn: parent; spacing: 25; opacity: 0
            Text { text: "USER: AYANATIACH"; color: "white"; font.pixelSize: 20; font.family: "Monospace"; anchors.horizontalCenter: parent.horizontalCenter }
            
	TextField {
                id: passwordField
                width: 250; height: 80
                echoMode: TextInput.Password
                passwordCharacter: "■"
                color: "white"
                
                font.pixelSize: 52
                font.letterSpacing:2
                font.family: "Monospace"
                
                horizontalAlignment: TextInput.AlignHCenter // Centre the text horizontally
		verticalAlignment: TextInput.AlignVCenter // same shi- but vertically
                leftPadding: 0
                
                background: Rectangle {
                    color: "black"
                    border.color: passwordField.color
                    border.width: 1
                    
                    
                    Text { 
                        text: "" // if wanna add something ig IT WILL BE ON THE LEFT OF THE PASS ENTERED
                        color: "#00ffff"
                        font.pixelSize: 30
                        anchors { left: parent.left; leftMargin: 15; verticalCenter: parent.verticalCenter } 
                    }
                }
                
                onAccepted: { successAnim.start() } 
            }

        SequentialAnimation {
            id: uiLoadAnim
            ParallelAnimation {
                NumberAnimation { target: topLeftUI; property: "opacity"; to: 1; duration: 600 }
                NumberAnimation { target: loginCenter; property: "opacity"; to: 1; duration: 600 }
            }
            ScriptAction { script: passwordField.forceActiveFocus() } // Auto-focuses the text box and does cool shi-
        }
    }

    // ======================================================
    // PHASE 4: POST-LOGIN PROFILE WINDOW (The final stretch)
    // ======================================================
    
    Item {
    id: profileWindow
        anchors.centerIn: parent
        width: 450; height: 180; opacity: 0; visible: opacity > 0; scale: 0.9

        Rectangle {
            anchors.fill: parent; color: "#050505"; border.color: "#00ffff"; border.width: 1
            Row {
                anchors.centerIn: parent; spacing: 20
                Rectangle {
                    width: 80; height: 80; color: "black"; border.color: "#00ffff"; border.width: 1
                    Image { source: "user_avatar.png"; anchors.fill: parent; anchors.margins: 2; fillMode: Image.PreserveAspectCrop }
                }
                Column {
                    spacing: 5
                    Text { text: "IDENTITY: AYANATIACH"; color: "white"; font.pixelSize: 18; font.family: "Monospace" }
                    Text { text: "STATUS: ACCESS_GRANTED"; color: "#00ffff"; font.pixelSize: 14; font.family: "Monospace" }
                    Text { text: "DECRYPTING_USER_SPACE..."; color: "#00ffff"; font.pixelSize: 10; font.family: "Monospace"; opacity: 0.5 }
                }
            }
        }

        // Animation that plays right before logging into Hyprland
        SequentialAnimation {
            id: successAnim
            // 1. Hide the login UI
            NumberAnimation { target: loginUI; property: "opacity"; to: 0; duration: 300 }
            
            // 2. Pop the profile card
            ParallelAnimation {
                NumberAnimation { target: profileWindow; property: "opacity"; to: 1; duration: 200 }
                NumberAnimation { target: profileWindow; property: "scale"; to: 1; duration: 300; easing.type: Easing.OutBack }
            }
            PauseAnimation { duration: 1500 }
            
            // 3. Fade out everything to black
            NumberAnimation { target: container; property: "opacity"; to: 0; duration: 500 }
            
            // checks if the entered pass is correct or not
            ScriptAction { script: sddm.login(userModel.lastUser, passwordField.text, sessionModel.lastIndex) }
        }
    }

    // ================================================================================================
    // GLITCH & AUTH FAILURE LOGIC (this probably doesn't work rn so will be fixing it in later update)
    // ================================================================================================
    Connections {
        target: sddm
        function onLoginFailed() {
            passwordField.color = "#ff0000"; 
            passwordField.text = ""; 
            glitchTimer.start()
        }
    }

    Timer {
        id: glitchTimer; interval: 40; repeat: true; property int count: 0
        onTriggered: {
            container.x = (Math.random() - 0.5) * 40
            if (count++ > 20) { stop(); count = 0; container.x = 0; passwordField.color = "white" }
        }
    }
}
}
