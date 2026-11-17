using System;
using System.Data.SqlClient;
using _24_1571GuadesPersonalPortfolio.Data;
using _24_1571GuadesPersonalPortfolio.Helpers;
using _24_1571GuadesPersonalPortfolio.Security;

namespace _24_1571GuadesPersonalPortfolio
{
    /// <summary>
    /// Public signup page. Creates a User account through usp_User_Register. The validators on the
    /// page mirror the database rules, and the stored procedure re-checks all of them, so a request
    /// that skips the browser is still rejected. It is public, so it inherits GuestPage (which sends
    /// anyone already logged in to Home), not BasePage.
    /// </summary>
    public partial class SignupPage : GuestPage
    {
        private const string LoginPath = "~/Login.aspx";
        private const string ErrorStyle = "alert alert-error";

        private const string InvalidInputMessage = "Something in the form isn't valid. Check each field and try again.";
        private const string DatabaseMessage = "We couldn't reach the database right now. Try again in a moment.";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtUsername.Focus();
            }
        }

        protected void btnSignup_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
            {
                return;
            }

            RegisterResult result;

            try
            {
                // Text fields are trimmed; the password is sent exactly as typed.
                result = UserRepository.Register(
                    txtUsername.Text.Trim(),
                    txtEmail.Text.Trim(),
                    txtPhone.Text.Trim(),
                    txtPassword.Text);
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage);
                return;
            }

            switch (result.ResultCode)
            {
                case Constants.RegisterCodes.Ok:
                    // Login.aspx shows the "Account created" notice.
                    Response.Redirect(LoginPath + "?" + Constants.Notices.Key + "=" + Constants.Notices.SignedUp);
                    break;

                case Constants.RegisterCodes.UsernameTaken:
                    cvUsernameTaken.IsValid = false;
                    txtUsername.Focus();
                    break;

                case Constants.RegisterCodes.EmailTaken:
                    cvEmailTaken.IsValid = false;
                    txtEmail.Focus();
                    break;

                default:
                    ShowMessage(InvalidInputMessage);
                    break;
            }
        }

        private void ShowMessage(string text)
        {
            pnlMessage.CssClass = ErrorStyle;
            litMessage.Text = text;
            pnlMessage.Visible = true;
        }
    }
}
