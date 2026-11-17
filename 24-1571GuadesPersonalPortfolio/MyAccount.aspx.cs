using System;
using System.Data.SqlClient;
using _24_1571GuadesPersonalPortfolio.Data;
using _24_1571GuadesPersonalPortfolio.Helpers;
using _24_1571GuadesPersonalPortfolio.Security;

namespace _24_1571GuadesPersonalPortfolio
{
    /// <summary>
    /// Self-service account page. A logged-in user (or Admin) can see their own
    /// username, update their own email and phone, and change their own password.
    /// Nothing here ever touches another account, and nothing here is website content.
    /// Inherits BasePage, so every request re-confirms the account is still Active.
    /// </summary>
    public partial class MyAccountPage : BasePage
    {
        private const string ErrorStyle = "alert alert-error";
        private const string SuccessStyle = "alert alert-success";

        private const string InvalidAccountInputMessage = "Something in the form isn't valid. Check each field and try again.";
        private const string InvalidPasswordInputMessage = "That new password doesn't meet the requirements.";
        private const string AccountUpdatedMessage = "Your account details were updated.";
        private const string PasswordChangedMessage = "Your password was changed.";
        private const string DatabaseMessage = "We couldn't reach the database right now. Try again in a moment.";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAccount();
            }
        }

        private void LoadAccount()
        {
            UserAccount account = UserRepository.GetById(CurrentUser.Id);

            if (account == null)
            {
                SignOutWithNotice(Constants.Notices.Deactivated);
                return;
            }

            litUsername.Text = account.Username;
            txtEmail.Text = account.Email;
            txtPhone.Text = account.Phone;
        }

        protected void btnSaveAccount_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
            {
                return;
            }

            int resultCode;

            try
            {
                resultCode = UserRepository.UpdateAccount(
                    CurrentUser.Id,
                    txtEmail.Text.Trim(),
                    txtPhone.Text.Trim());
            }
            catch (SqlException)
            {
                ShowAccountMessage(DatabaseMessage, false);
                return;
            }

            switch (resultCode)
            {
                case Constants.AccountUpdateCodes.Ok:
                    ShowAccountMessage(AccountUpdatedMessage, true);
                    break;

                case Constants.AccountUpdateCodes.EmailTaken:
                    cvEmailTaken.IsValid = false;
                    txtEmail.Focus();
                    break;

                case Constants.AccountUpdateCodes.UserNotFound:
                    SignOutWithNotice(Constants.Notices.Deactivated);
                    break;

                default:
                    ShowAccountMessage(InvalidAccountInputMessage, false);
                    break;
            }
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
            {
                return;
            }

            int resultCode;

            try
            {
                resultCode = UserRepository.ChangePassword(
                    CurrentUser.Id,
                    txtCurrentPassword.Text,
                    txtNewPassword.Text);
            }
            catch (SqlException)
            {
                ShowPasswordMessage(DatabaseMessage, false);
                return;
            }

            switch (resultCode)
            {
                case Constants.ChangePasswordCodes.Ok:
                    txtCurrentPassword.Text = string.Empty;
                    txtNewPassword.Text = string.Empty;
                    txtConfirmNewPassword.Text = string.Empty;
                    ShowPasswordMessage(PasswordChangedMessage, true);
                    break;

                case Constants.ChangePasswordCodes.WrongCurrentPassword:
                    cvWrongCurrentPassword.IsValid = false;
                    txtCurrentPassword.Focus();
                    break;

                case Constants.ChangePasswordCodes.UserNotFound:
                    SignOutWithNotice(Constants.Notices.Deactivated);
                    break;

                case Constants.ChangePasswordCodes.WeakNewPassword:
                    ShowPasswordMessage(InvalidPasswordInputMessage, false);
                    break;

                default:
                    ShowPasswordMessage(InvalidPasswordInputMessage, false);
                    break;
            }
        }

        private void ShowAccountMessage(string text, bool success)
        {
            pnlAccountMessage.CssClass = success ? SuccessStyle : ErrorStyle;
            litAccountMessage.Text = text;
            pnlAccountMessage.Visible = true;
        }

        private void ShowPasswordMessage(string text, bool success)
        {
            pnlPasswordMessage.CssClass = success ? SuccessStyle : ErrorStyle;
            litPasswordMessage.Text = text;
            pnlPasswordMessage.Visible = true;
        }
    }
}
