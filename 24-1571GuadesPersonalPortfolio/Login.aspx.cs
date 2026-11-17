using System;
using System.Data.SqlClient;
using System.Web;
using System.Web.Security;
using _24_1571GuadesPersonalPortfolio.Data;
using _24_1571GuadesPersonalPortfolio.Helpers;
using _24_1571GuadesPersonalPortfolio.Security;

namespace _24_1571GuadesPersonalPortfolio
{

    public partial class LoginPage : GuestPage
    {
        private const string HomePath = "~/Home.aspx";
        private const string ReturnUrlKey = "ReturnUrl";

        private const string ErrorStyle = "alert alert-error";
        private const string SuccessStyle = "alert alert-success";
        private const string InfoStyle = "alert alert-info";


        private const string InvalidCredentialsMessage = "That username, email or password isn't right. Check them and try again.";
        private const string InactiveMessage = "This account has been deactivated. Ask the site admin to turn it back on.";
        private const string DatabaseMessage = "We couldn't reach the database right now. Try again in a moment.";
        private const string SignedUpMessage = "Account created. Log in to continue.";
        private const string SignedOutMessage = "You were signed out because your account is no longer active.";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            ShowIncomingNotice();
            txtIdentifier.Focus();
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
            {
                return;
            }

            LoginResult result;

            try
            {

                result = UserRepository.Login(txtIdentifier.Text.Trim(), txtPassword.Text);
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, ErrorStyle);
                return;
            }

            switch (result.ResultCode)
            {
                case Constants.LoginCodes.Ok:
                    SignIn(result.UserId.Value, result.Username, result.Role);
                    break;

                case Constants.LoginCodes.Inactive:
                    ShowMessage(InactiveMessage, ErrorStyle);
                    txtIdentifier.Focus();
                    break;

                default:
                    ShowMessage(InvalidCredentialsMessage, ErrorStyle);
                    txtPassword.Focus();
                    break;
            }
        }

        private void SignIn(int userId, string username, string role)
        {
            DateTime issued = DateTime.Now;

            FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(
                1,                             
                username,
                issued,
                issued.Add(FormsAuthentication.Timeout),
                false,                                
                CurrentUser.BuildUserData(userId, role),
                FormsAuthentication.FormsCookiePath);

            HttpCookie cookie = new HttpCookie(
                FormsAuthentication.FormsCookieName,
                FormsAuthentication.Encrypt(ticket))
            {
                HttpOnly = true,
                Secure = FormsAuthentication.RequireSSL,
                Path = FormsAuthentication.FormsCookiePath
            };

            Response.Cookies.Add(cookie);
            Response.Redirect(GetSafeReturnUrl());
        }


        private string GetSafeReturnUrl()
        {
            string url = Request.QueryString[ReturnUrlKey];

            if (string.IsNullOrEmpty(url))
            {
                return HomePath;
            }

            bool isLocalPath = url.StartsWith("/", StringComparison.Ordinal)
                && !url.StartsWith("//", StringComparison.Ordinal)
                && !url.StartsWith("/\\", StringComparison.Ordinal);

            bool isLoginPage = url.IndexOf("Login.aspx", StringComparison.OrdinalIgnoreCase) >= 0;

            return isLocalPath && !isLoginPage ? url : HomePath;
        }

        private void ShowIncomingNotice()
        {
            switch (Request.QueryString[Constants.Notices.Key])
            {
                case Constants.Notices.SignedUp:
                    ShowMessage(SignedUpMessage, SuccessStyle);
                    break;

                case Constants.Notices.Deactivated:
                    ShowMessage(SignedOutMessage, InfoStyle);
                    break;
            }
        }

        private void ShowMessage(string text, string cssClass)
        {
            pnlMessage.CssClass = cssClass;
            litMessage.Text = text;
            pnlMessage.Visible = true;
        }
    }
}
