using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace _24_1571GuadesPersonalPortfolio.Data
{
    public class UserSummary
    {
        public int TotalUsers { get; set; }
        public int ActiveUsers { get; set; }
        public int InactiveUsers { get; set; }
        public int AdminUsers { get; set; }
        public int NewThisMonth { get; set; }
    }

  
    public class MonthlySignup
    {
        public string Label { get; set; }
        public int Signups { get; set; }
    }

   
    public class RecentUser
    {
        public int UserId { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string Role { get; set; }
        public string Status { get; set; }
        public DateTime CreatedAt { get; set; }
    }

  
    public class ContentCount
    {
        public string Section { get; set; }
        public int Items { get; set; }
    }

    public class VisitSummary
    {
        public int TotalVisits { get; set; }
        public int UniqueVisitors { get; set; }
        public int VisitsToday { get; set; }
        public int VisitsThisMonth { get; set; }
    }

    
    public class MonthlyVisits
    {
        public string Label { get; set; }
        public int Visits { get; set; }
    }

    public static class ReportRepository
    {

        public static UserSummary GetUserSummary()
        {
            DataTable table = Db.ExecuteTable("usp_Report_UserSummary");
            UserSummary summary = new UserSummary();

            if (table.Rows.Count > 0)
            {
                DataRow row = table.Rows[0];
                summary.TotalUsers = Convert.ToInt32(row["TotalUsers"]);
                summary.ActiveUsers = Convert.ToInt32(row["ActiveUsers"]);
                summary.InactiveUsers = Convert.ToInt32(row["InactiveUsers"]);
                summary.AdminUsers = Convert.ToInt32(row["AdminUsers"]);
                summary.NewThisMonth = Convert.ToInt32(row["NewThisMonth"]);
            }

            return summary;
        }

        public static List<MonthlySignup> GetSignupsByMonth()
        {
            DataTable table = Db.ExecuteTable("usp_Report_SignupsByMonth");
            List<MonthlySignup> months = new List<MonthlySignup>();

            foreach (DataRow row in table.Rows)
            {
                months.Add(new MonthlySignup
                {
                    Label = Convert.ToString(row["Label"]),
                    Signups = Convert.ToInt32(row["Signups"])
                });
            }

            return months;
        }

        public static List<RecentUser> GetRecentUsers()
        {
            DataTable table = Db.ExecuteTable("usp_Report_RecentUsers");
            List<RecentUser> users = new List<RecentUser>();

            foreach (DataRow row in table.Rows)
            {
                users.Add(new RecentUser
                {
                    UserId = Convert.ToInt32(row["UserId"]),
                    Username = Convert.ToString(row["Username"]),
                    Email = Convert.ToString(row["Email"]),
                    Role = Convert.ToString(row["Role"]),
                    Status = Convert.ToString(row["Status"]),
                    CreatedAt = Convert.ToDateTime(row["CreatedAt"])
                });
            }

            return users;
        }

      
        public static List<ContentCount> GetContentSummary()
        {
            DataTable table = Db.ExecuteTable("usp_Report_ContentSummary");
            List<ContentCount> counts = new List<ContentCount>();

            foreach (DataRow row in table.Rows)
            {
                counts.Add(new ContentCount
                {
                    Section = Convert.ToString(row["Section"]),
                    Items = Convert.ToInt32(row["Items"])
                });
            }

            return counts;
        }

        public static void RecordVisit(int userId)
        {
            Db.ExecuteNonQuery("usp_Visit_Record", new SqlParameter("@UserId", userId));
        }


        public static VisitSummary GetVisitSummary()
        {
            DataTable table = Db.ExecuteTable("usp_Report_VisitSummary");
            VisitSummary summary = new VisitSummary();

            if (table.Rows.Count > 0)
            {
                DataRow row = table.Rows[0];
                summary.TotalVisits = Convert.ToInt32(row["TotalVisits"]);
                summary.UniqueVisitors = Convert.ToInt32(row["UniqueVisitors"]);
                summary.VisitsToday = Convert.ToInt32(row["VisitsToday"]);
                summary.VisitsThisMonth = Convert.ToInt32(row["VisitsThisMonth"]);
            }

            return summary;
        }

        public static List<MonthlyVisits> GetVisitsByMonth()
        {
            DataTable table = Db.ExecuteTable("usp_Report_VisitsByMonth");
            List<MonthlyVisits> months = new List<MonthlyVisits>();

            foreach (DataRow row in table.Rows)
            {
                months.Add(new MonthlyVisits
                {
                    Label = Convert.ToString(row["Label"]),
                    Visits = Convert.ToInt32(row["Visits"])
                });
            }

            return months;
        }
    }
}
