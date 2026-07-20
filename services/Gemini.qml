pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.common
import qs.services

Singleton {
    id: root

    readonly property string baseUrl: "https://generativelanguage.googleapis.com/v1beta"

    property bool active: GlobalStates.leftPanelOpen
    property string state: "dormant"
    property var messages: []
    property int ping: 0
    property string errorText: ""

    property bool validatedThisSession: false
    readonly property bool networkUp: Network.ethernetConnected || Network.wifiStatus === "connected"

    property var _xhr: null
    property real _reqStart: 0
    property int _streamOffset: 0
    property int _streamMsgIndex: -1
    property string _targetText: ""
    property bool _netDone: false

    onActiveChanged: active ? enter() : teardown()

    Connections {
        target: Preferences
        function onGeminiApiKeyChanged() {
            root.validatedThisSession = false;
            if (root.active)
                root.enter();
        }
        function onGeminiModelChanged() {
            root.validatedThisSession = false;
        }
    }

    Timer {
        id: typeTimer
        interval: 16
        repeat: true
        running: false
        onTriggered: root._tick()
    }

    function enter(): void {
        errorText = "";
        if (!Preferences.geminiConfigured) {
            state = "needs-key";
            return;
        }
        Location.warmup();
        if (validatedThisSession) {
            state = "idle";
            return;
        }
        if (!networkUp) {
            state = "offline";
            return;
        }
        handshake();
    }

    function teardown(): void {
        abortInFlight();
        messages = [];
        state = "dormant";
        errorText = "";
    }

    function abortInFlight(): void {
        if (_xhr) {
            try {
                _xhr.abort();
            } catch (e) {}
            _xhr = null;
        }
        typeTimer.running = false;
        _streamMsgIndex = -1;
        _streamOffset = 0;
        _targetText = "";
        _netDone = false;
    }

    function retry(): void {
        validatedThisSession = false;
        if (active)
            enter();
    }

    function handshake(): void {
        state = "connecting";
        _reqStart = Date.now();
        const xhr = new XMLHttpRequest();
        xhr.open("GET", root.baseUrl + "/models?key=" + encodeURIComponent(Preferences.geminiApiKey));
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;
            root.ping = Math.round(Date.now() - root._reqStart);
            if (xhr.status >= 200 && xhr.status < 300) {
                root.validatedThisSession = true;
                if (root.active)
                    root.state = "idle";
            } else if (xhr.status === 400 || xhr.status === 401 || xhr.status === 403) {
                root.errorText = "Invalid API key";
                if (root.active)
                    root.state = "needs-key";
            } else if (xhr.status === 0) {
                if (root.active)
                    root.state = "offline";
            } else {
                const msg = root._apiErrorMessage(xhr.responseText, xhr.status);
                root.errorText = msg;
                root._pushError(msg);
                if (root.active)
                    root.state = "offline";
            }
        };
        xhr.send();
    }

    function _pushMessage(m: var): int {
        const a = root.messages.slice();
        a.push(m);
        root.messages = a;
        return a.length - 1;
    }

    function _setMessage(i: int, m: var): void {
        const a = root.messages.slice();
        a[i] = m;
        root.messages = a;
    }

    function _pushError(text: string): void {
        _pushMessage({
            "role": "error",
            "text": text,
            "streaming": false
        });
    }

    function _apiErrorMessage(responseText: string, status: int): string {
        let apiMsg = "";
        try {
            let obj = JSON.parse(responseText);
            if (Array.isArray(obj))
                obj = obj[0];
            if (obj && obj.error)
                apiMsg = obj.error.message || "";
        } catch (e) {}
        let label;
        switch (status) {
        case 429:
            label = "Rate limit reached";
            break;
        case 400:
            label = "Bad request";
            break;
        case 401:
        case 403:
            label = "Authentication failed";
            break;
        case 404:
            label = "Model not found";
            break;
        case 500:
        case 503:
            label = "Gemini service error";
            break;
        default:
            label = "Request failed";
        }
        let out = label + " (" + status + ")";
        if (apiMsg.length > 0)
            out += " — " + apiMsg;
        return out;
    }

    function send(text: string): void {
        if (!text || text.length === 0)
            return;
        if (state === "needs-key" || state === "offline" || state === "connecting" || state === "dormant")
            return;
        _pushMessage({
            "role": "user",
            "text": text,
            "streaming": false
        });
        state = "thinking";
        startStream();
    }

    function _buildContents(): var {
        const contents = [];
        for (let i = 0; i < root.messages.length; i++) {
            const m = root.messages[i];
            contents.push({
                "role": m.role === "model" ? "model" : "user",
                "parts": [{
                        "text": m.text
                    }]
            });
        }
        return contents;
    }

    function startStream(): void {
        _reqStart = Date.now();
        _streamOffset = 0;
        _streamMsgIndex = -1;
        _targetText = "";
        _netDone = false;

        const body = {
            "contents": _buildContents(),
            "generationConfig": {
                "temperature": Preferences.geminiTemperature
            }
        };
        if (Preferences.geminiMaxTokens > 0)
            body.generationConfig.maxOutputTokens = Preferences.geminiMaxTokens;

        const persona = "You are a helpful assistant in a desktop chat sidebar. Keep replies short and conversational, like texting a friend — usually one to three sentences. Get straight to the point, skip preamble and filler, and avoid headings or long bulleted lists unless the user explicitly asks for detail or a list. Match the user's tone.";
        const locationInfo = Location.ready ? ("\n\nUser location: " + Location.summary + ". Use it for weather and location-specific questions.") : "";
        const extraPrompt = (Preferences.geminiSystemPrompt && Preferences.geminiSystemPrompt.length > 0) ? ("\n\n" + Preferences.geminiSystemPrompt) : "";
        body.systemInstruction = {
            "parts": [{
                    "text": persona + locationInfo + extraPrompt
                }]
        };
        if (Preferences.geminiWebSearch)
            body.tools = [{
                    "google_search": {}
                }];

        const url = root.baseUrl + "/models/" + encodeURIComponent(Preferences.geminiModel) + ":streamGenerateContent?alt=sse&key=" + encodeURIComponent(Preferences.geminiApiKey);
        const xhr = new XMLHttpRequest();
        root._xhr = xhr;
        xhr.open("POST", url);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.LOADING || xhr.readyState === XMLHttpRequest.DONE)
                root._consumeStream(xhr.responseText);
            if (xhr.readyState === XMLHttpRequest.DONE)
                root._finishStream(xhr.status, xhr.responseText);
        };
        xhr.send(JSON.stringify(body));
    }

    function _consumeStream(fullText: string): void {
        if (!fullText || fullText.length <= root._streamOffset)
            return;
        const fresh = fullText.substring(root._streamOffset);
        root._streamOffset = fullText.length;
        const lines = fresh.split("\n");
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (line.indexOf("data:") !== 0)
                continue;
            const payload = line.substring(5).trim();
            if (payload.length === 0 || payload === "[DONE]")
                continue;
            let obj;
            try {
                obj = JSON.parse(payload);
            } catch (e) {
                continue;
            }
            const token = root._extractText(obj);
            if (token.length > 0)
                root._receiveToken(token);
        }
    }

    function _extractText(obj: var): string {
        try {
            const parts = obj.candidates[0].content.parts;
            let s = "";
            for (let i = 0; i < parts.length; i++)
                if (parts[i].text)
                    s += parts[i].text;
            return s;
        } catch (e) {
            return "";
        }
    }

    function _receiveToken(token: string): void {
        if (root._streamMsgIndex < 0) {
            if (root.active)
                root.state = "responding";
            root._streamMsgIndex = _pushMessage({
                "role": "model",
                "text": "",
                "streaming": true
            });
        }
        root._targetText += token;
        typeTimer.running = true;
    }

    function _tick(): void {
        if (root._streamMsgIndex < 0) {
            typeTimer.running = false;
            return;
        }
        const shown = root.messages[root._streamMsgIndex].text.length;
        const target = root._targetText.length;
        if (shown < target) {
            const step = Math.max(2, Math.floor((target - shown) / 40));
            _setMessage(root._streamMsgIndex, {
                "role": "model",
                "text": root._targetText.substring(0, shown + step),
                "streaming": true
            });
        } else if (root._netDone) {
            _setMessage(root._streamMsgIndex, {
                "role": "model",
                "text": root._targetText,
                "streaming": false
            });
            typeTimer.running = false;
            root._streamMsgIndex = -1;
            root._targetText = "";
            root._streamOffset = 0;
            if (root.active)
                root.state = "idle";
        }
    }

    function _finishStream(status: int, responseText: string): void {
        root._xhr = null;
        root._netDone = true;

        if (status !== 0 && (status < 200 || status >= 300)) {
            const msg = root._apiErrorMessage(responseText, status);
            root.errorText = msg;
            if (root._streamMsgIndex >= 0) {
                _setMessage(root._streamMsgIndex, {
                    "role": "model",
                    "text": root._targetText,
                    "streaming": false
                });
                typeTimer.running = false;
                root._streamMsgIndex = -1;
                root._targetText = "";
            }
            root._streamOffset = 0;
            _pushError(msg);
            if (root.active)
                root.state = "idle";
            return;
        }

        if (root._streamMsgIndex < 0) {
            root._streamOffset = 0;
            if (root.active)
                root.state = status === 0 ? "offline" : "idle";
            return;
        }
        typeTimer.running = true;
    }
}
