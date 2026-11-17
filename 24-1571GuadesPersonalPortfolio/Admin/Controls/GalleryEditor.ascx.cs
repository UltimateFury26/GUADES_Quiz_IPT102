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
    /// Manage Content tab for the Gallery: a list plus one add/edit form. A photo is required when adding
    /// and optional when editing (leaving it empty keeps the current one). The caption is optional.
    /// Replaced or deleted uploaded files are removed from disk; the seeded _Media photos are never deleted.
    /// </summary>
    public partial class GalleryEditor : ContentEditorBase
    {
        private const string CommandEdit = "edit";
        private const string CommandDelete = "delete";

        private const string GoneMessage = "That photo no longer exists. The list has been refreshed.";
        private const string PhotoRequiredMessage = "Choose a photo to add.";
        private const string AddTitle = "Add a photo";
        private const string EditTitle = "Edit photo";
        private const string AddPhotoHint = "JPG, PNG or GIF, up to 5 MB.";
        private const string EditPhotoHint = "JPG, PNG or GIF, up to 5 MB. Leave empty to keep the current photo.";

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
            litPhotoHint.Text = AddPhotoHint;
            pnlForm.Visible = true;
            btnAdd.Visible = false;
            pnlList.Visible = false;
            pnlEmpty.Visible = false;
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

            int galleryId;
            int.TryParse(hfGalleryId.Value, out galleryId);
            bool isEdit = galleryId > 0;

            if (!isEdit && !fuPhoto.HasFile)
            {
                ShowMessage(PhotoRequiredMessage, false);
                return;
            }

            string oldImagePath = null;
            string newImagePath = null;

            if (fuPhoto.HasFile)
            {
                if (isEdit)
                {
                    try
                    {
                        GalleryEntry existing = ContentRepository.GetGalleryById(galleryId);
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

            GalleryEntry entry = new GalleryEntry
            {
                GalleryId = galleryId,
                ImagePath = newImagePath,
                Caption = NullIfBlank(txtCaption.Text)
            };

            int? sortOrder = ParseNumber(txtSortOrder.Text);
            int affected = 1;

            try
            {
                if (isEdit)
                {
                    affected = ContentRepository.UpdateGalleryItem(entry, sortOrder);
                }
                else
                {
                    ContentRepository.InsertGalleryItem(entry, sortOrder);
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

            RedirectAfterSave(Constants.ContentTabs.Gallery);
        }

        /// <summary>Sets what each row's buttons do and asks for confirmation before a delete.</summary>
        protected void rptGallery_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            GalleryEntry entry = e.Item.DataItem as GalleryEntry;
            Button btnEdit = e.Item.FindControl("btnEdit") as Button;
            Button btnDelete = e.Item.FindControl("btnDelete") as Button;

            if (entry == null || btnEdit == null || btnDelete == null)
            {
                return;
            }

            string id = entry.GalleryId.ToString(CultureInfo.InvariantCulture);

            btnEdit.CommandName = CommandEdit;
            btnEdit.CommandArgument = id;

            btnDelete.CommandName = CommandDelete;
            btnDelete.CommandArgument = id;
            btnDelete.OnClientClick = "return confirm("
                + HttpUtility.JavaScriptStringEncode("Delete this photo? This can't be undone.", true)
                + ");";
        }

        protected void rptGallery_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int galleryId;

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out galleryId))
            {
                return;
            }

            if (e.CommandName == CommandEdit)
            {
                LoadForEdit(galleryId);
            }
            else if (e.CommandName == CommandDelete)
            {
                DeleteItem(galleryId);
            }
        }

        // ---- markup helpers ----

        /// <summary>
        /// A small photo for the list. When the file is not on disk an empty grey square is shown instead,
        /// with a tooltip, because Home hides photos whose file is missing.
        /// </summary>
        protected string ThumbHtml(object imagePath)
        {
            string url = ImageHelper.ResolveExisting(Convert.ToString(imagePath));

            return url.Length == 0
                ? "<span class=\"thumb thumb-empty\" title=\"The photo file was not found, so it is hidden on Home.\"></span>"
                : "<img class=\"thumb\" src=\"" + HttpUtility.HtmlAttributeEncode(url) + "\" alt=\"\" />";
        }

        /// <summary>The text, or a dash when the optional field is empty.</summary>
        protected string OrDash(object value)
        {
            string text = (Convert.ToString(value) ?? string.Empty).Trim();
            return text.Length == 0 ? "\u2014" : text;
        }

        // ---- private helpers ----

        private void BindList()
        {
            List<GalleryEntry> photos;

            try
            {
                photos = ContentRepository.GetGallery();
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                pnlList.Visible = false;
                pnlEmpty.Visible = false;
                return;
            }

            rptGallery.DataSource = photos;
            rptGallery.DataBind();

            pnlList.Visible = photos.Count > 0;
            pnlEmpty.Visible = photos.Count == 0;
        }

        private void LoadForEdit(int galleryId)
        {
            HideMessage();

            GalleryEntry entry;

            try
            {
                entry = ContentRepository.GetGalleryById(galleryId);
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

            hfGalleryId.Value = entry.GalleryId.ToString(CultureInfo.InvariantCulture);
            litFormTitle.Text = EditTitle;
            litPhotoHint.Text = EditPhotoHint;
            txtCaption.Text = entry.Caption;
            txtSortOrder.Text = entry.SortOrder.ToString(CultureInfo.InvariantCulture);

            string photoUrl = ImageHelper.ResolveExisting(entry.ImagePath);
            pnlCurrentPhoto.Visible = photoUrl.Length > 0;
            imgPhoto.ImageUrl = photoUrl;

            pnlForm.Visible = true;
            btnAdd.Visible = false;
            pnlList.Visible = false;
            pnlEmpty.Visible = false;
            txtCaption.Focus();
        }

        private void DeleteItem(int galleryId)
        {
            HideMessage();

            try
            {
                GalleryEntry entry = ContentRepository.GetGalleryById(galleryId);

                if (entry == null)
                {
                    BindList();
                    ShowMessage(GoneMessage, false);
                    return;
                }

                if (ContentRepository.DeleteGalleryItem(galleryId) > 0)
                {
                    FileUploader.DeleteIfUploaded(entry.ImagePath);
                }
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                return;
            }

            RedirectAfterSave(Constants.ContentTabs.Gallery);
        }

        private void ClearForm()
        {
            hfGalleryId.Value = "0";
            txtCaption.Text = string.Empty;
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
