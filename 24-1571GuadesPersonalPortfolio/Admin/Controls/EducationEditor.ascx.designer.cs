namespace _24_1571GuadesPersonalPortfolio
{
    public partial class EducationEditor
    {
        protected global::System.Web.UI.WebControls.Button btnAdd;

        protected global::System.Web.UI.WebControls.Panel pnlMessage;
        protected global::System.Web.UI.WebControls.Literal litMessage;

        protected global::System.Web.UI.WebControls.Panel pnlForm;
        protected global::System.Web.UI.WebControls.Literal litFormTitle;
        protected global::System.Web.UI.WebControls.HiddenField hfEducationId;

        protected global::System.Web.UI.WebControls.TextBox txtSchool;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvSchool;
        protected global::System.Web.UI.WebControls.TextBox txtLevel;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvLevel;
        protected global::System.Web.UI.WebControls.TextBox txtProgram;

        protected global::System.Web.UI.WebControls.TextBox txtStartYear;
        protected global::System.Web.UI.WebControls.RangeValidator rvStartYear;
        protected global::System.Web.UI.WebControls.TextBox txtEndYear;
        protected global::System.Web.UI.WebControls.RangeValidator rvEndYear;
        protected global::System.Web.UI.WebControls.CustomValidator cvYears;

        protected global::System.Web.UI.WebControls.TextBox txtDescription;

        protected global::System.Web.UI.WebControls.Panel pnlCurrentPhoto;
        protected global::System.Web.UI.WebControls.Image imgPhoto;
        protected global::System.Web.UI.WebControls.FileUpload fuPhoto;

        protected global::System.Web.UI.WebControls.TextBox txtSortOrder;
        protected global::System.Web.UI.WebControls.RangeValidator rvSortOrder;

        protected global::System.Web.UI.WebControls.Button btnSave;
        protected global::System.Web.UI.WebControls.Button btnCancel;

        protected global::System.Web.UI.WebControls.Panel pnlList;
        protected global::System.Web.UI.WebControls.Repeater rptSchools;
        protected global::System.Web.UI.WebControls.Panel pnlEmpty;
    }
}
