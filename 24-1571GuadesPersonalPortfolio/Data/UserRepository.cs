using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace _24_1571GuadesPersonalPortfolio.Data
{

    public class RegisterResult
    {
        public int ResultCode { get; set; }
        public int? UserId { get; set; }
    }

    public class LoginResult
    {
        public int ResultCode { get; set; }
        public int? UserId { get; set; }
        public string Username { get; set; }
        public string Role { get; set; }
    }

    public class UserAccount
    {
        public int UserId { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public string Role { get; set; }
        public string Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }
    }

    public static class UserRepository
    {
        public static RegisterResult Register(string username, string email, string phone, string password)
        {
            DataTable table = Db.ExecuteTable(
                "usp_User_Register",
                Db.Param("@Username", username),
                Db.Param("@Email", email),
                Db.Param("@Phone", phone),
                Db.Param("@Password", password));

            DataRow row = table.Rows[0];

            return new RegisterResult
            {
                ResultCode = Convert.ToInt32(row["ResultCode"]),
                UserId = row["UserId"] == DBNull.Value ? (int?)null : Convert.ToInt32(row["UserId"])
            };
        }

        public static LoginResult Login(string identifier, string password)
        {
            DataTable table = Db.ExecuteTable(
                "usp_User_Login",
                Db.Param("@Identifier", identifier),
                Db.Param("@Password", password));

            DataRow row = table.Rows[0];

            return new LoginResult
            {
                ResultCode = Convert.ToInt32(row["ResultCode"]),
                UserId = row["UserId"] == DBNull.Value ? (int?)null : Convert.ToInt32(row["UserId"]),
                Username = row["Username"] == DBNull.Value ? null : (string)row["Username"],
                Role = row["Role"] == DBNull.Value ? null : (string)row["Role"]
            };
        }

        public static UserAccount GetById(int userId)
        {
            DataTable table = Db.ExecuteTable("usp_User_GetById", Db.Param("@UserId", userId));

            if (table.Rows.Count == 0)
            {
                return null;
            }

            return ToUserAccount(table.Rows[0]);
        }

        public static int UpdateAccount(int userId, string email, string phone)
        {
            DataTable table = Db.ExecuteTable(
                "usp_User_UpdateAccount",
                Db.Param("@UserId", userId),
                Db.Param("@Email", email),
                Db.Param("@Phone", phone));

            return Convert.ToInt32(table.Rows[0]["ResultCode"]);
        }

        public static int ChangePassword(int userId, string currentPassword, string newPassword)
        {
            DataTable table = Db.ExecuteTable(
                "usp_User_ChangePassword",
                Db.Param("@UserId", userId),
                Db.Param("@CurrentPassword", currentPassword),
                Db.Param("@NewPassword", newPassword));

            return Convert.ToInt32(table.Rows[0]["ResultCode"]);
        }

        public static List<UserAccount> GetUsers(string search, string status)
        {
            DataTable table = Db.ExecuteTable(
                "usp_Admin_GetUsers",
                Db.Param("@Search", search),
                Db.Param("@Status", status));

            List<UserAccount> users = new List<UserAccount>();

            foreach (DataRow row in table.Rows)
            {
                users.Add(ToUserAccount(row));
            }

            return users;
        }

        public static int SetUserStatus(int actingAdminId, int userId, string status)
        {
            DataTable table = Db.ExecuteTable(
                "usp_Admin_SetUserStatus",
                Db.Param("@ActingAdminId", actingAdminId),
                Db.Param("@UserId", userId),
                Db.Param("@Status", status));

            return Convert.ToInt32(table.Rows[0]["ResultCode"]);
        }

        public static int DeleteUser(int actingAdminId, int userId)
        {
            DataTable table = Db.ExecuteTable(
                "usp_Admin_DeleteUser",
                Db.Param("@ActingAdminId", actingAdminId),
                Db.Param("@UserId", userId));

            return Convert.ToInt32(table.Rows[0]["ResultCode"]);
        }

        private static UserAccount ToUserAccount(DataRow row)
        {
            return new UserAccount
            {
                UserId = Convert.ToInt32(row["UserId"]),
                Username = (string)row["Username"],
                Email = (string)row["Email"],
                Phone = (string)row["Phone"],
                Role = (string)row["Role"],
                Status = (string)row["Status"],
                CreatedAt = Convert.ToDateTime(row["CreatedAt"]),
                LastLoginAt = row["LastLoginAt"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(row["LastLoginAt"])
            };
        }
    }
}
