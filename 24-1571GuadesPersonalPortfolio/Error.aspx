<%@ Page Title="Something went wrong" Language="C#" MasterPageFile="~/Auth.Master" AutoEventWireup="true" CodeBehind="Error.aspx.cs" Inherits="_24_1571GuadesPersonalPortfolio.ErrorPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="auth-title">Something went wrong</h1>
    <p class="auth-sub">
        We couldn't finish that request. Nothing you did caused it, so please try again in a moment.
    </p>
    <div class="auth-actions">
        <a class="pill-btn pill-btn-primary" href="~/Home.aspx" runat="server">Back to Home</a>
    </div>
</asp:Content>