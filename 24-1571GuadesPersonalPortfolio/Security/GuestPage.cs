using System;
using System.Web.UI;
using _24_1571GuadesPersonalPortfolio.Helpers;

namespace _24_1571GuadesPersonalPortfolio.Security
{
    /// <summary>
    /// Base class for the public pages that only make sense for someone who is NOT logged in
    /// (Login and Signup). A person who already has a valid ticket is sent straight to Home.
    /// Error.aspx does not inherit this, because it must stay reachable for everyone.
    ///
    /// It also handles one special case. When a logged-in non-Admin opens an /Admin URL,
    /// the Admin/Web.config rule refuses them and ASP.NET forwards them to Login.aspx with
    /// a ReturnUrl. Since they are already logged in, they go to Home with the "no access" notice.
    /// </summary>
    public class GuestPage : Page
    {
        private const string HomePath = "~/Home.aspx";
        private const string ReturnUrlKey = "ReturnUrl";
        private const string AdminFolder = "Admin";

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            if (!CurrentUser.IsAuthenticated)
            {
                return;
            }

            if (IsAdminUrl(Request.QueryString[ReturnUrlKey]))
            {
                Response.Redirect(
                    HomePath + "?" + Constants.Notices.Key + "=" + Constants.Notices.NoAccess);
                return;
            }

            Response.Redirect(HomePath);
        }

        /// <summary>
        /// True when the address points at a page inside the Admin folder, for example
        /// "/Admin/ManageUsers.aspx". Only the path is looked at, and the file name itself
        /// is skipped, so a page that merely has "Admin" in its name does not count.
        /// </summary>
        private static bool IsAdminUrl(string url)
        {
            if (string.IsNullOrEmpty(url))
            {
                return false;
            }

            int queryStart = url.IndexOf('?');
            string path = queryStart >= 0 ? url.Substring(0, queryStart) : url;
            string[] segments = path.Split('/');

            // The last segment is the file name, so only the folders before it are checked.
            for (int i = 0; i < segments.Length - 1; i++)
            {
                if (string.Equals(segments[i], AdminFolder, StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }
            }

            return false;
        }
    }
}