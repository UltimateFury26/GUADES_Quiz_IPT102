using System;
using System.Web.UI;

namespace _24_1571GuadesPersonalPortfolio
{
    /// <summary>
    /// Layout for the public pages (Login, Signup, Error): a centered card on a plain background.
    /// </summary>
    public partial class AuthMaster : MasterPage
    {
        private const string SiteName = "Portfolio";

        protected void Page_Load(object sender, EventArgs e)
        {
            string pageTitle = Page.Title;
            Page.Title = string.IsNullOrWhiteSpace(pageTitle) ? SiteName : pageTitle + " | " + SiteName;
        }
    }
}