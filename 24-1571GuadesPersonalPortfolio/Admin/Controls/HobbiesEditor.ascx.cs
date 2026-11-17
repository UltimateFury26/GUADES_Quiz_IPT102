using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.UI.WebControls;
using _24_1571GuadesPersonalPortfolio.Data;
using _24_1571GuadesPersonalPortfolio.Helpers;

namespace _24_1571GuadesPersonalPortfolio
{
    /// <summary>
    /// Manage Content tab for Hobbies &amp; Interest: a list plus one add/edit form with an optional photo.
    /// Follows the same pattern as the Education tab. A hobby without a photo still shows on Home,
    /// as a text card on the Interests board.
    /// </summary>
    public partial class HobbiesEditor : ContentEditorBase
    {
        private const string CommandEdit = "edit";
        private const string CommandDelete = "delete";

        private const int DescriptionMaxLength = 500;
        private const int ListPreviewLength = 80;

        private const string GoneMessage = "That hobby no longer exists. The list has been refreshed.";
        private const string DescriptionTooLongMessage = "The description is longer than 500 characters. Shorten it and try again.";
        private const string AddTitle = "Add a hobby";
        private const string EditTitle = "Edit hobby";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            BindList();

            if (WasJustSaved)
            {
                ShowMessage(SavedMessage, true);
            }
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            HideMessage();
            ClearForm();
            litFormTitle.Text = AddTitle;
            pnlForm.Visible = true;
            btnAdd.Visible = false;
            pnlList.Visible = false;
            pnlEmpty.Visible = false;
            txtTitle.Focus();
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            HideMessage();
            pnlForm.Visible = false;
            btnAdd.Visible = true;
            BindList();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
            {
                return;
            }

            if (txtDescription.Text.Length > DescriptionMaxLength)
            {
                ShowMessage(DescriptionTooLongMessage, false);
                return;
            }

            int hobbyId;
            int.TryParse(hfHobbyId.Value, out hobbyId);
            bool isEdit = hobbyId > 0;

            string oldImagePath = null;
            string newImagePath = null;

            if (fuPhoto.HasFile)
            {
                if (isEdit)
                {
                    try
                    {
                        HobbyEntry existing = ContentRepository.GetHobbyById(hobbyId);
                        oldImagePath = existing == null ? null : existing.ImagePath;
                    }
                    catch (SqlException)
                    {
                        ShowMessage(DatabaseMessage, false);
                        return;
                    }
                }

                UploadResult upload = FileUploader.SaveImage(fuPhoto.PostedFile);

                if (!upload.Success)
                {
                    ShowMessage(upload.Error, false);
                    return;
                }

                newImagePath = upload.RelativePath;
            }

            HobbyEntry entry = new HobbyEntry
            {
                HobbyId = hobbyId,
                Title = txtTitle.Text.Trim(),
                Description = NullIfBlank(txtDescription.Text),
                ImagePath = newImagePath
            };

            int? sortOrder = ParseNumber(txtSortOrder.Text);
            int affected = 1;

            try
            {
                if (isEdit)
                {
                    affected = ContentRepository.UpdateHobby(entry, sortOrder);
                }
                else
                {
                    ContentRepository.InsertHobby(entry, sortOrder);
                }
            }
            catch (SqlException)
            {
                FileUploader.DeleteIfUploaded(newImagePath);
                ShowMessage(DatabaseMessage, false);
                return;
            }

            if (affected == 0)
            {
                FileUploader.DeleteIfUploaded(newImagePath);
                pnlForm.Visible = false;
                btnAdd.Visible = true;
                BindList();
                ShowMessage(GoneMessage, false);
                return;
            }

            if (newImagePath != null)
            {
                FileUploader.DeleteIfUploaded(oldImagePath);
            }

            RedirectAfterSave(Constants.ContentTabs.Hobbies);
        }

        /// <summary>Sets what each row's buttons do and asks for confirmation before a delete.</summary>
        protected void rptHobbies_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            HobbyEntry entry = e.Item.DataItem as HobbyEntry;
            Button btnEdit = e.Item.FindControl("btnEdit") as Button;
            Button btnDelete = e.Item.FindControl("btnDelete") as Button;

            if (entry == null || btnEdit == null || btnDelete == null)
            {
                return;
            }

            string id = entry.HobbyId.ToString(CultureInfo.InvariantCulture);

            btnEdit.CommandName = CommandEdit;
            btnEdit.CommandArgument = id;

            btnDelete.CommandName = CommandDelete;
            btnDelete.CommandArgument = id;
            btnDelete.OnClientClick = "return confirm("
                + HttpUtility.JavaScriptStringEncode("Delete " + entry.Title + "? This can't be undone.", true)
                + ");";
        }

        protected void rptHobbies_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int hobbyId;

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out hobbyId))
            {
                return;
            }

            if (e.CommandName == CommandEdit)
            {
                LoadForEdit(hobbyId);
            }
            else if (e.CommandName == CommandDelete)
            {
                DeleteHobby(hobbyId);
            }
        }

        // ---- markup helpers ----

        /// <summary>A small photo for the list, or an empty grey square when there is no photo on disk.</summary>
        protected string ThumbHtml(object imagePath)
        {
            string url = ImageHelper.ResolveExisting(Convert.ToString(imagePath));

            return url.Length == 0
                ? "<span class=\"thumb thumb-empty\"></span>"
                : "<img class=\"thumb\" src=\"" + HttpUtility.HtmlAttributeEncode(url) + "\" alt=\"\" />";
        }

        /// <summary>The start of the description for the list, or a dash when there is none.</summary>
        protected string Preview(object description)
        {
            string text = Convert.ToString(description);

            if (string.IsNullOrWhiteSpace(text))
            {
                return "\u2014";
            }

            text = text.Trim();
            return text.Length <= ListPreviewLength ? text : text.Substring(0, ListPreviewLength).TrimEnd() + "\u2026";
        }

        // ---- private helpers ----

        private void BindList()
        {
            List<HobbyEntry> hobbies;

            try
            {
                hobbies = ContentRepository.GetHobbies();
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                pnlList.Visible = false;
                pnlEmpty.Visible = false;
                return;
            }

            rptHobbies.DataSource = hobbies;
            rptHobbies.DataBind();

            pnlList.Visible = hobbies.Count > 0;
            pnlEmpty.Visible = hobbies.Count == 0;
        }

        private void LoadForEdit(int hobbyId)
        {
            HideMessage();

            HobbyEntry entry;

            try
            {
                entry = ContentRepository.GetHobbyById(hobbyId);
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                return;
            }

            if (entry == null)
            {
                pnlForm.Visible = false;
                btnAdd.Visible = true;
                BindList();
                ShowMessage(GoneMessage, false);
                return;
            }

            ClearForm();

            hfHobbyId.Value = entry.HobbyId.ToString(CultureInfo.InvariantCulture);
            litFormTitle.Text = EditTitle;
            txtTitle.Text = entry.Title;
            txtDescription.Text = entry.Description;
            txtSortOrder.Text = entry.SortOrder.ToString(CultureInfo.InvariantCulture);

            string photoUrl = ImageHelper.ResolveExisting(entry.ImagePath);
            pnlCurrentPhoto.Visible = photoUrl.Length > 0;
            imgPhoto.ImageUrl = photoUrl;

            pnlForm.Visible = true;
            btnAdd.Visible = false;
            pnlList.Visible = false;
            pnlEmpty.Visible = false;
            txtTitle.Focus();
        }

        private void DeleteHobby(int hobbyId)
        {
            HideMessage();

            try
            {
                HobbyEntry entry = ContentRepository.GetHobbyById(hobbyId);

                if (entry == null)
                {
                    BindList();
                    ShowMessage(GoneMessage, false);
                    return;
                }

                if (ContentRepository.DeleteHobby(hobbyId) > 0)
                {
                    FileUploader.DeleteIfUploaded(entry.ImagePath);
                }
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                return;
            }

            RedirectAfterSave(Constants.ContentTabs.Hobbies);
        }

        private void ClearForm()
        {
            hfHobbyId.Value = "0";
            txtTitle.Text = string.Empty;
            txtDescription.Text = string.Empty;
            txtSortOrder.Text = string.Empty;
            pnlCurrentPhoto.Visible = false;
        }

        /// <summary>Reads a whole number from text; blank or non-numeric text gives null (the validator reports the latter).</summary>
        private static int? ParseNumber(string text)
        {
            int value;
            return int.TryParse((text ?? string.Empty).Trim(), NumberStyles.None, CultureInfo.InvariantCulture, out value)
                ? (int?)value
                : null;
        }

        private void ShowMessage(string text, bool success)
        {
            pnlMessage.CssClass = success ? SuccessStyle : ErrorStyle;
            litMessage.Text = text;
            pnlMessage.Visible = true;
        }

        private void HideMessage()
        {
            pnlMessage.Visible = false;
        }
    }
}
