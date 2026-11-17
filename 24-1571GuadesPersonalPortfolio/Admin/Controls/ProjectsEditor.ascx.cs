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
    /// Manage Content tab for Recent Projects: a list plus one add/edit form. Only the title is required;
    /// tech stack, role, details and repository link are optional and are hidden on Home when empty.
    /// Projects have no photo, so there is no upload here.
    /// </summary>
    public partial class ProjectsEditor : ContentEditorBase
    {
        private const string CommandEdit = "edit";
        private const string CommandDelete = "delete";

        private const int DetailsMaxLength = 2000;

        private const string GoneMessage = "That project no longer exists. The list has been refreshed.";
        private const string DetailsTooLongMessage = "The details are longer than 2000 characters. Shorten them and try again.";
        private const string BadLinkMessage = "The repository link must start with http:// or https://";
        private const string AddTitle = "Add a project";
        private const string EditTitle = "Edit project";

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

            if (txtDetails.Text.Length > DetailsMaxLength)
            {
                ShowMessage(DetailsTooLongMessage, false);
                return;
            }

            // The validator checks the shape; this makes sure the link really is a usable http(s) address.
            string repoUrl = NullIfBlank(txtRepoUrl.Text);

            if (repoUrl != null && UrlHelper.SafeHttpUrl(repoUrl).Length == 0)
            {
                ShowMessage(BadLinkMessage, false);
                return;
            }

            int projectId;
            int.TryParse(hfProjectId.Value, out projectId);
            bool isEdit = projectId > 0;

            Project project = new Project
            {
                ProjectId = projectId,
                Title = txtTitle.Text.Trim(),
                TechStack = NullIfBlank(txtTechStack.Text),
                Role = NullIfBlank(txtRole.Text),
                Details = NullIfBlank(txtDetails.Text),
                RepoUrl = repoUrl
            };

            int? sortOrder = ParseNumber(txtSortOrder.Text);
            int affected = 1;

            try
            {
                if (isEdit)
                {
                    affected = ContentRepository.UpdateProject(project, sortOrder);
                }
                else
                {
                    ContentRepository.InsertProject(project, sortOrder);
                }
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                return;
            }

            if (affected == 0)
            {
                pnlForm.Visible = false;
                btnAdd.Visible = true;
                BindList();
                ShowMessage(GoneMessage, false);
                return;
            }

            RedirectAfterSave(Constants.ContentTabs.Projects);
        }

        /// <summary>Sets what each row's buttons do and asks for confirmation before a delete.</summary>
        protected void rptProjects_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            Project project = e.Item.DataItem as Project;
            Button btnEdit = e.Item.FindControl("btnEdit") as Button;
            Button btnDelete = e.Item.FindControl("btnDelete") as Button;

            if (project == null || btnEdit == null || btnDelete == null)
            {
                return;
            }

            string id = project.ProjectId.ToString(CultureInfo.InvariantCulture);

            btnEdit.CommandName = CommandEdit;
            btnEdit.CommandArgument = id;

            btnDelete.CommandName = CommandDelete;
            btnDelete.CommandArgument = id;
            btnDelete.OnClientClick = "return confirm("
                + HttpUtility.JavaScriptStringEncode("Delete " + project.Title + "? This can't be undone.", true)
                + ");";
        }

        protected void rptProjects_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int projectId;

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out projectId))
            {
                return;
            }

            if (e.CommandName == CommandEdit)
            {
                LoadForEdit(projectId);
            }
            else if (e.CommandName == CommandDelete)
            {
                DeleteProject(projectId);
            }
        }

        // ---- markup helpers ----

        /// <summary>The text, or a dash when the optional field is empty.</summary>
        protected string OrDash(object value)
        {
            string text = (Convert.ToString(value) ?? string.Empty).Trim();
            return text.Length == 0 ? "\u2014" : text;
        }

        /// <summary>An "Open" link to the repository (new tab), or a dash when there is none or it is not a safe link.</summary>
        protected string RepoHtml(object repoUrl)
        {
            string url = UrlHelper.SafeHttpUrl(Convert.ToString(repoUrl));

            return url.Length == 0
                ? "\u2014"
                : "<a href=\"" + HttpUtility.HtmlAttributeEncode(url) + "\" target=\"_blank\" rel=\"noopener\">Open</a>";
        }

        // ---- private helpers ----

        private void BindList()
        {
            List<Project> projects;

            try
            {
                projects = ContentRepository.GetProjects();
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                pnlList.Visible = false;
                pnlEmpty.Visible = false;
                return;
            }

            rptProjects.DataSource = projects;
            rptProjects.DataBind();

            pnlList.Visible = projects.Count > 0;
            pnlEmpty.Visible = projects.Count == 0;
        }

        private void LoadForEdit(int projectId)
        {
            HideMessage();

            Project project;

            try
            {
                project = ContentRepository.GetProjectById(projectId);
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                return;
            }

            if (project == null)
            {
                pnlForm.Visible = false;
                btnAdd.Visible = true;
                BindList();
                ShowMessage(GoneMessage, false);
                return;
            }

            ClearForm();

            hfProjectId.Value = project.ProjectId.ToString(CultureInfo.InvariantCulture);
            litFormTitle.Text = EditTitle;
            txtTitle.Text = project.Title;
            txtTechStack.Text = project.TechStack;
            txtRole.Text = project.Role;
            txtDetails.Text = project.Details;
            txtRepoUrl.Text = project.RepoUrl;
            txtSortOrder.Text = project.SortOrder.ToString(CultureInfo.InvariantCulture);

            pnlForm.Visible = true;
            btnAdd.Visible = false;
            pnlList.Visible = false;
            pnlEmpty.Visible = false;
            txtTitle.Focus();
        }

        private void DeleteProject(int projectId)
        {
            HideMessage();

            try
            {
                if (ContentRepository.DeleteProject(projectId) == 0)
                {
                    BindList();
                    ShowMessage(GoneMessage, false);
                    return;
                }
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                return;
            }

            RedirectAfterSave(Constants.ContentTabs.Projects);
        }

        private void ClearForm()
        {
            hfProjectId.Value = "0";
            txtTitle.Text = string.Empty;
            txtTechStack.Text = string.Empty;
            txtRole.Text = string.Empty;
            txtDetails.Text = string.Empty;
            txtRepoUrl.Text = string.Empty;
            txtSortOrder.Text = string.Empty;
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
