namespace _24_1571GuadesPersonalPortfolio
{
    public partial class MyAccountPage
    {
        protected global::System.Web.UI.WebControls.Panel pnlAccountMessage;
        protected global::System.Web.UI.WebControls.Literal litAccountMessage;
        protected global::System.Web.UI.WebControls.Literal litUsername;

        protected global::System.Web.UI.WebControls.Label lblEmail;
        protected global::System.Web.UI.WebControls.TextBox txtEmail;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvEmail;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revEmail;
        protected global::System.Web.UI.WebControls.CustomValidator cvEmailTaken;

        protected global::System.Web.UI.WebControls.Label lblPhone;
        protected global::System.Web.UI.WebControls.TextBox txtPhone;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvPhone;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revPhone;

        protected global::System.Web.UI.WebControls.Button btnSaveAccount;

        protected global::System.Web.UI.WebControls.Panel pnlPasswordMessage;
        protected global::System.Web.UI.WebControls.Literal litPasswordMessage;

        protected global::System.Web.UI.WebControls.Label lblCurrentPassword;
        protected global::System.Web.UI.WebControls.TextBox txtCurrentPassword;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvCurrentPassword;
        protected global::System.Web.UI.WebControls.CustomValidator cvWrongCurrentPassword;

        protected global::System.Web.UI.WebControls.Label lblNewPassword;
        protected global::System.Web.UI.WebControls.TextBox txtNewPassword;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvNewPassword;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revNewPassword;

        protected global::System.Web.UI.WebControls.Label lblConfirmNewPassword;
        protected global::System.Web.UI.WebControls.TextBox txtConfirmNewPassword;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvConfirmNewPassword;
        protected global::System.Web.UI.WebControls.CompareValidator cmpConfirmNewPassword;

        protected global::System.Web.UI.WebControls.Button btnChangePassword;
    }
}
