pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool ready: false
    property bool _fetching: false
    property string city: ""
    property string region: ""
    property string country: ""
    property real latitude: 0
    property real longitude: 0
    property string timezone: ""

    readonly property string summary: {
        if (!ready)
            return "";
        let s = city;
        if (region && region !== city)
            s += ", " + region;
        if (country)
            s += ", " + country;
        s += " (" + latitude.toFixed(3) + ", " + longitude.toFixed(3) + ")";
        if (timezone)
            s += ", timezone " + timezone;
        return s;
    }

    function warmup(): void {
        if (ready || _fetching)
            return;
        _fetching = true;
        const xhr = new XMLHttpRequest();
        xhr.open("GET", "https://get.geojs.io/v1/ip/geo.json");
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;
            root._fetching = false;
            if (xhr.status < 200 || xhr.status >= 300)
                return;
            let d;
            try {
                d = JSON.parse(xhr.responseText);
            } catch (e) {
                return;
            }
            root.city = d.city || "";
            root.region = d.region || "";
            root.country = d.country || d.country_name || "";
            root.latitude = parseFloat(d.latitude) || 0;
            root.longitude = parseFloat(d.longitude) || 0;
            root.timezone = d.timezone || "";
            root.ready = true;
        };
        xhr.send();
    }
}
