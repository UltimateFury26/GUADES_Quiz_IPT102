using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.UI.WebControls;
using _24_1571GuadesPersonalPortfolio.Data;
using _24_1571GuadesPersonalPortfolio.Helpers;
using _24_1571GuadesPersonalPortfolio.Security;

namespace _24_1571GuadesPersonalPortfolio
{
    /// <summary>
    /// Admin page for user (account) management: list, search, filter, deactivate,
    /// reactivate and delete. It shows account information only and never any
    /// password data, and it never touches website content.
    /// Inherits AdminPage, so non-Admins are turned away before any of this runs.
    /// The stored procedures repeat the rules (no self-action, no action on an Admin),
    /// so the disabled buttons here are a convenience, not the only protection.
    /// </summary>
    public partial class ManageUsersPage : AdminPage
    {
        private const string ErrorStyle = "alert alert-error";
        private const string SuccessStyle = "alert alert-success";

        // Command names carried by the row buttons and the sortable column headers.
        private const string CommandDeactivate = "deactivate";
        private const string CommandReactivate = "reactivate";
        private const string CommandDelete = "delete";
        private const string CommandSort = "Sort";

        // ViewState keys for the current sort column and direction. Unsorted until the admin clicks a header.
        private const string SortFieldKey = "ManageUsers_SortField";
        private const string SortAscKey = "ManageUsers_SortAsc";

        private const string DatabaseMessage = "We couldn't reach the database right now. Try again in a moment.";
        private const string UserNotFoundMessage = "That user no longer exists.";
        private const string SelfActionMessage = "You can't change or delete your own account here.";
        private const string AdminTargetMessage = "Admin accounts can't be changed or deleted.";
        private const string NotAllowedMessage = "You don't have permission to do that.";
        private const string GenericFailureMessage = "That action couldn't be completed.";

        private const string DateFormat = "MMM d, yyyy";
        private const string DateTimeFormat = "MMM d, yyyy h:mm tt";

        // The search box and status dropdown above the table are plain HTML, filtered live
        // client-side in Portfolio.js, so this page no longer needs a Search/Clear round trip.
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindUsers();
            }
        }

        /// <summary>Decides, per row, which buttons say what and which are locked.</summary>
        protected void rptUsers_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            UserAccount user = e.Item.DataItem as UserAccount;
            Button btnToggle = e.Item.FindControl("btnToggle") as Button;
            Button btnDelete = e.Item.FindControl("btnDelete") as Button;

            if (user == null || btnToggle == null || btnDelete == null)
            {
                return;
            }

            bool isSelf = user.UserId == CurrentUser.Id;
            bool isAdminRow = user.Role == Constants.Roles.Admin;
            bool locked = isSelf || isAdminRow;
            bool isActive = user.Status == Constants.Status.Active;
            string userId = user.UserId.ToString(CultureInfo.InvariantCulture);

            btnToggle.Text = isActive ? "Deactivate" : "Reactivate";
            btnToggle.CommandName = isActive ? CommandDeactivate : CommandReactivate;
            btnToggle.CommandArgument = userId;
            btnToggle.OnClientClick = isActive
                ? ConfirmScript("Deactivate " + user.Username + "? They won't be able to log in until you reactivate them.")
                : string.Empty;

            btnDelete.CommandName = CommandDelete;
            btnDelete.CommandArgument = userId;
            btnDelete.OnClientClick = ConfirmScript("Delete " + user.Username + " permanently? This can't be undone.");

            btnToggle.Enabled = !locked;
            btnDelete.Enabled = !locked;

            if (locked)
            {
                string reason = isSelf ? "You can't change your own account." : "Admin accounts can't be changed or deleted.";
                btnToggle.ToolTip = reason;
                btnDelete.ToolTip = reason;
            }
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == CommandSort)
            {
                ApplySort(Convert.ToString(e.CommandArgument));
                BindUsers();
                return;
            }

            bool known = e.CommandName == CommandDeactivate
                || e.CommandName == CommandReactivate
                || e.CommandName == CommandDelete;

            int userId;

            if (!known || !int.TryParse(Convert.ToString(e.CommandArgument), out userId))
            {
                return;
            }

            ApplyAction(e.CommandName, userId);
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

        /// <summary>Sorts the in-memory list by whichever column the admin last clicked. Unsorted until then.</summary>
        private void SortUsers(List<UserAccount> users)
        {
            string field = Convert.ToString(ViewState[SortFieldKey]);

            if (string.IsNullOrEmpty(field))
            {
                return;
            }

            Comparison<UserAccount> compare;

            switch (field)
            {
                case "Username":
                    compare = (a, b) => string.Compare(a.Username, b.Username, StringComparison.OrdinalIgnoreCase);
                    break;
                case "Email":
                    compare = (a, b) => string.Compare(a.Email, b.Email, StringComparison.OrdinalIgnoreCase);
                    break;
                case "Phone":
                    compare = (a, b) => string.Compare(a.Phone, b.Phone, StringComparison.Ordinal);
                    break;
                case "Role":
                    compare = (a, b) => string.Compare(a.Role, b.Role, StringComparison.Ordinal);
                    break;
                case "Status":
                    compare = (a, b) => string.Compare(a.Status, b.Status, StringComparison.Ordinal);
                    break;
                case "CreatedAt":
                    compare = (a, b) => DateTime.Compare(a.CreatedAt, b.CreatedAt);
                    break;
                case "LastLoginAt":
                    compare = (a, b) => Nullable.Compare(a.LastLoginAt, b.LastLoginAt);
                    break;
                default:
                    compare = (a, b) => a.UserId.CompareTo(b.UserId);
                    break;
            }

            users.Sort(compare);

            if (!(ViewState[SortAscKey] == null || (bool)ViewState[SortAscKey]))
            {
                users.Reverse();
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

        protected string RoleBadgeClass(object role)
        {
            return Convert.ToString(role) == Constants.Roles.Admin ? "badge badge-admin" : "badge badge-user";
        }

        protected string StatusBadgeClass(object status)
        {
            return Convert.ToString(status) == Constants.Status.Active ? "badge badge-active" : "badge badge-inactive";
        }

        /// <summary>Small "you" tag next to the signed-in Admin's own row.</summary>
        protected string YouTag(object userId)
        {
            return Convert.ToInt32(userId) == CurrentUser.Id
                ? " <span class=\"you-tag\">you</span>"
                : string.Empty;
        }

        protected string FormatDate(object value)
        {
            return Convert.ToDateTime(value).ToString(DateFormat, CultureInfo.InvariantCulture);
        }

        protected string FormatLastLogin(object value)
        {
            return value == null || value == DBNull.Value
                ? "Never"
                : Convert.ToDateTime(value).ToString(DateTimeFormat, CultureInfo.InvariantCulture);
        }

        // ---- private helpers ----

        /// <summary>Loads every user. Searching and filtering by status happen client-side
        /// (Portfolio.js), against the rows this renders, so every user is always fetched.</summary>
        private void BindUsers()
        {
            List<UserAccount> users;

            try
            {
                users = UserRepository.GetUsers(null, null);
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                litCount.Text = string.Empty;
                pnlResults.Visible = false;
                pnlEmpty.Visible = false;
                return;
            }

            SortUsers(users);

            rptUsers.DataSource = users;
            rptUsers.DataBind();

            bool any = users.Count > 0;
            pnlResults.Visible = any;
            pnlEmpty.Visible = !any;
            litCount.Text = users.Count == 1 ? "1 user" : users.Count.ToString(CultureInfo.InvariantCulture) + " users";
        }

        /// <summary>Runs one row action, shows the outcome and reloads the list.</summary>
        private void ApplyAction(string command, int userId)
        {
            int code;
            string name;

            try
            {
                UserAccount target = UserRepository.GetById(userId);
                name = target == null ? "That user" : target.Username;
                code = RunCommand(command, userId);
            }
            catch (SqlException)
            {
                ShowMessage(DatabaseMessage, false);
                return;
            }

            if (code == Constants.AdminActionCodes.Ok)
            {
                ShowMessage(SuccessText(command, name), true);
            }
            else
            {
                ShowMessage(FailureText(code), false);
            }

            BindUsers();
        }

        private static int RunCommand(string command, int userId)
        {
            switch (command)
            {
                case CommandDeactivate:
                    return UserRepository.SetUserStatus(CurrentUser.Id, userId, Constants.Status.Inactive);

                case CommandReactivate:
                    return UserRepository.SetUserStatus(CurrentUser.Id, userId, Constants.Status.Active);

                default:
                    return UserRepository.DeleteUser(CurrentUser.Id, userId);
            }
        }

        private static string SuccessText(string command, string name)
        {
            switch (command)
            {
                case CommandDeactivate:
                    return name + " was deactivated. They can no longer log in.";

                case CommandReactivate:
                    return name + " was reactivated.";

                default:
                    return name + " was deleted.";
            }
        }

        private static string FailureText(int code)
        {
            switch (code)
            {
                case Constants.AdminActionCodes.UserNotFound:
                    return UserNotFoundMessage;

                case Constants.AdminActionCodes.CannotActOnSelf:
                    return SelfActionMessage;

                case Constants.AdminActionCodes.CannotActOnAdmin:
                    return AdminTargetMessage;

                case Constants.AdminActionCodes.NotAnAdmin:
                    return NotAllowedMessage;

                default:
                    return GenericFailureMessage;
            }
        }

        /// <summary>Builds a client-side confirm() call. The text is escaped for JavaScript.</summary>
        private static string ConfirmScript(string question)
        {
            return "return confirm(" + HttpUtility.JavaScriptStringEncode(question, true) + ");";
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
