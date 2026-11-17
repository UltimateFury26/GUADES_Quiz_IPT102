document.addEventListener("DOMContentLoaded", function () {

    // ---- Mobile icon-rail toggle ----
    var railToggle = document.getElementById("railToggle");
    var iconRail = document.getElementById("iconRail");
    var railClose = document.getElementById("railClose");
    var railBackdrop = document.getElementById("railBackdrop");

    function openRail() {
        if (!iconRail) { return; }
        iconRail.classList.add("open");
        if (railBackdrop) { railBackdrop.classList.add("open"); }
    }

    function closeRail() {
        if (!iconRail) { return; }
        iconRail.classList.remove("open");
        if (railBackdrop) { railBackdrop.classList.remove("open"); }
    }

    if (railToggle && iconRail) {
        railToggle.addEventListener("click", function () {
            if (iconRail.classList.contains("open")) {
                closeRail();
            } else {
                openRail();
            }
        });
    }

    if (railClose) {
        railClose.addEventListener("click", closeRail);
    }

    if (railBackdrop) {
        railBackdrop.addEventListener("click", closeRail);
    }

    // A tap on any rail link/button closes the rail too, so it doesn't stay open after navigating.
    if (iconRail) {
        iconRail.querySelectorAll("a, button").forEach(function (control) {
            if (control === railClose) { return; }
            control.addEventListener("click", closeRail);
        });
    }

    document.addEventListener("keydown", function (e) {
        if (e.key === "Escape" && iconRail && iconRail.classList.contains("open")) {
            closeRail();
        }
    });

    // ---- Generic overlay open/close (used for board overlays, pin modals, lightbox) ----
    function openOverlay(overlay) {
        if (!overlay) { return; }
        overlay.classList.add("open");
        document.body.style.overflow = "hidden";
    }

    function closeOverlay(overlay) {
        if (!overlay) { return; }
        overlay.classList.remove("open");
        document.body.style.overflow = "";
    }

    document.querySelectorAll("[data-modal]").forEach(function (trigger) {
        trigger.addEventListener("click", function () {
            openOverlay(document.getElementById(trigger.getAttribute("data-modal")));
        });
    });

    document.querySelectorAll("[data-board]").forEach(function (trigger) {
        trigger.addEventListener("click", function () {
            openOverlay(document.getElementById(trigger.getAttribute("data-board") + "Board"));
        });
    });

    document.querySelectorAll("[data-close]").forEach(function (btn) {
        btn.addEventListener("click", function () {
            closeOverlay(btn.closest(".modal-overlay"));
        });
    });

    document.querySelectorAll(".modal-overlay").forEach(function (overlay) {
        overlay.addEventListener("click", function (e) {
            if (e.target === overlay) {
                closeOverlay(overlay);
            }
        });
    });

    document.addEventListener("keydown", function (e) {
        if (e.key === "Escape") {
            document.querySelectorAll(".modal-overlay.open").forEach(closeOverlay);
        }
    });

    // ---- Lightbox (used inside the Gallery and Interests board overlays) ----
    var lightboxModal = document.getElementById("lightboxModal");
    var lightboxImage = document.getElementById("lightboxImage");
    var lightboxCaption = document.getElementById("lightboxCaption");

    document.querySelectorAll("[data-lightbox]").forEach(function (img) {
        img.addEventListener("click", function () {
            lightboxImage.src = img.getAttribute("data-lightbox");

            // Show the photo's caption under it when it has one (only Gallery photos carry data-caption).
            if (lightboxCaption) {
                var caption = img.getAttribute("data-caption") || "";
                lightboxCaption.textContent = caption;
                lightboxCaption.style.display = caption ? "" : "none";
            }

            openOverlay(lightboxModal);
        });
    });

    // ---- Board search: filters the board grid by title as you type ----
    var boardSearch = document.getElementById("boardSearch");
    var boardTiles = document.querySelectorAll(".board-tile");
    var boardsCount = document.getElementById("boardsCount");
    var totalBoards = boardTiles.length;

    if (boardSearch) {
        boardSearch.addEventListener("input", function () {
            var query = boardSearch.value.trim().toLowerCase();
            var visible = 0;

            boardTiles.forEach(function (tile) {
                var title = tile.getAttribute("data-title").toLowerCase();
                var match = title.indexOf(query) !== -1;
                tile.style.display = match ? "" : "none";
                if (match) { visible++; }
            });

            if (boardsCount) {
                boardsCount.textContent = query
                    ? visible + " of " + totalBoards + " boards"
                    : totalBoards + " boards";
            }
        });
    }

    // ---- Account menu: close when clicking elsewhere or pressing Esc ----
    var accountMenu = document.getElementById("accountMenu");

    if (accountMenu) {
        document.addEventListener("click", function (e) {
            if (!accountMenu.contains(e.target)) {
                accountMenu.removeAttribute("open");
            }
        });

        document.addEventListener("keydown", function (e) {
            if (e.key === "Escape") {
                accountMenu.removeAttribute("open");
            }
        });
    }


    // ---- Auto-dismiss save/update success banners after 5 seconds ----
    document.querySelectorAll(".alert-success").forEach(function (box) {
        window.setTimeout(function () {
            box.classList.add("alert-dismissing");
            window.setTimeout(function () {
                box.style.display = "none";
            }, 350);
        }, 5000);
    });

    // ---- Password show/hide ("eye") toggle, used on every password field ----
    document.querySelectorAll(".password-toggle").forEach(function (btn) {
        var field = btn.closest(".password-field");
        var input = field ? field.querySelector("input") : null;

        if (!input) { return; }

        var eyeIcon = btn.querySelector(".icon-eye");
        var eyeOffIcon = btn.querySelector(".icon-eye-off");

        btn.addEventListener("click", function () {
            var isHidden = input.type === "password";
            input.type = isHidden ? "text" : "password";
            btn.setAttribute("aria-label", isHidden ? "Hide password" : "Show password");

            if (eyeIcon) { eyeIcon.style.display = isHidden ? "none" : ""; }
            if (eyeOffIcon) { eyeOffIcon.style.display = isHidden ? "" : "none"; }
        });
    });

    // ---- Password strength meter (shown only under a "new password" field) ----
    function passwordStrengthScore(value) {
        var score = 0;
        if (value.length >= 8) { score++; }
        if (value.length >= 12) { score++; }
        if (/[a-z]/.test(value) && /[A-Z]/.test(value)) { score++; }
        if (/[0-9]/.test(value)) { score++; }
        if (/[^A-Za-z0-9]/.test(value)) { score++; }
        return Math.min(score, 4);
    }

    var strengthLabels = ["Very weak", "Weak", "Fair", "Good", "Strong"];

    document.querySelectorAll("[data-strength-for]").forEach(function (meter) {
        var input = document.getElementById(meter.getAttribute("data-strength-for"));
        var fill = meter.querySelector("[data-strength-fill]");
        var label = meter.querySelector("[data-strength-label]");

        if (!input || !fill || !label) { return; }

        function update() {
            var value = input.value;

            if (!value) {
                fill.className = "pwd-strength-fill";
                fill.style.width = "0%";
                label.textContent = "";
                return;
            }

            var score = passwordStrengthScore(value);
            fill.className = "pwd-strength-fill pwd-strength-" + score;
            fill.style.width = ((score + 1) / 5 * 100) + "%";
            label.textContent = strengthLabels[score];
        }

        input.addEventListener("input", update);
        update();
    });

    // ---- Manage Users: automatic (as-you-type) search and status filter ----
    // Every user is already rendered in the table; this only shows or hides rows,
    // so there is no round trip to the server while searching.
    var userSearchInput = document.getElementById("userSearchInput");
    var userStatusFilter = document.getElementById("userStatusFilter");
    var usersPanel = document.getElementById("pnlResults");
    var userNoMatches = document.getElementById("userNoMatches");
    var userCount = document.getElementById("litCount");

    if (usersPanel && (userSearchInput || userStatusFilter)) {
        var userRows = usersPanel.querySelectorAll("tbody tr");
        var totalUserCount = userRows.length;

        var filterUsers = function () {
            var query = userSearchInput ? userSearchInput.value.trim().toLowerCase() : "";
            var status = userStatusFilter ? userStatusFilter.value : "";
            var visible = 0;

            userRows.forEach(function (row) {
                var haystack = [
                    row.getAttribute("data-username"),
                    row.getAttribute("data-email"),
                    row.getAttribute("data-phone")
                ].join(" ").toLowerCase();

                var matchesQuery = query.length === 0 || haystack.indexOf(query) !== -1;
                var matchesStatus = status.length === 0 || row.getAttribute("data-status") === status;
                var match = matchesQuery && matchesStatus;

                row.style.display = match ? "" : "none";
                if (match) { visible++; }
            });

            if (userCount) {
                var noun = totalUserCount === 1 ? "1 user" : totalUserCount + " users";
                userCount.textContent = (query || status) ? visible + " of " + noun : noun;
            }

            if (userNoMatches) {
                userNoMatches.style.display = visible === 0 && totalUserCount > 0 ? "" : "none";
            }
        };

        if (userSearchInput) { userSearchInput.addEventListener("input", filterUsers); }
        if (userStatusFilter) { userStatusFilter.addEventListener("change", filterUsers); }
    }
});