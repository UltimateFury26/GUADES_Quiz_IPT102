using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using _24_1571GuadesPersonalPortfolio.Data;
using _24_1571GuadesPersonalPortfolio.Helpers;
using _24_1571GuadesPersonalPortfolio.Security;

namespace _24_1571GuadesPersonalPortfolio
{
    /// <summary>
    /// Admin page with the statistic reports: user summary cards, signups per month, active versus
    /// inactive accounts, the latest signups and a content summary. Every number comes from a
    /// stored procedure, and the charts are drawn with plain CSS (no scripts or libraries).
    /// It shows account statistics only, never password data.
    /// Inherits AdminPage, so non-Admins are turned away before any of this runs.
    /// </summary>
    public partial class ReportsPage : AdminPage
    {
        private const string DatabaseMessage = "We couldn't reach the database right now. Try again in a moment.";
        private const string DateFormat = "MMM d, yyyy";

        /// <summary>A bar can never be shorter than this (percent) unless it is zero, so one signup stays visible.</summary>
        private const int MinimumBarPercent = 4;

        /// <summary>One column of the signups-per-month chart.</summary>
        public class SignupBar
        {
            public string Month { get; set; }
            public string Year { get; set; }
            public int Signups { get; set; }
            public int HeightPercent { get; set; }
            public string Tooltip { get; set; }
        }

        /// <summary>One column of the visits-per-month chart.</summary>
        public class VisitBar
        {
            public string Month { get; set; }
            public string Year { get; set; }
            public int Visits { get; set; }
            public int HeightPercent { get; set; }
            public string Tooltip { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            try
            {
                BindSummary(ReportRepository.GetUserSummary());
                BindSignups(ReportRepository.GetSignupsByMonth());
                BindRecent(ReportRepository.GetRecentUsers());
                BindContent(ReportRepository.GetContentSummary());
                BindVisitSummary(ReportRepository.GetVisitSummary());
                BindVisits(ReportRepository.GetVisitsByMonth());
            }
            catch (SqlException)
            {
                pnlReport.Visible = false;
                litMessage.Text = DatabaseMessage;
                pnlMessage.Visible = true;
            }
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

        protected string FormatDate(object value)
        {
            return Convert.ToDateTime(value).ToString(DateFormat, CultureInfo.InvariantCulture);
        }

        // ---- private helpers ----

        /// <summary>Fills the five summary cards and the active-versus-inactive bar.</summary>
        private void BindSummary(UserSummary summary)
        {
            litTotal.Text = Number(summary.TotalUsers);
            litActive.Text = Number(summary.ActiveUsers);
            litInactive.Text = Number(summary.InactiveUsers);
            litAdmins.Text = Number(summary.AdminUsers);
            litNew.Text = Number(summary.NewThisMonth);

            int activePercent = Percent(summary.ActiveUsers, summary.TotalUsers);
            int inactivePercent = summary.TotalUsers == 0 ? 0 : 100 - activePercent;

            pnlBarActive.Style["width"] = Number(activePercent) + "%";
            pnlBarInactive.Style["width"] = Number(inactivePercent) + "%";

            pnlBarActive.ToolTip = "Active: " + Number(summary.ActiveUsers) + " (" + Number(activePercent) + "%)";
            pnlBarInactive.ToolTip = "Inactive: " + Number(summary.InactiveUsers) + " (" + Number(inactivePercent) + "%)";

            litActiveLegend.Text = Number(summary.ActiveUsers) + " (" + Number(activePercent) + "%)";
            litInactiveLegend.Text = Number(summary.InactiveUsers) + " (" + Number(inactivePercent) + "%)";
        }

        /// <summary>Turns the 12 monthly counts into chart columns scaled against the busiest month.</summary>
        private void BindSignups(List<MonthlySignup> months)
        {
            int max = 1;
            int total = 0;

            foreach (MonthlySignup month in months)
            {
                total += month.Signups;
                if (month.Signups > max)
                {
                    max = month.Signups;
                }
            }

            List<SignupBar> bars = new List<SignupBar>();

            foreach (MonthlySignup month in months)
            {
                string[] parts = (month.Label ?? string.Empty).Split(' ');

                bars.Add(new SignupBar
                {
                    Month = parts[0],
                    Year = parts.Length > 1 ? parts[1] : string.Empty,
                    Signups = month.Signups,
                    HeightPercent = BarHeight(month.Signups, max),
                    Tooltip = month.Label + ": " + Number(month.Signups) + (month.Signups == 1 ? " signup" : " signups")
                });
            }

            rptSignups.DataSource = bars;
            rptSignups.DataBind();

            litSignupTotal.Text = total == 0
                ? "No signups in the last 12 months."
                : Number(total) + (total == 1 ? " signup" : " signups") + " in the last 12 months.";
        }

        private void BindRecent(List<RecentUser> users)
        {
            rptRecent.DataSource = users;
            rptRecent.DataBind();
        }

        private void BindContent(List<ContentCount> counts)
        {
            rptContent.DataSource = counts;
            rptContent.DataBind();
        }

        /// <summary>Fills the four visit summary cards. Admin visits are never included; see usp_Visit_Record.</summary>
        private void BindVisitSummary(VisitSummary summary)
        {
            litVisitTotal.Text = Number(summary.TotalVisits);
            litVisitUnique.Text = Number(summary.UniqueVisitors);
            litVisitToday.Text = Number(summary.VisitsToday);
            litVisitMonth.Text = Number(summary.VisitsThisMonth);
            litVisitNote.Text = "Counts how many times a registered User has opened the portfolio. The Admin's own visits are not included.";
        }

        /// <summary>Turns the 12 monthly visit counts into chart columns, the same way BindSignups does.</summary>
        private void BindVisits(List<MonthlyVisits> months)
        {
            int max = 1;
            int total = 0;

            foreach (MonthlyVisits month in months)
            {
                total += month.Visits;
                if (month.Visits > max)
                {
                    max = month.Visits;
                }
            }

            List<VisitBar> bars = new List<VisitBar>();

            foreach (MonthlyVisits month in months)
            {
                string[] parts = (month.Label ?? string.Empty).Split(' ');

                bars.Add(new VisitBar
                {
                    Month = parts[0],
                    Year = parts.Length > 1 ? parts[1] : string.Empty,
                    Visits = month.Visits,
                    HeightPercent = BarHeight(month.Visits, max),
                    Tooltip = month.Label + ": " + Number(month.Visits) + (month.Visits == 1 ? " visit" : " visits")
                });
            }

            rptVisits.DataSource = bars;
            rptVisits.DataBind();

            litVisitsTotalNote.Text = total == 0
                ? "No visits in the last 12 months."
                : Number(total) + (total == 1 ? " visit" : " visits") + " in the last 12 months.";
        }

        /// <summary>Bar height in percent: 0 for none, otherwise proportional to the busiest month with a small minimum.</summary>
        private static int BarHeight(int value, int max)
        {
            if (value <= 0)
            {
                return 0;
            }

            return Math.Max(MinimumBarPercent, value * 100 / max);
        }

        /// <summary>Whole-number percentage of part in total, or 0 when there is no total.</summary>
        private static int Percent(int part, int total)
        {
            return total <= 0 ? 0 : (int)Math.Round(part * 100.0 / total, MidpointRounding.AwayFromZero);
        }

        private static string Number(int value)
        {
            return value.ToString(CultureInfo.InvariantCulture);
        }
    }
}
