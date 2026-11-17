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
    /// Manage Content tab for Skills: a list plus one add/edit form. A skill's category
    /// (Frontend, Backend or Tools) decides which board it appears on, on Home.
    /// Skills have no photo, so there is no upload here.
    /// </summary>
    public partial class SkillsEditor : ContentEditorBase
    {
        private const string CommandEdit = "edit";
        private const string CommandDelete = "delete";

        private const int DescriptionMaxLength = 1500;
        private const int ListPreviewLength = 90;

        private const string GoneMessage = "That skill no longer exists. The list has been refreshed.";
        private const string DescriptionTooLongMessage = "The description is longer than 1500 characters. Shorten it and try again.";
        private const string AddTitle = "Add a skill";
        private const string EditTitle = "Edit skill";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            FillCategories();
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
            txtName.Focus();
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

            int skillId;
            int.TryParse(hfSkillId.Value, out skillId);
            bool isEdit = skillId > 0;

            Skill skill = new Skill
            {
                SkillId = skillId,
                Name = txtName.Text.Trim(),
                Category = ddlCategory.SelectedValue,
                Description = NullIfBlank(txtDescription.Text)
            };

            int? sortOrder = ParseNumber(txtSortOrder.Text);
            int affected = 1;

            try
            {
                if (isEdit)
                {
                    affected = ContentRepository.UpdateSkill(skill, sortOrder);
                }
                else
                {
                    ContentRepository.InsertSkill(skill, sortOrder);
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

            RedirectAfterSave(Constants.ContentTabs.Skills);
        }

        /// <summary>Sets what each row's buttons do and asks for confirmation before a delete.</summary>
        protected void rptSkills_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            Skill skill = e.Item.DataItem as Skill;
            Button btnEdit = e.Item.FindControl("btnEdit") as Button;
            Button btnDelete = e.Item.FindControl("btnDelete") as Button;

            if (skill == null || btnEdit == null || btnDelete == null)
            {
                return;
            }

            string id = skill.SkillId.ToString(CultureInfo.InvariantCulture);

            btnEdit.CommandName = CommandEdit;
            btnEdit.CommandArgument = id;

            btnDelete.CommandName = CommandDelete;
            btnDelete.CommandArgument = id;
            btnDelete.OnClientClick = "return confirm("
                + HttpUtility.JavaScriptStringEncode("Delete " + skill.Name + "? This can't be undone.", true)
                + ");";
        }

        protected void rptSkills_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int skillId;

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out skillId))
            {
                return;
            }

            if (e.CommandName == CommandEdit)
            {
                LoadForEdit(skillId);
            }
            else if (e.CommandName == CommandDelete)
            {
                DeleteSkill(skillId);
            }
        }

        // ---- markup helpers ----

        /// <summary>The name of the board a category feeds, e.g. "Tools" is shown as "Tools &amp; Platforms".</summary>
        protected string CategoryLabel(object category)
        {
            string value = Convert.ToString(category);
            return value == Constants.SkillCategories.Tools ? "Tools & Platforms" : value;
        }

        /// <summary>The start of a description for the list, or a dash when there is none.</summary>
        protected string Shorten(object description)
        {
            string text = (Convert.ToString(description) ?? string.Empty).Trim();

            if (text.Length == 0)
            {
                return "\u2014";
            }

            return text.Length <= ListPreviewLength ? text : text.Substring(0, ListPreviewLength).TrimEnd() + "\u2026";
        }

        // ---- private helpers ----

        private void FillCategories()
        {
            string[] categories =
            {
                Constants.SkillCategories.Frontend,
                Constants.SkillCategories.Backend,
                Constants.SkillCategories.Tools
            };

            foreach (string category in categories)
            {
                ddlCategory.Items.Add(new ListItem(CategoryLabel(category), category));
            }
        }

        private void BindList()
        {
            List<Skill> skills;

            try
            {
                skills = ContentRepository.GetSkills();
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                pnlList.Visible = false;
                pnlEmpty.Visible = false;
                return;
            }

            rptSkills.DataSource = skills;
            rptSkills.DataBind();

            pnlList.Visible = skills.Count > 0;
            pnlEmpty.Visible = skills.Count == 0;
        }

        private void LoadForEdit(int skillId)
        {
            HideMessage();

            Skill skill;

            try
            {
                skill = ContentRepository.GetSkillById(skillId);
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                return;
            }

            if (skill == null)
            {
                pnlForm.Visible = false;
                btnAdd.Visible = true;
                BindList();
                ShowMessage(GoneMessage, false);
                return;
            }

            ClearForm();

            hfSkillId.Value = skill.SkillId.ToString(CultureInfo.InvariantCulture);
            litFormTitle.Text = EditTitle;
            txtName.Text = skill.Name;
            ddlCategory.SelectedValue = skill.Category;
            txtDescription.Text = skill.Description;
            txtSortOrder.Text = skill.SortOrder.ToString(CultureInfo.InvariantCulture);

            pnlForm.Visible = true;
            btnAdd.Visible = false;
            pnlList.Visible = false;
            pnlEmpty.Visible = false;
            txtName.Focus();
        }

        private void DeleteSkill(int skillId)
        {
            HideMessage();

            try
            {
                if (ContentRepository.DeleteSkill(skillId) == 0)
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

            RedirectAfterSave(Constants.ContentTabs.Skills);
        }

        private void ClearForm()
        {
            hfSkillId.Value = "0";
            txtName.Text = string.Empty;
            ddlCategory.SelectedIndex = 0;
            txtDescription.Text = string.Empty;
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
