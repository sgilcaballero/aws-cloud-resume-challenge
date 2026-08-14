window.addEventListener('DOMContentLoaded', () => {
    getVisitCount();
});

const getVisitCount = () => {
    // Target the local proxy network mapping over secure developer ports
    fetch('https://api.local:8443/Prod/counter', {
        method: 'POST'
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP network error! Status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        console.log("Database count fetched successfully:", data);
        // Map the integer attribute to your placeholder text node
        document.getElementById('counter').innerText = data.count;
    })
    .catch(error => {
        console.error("Error communicating with serverless loop:", error);
        document.getElementById('counter').innerText = "⚠️ Error";
    });
}
