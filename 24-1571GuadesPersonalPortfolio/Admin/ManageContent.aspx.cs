using System;
using System.Collections.Generic;
using _24_1571GuadesPersonalPortfolio.Helpers;
using _24_1571GuadesPersonalPortfolio.Security;

namespace _24_1571GuadesPersonalPortfolio
{
    /// <summary>One tab on the Manage Content page: its key in the address, its label and the editor control it shows.</summary>
    public sealed class ContentTab
    {
        public string Key { get; private set; }
        public string Title { get; private set; }
        public string ControlPath { get; private set; }

        public ContentTab(string key, string title, string controlPath)
        {
            Key = key;
            Title = title;
            ControlPath = controlPath;
        }
    }

    /// <summary>
    /// Admin page that hosts one editor per website-content section. The tab in the address
    /// (?tab=personal) decides which editor control is loaded; each editor is its own user control
    /// in Admin/Controls, so this page stays small. To add a section, add one line to Tabs.
    /// Inherits AdminPage, so non-Admins are turned away before anything loads.
    /// </summary>
    public partial class ManageContentPage : AdminPage
    {
        private const string ControlFolder = "~/Admin/Controls/";
        private const string PagePath = "~/Admin/ManageContent.aspx";

        private static readonly ContentTab[] Tabs =
        {
            new ContentTab(Constants.ContentTabs.Personal, "Personal Info", ControlFolder + "PersonalInfoEditor.ascx"),
            new ContentTab(Constants.ContentTabs.Education, "Education", ControlFolder + "EducationEditor.ascx"),
            new ContentTab(Constants.ContentTabs.Skills, "Skills", ControlFolder + "SkillsEditor.ascx"),
            new ContentTab(Constants.ContentTabs.Hobbies, "Hobbies", ControlFolder + "HobbiesEditor.ascx"),
            new ContentTab(Constants.ContentTabs.Projects, "Projects", ControlFolder + "ProjectsEditor.ascx"),
            new ContentTab(Constants.ContentTabs.Gallery, "Gallery", ControlFolder + "GalleryEditor.ascx")
        };

        private ContentTab activeTab;

        /// <summary>Every tab, in display order (read by the markup).</summary>
        protected IEnumerable<ContentTab> AllTabs
        {
            get { return Tabs; }
        }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            // Dynamically added controls must exist on every request, postbacks included,
            // so their events and view state line up.
            activeTab = FindTab(Request.QueryString[Constants.ContentQuery.Tab]);
            phEditor.Controls.Add(LoadControl(activeTab.ControlPath));
        }

        protected string TabActiveClass(ContentTab tab)
        {
            return tab.Key == activeTab.Key ? " active" : string.Empty;
        }

        protected string TabUrl(ContentTab tab)
        {
            return ResolveUrl(PagePath) + "?" + Constants.ContentQuery.Tab + "=" + Server.UrlEncode(tab.Key);
        }

        /// <summary>Finds the tab for a key; an unknown or missing key shows the first tab.</summary>
        private static ContentTab FindTab(string key)
        {
            foreach (ContentTab tab in Tabs)
            {
                if (string.Equals(tab.Key, key, StringComparison.OrdinalIgnoreCase))
                {
                    return tab;
                }
            }

            return Tabs[0];
        }
    }
}
