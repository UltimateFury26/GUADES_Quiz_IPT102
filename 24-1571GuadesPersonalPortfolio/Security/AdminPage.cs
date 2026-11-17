using System;
using _24_1571GuadesPersonalPortfolio.Helpers;

namespace _24_1571GuadesPersonalPortfolio.Security
{
    /// <summary>
    /// Base class for every page in the Admin folder. Runs the BasePage checks first,
    /// then sends anyone who is not an Admin back to Home with the "no access" notice.
    /// This is the second layer behind the Admin/Web.config rule.
    /// </summary>
    public class AdminPage : BasePage
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            if (!CurrentUser.IsAdmin)
            {
                Response.Redirect(
                    "~/Home.aspx?" + Constants.Notices.Key + "=" + Constants.Notices.NoAccess);
            }
        }
    }
}