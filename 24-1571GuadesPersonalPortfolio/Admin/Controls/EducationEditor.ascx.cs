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
    /// Manage Content tab for Educational Attainment: a list of schools plus one add/edit form.
    /// The form is hidden until "Add school" or a row's "Edit" is clicked. A successful save or
    /// delete redirects back to this tab, so the list, the page header and Home all show the change.
    /// </summary>
    public partial class EducationEditor : ContentEditorBase
    {
        private const string CommandEdit = "edit";
        private const string CommandDelete = "delete";

        private const int DescriptionMaxLength = 1000;

        private const string GoneMessage = "That school no longer exists. The list has been refreshed.";
        private const string DescriptionTooLongMessage = "The description is longer than 1000 characters. Shorten it and try again.";
        private const string AddTitle = "Add a school";
        private const string EditTitle = "Edit school";

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
            txtSchool.Focus();
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

            int educationId;
            int.TryParse(hfEducationId.Value, out educationId);
            bool isEdit = educationId > 0;

            string oldPhotoPath = null;
            string newPhotoPath = null;

            if (fuPhoto.HasFile)
            {
                if (isEdit)
                {
                    try
                    {
                        EducationEntry existing = ContentRepository.GetEducationById(educationId);
                        oldPhotoPath = existing == null ? null : existing.PhotoPath;
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

                newPhotoPath = upload.RelativePath;
            }

            EducationEntry entry = new EducationEntry
            {
                EducationId = educationId,
                SchoolName = txtSchool.Text.Trim(),
                Level = txtLevel.Text.Trim(),
                Program = NullIfBlank(txtProgram.Text),
                StartYear = ParseNumber(txtStartYear.Text),
                EndYear = ParseNumber(txtEndYear.Text),
                Description = NullIfBlank(txtDescription.Text),
                PhotoPath = newPhotoPath
            };

            int? sortOrder = ParseNumber(txtSortOrder.Text);
            int affected = 1;

            try
            {
                if (isEdit)
                {
                    affected = ContentRepository.UpdateEducation(entry, sortOrder);
                }
                else
                {
                    ContentRepository.InsertEducation(entry, sortOrder);
                }
            }
            catch (SqlException)
            {
                FileUploader.DeleteIfUploaded(newPhotoPath);
                ShowMessage(DatabaseMessage, false);
                return;
            }

            if (affected == 0)
            {
                FileUploader.DeleteIfUploaded(newPhotoPath);
                pnlForm.Visible = false;
                btnAdd.Visible = true;
                BindList();
                ShowMessage(GoneMessage, false);
                return;
            }

            if (newPhotoPath != null)
            {
                FileUploader.DeleteIfUploaded(oldPhotoPath);
            }

            RedirectAfterSave(Constants.ContentTabs.Education);
        }

        /// <summary>Years must make sense together: an end year needs a start year and cannot be earlier than it.</summary>
        protected void cvYears_ServerValidate(object source, ServerValidateEventArgs args)
        {
            int? start = ParseNumber(txtStartYear.Text);
            int? end = ParseNumber(txtEndYear.Text);

            args.IsValid = true;

            if (end.HasValue && !start.HasValue)
            {
                cvYears.ErrorMessage = "Enter a start year too, or clear the end year.";
                args.IsValid = false;
            }
            else if (start.HasValue && end.HasValue && end.Value < start.Value)
            {
                cvYears.ErrorMessage = "The end year can't be before the start year.";
                args.IsValid = false;
            }
        }

        /// <summary>Sets what each row's buttons do and asks for confirmation before a delete.</summary>
        protected void rptSchools_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            EducationEntry entry = e.Item.DataItem as EducationEntry;
            Button btnEdit = e.Item.FindControl("btnEdit") as Button;
            Button btnDelete = e.Item.FindControl("btnDelete") as Button;

            if (entry == null || btnEdit == null || btnDelete == null)
            {
                return;
            }

            string id = entry.EducationId.ToString(CultureInfo.InvariantCulture);

            btnEdit.CommandName = CommandEdit;
            btnEdit.CommandArgument = id;

            btnDelete.CommandName = CommandDelete;
            btnDelete.CommandArgument = id;
            btnDelete.OnClientClick = "return confirm("
                + HttpUtility.JavaScriptStringEncode("Delete " + entry.SchoolName + " (" + entry.Level + ")? This can't be undone.", true)
                + ");";
        }

        protected void rptSchools_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int educationId;

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out educationId))
            {
                return;
            }

            if (e.CommandName == CommandEdit)
            {
                LoadForEdit(educationId);
            }
            else if (e.CommandName == CommandDelete)
            {
                DeleteSchool(educationId);
            }
        }

        // ---- markup helpers ----

        /// <summary>A small photo for the list, or an empty grey square when there is no photo on disk.</summary>
        protected string ThumbHtml(object photoPath)
        {
            string url = ImageHelper.ResolveExisting(Convert.ToString(photoPath));

            return url.Length == 0
                ? "<span class=\"thumb thumb-empty\"></span>"
                : "<img class=\"thumb\" src=\"" + HttpUtility.HtmlAttributeEncode(url) + "\" alt=\"\" />";
        }

        /// <summary>"2022 - 2024", "2024 - Present", or a dash when the years are not known.</summary>
        protected string FormatYears(object startYear, object endYear)
        {
            if (startYear == null || startYear == DBNull.Value)
            {
                return "\u2014";
            }

            bool hasEnd = endYear != null && endYear != DBNull.Value;
            return Convert.ToString(startYear, CultureInfo.InvariantCulture) + " \u2013 "
                + (hasEnd ? Convert.ToString(endYear, CultureInfo.InvariantCulture) : "Present");
        }

        // ---- private helpers ----

        private void BindList()
        {
            List<EducationEntry> schools;

            try
            {
                schools = ContentRepository.GetEducation();
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                pnlList.Visible = false;
                pnlEmpty.Visible = false;
                return;
            }

            rptSchools.DataSource = schools;
            rptSchools.DataBind();

            pnlList.Visible = schools.Count > 0;
            pnlEmpty.Visible = schools.Count == 0;
        }

        private void LoadForEdit(int educationId)
        {
            HideMessage();

            EducationEntry entry;

            try
            {
                entry = ContentRepository.GetEducationById(educationId);
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

            hfEducationId.Value = entry.EducationId.ToString(CultureInfo.InvariantCulture);
            litFormTitle.Text = EditTitle;
            txtSchool.Text = entry.SchoolName;
            txtLevel.Text = entry.Level;
            txtProgram.Text = entry.Program;
            txtStartYear.Text = entry.StartYear.HasValue ? entry.StartYear.Value.ToString(CultureInfo.InvariantCulture) : string.Empty;
            txtEndYear.Text = entry.EndYear.HasValue ? entry.EndYear.Value.ToString(CultureInfo.InvariantCulture) : string.Empty;
            txtDescription.Text = entry.Description;
            txtSortOrder.Text = entry.SortOrder.ToString(CultureInfo.InvariantCulture);

            string photoUrl = ImageHelper.ResolveExisting(entry.PhotoPath);
            pnlCurrentPhoto.Visible = photoUrl.Length > 0;
            imgPhoto.ImageUrl = photoUrl;

            pnlForm.Visible = true;
            btnAdd.Visible = false;
            pnlList.Visible = false;
            pnlEmpty.Visible = false;
            txtSchool.Focus();
        }

        private void DeleteSchool(int educationId)
        {
            HideMessage();

            try
            {
                EducationEntry entry = ContentRepository.GetEducationById(educationId);

                if (entry == null)
                {
                    BindList();
                    ShowMessage(GoneMessage, false);
                    return;
                }

                if (ContentRepository.DeleteEducation(educationId) > 0)
                {
                    FileUploader.DeleteIfUploaded(entry.PhotoPath);
                }
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                return;
            }

            RedirectAfterSave(Constants.ContentTabs.Education);
        }

        private void ClearForm()
        {
            hfEducationId.Value = "0";
            txtSchool.Text = string.Empty;
            txtLevel.Text = string.Empty;
            txtProgram.Text = string.Empty;
            txtStartYear.Text = string.Empty;
            txtEndYear.Text = string.Empty;
            txtDescription.Text = string.Empty;
            txtSortOrder.Text = string.Empty;
            pnlCurrentPhoto.Visible = false;
        }

        /// <summary>Reads a whole number from text; blank or non-numeric text gives null (the validators report the latter).</summary>
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
