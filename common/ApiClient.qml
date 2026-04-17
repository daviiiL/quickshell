import QtQuick

QtObject {
    id: root

    property string baseUrl: "https://www.example.com"
    property var defaultHeaders: ({
            "Accept": "*/*"
        })

    function _applyHeaders(xhr, headers) {
        for (const k in defaultHeaders)
            xhr.setRequestHeader(k, defaultHeaders[k]);
        if (headers) {
            for (const h in headers)
                xhr.setRequestHeader(h, headers[h]);
        }
    }

    function get(path, onSuccess, onError, headers) {
        const xhr = new XMLHttpRequest();
        xhr.open("GET", new URL(path, baseUrl).toString());
        root._applyHeaders(xhr, headers);

        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;
            if (xhr.status >= 200 && xhr.status < 300) {
                let data = xhr.responseText;
                try {
                    data = JSON.parse(xhr.responseText);
                } catch (e) {
                }
                if (onSuccess)
                    onSuccess(data, xhr);
            } else if (onError) {
                onError(xhr.status, xhr.responseText, xhr);
            }
        };

        xhr.send();
    }
}
