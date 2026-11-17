namespace _24_1571GuadesPersonalPortfolio
{
    public partial class ProjectsEditor
    {
        protected global::System.Web.UI.WebControls.Button btnAdd;

        protected global::System.Web.UI.WebControls.Panel pnlMessage;
        protected global::System.Web.UI.WebControls.Literal litMessage;

        protected global::System.Web.UI.WebControls.Panel pnlForm;
        protected global::System.Web.UI.WebControls.Literal litFormTitle;
        protected global::System.Web.UI.WebControls.HiddenField hfProjectId;

        protected global::System.Web.UI.WebControls.TextBox txtTitle;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvTitle;
        protected global::System.Web.UI.WebControls.TextBox txtTechStack;
        protected global::System.Web.UI.WebControls.TextBox txtRole;
        protected global::System.Web.UI.WebControls.TextBox txtDetails;
        protected global::System.Web.UI.WebControls.TextBox txtRepoUrl;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revRepoUrl;

        protected global::System.Web.UI.WebControls.TextBox txtSortOrder;
        protected global::System.Web.UI.WebControls.RangeValidator rvSortOrder;

        protected global::System.Web.UI.WebControls.Button btnSave;
        protected global::System.Web.UI.WebControls.Button btnCancel;

        protected global::System.Web.UI.WebControls.Panel pnlList;
        protected global::System.Web.UI.WebControls.Repeater rptProjects;
        protected global::System.Web.UI.WebControls.Panel pnlEmpty;
    }
}
