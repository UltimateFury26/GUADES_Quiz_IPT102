using System;
using System.Web.UI;
using _24_1571GuadesPersonalPortfolio.Helpers;

namespace _24_1571GuadesPersonalPortfolio
{
    /// <summary>
    /// Shared behaviour for the section editors on the Manage Content page (one user control per
    /// section). After a successful save an editor redirects back to its own tab with a "saved" flag,
    /// so the page header and the rest of the site show the new data straight away and a refresh
    /// never resubmits the form.
    /// </summary>
    public abstract class ContentEditorBase : UserControl
    {
        protected const string ErrorStyle = "alert alert-error";
        protected const string SuccessStyle = "alert alert-success";

        protected const string SavedMessage = "Your changes were saved.";
        protected const string DatabaseMessage = "We couldn't reach the database right now. Try again in a moment.";

        /// <summary>True when this page load is the result of a successful save.</summary>
        protected bool WasJustSaved
        {
            get { return Request.QueryString[Constants.ContentQuery.Saved] == "1"; }
        }

        /// <summary>Sends the Admin back to the given tab with the "saved" flag set.</summary>
        protected void RedirectAfterSave(string tabKey)
        {
            Response.Redirect(
                Request.AppRelativeCurrentExecutionFilePath
                + "?" + Constants.ContentQuery.Tab + "=" + Server.UrlEncode(tabKey)
                + "&" + Constants.ContentQuery.Saved + "=1");
        }

        /// <summary>Trims the text and returns null when nothing is left, so empty optional fields are stored as NULL.</summary>
        protected static string NullIfBlank(string value)
        {
            string trimmed = (value ?? string.Empty).Trim();
            return trimmed.Length == 0 ? null : trimmed;
        }
    }
}
