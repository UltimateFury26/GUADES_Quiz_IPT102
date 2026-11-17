using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI.WebControls;
using _24_1571GuadesPersonalPortfolio.Data;
using _24_1571GuadesPersonalPortfolio.Helpers;
using _24_1571GuadesPersonalPortfolio.Security;

namespace _24_1571GuadesPersonalPortfolio
{
    /// <summary>
    /// Admin page for announcements: list, create, edit, publish or unpublish, and delete.
    /// Announcements are website content, so they belong to the site and are shown to every
    /// logged-in user on Home; only published ones are visible there.
    /// Inherits AdminPage, so non-Admins are turned away before any of this runs.
    /// After every successful change the page redirects to itself with a "done" code,
    /// so a browser refresh never repeats the action.
    /// </summary>
    public partial class ManagePostsPage : AdminPage
    {
        private const string ErrorStyle = "alert alert-error";
        private const string SuccessStyle = "alert alert-success";

        // Command names carried by the row buttons.
        private const string CommandEdit = "edit";
        private const string CommandPublish = "publish";
        private const string CommandUnpublish = "unpublish";
        private const string CommandDelete = "delete";
        private const string CommandSort = "Sort";

        // ViewState keys for the current sort column and direction. Newest-first until the admin clicks a header.
        private const string SortFieldKey = "ManagePosts_SortField";
        private const string SortAscKey = "ManagePosts_SortAsc";

        private const int TitleMaxLength = 150;
        private const int BodyMaxLength = 4000;
        private const int ListPreviewLength = 100;

        private const string PagePath = "~/Admin/ManagePosts.aspx";
        private const string AddTitle = "New announcement";
        private const string EditTitle = "Edit announcement";

        private const string DatabaseMessage = "We couldn't reach the database right now. Try again in a moment.";
        private const string GoneMessage = "That announcement no longer exists. The list has been refreshed.";
        private const string TitleTooLongMessage = "The title is longer than 150 characters. Shorten it and try again.";
        private const string BodyTooLongMessage = "The message is longer than 4,000 characters. Shorten it and try again.";

        private const string DateTimeFormat = "MMM d, yyyy h:mm tt";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            BindList();

            string done = DoneText(Request.QueryString[Constants.PostQuery.Done]);
            if (done != null)
            {
                ShowMessage(done, true);
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

            string title = txtTitle.Text.Trim();
            string body = txtBody.Text.Trim();

            if (title.Length > TitleMaxLength)
            {
                ShowMessage(TitleTooLongMessage, false);
                return;
            }

            if (body.Length > BodyMaxLength)
            {
                ShowMessage(BodyTooLongMessage, false);
                return;
            }

            int postId;
            int.TryParse(hfPostId.Value, out postId);
            bool isEdit = postId > 0;
            bool publish = chkPublish.Checked;
            int affected = 1;

            try
            {
                if (isEdit)
                {
                    affected = PostRepository.Update(postId, title, body, publish);
                }
                else
                {
                    PostRepository.Insert(title, body, publish, CurrentUser.Id);
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

            RedirectDone(isEdit ? Constants.PostQuery.Updated : Constants.PostQuery.Created);
        }

        /// <summary>Decides, per row, what the Publish/Unpublish button says and asks before a delete.</summary>
        protected void rptPosts_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            Post post = e.Item.DataItem as Post;
            Button btnEdit = e.Item.FindControl("btnEdit") as Button;
            Button btnToggle = e.Item.FindControl("btnToggle") as Button;
            Button btnDelete = e.Item.FindControl("btnDelete") as Button;

            if (post == null || btnEdit == null || btnToggle == null || btnDelete == null)
            {
                return;
            }

            string id = post.PostId.ToString(CultureInfo.InvariantCulture);

            btnEdit.CommandName = CommandEdit;
            btnEdit.CommandArgument = id;

            btnToggle.Text = post.IsPublished ? "Unpublish" : "Publish";
            btnToggle.CommandName = post.IsPublished ? CommandUnpublish : CommandPublish;
            btnToggle.CommandArgument = id;

            btnDelete.CommandName = CommandDelete;
            btnDelete.CommandArgument = id;
            btnDelete.OnClientClick = "return confirm("
                + HttpUtility.JavaScriptStringEncode("Delete \"" + post.Title + "\"? This can't be undone.", true)
                + ");";
        }

        protected void rptPosts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == CommandSort)
            {
                ApplySort(Convert.ToString(e.CommandArgument));
                BindList();
                return;
            }

            int postId;

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out postId))
            {
                return;
            }

            switch (e.CommandName)
            {
                case CommandEdit:
                    LoadForEdit(postId);
                    break;

                case CommandPublish:
                    SetPublished(postId, true);
                    break;

                case CommandUnpublish:
                    SetPublished(postId, false);
                    break;

                case CommandDelete:
                    DeletePost(postId);
                    break;
            }
        }

        /// <summary>Clicking a column header sorts by it; clicking the same header again reverses the direction.</summary>
        private void ApplySort(string field)
        {
            if (string.IsNullOrEmpty(field))
            {
                return;
            }

            if (Convert.ToString(ViewState[SortFieldKey]) == field)
            {
                ViewState[SortAscKey] = !(ViewState[SortAscKey] == null || (bool)ViewState[SortAscKey]);
            }
            else
            {
                ViewState[SortFieldKey] = field;
                ViewState[SortAscKey] = true;
            }
        }

        /// <summary>Sorts the in-memory list by whichever column the admin last clicked. Newest-first (the repository's own order) until then.</summary>
        private void SortPosts(List<Post> posts)
        {
            string field = Convert.ToString(ViewState[SortFieldKey]);

            if (string.IsNullOrEmpty(field))
            {
                return;
            }

            Comparison<Post> compare;

            switch (field)
            {
                case "Title":
                    compare = (a, b) => string.Compare(a.Title, b.Title, StringComparison.OrdinalIgnoreCase);
                    break;
                case "IsPublished":
                    compare = (a, b) => a.IsPublished.CompareTo(b.IsPublished);
                    break;
                case "AuthorName":
                    compare = (a, b) => string.Compare(a.AuthorName, b.AuthorName, StringComparison.OrdinalIgnoreCase);
                    break;
                default:
                    compare = (a, b) => DateTime.Compare(a.CreatedAt, b.CreatedAt);
                    break;
            }

            posts.Sort(compare);

            if (!(ViewState[SortAscKey] == null || (bool)ViewState[SortAscKey]))
            {
                posts.Reverse();
            }
        }

        /// <summary>Header text plus a ▲/▼ arrow when this column is the active sort.</summary>
        protected string SortHeaderText(string label, string field)
        {
            if (Convert.ToString(ViewState[SortFieldKey]) != field)
            {
                return label;
            }

            bool asc = ViewState[SortAscKey] == null || (bool)ViewState[SortAscKey];
            return label + (asc ? " \u25B2" : " \u25BC");
        }

        /// <summary>Highlights whichever header is the active sort.</summary>
        protected string SortHeaderClass(string field)
        {
            return Convert.ToString(ViewState[SortFieldKey]) == field ? "th-sort active" : "th-sort";
        }

        // ---- markup helpers (used by the data-binding expressions in the .aspx) ----

        /// <summary>The Published or Draft badge.</summary>
        protected string StatusHtml(object isPublished)
        {
            return Convert.ToBoolean(isPublished)
                ? "<span class=\"badge badge-active\">Published</span>"
                : "<span class=\"badge badge-user\">Draft</span>";
        }

        /// <summary>The created date, plus an "Updated" line when the post was changed afterwards.</summary>
        protected string PostedHtml(object dataItem)
        {
            Post post = dataItem as Post;

            if (post == null)
            {
                return string.Empty;
            }

            string html = HttpUtility.HtmlEncode(post.CreatedAt.ToString(DateTimeFormat, CultureInfo.InvariantCulture));

            if (post.UpdatedAt.HasValue)
            {
                html += "<p class=\"post-meta\">Updated "
                    + HttpUtility.HtmlEncode(post.UpdatedAt.Value.ToString(DateTimeFormat, CultureInfo.InvariantCulture))
                    + "</p>";
            }

            return html;
        }

        /// <summary>The start of the message for the list, on one line.</summary>
        protected string Preview(object body)
        {
            string text = Regex.Replace(Convert.ToString(body) ?? string.Empty, @"\s+", " ").Trim();

            return text.Length <= ListPreviewLength
                ? text
                : text.Substring(0, ListPreviewLength).TrimEnd() + "\u2026";
        }

        // ---- private helpers ----

        private void BindList()
        {
            List<Post> posts;

            try
            {
                posts = PostRepository.GetAll();
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                litCount.Text = string.Empty;
                pnlList.Visible = false;
                pnlEmpty.Visible = false;
                return;
            }

            SortPosts(posts);

            rptPosts.DataSource = posts;
            rptPosts.DataBind();

            int published = 0;
            foreach (Post post in posts)
            {
                if (post.IsPublished)
                {
                    published++;
                }
            }

            pnlList.Visible = posts.Count > 0;
            pnlEmpty.Visible = posts.Count == 0;
            litCount.Text = CountText(posts.Count, published);
        }

        private static string CountText(int total, int published)
        {
            string noun = total == 1 ? "1 post" : total.ToString(CultureInfo.InvariantCulture) + " posts";
            return noun + ", " + published.ToString(CultureInfo.InvariantCulture) + " published";
        }

        private void LoadForEdit(int postId)
        {
            HideMessage();

            Post post;

            try
            {
                post = PostRepository.GetById(postId);
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                return;
            }

            if (post == null)
            {
                pnlForm.Visible = false;
                btnAdd.Visible = true;
                BindList();
                ShowMessage(GoneMessage, false);
                return;
            }

            ClearForm();

            hfPostId.Value = post.PostId.ToString(CultureInfo.InvariantCulture);
            litFormTitle.Text = EditTitle;
            txtTitle.Text = post.Title;
            txtBody.Text = post.Body;
            chkPublish.Checked = post.IsPublished;

            pnlForm.Visible = true;
            btnAdd.Visible = false;
            pnlList.Visible = false;
            pnlEmpty.Visible = false;
            txtTitle.Focus();
        }

        private void SetPublished(int postId, bool publish)
        {
            HideMessage();
            int affected;

            try
            {
                affected = PostRepository.SetPublished(postId, publish);
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

            RedirectDone(publish ? Constants.PostQuery.Published : Constants.PostQuery.Unpublished);
        }

        private void DeletePost(int postId)
        {
            HideMessage();
            int affected;

            try
            {
                affected = PostRepository.Delete(postId);
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

            RedirectDone(Constants.PostQuery.Deleted);
        }

        private void ClearForm()
        {
            hfPostId.Value = "0";
            txtTitle.Text = string.Empty;
            txtBody.Text = string.Empty;
            chkPublish.Checked = false;
        }

        /// <summary>Reloads this page with a "done" code so a refresh does not repeat the action.</summary>
        private void RedirectDone(string code)
        {
            Response.Redirect(PagePath + "?" + Constants.PostQuery.Done + "=" + Server.UrlEncode(code));
        }

        /// <summary>Maps a "done" code to its message. Unknown codes give null, so arbitrary text is never shown.</summary>
        private static string DoneText(string code)
        {
            switch (code)
            {
                case Constants.PostQuery.Created:
                    return "The announcement was created.";

                case Constants.PostQuery.Updated:
                    return "The announcement was updated.";

                case Constants.PostQuery.Published:
                    return "The announcement is now published. Users can see it on Home.";

                case Constants.PostQuery.Unpublished:
                    return "The announcement was unpublished. It is now a draft and hidden from users.";

                case Constants.PostQuery.Deleted:
                    return "The announcement was deleted.";

                default:
                    return null;
            }
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
