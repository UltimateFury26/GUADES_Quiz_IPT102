using System;
using System.Data.SqlClient;
using _24_1571GuadesPersonalPortfolio.Data;
using _24_1571GuadesPersonalPortfolio.Helpers;

namespace _24_1571GuadesPersonalPortfolio
{
    /// <summary>
    /// Manage Content tab for the owner's profile: name, tagline, bio, contact details, links and photo.
    /// There is exactly one profile row, so this is a single edit form with no list.
    /// </summary>
    public partial class PersonalInfoEditor : ContentEditorBase
    {
        private const int BioMaxLength = 2000;

        private const string BioTooLongMessage = "The bio is longer than 2000 characters. Shorten it and try again.";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            LoadForm();

            if (WasJustSaved)
            {
                ShowMessage(SavedMessage, true);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
            {
                return;
            }

            string gitHub = NullIfBlank(txtGitHub.Text);
            string linkedIn = NullIfBlank(txtLinkedIn.Text);

            // The validators check the shape; this makes sure a link really is a usable http(s) address.
            if (gitHub != null && UrlHelper.SafeHttpUrl(gitHub).Length == 0)
            {
                revGitHub.IsValid = false;
                return;
            }

            if (linkedIn != null && UrlHelper.SafeHttpUrl(linkedIn).Length == 0)
            {
                revLinkedIn.IsValid = false;
                return;
            }

            if (txtBio.Text.Length > BioMaxLength)
            {
                ShowMessage(BioTooLongMessage, false);
                return;
            }

            string oldAvatarPath;

            try
            {
                PersonalInfo current = ContentRepository.GetPersonalInfo();
                oldAvatarPath = current == null ? null : current.AvatarPath;
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                return;
            }

            string newAvatarPath = null;

            if (fuAvatar.HasFile)
            {
                UploadResult upload = FileUploader.SaveImage(fuAvatar.PostedFile);

                if (!upload.Success)
                {
                    ShowMessage(upload.Error, false);
                    return;
                }

                newAvatarPath = upload.RelativePath;
            }

            try
            {
                ContentRepository.UpdatePersonalInfo(new PersonalInfo
                {
                    FullName = txtFullName.Text.Trim(),
                    Tagline = NullIfBlank(txtTagline.Text),
                    Bio = NullIfBlank(txtBio.Text),
                    Email = NullIfBlank(txtEmail.Text),
                    Phone = NullIfBlank(txtPhone.Text),
                    Address = NullIfBlank(txtAddress.Text),
                    GitHubUrl = gitHub,
                    LinkedInUrl = linkedIn,
                    AvatarPath = newAvatarPath
                });
            }
            catch (SqlException)
            {
                FileUploader.DeleteIfUploaded(newAvatarPath);
                ShowMessage(DatabaseMessage, false);
                return;
            }

            if (newAvatarPath != null)
            {
                FileUploader.DeleteIfUploaded(oldAvatarPath);
            }

            RedirectAfterSave(Constants.ContentTabs.Personal);
        }

        private void LoadForm()
        {
            PersonalInfo info;

            try
            {
                info = ContentRepository.GetPersonalInfo();
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                return;
            }

            if (info == null)
            {
                return;
            }

            txtFullName.Text = info.FullName;
            txtTagline.Text = info.Tagline;
            txtBio.Text = info.Bio;
            txtEmail.Text = info.Email;
            txtPhone.Text = info.Phone;
            txtAddress.Text = info.Address;
            txtGitHub.Text = info.GitHubUrl;
            txtLinkedIn.Text = info.LinkedInUrl;

            string avatarUrl = ImageHelper.ResolveExisting(info.AvatarPath);
            imgAvatar.Visible = avatarUrl.Length > 0;
            pnlNoAvatar.Visible = avatarUrl.Length == 0;
            imgAvatar.ImageUrl = avatarUrl;
        }

        private void ShowMessage(string text, bool success)
        {
            pnlMessage.CssClass = success ? SuccessStyle : ErrorStyle;
            litMessage.Text = text;
            pnlMessage.Visible = true;
        }
    }
}
