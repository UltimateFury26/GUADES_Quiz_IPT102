using System;
using System.Text.RegularExpressions;
using System.Web.Security;
using System.Web.UI;
using _24_1571GuadesPersonalPortfolio.Data;
using _24_1571GuadesPersonalPortfolio.Helpers;
using _24_1571GuadesPersonalPortfolio.Security;

namespace _24_1571GuadesPersonalPortfolio
{
    /// <summary>
    /// Layout for every logged-in page: icon rail, top bar with the account menu, footer and Contact modal.
    /// The owner's details come from the database, never from the markup.
    /// </summary>
    public partial class SiteMaster : MasterPage
    {
        private const string HomePath = "~/Home.aspx";

        // Values read by the markup. Every one is set in LoadOwner, so none can be null.
        protected string OwnerName = "Portfolio";
        protected string Initials = "P";
        protected string Email = string.Empty;
        protected string PhoneDisplay = string.Empty;
        protected string Address = string.Empty;
        protected string GitHubUrl = string.Empty;
        protected string LinkedInUrl = string.Empty;

        protected string AccountName { get { return CurrentUser.Username; } }
        protected string AccountRole { get { return CurrentUser.Role; } }
        protected bool IsAdmin { get { return CurrentUser.IsAdmin; } }

        /// <summary>First letter of the logged-in username, for the avatar circle.</summary>
        protected string AccountInitial
        {
            get
            {
                string name = CurrentUser.Username;
                return string.IsNullOrEmpty(name) ? "?" : name.Substring(0, 1).ToUpperInvariant();
            }
        }

        /// <summary>The board search box only makes sense on Home.</summary>
        protected bool ShowSearch
        {
            get { return IsCurrentPage(HomePath); }
        }

        /// <summary>One-time notice passed in the query string, such as "no access".</summary>
        protected string NoticeText
        {
            get
            {
                return Request.QueryString[Constants.Notices.Key] == Constants.Notices.NoAccess
                    ? "You don't have access to that page."
                    : string.Empty;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            LoadOwner();

            string pageTitle = Page.Title;
            Page.Title = string.IsNullOrWhiteSpace(pageTitle)
                ? OwnerName + " | IT Portfolio"
                : pageTitle + " | " + OwnerName;
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            Session.Abandon();
            Response.Redirect("~/Login.aspx");
        }

        /// <summary>Returns " active" when the given app-relative path is the page being shown.</summary>
        protected string ActiveClass(string appRelativePath)
        {
            return IsCurrentPage(appRelativePath) ? " active" : string.Empty;
        }

        private bool IsCurrentPage(string appRelativePath)
        {
            return string.Equals(
                Request.AppRelativeCurrentExecutionFilePath,
                appRelativePath,
                StringComparison.OrdinalIgnoreCase);
        }

        private void LoadOwner()
        {
            PersonalInfo info = ContentRepository.GetPersonalInfo();
            if (info == null)
            {
                return;
            }

            OwnerName = info.FullName;
            Initials = GetInitials(info.FullName);
            Email = info.Email ?? string.Empty;
            PhoneDisplay = FormatPhone(info.Phone);
            Address = info.Address ?? string.Empty;
            GitHubUrl = UrlHelper.SafeHttpUrl(info.GitHubUrl);
            LinkedInUrl = UrlHelper.SafeHttpUrl(info.LinkedInUrl);
        }

        /// <summary>First letter of the first and last words, e.g. "Mark Rafael L. Guades" gives "MG".</summary>
        private static string GetInitials(string name)
        {
            string[] words = (name ?? string.Empty).Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);

            if (words.Length == 0)
            {
                return "P";
            }

            string first = words[0].Substring(0, 1);
            string last = words.Length > 1 ? words[words.Length - 1].Substring(0, 1) : string.Empty;
            return (first + last).ToUpperInvariant();
        }

        /// <summary>Shows an 11-digit number as 0924 016 9431. Anything else is shown as stored.</summary>
        private static string FormatPhone(string phone)
        {
            if (string.IsNullOrWhiteSpace(phone))
            {
                return string.Empty;
            }

            if (Regex.IsMatch(phone, @"^\d{11}$"))
            {
                return phone.Substring(0, 4) + " " + phone.Substring(4, 3) + " " + phone.Substring(7);
            }

            return phone;
        }
    }
}