using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using _24_1571GuadesPersonalPortfolio.Data;
using _24_1571GuadesPersonalPortfolio.Helpers;
using _24_1571GuadesPersonalPortfolio.Security;

namespace _24_1571GuadesPersonalPortfolio
{
    /// <summary>
    /// The personal website. Inherits BasePage, so every request confirms the
    /// account is still Active. The profile header, the latest announcement, the Announcements
    /// board, the Recent Projects board, the three skill boards, the Education board, the Gallery board and the Interests
    /// board all come from the database.
    /// </summary>
    public partial class HomePage : BasePage
    {
        /// <summary>
        /// One hobby as the page draws it. With a photo it is a picture pin that opens the lightbox;
        /// without one (or when the file is missing) it is a coloured text card, so no hobby disappears.
        /// </summary>
        protected sealed class HobbyView
        {
            public string Title;
            public string Description;   // empty when there is none
            public string ImageUrl;      // empty when there is no photo on disk
            public string CardStyle;     // background colour for the text card; empty when there is a photo
        }

        /// <summary>A gallery photo that exists on disk, ready for the markup.</summary>
        protected sealed class GalleryPhoto
        {
            public string Url;   // browser URL of the image
            public string Alt;   // the caption when there is one, otherwise "Gallery photo N"
            public string Caption; // the caption shown under the photo; empty when there is none
        }

        // Pin cover colours, rotated in order (same palette as the original boards).
        private static readonly string[] PinColors =
            { "#2f5d62", "#3d4a63", "#5c4a3d", "#47543d", "#614a2e" };

        /// <summary>
        /// One skill board as the page draws it. The look (title, blurb, colour, icon) is fixed
        /// presentation; which skills appear on it comes from the database, by Category.
        /// </summary>
        protected sealed class SkillBoardView
        {
            public string Category;      // matches Skills.Category
            public string Key;           // "frontend" -> data-board="frontend", overlay id "frontendBoard"
            public string Title;
            public string Description;
            public string Color;
            public string IconMarkup;    // inner SVG shapes; fixed strings written in this file, never user input
            public List<Skill> Skills = new List<Skill>();

            public string OverlayId { get { return Key + "Board"; } }
        }

        // Values read by the markup. Each is set in LoadProfile, so none can be null.
        protected string FullName = string.Empty;
        protected string Tagline = string.Empty;
        protected string Bio = string.Empty;
        protected string AvatarUrl = string.Empty;

        /// <summary>Every published announcement, newest first. Empty when there are none.</summary>
        protected List<Post> Posts = new List<Post>();

        /// <summary>The newest published announcement, or null when there is none (the card is then hidden).</summary>
        protected Post LatestPost;

        /// <summary>The latest announcement's date as text, e.g. "September 24, 2026".</summary>
        protected string LatestPostDate = string.Empty;

        /// <summary>Every project in display order. Empty when there are none.</summary>
        protected List<Project> Projects = new List<Project>();

        /// <summary>Every school in display order. Empty when there are none.</summary>
        protected List<EducationEntry> Schools = new List<EducationEntry>();

        /// <summary>
        /// Gallery photos in display order. Only photos whose file exists are listed, so a missing
        /// file never shows a broken picture. Empty when there are none (the board is then hidden).
        /// </summary>
        protected List<GalleryPhoto> GalleryPhotos = new List<GalleryPhoto>();

        /// <summary>Every hobby in display order. Empty when there are none (the board is then hidden).</summary>
        protected List<HobbyView> Hobbies = new List<HobbyView>();

        /// <summary>Up to four hobby photos that exist on disk, used for the Interests tile's preview.</summary>
        protected List<string> InterestPreview = new List<string>();

        /// <summary>The skill boards that have at least one skill, in display order.</summary>
        protected List<SkillBoardView> SkillBoards = new List<SkillBoardView>();

        protected void Page_Load(object sender, EventArgs e)
        {
            LoadProfile();
            LoadAnnouncements();
            Projects = ContentRepository.GetProjects();
            LoadSkillBoards();
            Schools = ContentRepository.GetEducation();
            LoadGallery();
            LoadHobbies();
            RecordVisit();
        }

        /// <summary>
        /// Counts one portfolio view for the Reports page's user-visit statistics. Only regular
        /// Users are counted, so the Admin looking at their own site is never included: the stored
        /// procedure itself enforces this, and the role check here just avoids a needless call.
        /// A failure here (e.g. the database is briefly unreachable) must never break the page,
        /// so it is swallowed rather than shown to the visitor.
        /// </summary>
        private void RecordVisit()
        {
            if (IsPostBack || CurrentUser.IsAdmin)
            {
                return;
            }

            try
            {
                ReportRepository.RecordVisit(CurrentUser.Id);
            }
            catch (SqlException)
            {
                // Statistics are non-essential; the page still renders normally.
            }
        }

        /// <summary>
        /// Reads the owner's profile through usp_PersonalInfo_Get. Empty values stay empty,
        /// and the markup hides any part of the header that has nothing to show.
        /// </summary>
        private void LoadProfile()
        {
            PersonalInfo info = ContentRepository.GetPersonalInfo();
            if (info == null)
            {
                return;
            }

            FullName = info.FullName;
            Tagline = info.Tagline ?? string.Empty;
            Bio = info.Bio ?? string.Empty;

            // Empty when there is no avatar or the file is missing; the markup then hides the picture.
            AvatarUrl = ImageHelper.ResolveExisting(info.AvatarPath);
        }

        /// <summary>
        /// Reads the published announcements through usp_Post_GetPublished. They arrive newest
        /// first, so the first one is the latest. Drafts are excluded by the procedure.
        /// </summary>
        private void LoadAnnouncements()
        {
            Posts = PostRepository.GetPublished();
            if (Posts.Count == 0)
            {
                return;
            }

            LatestPost = Posts[0];
            LatestPostDate = FormatDate(LatestPost.CreatedAt);
        }

        /// <summary>
        /// Reads every skill through usp_Skill_GetAll and sorts them onto the Frontend, Backend and
        /// Tools boards by Category. A board with no skills is left out, so it never shows empty.
        /// </summary>
        private void LoadSkillBoards()
        {
            List<Skill> skills = ContentRepository.GetSkills();

            foreach (SkillBoardView board in CreateSkillBoards())
            {
                board.Skills = skills.Where(skill => skill.Category == board.Category).ToList();

                if (board.Skills.Count > 0)
                {
                    SkillBoards.Add(board);
                }
            }
        }

        /// <summary>
        /// Reads the gallery through usp_Gallery_GetAll and keeps the photos that exist on disk.
        /// </summary>
        private void LoadGallery()
        {
            List<GalleryEntry> entries = ContentRepository.GetGallery();

            for (int i = 0; i < entries.Count; i++)
            {
                string url = ImageHelper.ResolveExisting(entries[i].ImagePath);
                if (url.Length == 0)
                {
                    continue;
                }

                string caption = entries[i].Caption;
                GalleryPhotos.Add(new GalleryPhoto
                {
                    Url = url,
                    Alt = string.IsNullOrWhiteSpace(caption) ? "Gallery photo " + (i + 1) : caption,
                    Caption = string.IsNullOrWhiteSpace(caption) ? string.Empty : caption.Trim()
                });
            }
        }

        /// <summary>
        /// Reads the hobbies through usp_Hobby_GetAll. A hobby whose photo is missing keeps its place
        /// as a text card; only hobbies with a real photo feed the tile's preview.
        /// </summary>
        private void LoadHobbies()
        {
            List<HobbyEntry> entries = ContentRepository.GetHobbies();

            for (int i = 0; i < entries.Count; i++)
            {
                string imageUrl = ImageHelper.ResolveExisting(entries[i].ImagePath);

                Hobbies.Add(new HobbyView
                {
                    Title = entries[i].Title,
                    Description = entries[i].Description ?? string.Empty,
                    ImageUrl = imageUrl,
                    CardStyle = imageUrl.Length > 0 ? string.Empty : PinStyle(i)
                });

                if (imageUrl.Length > 0 && InterestPreview.Count < 4)
                {
                    InterestPreview.Add(imageUrl);
                }
            }
        }

        /// <summary>The fixed look of the three skill boards, one per category.</summary>
        private static List<SkillBoardView> CreateSkillBoards()
        {
            return new List<SkillBoardView>
            {
                new SkillBoardView
                {
                    Category = Constants.SkillCategories.Frontend,
                    Key = "frontend",
                    Title = "Frontend",
                    Description = "Client-side languages and tools I use to build interfaces.",
                    Color = "#2f5d62",
                    IconMarkup = "<rect x=\"3\" y=\"4\" width=\"18\" height=\"16\" rx=\"2\" /><path d=\"M3 9h18\" />"
                },
                new SkillBoardView
                {
                    Category = Constants.SkillCategories.Backend,
                    Key = "backend",
                    Title = "Backend",
                    Description = "Server-side languages and data tools I work with.",
                    Color = "#3d4a63",
                    IconMarkup = "<rect x=\"3\" y=\"4\" width=\"18\" height=\"6\" rx=\"1.5\" /><rect x=\"3\" y=\"14\" width=\"18\" height=\"6\" rx=\"1.5\" /><path d=\"M7 7h.01\" /><path d=\"M7 17h.01\" />"
                },
                new SkillBoardView
                {
                    Category = Constants.SkillCategories.Tools,
                    Key = "tools",
                    Title = "Tools & Platforms",
                    Description = "Software and platforms I use day-to-day for development.",
                    Color = "#5c4a3d",
                    IconMarkup = "<path d=\"M14.7 6.3a4 4 0 0 0-5.4 5.4L3 18l3 3 6.3-6.3a4 4 0 0 0 5.4-5.4l-2.8 2.8-2-2z\" />"
                }
            };
        }

        /// <summary>Total boards shown on Home, used by the "N boards" label.</summary>
        protected int BoardCount
        {
            get
            {
                return (Posts.Count > 0 ? 1 : 0)
                    + (Projects.Count > 0 ? 1 : 0)
                    + SkillBoards.Count
                    + (Schools.Count > 0 ? 1 : 0)
                    + (GalleryPhotos.Count > 0 ? 1 : 0)
                    + (Hobbies.Count > 0 ? 1 : 0);
            }
        }

        /// <summary>
        /// Inline style for the pin at this position: its cover colour, taken from the palette
        /// (which repeats when it runs out). Returned whole so the markup holds one value.
        /// </summary>
        protected static string PinStyle(int index)
        {
            return "background:" + PinColors[index % PinColors.Length];
        }

        /// <summary>
        /// Extra CSS class for the Gallery tile's photo cover, chosen by how many photos there are:
        /// one photo fills the cover, two share it equally, three or more use the large-plus-stack layout.
        /// </summary>
        protected string GalleryCoverClass
        {
            get
            {
                if (GalleryPhotos.Count == 1)
                {
                    return " cover-single";
                }

                return GalleryPhotos.Count == 2 ? " cover-duo" : string.Empty;
            }
        }

        /// <summary>Extra CSS class for the Interests tile's preview: one photo (or the icon cover) fills it, two share it.</summary>
        protected string InterestCoverClass
        {
            get { return InterestPreview.Count == 2 ? " cover-duo" : (InterestPreview.Count > 2 ? string.Empty : " cover-single"); }
        }

        /// <summary>The element id used by a school's detail modal, e.g. "schoolModal1".</summary>
        protected static string SchoolModalId(int educationId)
        {
            return "schoolModal" + educationId;
        }

        /// <summary>
        /// The years spent at a school: "2022 – 2024", "2024 – Present" when still studying, or
        /// "Until 2024" when only the end is known. Empty when neither year is known, so the page hides the line.
        /// </summary>
        protected static string YearsText(EducationEntry school)
        {
            if (!school.StartYear.HasValue && !school.EndYear.HasValue)
            {
                return string.Empty;
            }

            if (!school.StartYear.HasValue)
            {
                return "Until " + school.EndYear.Value.ToString(CultureInfo.InvariantCulture);
            }

            string end = school.EndYear.HasValue
                ? school.EndYear.Value.ToString(CultureInfo.InvariantCulture)
                : "Present";

            return school.StartYear.Value.ToString(CultureInfo.InvariantCulture) + " \u2013 " + end;
        }

        /// <summary>
        /// Pin caption for a school. One school can have several entries (Elementary, Junior High,
        /// Senior High), so the level comes first, e.g. "Senior High School · Dr. Carlos S. Lanting College".
        /// </summary>
        protected static string SchoolLabel(EducationEntry school)
        {
            return school.Level + " \u00B7 " + school.SchoolName;
        }

        /// <summary>A stored image path as a URL, or an empty string when there is no such file (shows the icon cover instead).</summary>
        protected static string PhotoUrl(string path)
        {
            return ImageHelper.ResolveExisting(path);
        }

        /// <summary>
        /// Style for a pin cover: a coloured background when there is no photo, nothing when the
        /// photo fills the cover.
        /// </summary>
        protected static string CoverStyle(string photoUrl, int index)
        {
            return photoUrl.Length > 0 ? string.Empty : PinStyle(index);
        }

        /// <summary>The element id used by a skill's detail modal, e.g. "skillModal4".</summary>
        protected static string SkillModalId(int skillId)
        {
            return "skillModal" + skillId;
        }

        /// <summary>The element id used by a project's detail modal, e.g. "projectModal2".</summary>
        protected static string ProjectModalId(int projectId)
        {
            return "projectModal" + projectId;
        }

        /// <summary>A project's repository link if it is a safe http/https address, otherwise an empty string.</summary>
        protected static string RepoLink(Project project)
        {
            return UrlHelper.SafeHttpUrl(project.RepoUrl);
        }

        /// <summary>The element id used by an announcement's detail modal, e.g. "postModal3".</summary>
        protected static string PostModalId(int postId)
        {
            return "postModal" + postId;
        }

        /// <summary>"1 pin" or "N pins".</summary>
        protected static string PinCountText(int count)
        {
            return count == 1 ? "1 pin" : count + " pins";
        }

        /// <summary>A date as text, e.g. "September 24, 2026".</summary>
        protected static string FormatDate(DateTime date)
        {
            return date.ToString("MMMM d, yyyy", CultureInfo.InvariantCulture);
        }
    }
}