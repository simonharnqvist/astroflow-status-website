const icons = {
  checking: `
    <svg class="icon spin" fill="none" stroke="#95a5a6" viewBox="0 0 24 24">
      <circle cx="12" cy="12" r="10" stroke-width="3" opacity="0.3"></circle>
      <path d="M12 2 a10 10 0 0 1 10 10" stroke-width="3"></path>
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


async function loadStatuses() {
  const container = document.getElementById("status");
  container.innerHTML = "";

  // 1. Load URLs from backend-served config
  let urls;
  try {
    const cfgRes = await fetch("/config/urls.json");
    const cfg = await cfgRes.json();
    urls = cfg.urls;
  } catch (err) {
    console.error("Failed to load config.json:", err);
    container.textContent = "Failed to load config.";
    return;
  }

  const rows = {};

  // 2. Render "Checking…" immediately
  urls.forEach(url => {
    const row = document.createElement("div");
    row.className = "status-item border-checking";

    const urlEl = document.createElement("div");
    urlEl.className = "url";
    urlEl.innerHTML = icons.checking + url;

    const badge = document.createElement("div");
    badge.className = "badge checking";
    badge.textContent = "Checking…";

    row.appendChild(urlEl);
    row.appendChild(badge);
    container.appendChild(row);

    rows[url] = { row, urlEl, badge };
  });

  // 3. Fetch backend results
  let results;
  try {
    const res = await fetch("/status");
    const data = await res.json();
    results = data.results;
  } catch (err) {
    console.error("Failed to fetch status:", err);
    return;
  }

  // 4. Update rows with real statuses
  results.forEach(item => {
    const entry = rows[item.url];
    if (!entry) return;

    const { row, urlEl, badge } = entry;

    if (item.status === "online") {
      urlEl.innerHTML = icons.online + item.url;
      badge.textContent = "Online";
      badge.className = "badge online";
      row.className = "status-item border-online";

    } else if (item.status === "error") {
      urlEl.innerHTML = icons.error + item.url;
      badge.textContent = `Error ${item.code}`;
      badge.className = "badge error";
      row.className = "status-item border-error";

    } else {
      urlEl.innerHTML = icons.offline + item.url;
      badge.textContent = "Offline";
      badge.className = "badge offline";
      row.className = "status-item border-offline";
    }
  });
}

loadStatuses();
