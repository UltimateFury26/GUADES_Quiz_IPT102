using System;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using _24_1571GuadesPersonalPortfolio.Data;
using _24_1571GuadesPersonalPortfolio.Helpers;

namespace _24_1571GuadesPersonalPortfolio.Security
{
    /// <summary>
    /// Base class for every page that needs a logged-in user (Home, MyAccount and,
    /// through AdminPage, all Admin pages). On each request it confirms the account
    /// still exists and is Active, and signs the user out if it does not.
    /// Login, Signup and Error do NOT inherit this, because they are public.
    /// </summary>
    public class BasePage : Page
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            if (!CurrentUser.IsAuthenticated)
            {
                // Web.config already redirects anonymous users; this is a safety net.
                FormsAuthentication.RedirectToLoginPage();
                return;
            }

            UserAccount account = UserRepository.GetById(CurrentUser.Id);

            if (account == null || account.Status != Constants.Status.Active)
            {
                SignOutWithNotice(Constants.Notices.Deactivated);
            }
        }

        /// <summary>
        /// Ends the session and sends the person to Login with a one-time notice.
        /// </summary>
        protected void SignOutWithNotice(string notice)
        {
            FormsAuthentication.SignOut();
            Session.Abandon();
            Response.Redirect(
                "~/Login.aspx?" + Constants.Notices.Key + "=" + Server.UrlEncode(notice));
        }
    }
}