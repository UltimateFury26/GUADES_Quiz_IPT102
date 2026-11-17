<%@ Page Title="Log in" Language="C#" MasterPageFile="~/Auth.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="_24_1571GuadesPersonalPortfolio.LoginPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="auth-title">Log in</h1>
    <p class="auth-sub">Use your username or email to view the portfolio.</p>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false" role="alert">
        <asp:Literal ID="litMessage" runat="server" Mode="Encode" />
    </asp:Panel>

    <asp:Panel ID="pnlForm" runat="server" CssClass="auth-form" DefaultButton="btnLogin">
        <div class="form-field">
            <asp:Label ID="lblIdentifier" runat="server" AssociatedControlID="txtIdentifier"
                CssClass="form-label" Text="Username or email" />
            <asp:TextBox ID="txtIdentifier" runat="server" CssClass="form-input" MaxLength="100"
                autocomplete="username" autocapitalize="none" spellcheck="false" />
            <asp:RequiredFieldValidator ID="rfvIdentifier" runat="server" ControlToValidate="txtIdentifier"
                Display="Dynamic" CssClass="form-error" ErrorMessage="Enter your username or email." />
        </div>

        <div class="form-field">
            <asp:Label ID="lblPassword" runat="server" AssociatedControlID="txtPassword"
                CssClass="form-label" Text="Password" />
            <div class="password-field">
                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-input" TextMode="Password"
                    MaxLength="100" autocomplete="current-password" />
                <button type="button" class="password-toggle" aria-label="Show password">
                    <svg class="icon icon-eye" viewBox="0 0 24 24"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7z" /><circle cx="12" cy="12" r="3" /></svg>
                    <svg class="icon icon-eye-off" viewBox="0 0 24 24"><path d="M3 3l18 18" /><path d="M10.6 5.2A10.6 10.6 0 0 1 12 5c6.4 0 10 7 10 7a17.7 17.7 0 0 1-3.2 4.1M6.6 6.6C4 8.3 2 12 2 12s3.6 7 10 7c1.4 0 2.7-.3 3.9-.8" /><path d="M9.9 9.9a3 3 0 0 0 4.2 4.2" /></svg>
                </button>
            </div>
            <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword"
                Display="Dynamic" CssClass="form-error" ErrorMessage="Enter your password." />
        </div>

        <asp:Button ID="btnLogin" runat="server" Text="Log in"
            CssClass="pill-btn pill-btn-primary auth-submit" OnClick="btnLogin_Click" />
    </asp:Panel>

    <p class="auth-foot">
        New here? <a href="~/Signup.aspx" runat="server">Create an account</a>
    </p>
</asp:Content>
