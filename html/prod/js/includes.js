// Client-side HTML includes + nav highlight + smart env links
(async () => {
  // ---- 1) Client-side includes (header/footer, etc.) ----
  const nodes = Array.from(document.querySelectorAll("[data-include]"));
  const hasIncludes = nodes.length > 0;

  const isLocalLike = location.hostname === "localhost" || location.hostname.endsWith(".local");
  const bust = isLocalLike ? ("?_cb=" + Date.now()) : "";

  // Detect environment early
  const host = location.hostname;
  const isDevHost = /mitchellnet\.dev\.local$/i.test(host) || host === "localhost";

  if (hasIncludes) {
    for (const el of nodes) {
      const url = el.getAttribute("data-include") + bust;
      try {
        const res = await fetch(url, { credentials: "same-origin" });
        if (!res.ok) throw new Error(`${res.status} ${res.statusText} for ${url}`);
        const html = await res.text();
        const tmp = document.createElement("div");
        tmp.innerHTML = html;
        const frag = document.createDocumentFragment();
        while (tmp.firstChild) frag.appendChild(tmp.firstChild);
        el.replaceWith(frag);
      } catch (e) {
        console.error("Include failed:", e);
        el.outerHTML = `<div class="include-error" role="alert">Failed to load ${url}</div>`;
      }
    }
  }

  // ---- 2) Environment detection and banner update (AFTER includes loaded) ----
  
  // Update environment banner if present
  const envBanner = document.getElementById('env-banner');
  if (envBanner) {
    if (isDevHost) {
      envBanner.className = 'env-test';
      envBanner.textContent = '⚠️ DEVELOPMENT ENVIRONMENT';
    } else {
      envBanner.className = 'env-prod';
      envBanner.textContent = '';
    }
  }

  // Update DEV badge in header if present (NOW the header is loaded)
  const devBadge = document.getElementById('dev-badge');
  if (devBadge && isDevHost) {
    devBadge.style.display = 'inline';
  }

  // ---- 3) Highlight current nav link (after includes are in DOM) ----
  try {
    const here = new URL(location.href);
    const sel = `header nav a[href="${here.pathname.replace(/\/+$/, "/")}"], header nav a[href="${here.pathname}"]`;
    const active = document.querySelector(sel) || document.querySelector(`header nav a[href="/"]`);
    if (active) active.classList.add("is-active");
  } catch {}

  // ---- 4) Smart environment link rewriter (dev vs server) ----
  // Detect if we’re on the local dev hostnames (*.dev.mitchellnet.local)
  
  const urls = isDevHost
    ? {
        prod: "https://mitchellnet.dev.local",
      }
    : {
        prod: "https://mitchellnet.local",
      };

  // Rewrite anchors that are clearly "Go to Production" / "Go to Test"
  // Priority: data attribute > text heuristic
  document.querySelectorAll('a.button, a[data-env-link]').forEach((a) => {
    const attr = (a.getAttribute("data-env-link") || "").toLowerCase();
    const text = (a.textContent || "").toLowerCase();

    if (attr === "prod" || /prod/.test(text)) {
      a.href = urls.prod;
    } else if (attr === "test" || /test/.test(text)) {
      a.href = urls.test;
    }
  });

  // Optional: expose for quick debugging
  window.__mitchellEnv = { host, isDevHost, urls };
})();
