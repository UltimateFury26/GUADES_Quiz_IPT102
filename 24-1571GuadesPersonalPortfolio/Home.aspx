<%@ Page Title="Home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="_24_1571GuadesPersonalPortfolio.HomePage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <!-- PROFILE HEADER -->
        <section class="profile-header">
            <% if (AvatarUrl.Length > 0) { %>
            <img src="<%: AvatarUrl %>" alt="<%: FullName %>" class="profile-avatar" />
            <% } %>
            <h1 class="profile-name"><%: FullName %></h1>
            <% if (Tagline.Length > 0) { %>
            <p class="profile-tagline"><%: Tagline %></p>
            <% } %>
            <% if (Bio.Length > 0) { %>
            <p class="profile-bio"><%: Bio %></p>
            <% } %>
            <div class="profile-actions">
                <button type="button" class="pill-btn pill-btn-primary" data-modal="contactModal">
                    <svg class="icon" viewBox="0 0 24 24" style="width:16px;height:16px"><rect x="3" y="5" width="18" height="14" rx="2" /><circle cx="9" cy="12" r="2" /><path d="M14 10h5" /><path d="M14 14h5" /></svg>
                    Contact
                </button>
            </div>
        </section>

        <!-- LATEST ANNOUNCEMENT (hidden when nothing is published) -->
        <% if (LatestPost != null) { %>
        <section class="announcement-card" aria-label="Latest announcement">
            <p class="announcement-label">Latest announcement</p>
            <h2 class="announcement-title"><%: LatestPost.Title %></h2>
            <p class="announcement-date"><%: LatestPostDate %></p>
            <p class="announcement-body"><%: LatestPost.Body %></p>
        </section>
        <% } %>

        <!-- BOARDS -->
        <section id="boards">
            <div class="boards-heading-row">
                <h2 class="boards-heading">Boards</h2>
                <span class="boards-count" id="boardsCount"><%: BoardCount %> boards</span>
            </div>

            <div class="board-grid">

                <% if (Posts.Count > 0) { %>
                <button type="button" class="board-tile" data-board="announcements" data-title="Announcements">
                    <div class="board-cover cover-solid" style="background:#d51007">
                        <svg class="icon" viewBox="0 0 24 24"><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9" /><path d="M13.7 21a2 2 0 0 1-3.4 0" /></svg>
                    </div>
                    <div class="board-meta">
                        <p class="board-title">Announcements</p>
                        <p class="board-sub"><%: PinCountText(Posts.Count) %></p>
                    </div>
                </button>
                <% } %>

                <% if (Projects.Count > 0) { %>
                <button type="button" class="board-tile" data-board="projects" data-title="Recent Projects">
                    <div class="board-cover cover-solid" style="background:#23272f">
                        <svg class="icon" viewBox="0 0 24 24"><path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7z" /></svg>
                    </div>
                    <div class="board-meta">
                        <p class="board-title">Recent Projects</p>
                        <p class="board-sub"><%: PinCountText(Projects.Count) %></p>
                    </div>
                </button>
                <% } %>

                <% foreach (var board in SkillBoards) { %>
                <button type="button" class="board-tile" data-board="<%: board.Key %>" data-title="<%: board.Title %>">
                    <div class="board-cover cover-solid" style="background:<%: board.Color %>">
                        <svg class="icon" viewBox="0 0 24 24"><%= board.IconMarkup %></svg>
                    </div>
                    <div class="board-meta">
                        <p class="board-title"><%: board.Title %></p>
                        <p class="board-sub"><%: PinCountText(board.Skills.Count) %></p>
                    </div>
                </button>

                <% } %>
                <% if (Schools.Count > 0) { %>
                <button type="button" class="board-tile" data-board="education" data-title="Education">
                    <div class="board-cover cover-solid" style="background:#47543d">
                        <svg class="icon" viewBox="0 0 24 24"><path d="M2 9l10-5 10 5-10 5-10-5z" /><path d="M6 11v5c0 1.5 2.7 3 6 3s6-1.5 6-3v-5" /><path d="M22 9v6" /></svg>
                    </div>
                    <div class="board-meta">
                        <p class="board-title">Education</p>
                        <p class="board-sub"><%: PinCountText(Schools.Count) %></p>
                    </div>
                </button>
                <% } %>

                <% if (GalleryPhotos.Count > 0) { %>
                <button type="button" class="board-tile board-tile-wide" data-board="gallery" data-title="Gallery">
                    <div class="board-cover">
                        <div class="cover-quad<%: GalleryCoverClass %>">
                            <img class="cover-main" src="<%: GalleryPhotos[0].Url %>" alt="" />
                            <% if (GalleryPhotos.Count > 1) { %>
                            <div class="cover-stack">
                                <% for (int slot = 1; slot < GalleryPhotos.Count && slot <= 3; slot++) { %>
                                <img src="<%: GalleryPhotos[slot].Url %>" alt="" />
                                <% } %>
                            </div>
                            <% } %>
                        </div>
                    </div>
                    <div class="board-meta">
                        <p class="board-title">Gallery</p>
                        <p class="board-sub"><%: PinCountText(GalleryPhotos.Count) %></p>
                    </div>
                </button>
                <% } %>

                <% if (Hobbies.Count > 0) { %>
                <button type="button" class="board-tile board-tile-wide" data-board="interests" data-title="Interests">
                    <div class="board-cover">
                        <div class="cover-quad<%: InterestCoverClass %>">
                            <% if (InterestPreview.Count == 0) { %>
                            <div class="cover-solid" style="background:#3d4a63">
                                <svg class="icon" viewBox="0 0 24 24"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8l1 1.1L12 21l7.8-7.5 1-1.1a5.5 5.5 0 0 0 0-7.8z" /></svg>
                            </div>
                            <% } else { %>
                            <img class="cover-main" src="<%: InterestPreview[0] %>" alt="" />
                            <% if (InterestPreview.Count > 1) { %>
                            <div class="cover-stack">
                                <% for (int slot = 1; slot < InterestPreview.Count; slot++) { %>
                                <img src="<%: InterestPreview[slot] %>" alt="" />
                                <% } %>
                            </div>
                            <% } %>
                            <% } %>
                        </div>
                    </div>
                    <div class="board-meta">
                        <p class="board-title">Interests</p>
                        <p class="board-sub"><%: PinCountText(Hobbies.Count) %></p>
                    </div>
                </button>
                <% } %>

            </div>
        </section>

        <!-- ================= BOARD OVERLAYS ================= -->

        <!-- Announcements board (built from the database) -->
        <% if (Posts.Count > 0) { %>
        <div class="modal-overlay" id="announcementsBoard">
            <div class="modal-box board-box">
                <button type="button" class="modal-close" data-close>
                    <svg class="icon" viewBox="0 0 24 24"><path d="M6 6l12 12" /><path d="M18 6 6 18" /></svg>
                </button>
                <div class="board-overlay-header">
                    <button type="button" class="board-back" data-close>
                        <svg class="icon" viewBox="0 0 24 24"><path d="M15 5l-7 7 7 7" /></svg>
                    </button>
                    <div>
                        <h3 class="board-overlay-title">Announcements</h3>
                        <p class="board-overlay-sub"><%: PinCountText(Posts.Count) %></p>
                        <p class="board-overlay-desc">News and updates posted on this site.</p>
                    </div>
                </div>
                <div class="pin-grid">
                    <% for (int i = 0; i < Posts.Count; i++) { %>
                    <button type="button" class="pin-card" data-modal="<%: PostModalId(Posts[i].PostId) %>">
                        <div class="pin-cover" style="<%: PinStyle(i) %>">
                            <svg class="icon" viewBox="0 0 24 24"><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9" /><path d="M13.7 21a2 2 0 0 1-3.4 0" /></svg>
                        </div>
                        <p class="pin-label"><%: Posts[i].Title %></p>
                    </button>
                    <% } %>
                </div>
            </div>
        </div>
        <% } %>

        <!-- Projects board (built from the database) -->
        <% if (Projects.Count > 0) { %>
        <div class="modal-overlay" id="projectsBoard">
            <div class="modal-box board-box">
                <button type="button" class="modal-close" data-close>
                    <svg class="icon" viewBox="0 0 24 24"><path d="M6 6l12 12" /><path d="M18 6 6 18" /></svg>
                </button>
                <div class="board-overlay-header">
                    <button type="button" class="board-back" data-close>
                        <svg class="icon" viewBox="0 0 24 24"><path d="M15 5l-7 7 7 7" /></svg>
                    </button>
                    <div>
                        <h3 class="board-overlay-title">Recent Projects</h3>
                        <p class="board-overlay-sub"><%: PinCountText(Projects.Count) %></p>
                        <p class="board-overlay-desc">A running list of things I've built, from class exercises to bigger side projects.</p>
                    </div>
                </div>
                <div class="pin-grid">
                    <% for (int i = 0; i < Projects.Count; i++) { %>
                    <button type="button" class="pin-card" data-modal="<%: ProjectModalId(Projects[i].ProjectId) %>">
                        <div class="pin-cover" style="<%: PinStyle(i) %>">
                            <svg class="icon" viewBox="0 0 24 24"><path d="M9 18 3 12l6-6" /><path d="M15 6l6 6-6 6" /></svg>
                        </div>
                        <p class="pin-label"><%: Projects[i].Title %></p>
                    </button>
                    <% } %>
                </div>
            </div>
        </div>
        <% } %>

        <!-- Skill boards: Frontend, Backend, Tools (built from the database, by category) -->
        <% foreach (var board in SkillBoards) { %>
        <div class="modal-overlay" id="<%: board.OverlayId %>">
            <div class="modal-box board-box">
                <button type="button" class="modal-close" data-close>
                    <svg class="icon" viewBox="0 0 24 24"><path d="M6 6l12 12" /><path d="M18 6 6 18" /></svg>
                </button>
                <div class="board-overlay-header">
                    <button type="button" class="board-back" data-close>
                        <svg class="icon" viewBox="0 0 24 24"><path d="M15 5l-7 7 7 7" /></svg>
                    </button>
                    <div>
                        <h3 class="board-overlay-title"><%: board.Title %></h3>
                        <p class="board-overlay-sub"><%: PinCountText(board.Skills.Count) %></p>
                        <p class="board-overlay-desc"><%: board.Description %></p>
                    </div>
                </div>
                <div class="pin-grid">
                    <% for (int i = 0; i < board.Skills.Count; i++) { %>
                    <button type="button" class="pin-card" data-modal="<%: SkillModalId(board.Skills[i].SkillId) %>">
                        <div class="pin-cover" style="<%: PinStyle(i) %>">
                            <svg class="icon" viewBox="0 0 24 24"><%= board.IconMarkup %></svg>
                        </div>
                        <p class="pin-label"><%: board.Skills[i].Name %></p>
                    </button>
                    <% } %>
                </div>
            </div>
        </div>

        <% } %>
        <!-- Education board (built from the database) -->
        <% if (Schools.Count > 0) { %>
        <div class="modal-overlay" id="educationBoard">
            <div class="modal-box board-box">
                <button type="button" class="modal-close" data-close>
                    <svg class="icon" viewBox="0 0 24 24"><path d="M6 6l12 12" /><path d="M18 6 6 18" /></svg>
                </button>
                <div class="board-overlay-header">
                    <button type="button" class="board-back" data-close>
                        <svg class="icon" viewBox="0 0 24 24"><path d="M15 5l-7 7 7 7" /></svg>
                    </button>
                    <div>
                        <h3 class="board-overlay-title">Education</h3>
                        <p class="board-overlay-sub"><%: PinCountText(Schools.Count) %></p>
                        <p class="board-overlay-desc">Where I've studied and what I'm working toward.</p>
                    </div>
                </div>
                <div class="pin-grid">
                    <% for (int i = 0; i < Schools.Count; i++) { %>
                    <% string photo = PhotoUrl(Schools[i].PhotoPath); %>
                    <button type="button" class="pin-card" data-modal="<%: SchoolModalId(Schools[i].EducationId) %>">
                        <div class="pin-cover" style="<%: CoverStyle(photo, i) %>">
                            <% if (photo.Length > 0) { %>
                            <img src="<%: photo %>" alt="<%: SchoolLabel(Schools[i]) %>" />
                            <% } else { %>
                            <svg class="icon" viewBox="0 0 24 24"><path d="M2 9l10-5 10 5-10 5-10-5z" /><path d="M6 11v5c0 1.5 2.7 3 6 3s6-1.5 6-3v-5" /><path d="M22 9v6" /></svg>
                            <% } %>
                        </div>
                        <p class="pin-label"><%: SchoolLabel(Schools[i]) %></p>
                    </button>
                    <% } %>
                </div>
            </div>
        </div>
        <% } %>

        <!-- Gallery board (built from the database; opens the shared lightbox) -->
        <% if (GalleryPhotos.Count > 0) { %>
        <div class="modal-overlay" id="galleryBoard">
            <div class="modal-box board-box">
                <button type="button" class="modal-close" data-close>
                    <svg class="icon" viewBox="0 0 24 24"><path d="M6 6l12 12" /><path d="M18 6 6 18" /></svg>
                </button>
                <div class="board-overlay-header">
                    <button type="button" class="board-back" data-close>
                        <svg class="icon" viewBox="0 0 24 24"><path d="M15 5l-7 7 7 7" /></svg>
                    </button>
                    <div>
                        <h3 class="board-overlay-title">Gallery</h3>
                        <p class="board-overlay-sub"><%: PinCountText(GalleryPhotos.Count) %></p>
                        <p class="board-overlay-desc">A few photos worth sharing.</p>
                    </div>
                </div>
                <div class="pin-grid">
                    <% foreach (var photo in GalleryPhotos) { %>
                    <div class="pin-item">
                        <div class="pin-cover" style="cursor:pointer">
                            <img src="<%: photo.Url %>" alt="<%: photo.Alt %>" data-lightbox="<%: photo.Url %>" data-caption="<%: photo.Caption %>" />
                        </div>
                        <% if (photo.Caption.Length > 0) { %>
                        <p class="pin-label"><%: photo.Caption %></p>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
        <% } %>

        <!-- Interests board (masonry; built from the database). A hobby with a photo opens the lightbox,
             a hobby without one is a text card. -->
        <% if (Hobbies.Count > 0) { %>
        <div class="modal-overlay" id="interestsBoard">
            <div class="modal-box board-box">
                <button type="button" class="modal-close" data-close>
                    <svg class="icon" viewBox="0 0 24 24"><path d="M6 6l12 12" /><path d="M18 6 6 18" /></svg>
                </button>
                <div class="board-overlay-header">
                    <button type="button" class="board-back" data-close>
                        <svg class="icon" viewBox="0 0 24 24"><path d="M15 5l-7 7 7 7" /></svg>
                    </button>
                    <div>
                        <h3 class="board-overlay-title">Interests</h3>
                        <p class="board-overlay-sub"><%: PinCountText(Hobbies.Count) %></p>
                        <p class="board-overlay-desc">Things I like outside of code.</p>
                    </div>
                </div>
                <div class="masonry-grid">
                    <% foreach (var hobby in Hobbies) { %>
                    <% if (hobby.ImageUrl.Length > 0) { %>
                    <div class="masonry-item">
                        <img src="<%: hobby.ImageUrl %>" alt="<%: hobby.Title %>" data-lightbox="<%: hobby.ImageUrl %>" />
                        <div class="masonry-caption">
                            <strong><%: hobby.Title %></strong>
                            <% if (hobby.Description.Length > 0) { %>
                            <span><%: hobby.Description %></span>
                            <% } %>
                        </div>
                    </div>
                    <% } else { %>
                    <div class="masonry-item masonry-text" style="<%: hobby.CardStyle %>">
                        <p class="masonry-text-title"><%: hobby.Title %></p>
                        <% if (hobby.Description.Length > 0) { %>
                        <p class="masonry-text-desc"><%: hobby.Description %></p>
                        <% } %>
                    </div>
                    <% } %>
                    <% } %>
                </div>
            </div>
        </div>
        <% } %>

        <!-- ================= PIN DETAIL MODALS ================= -->

        <!-- Announcement detail modals (built from the database) -->
        <% foreach (_24_1571GuadesPersonalPortfolio.Data.Post post in Posts) { %>
        <div class="modal-overlay" id="<%: PostModalId(post.PostId) %>">
            <div class="modal-box">
                <button type="button" class="modal-close" data-close>
                    <svg class="icon" viewBox="0 0 24 24"><path d="M6 6l12 12" /><path d="M18 6 6 18" /></svg>
                </button>
                <h3><%: post.Title %></h3>
                <p class="announcement-date"><%: FormatDate(post.CreatedAt) %></p>
                <p class="announcement-body"><%: post.Body %></p>
            </div>
        </div>
        <% } %>

        <!-- Project detail modals (built from the database; empty optional fields are hidden) -->
        <% foreach (var project in Projects) { %>
        <div class="modal-overlay" id="<%: ProjectModalId(project.ProjectId) %>">
            <div class="modal-box">
                <button type="button" class="modal-close" data-close>
                    <svg class="icon" viewBox="0 0 24 24"><path d="M6 6l12 12" /><path d="M18 6 6 18" /></svg>
                </button>
                <h3><%: project.Title %></h3>
                <% if (!string.IsNullOrWhiteSpace(project.TechStack)) { %>
                <p><strong>Tech stack:</strong> <%: project.TechStack %></p>
                <% } %>
                <% if (!string.IsNullOrWhiteSpace(project.Role)) { %>
                <p><strong>My role:</strong> <%: project.Role %></p>
                <% } %>
                <% if (!string.IsNullOrWhiteSpace(project.Details)) { %>
                <p><strong>Details:</strong> <%: project.Details %></p>
                <% } %>
                <% if (RepoLink(project).Length > 0) { %>
                <a href="<%: RepoLink(project) %>" target="_blank" rel="noopener" class="modal-link">
                    <svg class="icon" viewBox="0 0 24 24"><path d="M14 4h6v6" /><path d="M20 4 10 14" /><path d="M18 13v5a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h5" /></svg>
                    View Repo
                </a>
                <% } %>
            </div>
        </div>
        <% } %>

        <!-- School detail modals (built from the database; empty optional fields are hidden) -->
        <% foreach (var school in Schools) { %>
        <div class="modal-overlay" id="<%: SchoolModalId(school.EducationId) %>">
            <div class="modal-box">
                <button type="button" class="modal-close" data-close>
                    <svg class="icon" viewBox="0 0 24 24"><path d="M6 6l12 12" /><path d="M18 6 6 18" /></svg>
                </button>
                <h3><%: school.SchoolName %></h3>
                <p><strong>Level:</strong> <%: school.Level %></p>
                <% if (!string.IsNullOrWhiteSpace(school.Program)) { %>
                <p><strong>Program:</strong> <%: school.Program %></p>
                <% } %>
                <% if (YearsText(school).Length > 0) { %>
                <p><strong>Years:</strong> <%: YearsText(school) %></p>
                <% } %>
                <% if (!string.IsNullOrWhiteSpace(school.Description)) { %>
                <p><%: school.Description %></p>
                <% } %>
            </div>
        </div>
        <% } %>

        <!-- Skill detail modals (built from the database) -->
        <% foreach (var board in SkillBoards) { %>
        <% foreach (var skill in board.Skills) { %>
        <div class="modal-overlay" id="<%: SkillModalId(skill.SkillId) %>">
            <div class="modal-box">
                <button type="button" class="modal-close" data-close>
                    <svg class="icon" viewBox="0 0 24 24"><path d="M6 6l12 12" /><path d="M18 6 6 18" /></svg>
                </button>
                <h3><%: skill.Name %></h3>
                <% if (!string.IsNullOrWhiteSpace(skill.Description)) { %>
                <p><%: skill.Description %></p>
                <% } %>
            </div>
        </div>
        <% } %>
        <% } %>

        <!-- LIGHTBOX (shared by the Gallery and Interests boards) -->
        <div class="modal-overlay" id="lightboxModal">
            <div class="modal-box lightbox-box">
                <button type="button" class="modal-close" data-close>
                    <svg class="icon" viewBox="0 0 24 24"><path d="M6 6l12 12" /><path d="M18 6 6 18" /></svg>
                </button>
                <img id="lightboxImage" src="" alt="Gallery preview" />
                <p id="lightboxCaption" class="lightbox-caption" style="display:none"></p>
            </div>
        </div>
</asp:Content>
