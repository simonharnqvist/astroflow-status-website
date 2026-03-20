const icons = {
  checking: `
    <svg class="icon" fill="none" stroke="#3498db" viewBox="0 0 24 24">
      <circle cx="12" cy="12" r="10"></circle>
      <path d="M12 6v6l4 2"></path>
    </svg>
  `,
  online: `
    <svg class="icon" fill="none" stroke="#2ecc71" viewBox="0 0 24 24">
      <path d="M20 6L9 17l-5-5"></path>
    </svg>
  `,
  error: `
    <svg class="icon" fill="none" stroke="#f39c12" viewBox="0 0 24 24">
      <circle cx="12" cy="12" r="10"></circle>
      <line x1="12" y1="8" x2="12" y2="12"></line>
      <line x1="12" y1="16" x2="12" y2="16"></line>
    </svg>
  `,
  offline: `
    <svg class="icon" fill="none" stroke="#e74c3c" viewBox="0 0 24 24">
      <line x1="18" y1="6" x2="6" y2="18"></line>
      <line x1="6" y1="6" x2="18" y2="18"></line>
    </svg>
  `
};

async function checkStatus(url) {
  const container = document.getElementById("status");

  // Create row
  const row = document.createElement("div");
  row.className = "status-item";

  const urlEl = document.createElement("div");
  urlEl.className = "url";
  urlEl.innerHTML = icons.checking + url;

  const badge = document.createElement("div");
  badge.className = "badge checking";
  badge.textContent = "Checking…";

  row.appendChild(urlEl);
  row.appendChild(badge);
  container.appendChild(row);

  try {
    const r = await fetch(url);

    if (r.ok) {
      urlEl.innerHTML = icons.online + url;
      badge.className = "badge online";
      badge.textContent = "Online";
      row.classList.add("border-online");
    } else {
      urlEl.innerHTML = icons.error + url;
      badge.className = "badge error";
      badge.textContent = "Error " + r.status;
      row.classList.add("border-error");
    }
  } catch {
    urlEl.innerHTML = icons.offline + url;
    badge.className = "badge offline";
    badge.textContent = "Offline";
    row.classList.add("border-offline");
  }
}
async function init() {
  const config = await loadConfig();
  config.urls.forEach(checkStatus);
}

async function loadConfig() {
  const res = await fetch('/config/status-config.json', { cache: 'no-store' });
  return res.json();
}

init();